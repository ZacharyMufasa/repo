SELECT c.name AS category_name, COUNT(ch.checkout_id) AS checkout_count
FROM category AS c
LEFT JOIN tool AS t ON t.category_id = c.category_id
LEFT JOIN checkout AS ch ON ch.tool_id = t.tool_id
GROUP BY c.category_id, c.name
ORDER BY checkout_count DESC, category_name;

