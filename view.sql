
CREATE OR REPLACE VIEW view_popular_discounts AS
SELECT
    g.gameID AS GameID,
    g.title AS Game_Name,
    g.overallAvgRating AS Average_Rating,
    g.price AS Price,
    p.promoName AS Promo_Info
FROM
    game g
JOIN
    promos p ON g.promoID = p.promoID
WHERE
    g.overallAvgRating >= 4.5
    AND g.price > 0
    AND p.promoName != 'Standard Price' -- YENİ EKLENEN SATIR: Standart fiyatlıları gizle!
ORDER BY
    g.overallAvgRating DESC;