/*******************************************************************************
Project: Exploring Startup Trends with SQL
Company: VentureInsight Research Firm
Description: 10-part analysis of venture funds, acquisitions, and startup success.
*******************************************************************************/

-- Task 1: Calculate the number of companies that have been closed down.
SELECT COUNT(status)
FROM company
    WHERE status= 'closed';


-- Task 2: Funding for news-related companies in the USA (sorted by funding_total).
SELECT funding_total
FROM company
WHERE category_code='news' AND country_code='USA'
ORDER BY funding_total DESC;


-- Task 3: Total amount of cash-only acquisitions from 2011 to 2013.
SELECT SUM(price_amount)
FROM acquisition
WHERE term_code='cash' AND acquired_at >= '2011-01-01' AND acquired_at<= '2013-12-31';


-- Task 4: Identify people with Twitter usernames starting with 'Silver'.
SELECT first_name, last_name, twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';


-- Task 5: Identify people with 'money' in their Twitter handle and last name starting with 'K'.
SELECT *
FROM people
WHERE last_name LIKE 'K%' AND twitter_username LIKE '%money%';


-- Task 6: Total money raised by companies for every country.
SELECT country_code, SUM(funding_total)
FROM company
GRoup BY country_code
ORDER BY SUM(funding_total) DESC;


-- Task 7: Highest and lowest funding amounts per date (excluding zeros).
SELECT DISTINCT funded_at, MIN(raised_amount), MAX(raised_amount)
FROM funding_round
GROUP BY funded_at HAVING MIN(raised_amount)<>0 AND MIN(raised_amount)<> MAX(raised_amount);


-- Task 8: Classify funds into activity categories (high, middle, low).
SELECT *, CASE WHEN invested_companies>100 THEN 'high_activity' WHEN invested_companies BETWEEN 20 AND 99 THEN 'middle_activity' WHEN invested_companies<20 THEN 'low_activity' END AS categories
FROM fund;


-- Task 9: Average funding rounds for each activity category.
SELECT CASE WHEN invested_companies>100 THEN 'high_activity' WHEN invested_companies BETWEEN 20 AND 99 THEN 'middle_activity' WHEN invested_companies<20 THEN 'low_activity' END AS categories, ROUND(AVG(investment_rounds)) AS avg
FROM fund
GROUP BY categories
ORDER BY AVG(investment_rounds) ASC;


-- Task 10: Average number of degrees for employees at startups that closed after one round.
WITH Closed AS (SELECT company.id
    FROM company INNER JOIN funding_round ON company.id=funding_round.company_id
    WHERE company.status = 'closed' AND funding_round.is_first_round=1 AND funding_round.is_last_round=1
    GROUP BY company.id),
EmployeeDegrees AS (SELECT people.id, COUNT(education.degree_type) AS num_degrees
    FROM people INNER JOIN education ON people.id= education.person_id
    WHERE people.company_id IN (SELECT id FROM Closed)
    GROUP BY people.id)
SELECT AVG(num_degrees)
FROM EmployeeDegrees;