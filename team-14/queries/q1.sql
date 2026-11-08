SELECT t.tool_id, t.name AS tool_name, c.name AS category_name
FROM tool AS t
JOIN category AS c ON c.category_id = t.category_id
WHERE t.tool_condition = 'needs_repair'
ORDER BY t.tool_id;

