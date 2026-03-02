# Recruit.log: Mapping CS Internship and Job Outcomes

A complete database design and implementation for **Recruit.log**, a platform that records and analyzes internship and job application outcomes among Computer Science students, providing data-driven insights for applicants, advisors, and institutional researchers.

---

## Quick Start

```bash
# 1. Create and populate the database
bash setup.sh

# 2. Run any query
sqlite3 -header -column recruitlog.db < sql/queries/query1_three_table_join.sql

```

---

## Repository Structure

```
recruit-log-db/
├── README.md                  ← This file
├── .gitignore
├── setup.sh                   ← Creates the database from SQL scripts
│
├── docs/
│   ├── requirements.pdf       ← [Q0] Requirements document
│   ├── bcnf_schema.pdf        ← [Q3] Relational schema + BCNF proof
│   └── query_outputs.txt      ← [Q6] Example outputs of all queries
│
├── diagrams/
│   ├── uml_conceptual_model.png  ← [Q1] Static PNG of UML Conceptual Model
│   ├── uml_conceptual_model.mmd  ← [Q1] Mermaid Source of UML
│   ├── erd_logical_model.png     ← [Q2] Static PNG of ERD Logical Model
│   └── erd_logical_model.mmd     ← [Q2] Mermaid Source of ERD
│
├── sql/
│   ├── create_tables.sql      ← [Q4] DDL statements
│   ├── populate_data.sql      ← [Q5] Test data
│   └── queries/
│       ├── query1_three_table_join.sql    ← [Q6] Join of 6 tables
│       ├── query2_subquery.sql            ← [Q6] Scalar subquery
│       ├── query3_group_by_having.sql     ← [Q6] GROUP BY + HAVING
│       ├── query4_complex_search.sql      ← [Q6] Complex search criterion
│       ├── query5_partition_by.sql        ← [Q6] RANK() with PARTITION BY
│       ├── query6_case_when.sql           ← [Q6] SELECT CASE/WHEN
│       ├── query7_rcte.sql               ← [Q6] Recursive CTE
│       └── query8_correlated_subquery.sql ← [Q6] Correlated subquery
```

---

## Assignment Deliverables

### Q0 — Requirements Document (10 pts)

**File:** [`docs/requirements.pdf`](docs/requirements.pdf)

Describes the CS recruiting problem domain, lists 12 business rules, user personas and user stories, and extracts candidate nouns (entities/attributes) and verbs (relationships/actions) from a requirements narrative. Key rules include: applicant data is anonymized when public, applicants can only apply to each listing once, and application outcomes track rejection stage.

### Q1 — UML Conceptual Model (15 pts)

*(Available as static graphic: [`diagrams/uml_conceptual_model.png`](diagrams/uml_conceptual_model.png))*

Ten classes with full multiplicity constraints, domain-typed attributes, and labeled relationships across all four UML relationship types:

**Composition (◆):**
- Company **1** ◆── **0..*** JobListing (listing cannot exist without company)
- JobListing **1** ◆── **0..*** ListingRequirement (requirement cannot exist without listing)

**Aggregation (◇):**
- Applicant **1** ◇── **0..*** ApplicantSkill (applicant "has" skills, skills exist independently)
- Advisor **1** ◇── **0..*** AdvisorBookmark (advisor collects bookmarks, listings exist independently)

**Association (plain):**
- Applicant **1** ── **0..*** Application (submits)
- JobListing **1** ── **0..*** Application (receives)
- Skill **1** ── **0..*** ApplicantSkill (describes)
- Skill **1** ── **0..*** ListingRequirement (specifies)
- JobListing **1** ── **0..*** AdvisorBookmark (referenced in)

**Generalization (△):**
- JobListing ◁── Internship (is-a)
- JobListing ◁── FullTimePosition (is-a)

### Q2 — Logical Data Model / ERD (10 pts)

*(Available as static graphic: [`diagrams/erd_logical_model.png`](diagrams/erd_logical_model.png))*

Uses Crow's Foot notation with SQL data types (int, text, real, boolean, date). All M:N relationships resolved into association entities:
- **Applicant_Skill** resolves Applicant ↔ Skill (carries `proficiency_level` and `years_used`)
- **Listing_Requirement** resolves Job_Listing ↔ Skill (carries `is_required` and `desired_proficiency`)
- **Advisor_Bookmark** resolves Advisor ↔ Job_Listing (carries `last_viewed` and `is_bookmarked`)
- **Application** resolves Applicant ↔ Job_Listing (carries `status`, `rejection_stage`, `offer_salary`, etc.)

### Q3 — Relational Schema in BCNF (15 pts)

**File:** [`docs/bcnf_schema.pdf`](docs/bcnf_schema.pdf)

Eleven relations, each proven to be in BCNF by listing functional dependencies and verifying every determinant is a superkey:

| # | Relation | Key(s) | Non-trivial FDs | BCNF? |
|---|----------|--------|-----------------|-------|
| 1 | Company | {company_id}, {company_name} | Both CKs → all others | ✓ |
| 2 | Job_Listing | {listing_id} | listing_id → all others | ✓ |
| 3 | Internship | {listing_id} | listing_id → all others | ✓ |
| 4 | Full_Time_Position | {listing_id} | listing_id → all others | ✓ |
| 5 | Skill | {skill_id}, {skill_name} | Both CKs → all others | ✓ |
| 6 | Applicant | {applicant_id}, {email}, {username} | All 3 CKs → all others | ✓ |
| 7 | Applicant_Skill | {applicant_id, skill_id} | Composite key → proficiency_level, years_used | ✓ |
| 8 | Listing_Requirement | {listing_id, skill_id} | Composite key → is_required, desired_proficiency | ✓ |
| 9 | Application | {application_id}, {applicant_id, listing_id} | Both CKs → all others | ✓ |
| 10 | Advisor | {advisor_id}, {email} | Both CKs → all others | ✓ |
| 11 | Advisor_Bookmark | {advisor_id, listing_id} | Composite key → last_viewed, is_bookmarked | ✓ |

### Q4 — SQL DDL (10 pts)

**File:** [`sql/create_tables.sql`](sql/create_tables.sql)

Creates all 11 tables with:
- Primary keys (AUTOINCREMENT where appropriate)
- Foreign keys with ON DELETE/UPDATE CASCADE actions
- CHECK constraints (e.g., `gpa BETWEEN 0.0 AND 4.0`, `salary_max >= salary_min`, status and rejection_stage enums)
- UNIQUE constraints (Company.company_name, Skill.skill_name, Applicant.email, Applicant.username, Advisor.email, Application(applicant_id, listing_id))
- Conditional CHECKs (rejection_stage only set when status = 'rejected', offer_salary only set when status = 'accepted')
- `PRAGMA foreign_keys = ON` for SQLite enforcement

Constraint enforcement verified:

| Test | Expected | Result |
|------|----------|--------|
| `gpa = 5.0` (outside 0.0–4.0) | CHECK fails | ✓ Rejected |
| Duplicate applicant email | UNIQUE fails | ✓ Rejected |
| Same applicant applying to same listing twice | UNIQUE fails | ✓ Rejected |
| Non-existent company_id in Job_Listing | FK fails | ✓ Rejected |
| `status = 'rejected'` with NULL rejection_stage | CHECK fails | ✓ Rejected |

### Q5 — Test Data (10 pts)

**File:** [`sql/populate_data.sql`](sql/populate_data.sql)

| Table | Records | Notes |
|-------|---------|-------|
| Company | 12 | Real tech companies (Google, Meta, Stripe, Anthropic, etc.) |
| Job_Listing | 14 | 7 internships + 7 full-time positions |
| Internship | 7 | Subtype data (season, co-op flag, duration) |
| Full_Time_Position | 7 | Subtype data (employment type, signing bonus, remote policy) |
| Skill | 15 | Languages, frameworks, tools, and concepts |
| Applicant | 15 | Fictional CS students across 12 universities |
| Applicant_Skill | 40 | Diverse skill distributions across applicants |
| Listing_Requirement | 25 | Required and preferred skills per listing |
| Application | 30 | Mix of accepted, rejected, withdrawn, and in-progress |
| Advisor | 5 | Faculty, career center, institutional researcher, consultant |
| Advisor_Bookmark | 10 | Bookmarked and viewed listings |

### Q6 — Queries (10 pts)

All queries and their outputs are documented in [`docs/query_outputs.txt`](docs/query_outputs.txt).

| Query | Requirement | File | Description |
|-------|-------------|------|-------------|
| 1 | Join of ≥3 tables | [`query1_three_table_join.sql`](sql/queries/query1_three_table_join.sql) | Accepted applicants' skills per company (joins Application → Applicant → Job_Listing → Company → Applicant_Skill → Skill) |
| 2 | Subquery | [`query2_subquery.sql`](sql/queries/query2_subquery.sql) | Applicants with GPA above the average GPA of accepted applicants (scalar subquery in WHERE) |
| 3 | GROUP BY + HAVING | [`query3_group_by_having.sql`](sql/queries/query3_group_by_having.sql) | Companies with acceptance rate below 50% |
| 4 | Complex search | [`query4_complex_search.sql`](sql/queries/query4_complex_search.sql) | Graduate students with 2+ years experience OR BS students with high GPA and advanced Python (AND/OR with IN, multiple expressions) |
| 5 | PARTITION BY | [`query5_partition_by.sql`](sql/queries/query5_partition_by.sql) | RANK() accepted applicants by offer salary within each company |
| 6 | CASE/WHEN | [`query6_case_when.sql`](sql/queries/query6_case_when.sql) | Rejection funnel analysis mapping status + rejection_stage to human-readable outcomes |
| 7 | RCTE | [`query7_rcte.sql`](sql/queries/query7_rcte.sql) | Recursive salary bracket generator with offer distribution |
| 8 | Correlated subquery | [`query8_correlated_subquery.sql`](sql/queries/query8_correlated_subquery.sql) | Per-skill success rate: accepted vs rejected applicant counts |

---

## Schema Overview

```
Company  1 ◆────< N  Job_Listing  1 ◆────< N  Listing_Requirement  N >────  1  Skill
                       │  △                                                      │
                       │  ├── Internship                                         │
                       │  └── Full_Time_Position                                 │
                       │                                                         │
                       1                                                         1
                       │                                                         │
                       N                                                         N
                   Application                                            Applicant_Skill
                    N     1                                                N     1
                    │                                                      │
                    │                                                      │
                    1                                                      1
                Applicant                                              Applicant

Advisor  1 ◇────< N  Advisor_Bookmark  N >────  1  Job_Listing
```

---

## How to Run Queries Individually

```bash
# Make sure database exists
bash setup.sh

# Run any query with formatted output
sqlite3 -header -column recruitlog.db < sql/queries/query1_three_table_join.sql
sqlite3 -header -column recruitlog.db < sql/queries/query2_subquery.sql
sqlite3 -header -column recruitlog.db < sql/queries/query3_group_by_having.sql
sqlite3 -header -column recruitlog.db < sql/queries/query4_complex_search.sql
sqlite3 -header -column recruitlog.db < sql/queries/query5_partition_by.sql
sqlite3 -header -column recruitlog.db < sql/queries/query6_case_when.sql
sqlite3 -header -column recruitlog.db < sql/queries/query7_rcte.sql
sqlite3 -header -column recruitlog.db < sql/queries/query8_correlated_subquery.sql
```

---

## Authors

**Ganesh Batchu** & **Quinn Lambert**
CS3200 — Database Design | Northeastern University
