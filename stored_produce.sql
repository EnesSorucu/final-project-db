
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_buy_game_simulation$$

CREATE PROCEDURE sp_buy_game_simulation (
    IN game_id_input INT,
    INOUT user_wallet DECIMAL(10, 2),
    OUT result_message VARCHAR(255)
)
BEGIN
    DECLARE game_price DECIMAL(10, 2);
    DECLARE game_title VARCHAR(255);

    -- 1. Oyunun fiyatını ve ismini bul
    SELECT price, title INTO game_price, game_title
    FROM game
    WHERE gameID = game_id_input
    LIMIT 1;

    -- 2. Kontrol Et: Oyun var mı?
    IF game_title IS NULL THEN
        SET result_message = 'HATA: Oyun bulunamadı!';

    -- 3. Kontrol Et: Bütçe yetiyor mu?
    ELSEIF user_wallet >= game_price THEN
        SET user_wallet = user_wallet - game_price; -- Parayı düş
        SET result_message = CONCAT('BAŞARILI: "', game_title, '" satın alındı. İyi oyunlar!');

    -- 4. Para yetmiyorsa
    ELSE
        SET result_message = CONCAT('YETERSİZ BAKİYE: "', game_title, '" için ', (game_price - user_wallet), ' birim daha lazım.');
    END IF;

END$$

DELIMITER ;