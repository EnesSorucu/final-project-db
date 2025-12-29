SELECT
    g.title AS Game_Name,
    SUM(g.price * disc_val.integerValue / 100) AS Total_Discount_Amount
FROM
    game g
JOIN
    gamesIntegerCol disc_val ON g.gameID = disc_val.gameID
JOIN
    integer_col ic_disc ON disc_val.integerColID = ic_disc.colID AND ic_disc.colName = 'discountPercentage'
JOIN
    gamesIntegerCol date_val ON g.gameID = date_val.gameID
JOIN
    integer_col ic_date ON date_val.integerColID = ic_date.colID AND ic_date.colName = 'releaseDate'
WHERE
    disc_val.integerValue > 0
    AND FROM_UNIXTIME(date_val.integerValue, '%Y') > 2020
GROUP BY
    g.gameID, g.title
ORDER BY
    Total_Discount_Amount DESC
LIMIT 20;