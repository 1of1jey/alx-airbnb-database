SELECT 
    p.property_id,
    p.name,
    p.pricepernight,
    p.host_id
FROM 
    Property p
WHERE 
    p.property_id IN (
        SELECT r.property_id
        FROM Review r
        GROUP BY r.property_id
        HAVING AVG(r.rating) > 4.0
    )
ORDER BY 
    p.name;

SELECT 
    p.property_id,
    p.name,
    p.pricepernight,
    (
        SELECT AVG(r.rating)
        FROM Review r
        WHERE r.property_id = p.property_id
    ) AS average_rating,
    (
        SELECT COUNT(r.review_id)
        FROM Review r
        WHERE r.property_id = p.property_id
    ) AS review_count
FROM 
    Property p
WHERE 
    p.property_id IN (
        SELECT r.property_id
        FROM Review r
        GROUP BY r.property_id
        HAVING AVG(r.rating) > 4.0
    )
ORDER BY 
    average_rating DESC;
