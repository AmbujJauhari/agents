-- Known-good starting points. Adapt these rather than writing from scratch.
-- Fill in with the queries you find yourself rewriting.

-- ---------------------------------------------------------------
-- Metadata
-- ---------------------------------------------------------------
-- sp_help <table>
-- sp_helptext <proc>
-- sp_depends <object>
SELECT name, type, crdate FROM sysobjects WHERE name LIKE '%<pattern>%' ORDER BY name;

-- ---------------------------------------------------------------
-- Count-first template (always run before selecting rows)
-- ---------------------------------------------------------------
SELECT COUNT(*) FROM <table> WHERE <filter>;

-- ---------------------------------------------------------------
-- Fan-out check: row count before vs after a join
-- ---------------------------------------------------------------
SELECT COUNT(*) FROM <a> WHERE <filter>;
SELECT COUNT(*) FROM <a> JOIN <b> ON <keys> WHERE <filter>;
-- counts differ -> investigate before trusting any aggregate

-- ---------------------------------------------------------------
-- Add your recurring investigations below, each with a comment
-- saying what question it answers.
-- ---------------------------------------------------------------
