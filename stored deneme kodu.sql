SET @my_wallet = 50.00;      -- Cebimizde 50 TL var
SET @message = '';           -- Mesaj boş
SET @game_id = 4;            -- ID'si 4 olan oyunu (Descent) almaya çalışıyoruz

CALL sp_buy_game_simulation(@game_id, @my_wallet, @message);

SELECT
    @game_id AS GameID,
    @message AS Transaction_Status,
    @my_wallet AS Remaining_Money; -- Kalan para