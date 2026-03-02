-- ============================================================
-- QUERY 2: Subquery
-- "Which applicants have a GPA above the average GPA of all
--  accepted applicants?"
-- Uses a scalar subquery in the WHERE clause
-- ============================================================
SELECT
    a.username,
    a.university,
    a.gpa,
    a.degree_level
FROM Applicant a
WHERE a.gpa > (
    SELECT AVG(a2.gpa)
    FROM Applicant a2
    JOIN Application app ON a2.applicant_id = app.applicant_id
    WHERE app.status = 'accepted'
)
ORDER BY a.gpa DESC;
-- Expected output: Applicants with GPA above the average of
-- accepted applicants (~3.75). Should include high-GPA students
-- like henry_quant (3.95), bob_algo (3.92), eve_data (3.91),
-- kate_ai (3.88), alice_dev (3.85), and olivia_ds (3.80).
-- Approximately 6-8 rows.
