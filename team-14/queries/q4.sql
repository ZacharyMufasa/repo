SELECT m.member_id, m.email
FROM member AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM checkout AS ch
    WHERE ch.member_id = m.member_id
)
ORDER BY m.member_id;

