SELECT
    gr.genre AS Game_Genre,
    MAX(LENGTH(g.gallery) - LENGTH(REPLACE(g.gallery, ',', '')) + 1) AS Max_Images,
    SUM(gic.integerValue) AS Total_Reviews
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
    ic.colName = 'reviewCount'
    AND g.gallery IS NOT NULL
GROUP BY
    gr.genre
ORDER BY
    Total_Reviews DESC
LIMIT 20;