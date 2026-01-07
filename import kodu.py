import pandas as pd
import mysql.connector
import json
import ast

# 1. VERİTABANI BAĞLANTISI (mydb)
conn = mysql.connector.connect(host="localhost", user="root", password="PASSWORD", database="mydb")
cursor = conn.cursor()

# Veri setini yükle
df = pd.read_csv("gog_games_dataset.csv")
df = df.sort_values(by="id").reset_index(drop=True)

# 2. TEMİZLİK (Truncate) - Eski verileri siler
print("Tablolar temizleniyor...")
cursor.execute("SET FOREIGN_KEY_CHECKS=0")
tables = [
    "media", "gamesBooleanCol", "gamesIntegerCol", "whichGenre", "whichOperatingSystem",
    "publishersGame", "developersGame", "game", "video", "provider",
    "Boolean_col", "integer_col", "genres", "publisher", "developer",
    "operatingSystem", "generalForum", "promos", "currency"
]
for t in tables:
    try:
        cursor.execute(f"TRUNCATE TABLE {t}")
    except:
        pass  # Tablo yoksa hata vermesin devam etsin
cursor.execute("SET FOREIGN_KEY_CHECKS=1")

# 3. SABİT TANIMLAMALAR (EAV Sütunları)
print("Sabit tanımlar yükleniyor...")
# Availability içindeki key'leri de buraya ekliyoruz!
boolean_columns = [
    "isComingSoon", "isTBA", "buyable", "isReviewable",
    "isGame", "isMovie", "isDiscounted_main", "isMod",
    "isAvailable", "isAvailableInAccount"  # <-- JSON'dan çıkanlar
]
for col in boolean_columns:
    cursor.execute("INSERT IGNORE INTO Boolean_col (colName) VALUES (%s)", (col,))

integer_columns = ["ageLimit", "rating", "reviewCount", "reviewPages", "discountPercentage", "releaseDate", "type"]
for col in integer_columns:
    cursor.execute("INSERT IGNORE INTO integer_col (colName) VALUES (%s)", (col,))
conn.commit()

# ID Mapping (Hızlı erişim için) 
cursor.execute("SELECT colID, colName FROM Boolean_col")
boolean_ids = {name: cid for cid, name in cursor.fetchall()}
cursor.execute("SELECT colID, colName FROM integer_col")
integer_ids = {name: cid for cid, name in cursor.fetchall()}

# 4. YARDIMCI TABLOLAR (Forum, Promo, Currency, Provider)
print("Yardımcı tablolar dolduruluyor...")

# Forum
u_forums = {str(row["forumUrl"]).strip() for _, row in df.iterrows() if not pd.isna(row.get("forumUrl"))}
for f in sorted(list(u_forums)): cursor.execute("INSERT IGNORE INTO generalForum (generalForumUrl) VALUES (%s)", (f,))
cursor.execute("SELECT generalForumUrl, forumID FROM generalForum")
forum_map = {url: fid for url, fid in cursor.fetchall()}

# Promo
u_promos = {str(row["promoId"]).strip() for _, row in df.iterrows() if
            not pd.isna(row.get("promoId")) and str(row["promoId"]).strip() != ""}
for p in sorted(list(u_promos)): cursor.execute("INSERT IGNORE INTO promos (promoName) VALUES (%s)", (p,))
cursor.execute("SELECT promoName, promoID FROM promos")
promo_db_map = {name: pid for name, pid in cursor.fetchall()}

# Currency
u_currencies = {str(row.get("currency", "USD")).strip() for _, row in df.iterrows()}
for c in sorted(list(u_currencies)): cursor.execute("INSERT IGNORE INTO currency (currencyName) VALUES (%s)", (c,))
cursor.execute("SELECT currencyName, currencyID FROM currency")
currency_map = {name: cid for name, cid in cursor.fetchall()}

# Provider (Video için - youtube vb.)
cursor.execute("INSERT IGNORE INTO provider (providerName) VALUES ('youtube')")
cursor.execute("SELECT providerName, providerID FROM provider")
provider_map = {name: pid for name, pid in cursor.fetchall()}

conn.commit()

# 5. ANA DÖNGÜ (GAME ve Bağlı Tablolar)
print("Oyunlar ve Medyalar işleniyor (Bu işlem biraz sürebilir)...")

# --- VİDEO ÖNBELLEĞİ (Duplicate Önlemek İçin) ---
added_videos_cache = {}

for _, row in df.iterrows():
    g_id = int(row["id"])

    # 5.1. Game Tablosu Hazırlığı
    f_url = str(row.get("forumUrl", "")).strip()
    f_id = forum_map.get(f_url, 1)
    p_id = promo_db_map.get(str(row.get("promoId", "")).strip(), None)
    curr_id = currency_map.get(str(row.get("currency", "USD")).strip(), currency_map.get("USD"))

    try:
        price_val = float(row["amount"]) if not pd.isna(row["amount"]) else 0.0
    except:
        price_val = 0.0

    # VİDEO MANTIĞI (Cache Kontrollü)
    video_db_id = None
    vid_raw = row.get("video", None)

    if pd.notna(vid_raw):
        try:
            vid_data = ast.literal_eval(vid_raw) if isinstance(vid_raw, str) else vid_raw

            target_video = None
            if isinstance(vid_data, list) and len(vid_data) > 0:
                target_video = vid_data[0]
            elif isinstance(vid_data, dict):
                target_video = vid_data

            if target_video:
                v_provider_name = target_video.get('provider', 'youtube')
                v_video_string_id = target_video.get('video_id', target_video.get('id', ''))

                if v_video_string_id:
                    # KONTROL: Cache'de var mı?
                    if v_video_string_id in added_videos_cache:
                        video_db_id = added_videos_cache[v_video_string_id]
                    else:
                        # Yoksa Ekle
                        if v_provider_name not in provider_map:
                            cursor.execute("INSERT INTO provider (providerName) VALUES (%s)", (v_provider_name,))
                            provider_map[v_provider_name] = cursor.lastrowid

                        prov_id = provider_map[v_provider_name]

                        # UNIQUE olduğu için IGNORE kullanıyoruz, varsa eklemez
                        cursor.execute("INSERT IGNORE INTO video (videoID, providerID) VALUES (%s, %s)",
                                       (v_video_string_id, prov_id))

                        if cursor.lastrowid:
                            video_db_id = cursor.lastrowid
                        else:
                            # Zaten varsa ID'sini çek
                            cursor.execute("SELECT idVideo FROM video WHERE videoID = %s", (v_video_string_id,))
                            result = cursor.fetchone()
                            if result:
                                video_db_id = result[0]

                        # Cache'e kaydet
                        if video_db_id:
                            added_videos_cache[v_video_string_id] = video_db_id
        except:
            pass

            # OYUNU EKLE
    cursor.execute("""
        INSERT IGNORE INTO game 
        (gameID, title, price, currencyID, marketUrl, filteredAvgRating, overallAvgRating, 
         supportUrl, forumID, promoID, idVideo)  
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """, (
        g_id, row["title"], price_val, curr_id, row["url"],
        row["filteredAvgRating"] or 0, row["overallAvgRating"] or 0,
        row["supportUrl"] or "", f_id, p_id, video_db_id
    ))

    # 5.2. MEDIA TABLOSU (Image, BoxImage, Gallery -> HEPSİ BURAYA)

    # A) Ana Resim (Image)
    if pd.notna(row.get("image")):
        cursor.execute("""
            INSERT INTO media (imageUrl, isPrimaryImage, isBoxImage, isInGalery, game_gameID)
            VALUES (%s, 1, 0, 0, %s)
        """, (str(row["image"]), g_id))

    # B) Kutu Resmi (BoxImage)
    if pd.notna(row.get("boxImage")):
        cursor.execute("""
            INSERT INTO media (imageUrl, isPrimaryImage, isBoxImage, isInGalery, game_gameID)
            VALUES (%s, 0, 1, 0, %s)
        """, (str(row["boxImage"]), g_id))

    # C) Galeri (Gallery JSON Listesi)
    gal_raw = row.get("gallery", "[]")
    if pd.notna(gal_raw):
        try:
            gal_list = ast.literal_eval(gal_raw) if isinstance(gal_raw, str) else gal_raw
            if isinstance(gal_list, list):
                for img_url in gal_list:
                    if img_url:
                        # Gallery resmi olarak ekle
                        cursor.execute("""
                            INSERT INTO media (imageUrl, isPrimaryImage, isBoxImage, isInGalery, game_gameID)
                            VALUES (%s, 0, 0, 1, %s)
                        """, (str(img_url), g_id))
        except:
            pass

    # 5.3. AVAILABILITY -> BOOLEAN EAV TABLOSUNA
    avail_raw = row.get("availability", "{}")
    is_avail = 0
    is_acc = 0
    if pd.notna(avail_raw):
        try:
            avail_data = ast.literal_eval(avail_raw) if isinstance(avail_raw, str) else avail_raw
            is_avail = 1 if avail_data.get('isAvailable') else 0
            is_acc = 1 if avail_data.get('isAvailableInAccount') else 0
        except:
            pass

    # EAV Tablosuna Kayıt
    cursor.execute("INSERT IGNORE INTO gamesBooleanCol VALUES (%s,%s,%s)", (g_id, boolean_ids['isAvailable'], is_avail))
    cursor.execute("INSERT IGNORE INTO gamesBooleanCol VALUES (%s,%s,%s)",
                   (g_id, boolean_ids['isAvailableInAccount'], is_acc))

    # Diğer standart Booleanlar
    csv_bools = ["isComingSoon", "isTBA", "buyable", "isReviewable", "isGame", "isMovie", "isDiscounted_main", "isMod"]
    for col in csv_bools:
        val = 1 if str(row.get(col, False)).lower() in ["true", "1"] else 0
        cursor.execute("INSERT IGNORE INTO gamesBooleanCol VALUES (%s,%s,%s)", (g_id, boolean_ids[col], val))

    # 5.4. INTEGER EAV
    int_fields = {"ageLimit": "ageLimit", "rating": "rating", "reviewCount": "reviewCount",
                  "reviewPages": "reviewPages", "discountPercentage": "discountPercentage", "type": "type"}
    for csv_f, db_f in int_fields.items():
        if csv_f in row and not pd.isna(row[csv_f]):
            cursor.execute("INSERT IGNORE INTO gamesIntegerCol VALUES (%s,%s,%s)",
                           (g_id, integer_ids[db_f], int(float(row[csv_f]))))

    if "dateReleaseDate" in row and not pd.isna(row["dateReleaseDate"]):
        try:
            ts = int(pd.to_datetime(row["dateReleaseDate"]).timestamp())
            cursor.execute("INSERT IGNORE INTO gamesIntegerCol VALUES (%s,%s,%s)",
                           (g_id, integer_ids["releaseDate"], ts))
        except:
            pass

conn.commit()

# 6. ÇOKLU İLİŞKİLER (Genre, Dev, Pub, OS)
print("Çoklu ilişkiler işleniyor...")


def handle_multi_value_table(csv_col, db_table, db_col, relation_table, rel_id_col):
    vals = set()
    for _, r in df.iterrows():
        if not pd.isna(r.get(csv_col)):
            raw_val = str(r[csv_col])
            clean_val = raw_val.replace("[", "").replace("]", "").replace("'", "")
            for x in clean_val.split(","):
                if x.strip(): vals.add(x.strip())

    for v in sorted(list(vals)):
        cursor.execute(f"INSERT IGNORE INTO {db_table} ({db_col}) VALUES (%s)", (v,))
    conn.commit()

    cursor.execute(f"SELECT {rel_id_col}, {db_col} FROM {db_table}")
    v_map = {n: i for i, n in cursor.fetchall()}

    for _, r in df.iterrows():
        if not pd.isna(r.get(csv_col)):
            raw_val = str(r[csv_col])
            clean_val = raw_val.replace("[", "").replace("]", "").replace("'", "")
            items = [x.strip() for x in clean_val.split(",") if x.strip()]
            for i in items:
                if i in v_map: cursor.execute(
                    f"INSERT IGNORE INTO {relation_table} ({rel_id_col}, gameID) VALUES (%s,%s)",
                    (v_map[i], int(r["id"])))
    conn.commit()


handle_multi_value_table("developer", "developer", "developer", "developersGame", "developerID")
handle_multi_value_table("publisher", "publisher", "publisher", "publishersGame", "publisherID")
handle_multi_value_table("supportedOperatingSystems", "operatingSystem", "systemName", "whichOperatingSystem",
                         "systemID")

# 7. GENRES (Özel İşlem - Primary Genre)
g_set = set()
for _, r in df.iterrows():
    if not pd.isna(r["genres"]):
        clean_val = str(r["genres"]).replace("[", "").replace("]", "").replace("'", "")
        [g_set.add(x.strip()) for x in clean_val.split(",") if x.strip()]
for g in sorted(list(g_set)): cursor.execute("INSERT IGNORE INTO genres (genre) VALUES (%s)", (g,))
conn.commit()

cursor.execute("SELECT genreID, genre FROM genres")
g_map = {n: i for i, n in cursor.fetchall()}

for _, r in df.iterrows():
    if not pd.isna(r["genres"]):
        clean_val = str(r["genres"]).replace("[", "").replace("]", "").replace("'", "")
        gs = [x.strip() for x in clean_val.split(",") if x.strip()]
        for i, g in enumerate(gs):
            if g in g_map:
                cursor.execute(
                    "INSERT IGNORE INTO whichGenre (gameID, genreID, isPrimaryGenre) VALUES (%s,%s,%s)",
                    (int(r["id"]), g_map[g], 1 if i == 0 else 0))
conn.commit()

cursor.close()
conn.close()
print("🎉 İŞLEM TAMAMLANDI! (Schema: mydb)")
