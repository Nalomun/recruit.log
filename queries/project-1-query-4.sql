-- ============================================================
-- QUERY 4: Complex search criterion (multiple AND/OR)
-- "Find applicants who are either MS/PhD with 2+ years exp
--  OR BS students with GPA above 3.8 who know Python at
--  advanced level"
-- ============================================================
SELECT DISTINCT
    a.username,
    a.university,
    a.degree_level,
    a.gpa,
    a.years_of_experience
FROM Applicant a
LEFT JOIN Applicant_Skill ask ON a.applicant_id = ask.applicant_id
LEFT JOIN Skill s ON ask.skill_id = s.skill_id
WHERE
    (
        a.degree_level IN ('MS', 'PhD')
        AND a.years_of_experience >= 2
    )
    OR
    (
        a.degree_level = 'BS'
        AND a.gpa > 3.8
        AND s.skill_name = 'Python'
        AND ask.proficiency_level = 'advanced'
    )
ORDER BY a.degree_level, a.gpa DESC;
-- Expected output: Graduate students with experience (eve_data
-- MS 3.91, henry_quant MS 3.95, kate_ai PhD 3.88) plus BS
-- students with high GPA and advanced Python (alice_dev BS 3.85,
-- bob_algo BS 3.92). Approximately 4-6 rows.
