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
