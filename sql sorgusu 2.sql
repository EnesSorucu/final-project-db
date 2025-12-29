
SELECT
    p.publisher AS Publisher_Name,
    COUNT(pg.gameID) AS Total_Games_Published
FROM
    publisher p
JOIN
    publishersGame pg ON p.publisherID = pg.publisherID
GROUP BY
    p.publisher
ORDER BY
    Total_Games_Published DESC;