SELECT ranked.category_name, ranked.tool_id, ranked.tool_name,
       ranked.checkout_count, ranked.category_rank
FROM (
    SELECT c.name AS category_name, t.tool_id, t.name AS tool_name,
           COUNT(ch.checkout_id) AS checkout_count,
           RANK() OVER (
               PARTITION BY c.category_id
               ORDER BY COUNT(ch.checkout_id) DESC
           ) AS category_rank
    FROM category AS c
    JOIN tool AS t ON t.category_id = c.category_id
    JOIN checkout AS ch ON ch.tool_id = t.tool_id
    GROUP BY c.category_id, c.name, t.tool_id, t.name
) AS ranked
WHERE ranked.category_rank <= 3
ORDER BY ranked.category_name, ranked.category_rank, ranked.tool_id;

