SELECT t.tool_id, t.name AS tool_name,
       COUNT(ch.checkout_id) AS times_checked_out
FROM tool AS t
LEFT JOIN checkout AS ch ON ch.tool_id = t.tool_id
GROUP BY t.tool_id, t.name
HAVING COUNT(ch.checkout_id) > (
    SELECT AVG(tool_counts.checkout_count)
    FROM (
        SELECT COUNT(ch2.checkout_id) AS checkout_count
        FROM tool AS t2
        LEFT JOIN checkout AS ch2 ON ch2.tool_id = t2.tool_id
        GROUP BY t2.tool_id
    ) AS tool_counts
)
ORDER BY times_checked_out DESC, t.tool_id;

