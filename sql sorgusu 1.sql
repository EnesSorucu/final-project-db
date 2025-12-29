SELECT
    gr.genre AS Genre,
    COUNT(g.gameID) AS Total_Games
FROM
    genres gr
JOIN
    whichGenre wg ON gr.genreID = wg.genreID
JOIN
    game g ON wg.gameID = g.gameID
GROUP BY
    gr.genre
ORDER BY
    Total_Games DESC
LIMIT 20;