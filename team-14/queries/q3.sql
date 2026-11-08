SELECT ch.checkout_id, t.name AS tool_name, m.email AS member_email,
       ch.due_date, DATEDIFF('2026-06-30', ch.due_date) AS days_overdue
FROM checkout AS ch
JOIN tool AS t ON t.tool_id = ch.tool_id
JOIN member AS m ON m.member_id = ch.member_id
WHERE ch.return_date IS NULL
  AND ch.due_date < '2026-06-30'
ORDER BY days_overdue DESC, ch.checkout_id;

