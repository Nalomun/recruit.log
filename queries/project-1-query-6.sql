-- ============================================================
-- QUERY 6: SELECT CASE/WHEN
-- "Categorize each application outcome and show rejection
--  funnel stage analysis"
-- ============================================================
SELECT
    a.username,
    c.company_name,
    jl.title,
    app.status,
    CASE
        WHEN app.status = 'accepted' THEN 'Offer Received'
        WHEN app.status = 'withdrawn' THEN 'Self-Withdrawn'
        WHEN app.status = 'applied' THEN 'In Progress'
        WHEN app.rejection_stage = 'application' THEN 'Rejected: Resume Screen'
        WHEN app.rejection_stage = 'OA' THEN 'Rejected: Online Assessment'
        WHEN app.rejection_stage = 'phoneScreen' THEN 'Rejected: Phone Screen'
        WHEN app.rejection_stage = 'interview' THEN 'Rejected: Final Interview'
        WHEN app.rejection_stage = 'offer' THEN 'Rejected: Post-Offer'
        ELSE 'Unknown'
    END AS outcome_detail
FROM Application app
JOIN Applicant a ON app.applicant_id = a.applicant_id
JOIN Job_Listing jl ON app.listing_id = jl.listing_id
JOIN Company c ON jl.company_id = c.company_id
ORDER BY a.username, c.company_name;
-- Expected output: 30 rows (one per application) with readable
-- outcome labels. For example, alice_dev at Google shows
-- "Offer Received", alice_dev at Stripe shows "Rejected:
-- Final Interview", alice_dev at Figma shows "Rejected:
-- Online Assessment".
