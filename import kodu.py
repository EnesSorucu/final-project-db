import pandas as pd
import mysql.connector
import json

conn = mysql.connector.connect(host="localhost", user="root", password="password", database="mydb")
cursor = conn.cursor()

df = pd.read_csv("gog_games_dataset.csv")
df = df.sort_values(by="id").reset_index(drop=True)

cursor.execute("SET FOREIGN_KEY_CHECKS=0")
tables = [
    "gamesBooleanCol", "gamesIntegerCol", "whichGenre", "whichOperatingSystem",
    "publishersGame", "developersGame", "game", "Boolean_col", "integer_col",
    "genres", "publisher", "developer", "operatingSystem", "generalForum", "promos"
]
for t in tables:
    cursor.execute(f"TRUNCATE TABLE {t}")
cursor.execute("SET FOREIGN_KEY_CHECKS=1")

boolean_columns = ["isComingSoon", "isTBA", "buyable", "isReviewable", "isGame", "isMovie", "isDiscounted_main",
                   "isMod"]
for col in boolean_columns:
    cursor.execute("INSERT IGNORE INTO Boolean_col (colName) VALUES (%s)", (col,))

integer_columns = ["ageLimit", "rating", "reviewCount", "reviewPages", "discountPercentage", "releaseDate", "type"]
for col in integer_columns:
    cursor.execute("INSERT IGNORE INTO integer_col (colName) VALUES (%s)", (col,))
conn.commit()

cursor.execute("SELECT colID, colName FROM Boolean_col")
boolean_ids = {name: cid for cid, name in cursor.fetchall()}
cursor.execute("SELECT colID, colName FROM integer_col")
integer_ids = {name: cid for cid, name in cursor.fetchall()}

u_forums = {str(row["forumUrl"]).strip() for _, row in df.iterrows() if not pd.isna(row.get("forumUrl"))}
for f in sorted(list(u_forums)): cursor.execute("INSERT IGNORE INTO generalForum (generalForumUrl) VALUES (%s)", (f,))
cursor.execute("SELECT generalForumUrl, forumID FROM generalForum");
forum_map = {url: fid for url, fid in cursor.fetchall()}

u_promos = {str(row["promoId"]).strip() for _, row in df.iterrows() if
            not pd.isna(row.get("promoId")) and str(row["promoId"]).strip() != ""}
for p in sorted(list(u_promos)): cursor.execute("INSERT IGNORE INTO promos (promoName) VALUES (%s)", (p,))
cursor.execute("SELECT promoName, promoID FROM promos");
promo_db_map = {name: pid for name, pid in cursor.fetchall()}

for _, row in df.iterrows():
    f_url = str(row.get("forumUrl", "")).strip()
    f_id = forum_map.get(f_url, forum_map.get(str(row["url"]).strip(), 1))
    p_id = promo_db_map.get(str(row.get("promoId", "")).strip(), None)

    try:
        price_val = float(row["amount"]) if not pd.isna(row["amount"]) else 0.0
    except:
        price_val = 0.0

    currency_val = str(row.get("currency", "EUR")).strip()
    if not currency_val or currency_val == "nan": currency_val = "USD"

    vid_json = json.dumps(row.get("video")) if not pd.isna(row.get("video")) and str(row.get("video")).strip() not in [
        "", "[]", "{}"] else None

    cursor.execute("""
        INSERT IGNORE INTO game 
        (gameID, title, price, currency, marketUrl, availability, filteredAvgRating, overallAvgRating, 
         supportUrl, gallery, video, image, boxImage, forumID, promoID)  
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """, (
        int(row["id"]), row["title"], price_val, currency_val, row["url"],
        json.dumps(row["availability"]) if not pd.isna(row["availability"]) else "{}",
        row["filteredAvgRating"] or 0, row["overallAvgRating"] or 0,
        row["supportUrl"] or "", json.dumps(row["gallery"]) or "{}",
        vid_json, row["image"] or "", row["boxImage"] or "", f_id, p_id
    ))
conn.commit()

def handle_multi_value_table(csv_col, db_table, db_col, relation_table, rel_id_col):
    vals = set()
    for _, r in df.iterrows():
        if not pd.isna(r.get(csv_col)):
            [vals.add(x.strip()) for x in str(r[csv_col]).replace("[", "").replace("]", "").replace("'", "").split(",")
             if x.strip()]
    for v in sorted(list(vals)): cursor.execute(f"INSERT IGNORE INTO {db_table} ({db_col}) VALUES (%s)", (v,))
    conn.commit()
    cursor.execute(f"SELECT {rel_id_col}, {db_col} FROM {db_table}");
    v_map = {n: i for i, n in cursor.fetchall()}
    for _, r in df.iterrows():
        if not pd.isna(r.get(csv_col)):
            items = [x.strip() for x in str(r[csv_col]).replace("[", "").replace("]", "").replace("'", "").split(",") if
                     x.strip()]
            for i in items:
                if i in v_map: cursor.execute(
                    f"INSERT IGNORE INTO {relation_table} ({rel_id_col}, gameID) VALUES (%s,%s)",
                    (v_map[i], int(r["id"])))
    conn.commit()


handle_multi_value_table("developer", "developer", "developer", "developersGame", "developerID")
handle_multi_value_table("publisher", "publisher", "publisher", "publishersGame", "publisherID")
handle_multi_value_table("supportedOperatingSystems", "operatingSystem", "systemName", "whichOperatingSystem",
                         "systemID")

g_set = set()
for _, r in df.iterrows():
    if not pd.isna(r["genres"]):
        [g_set.add(x.strip()) for x in str(r["genres"]).replace("[", "").replace("]", "").replace("'", "").split(",") if
         x.strip()]
for g in sorted(list(g_set)): cursor.execute("INSERT IGNORE INTO genres (genre) VALUES (%s)", (g,))
conn.commit()
cursor.execute("SELECT genreID, genre FROM genres");
g_map = {n: i for i, n in cursor.fetchall()}
for _, r in df.iterrows():
    if not pd.isna(r["genres"]):
        gs = [x.strip() for x in str(r["genres"]).replace("[", "").replace("]", "").replace("'", "").split(",") if
              x.strip()]
        for i, g in enumerate(gs):
            if g in g_map: cursor.execute(
                "INSERT IGNORE INTO whichGenre (gameID, genreID, isPrimaryGenre) VALUES (%s,%s,%s)",
                (int(r["id"]), g_map[g], 1 if i == 0 else 0))
conn.commit()

for _, row in df.iterrows():
    g_id = int(row["id"])

    for col in boolean_columns:
        val = 1 if str(row.get(col, False)).lower() in ["true", "1"] else 0
        cursor.execute("INSERT IGNORE INTO gamesBooleanCol VALUES (%s,%s,%s)", (g_id, boolean_ids[col], val))

    int_fields = {
        "ageLimit": "ageLimit", "rating": "rating", "reviewCount": "reviewCount",
        "reviewPages": "reviewPages", "discountPercentage": "discountPercentage", "type": "type"
    }
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
cursor.close()
conn.close()
