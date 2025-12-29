SELECT
    gr.genre AS Game_Genre,
    MIN(g.price) AS Minimum_Discounted_Price,
    ROUND(AVG(gic.integerValue), 2) AS Average_Discount_Percentage
FROM
    genres gr
JOIN
    whichGenre wg ON gr.genreID = wg.genreID
JOIN
    game g ON wg.gameID = g.gameID
JOIN
    gamesIntegerCol gic ON g.gameID = gic.gameID
JOIN
    integer_col ic ON gic.integerColID = ic.colID
WHERE
    ic.colName = 'discountPercentage'
    AND gic.integerValue > 0
GROUP BY
    gr.genre
ORDER BY
    Average_Discount_Percentage DESC
LIMIT 20;