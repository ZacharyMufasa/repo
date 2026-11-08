SELECT m.member_id, m.email
FROM member AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM category AS c
    WHERE c.requires_certification = 1
      AND NOT EXISTS (
          SELECT 1
          FROM checkout AS ch
          JOIN tool AS t ON t.tool_id = ch.tool_id
          WHERE ch.member_id = m.member_id
            AND t.category_id = c.category_id
      )
)
ORDER BY m.member_id;

