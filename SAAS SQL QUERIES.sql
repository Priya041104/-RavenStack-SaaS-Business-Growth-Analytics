CREATE DATABASE saas_analytics;
USE saas_analytics;
SHOW TABLES;
RENAME TABLE ravenstack_accounts TO accounts;
RENAME TABLE ravenstack_churn_events TO events;
RENAME TABLE featutre TO usage_data;
RENAME TABLE ravenstack_subscriptions TO subscription;
RENAME TABLE ravenstack_support_tickets TO tickets;
 SELECT * FROM accounts LIMIT 5;
 SELECT * FROM subscription LIMIT 5;
 SELECT * FROM usage_data LIMIT 5;
 SELECT * FROM tickets LIMIT 5;
SELECT * FROM events LIMIT 5;
SELECT COUNT(*) FROM accounts;
SELECT COUNT(*) FROM subscription;
SELECT COUNT(*) FROM usage_data;
SELECT COUNT(*) FROM tickets;
SELECT COUNT(*) FROM events;
DESCRIBE accounts; 
ALTER TABLE accounts
CHANGE COLUMN `ï»¿account_id` account_id INT;
ALTER TABLE accounts
CHANGE COLUMN `ï»¿account_id` account_id VARCHAR(50);
DESCRIBE subscription;
ALTER TABLE subscription
CHANGE COLUMN `ï»¿subscription_id` subscription_id VARCHAR(50);
DESCRIBE usage_data;
ALTER TABLE usage_data
CHANGE COLUMN `ï»¿usage_id` usage_id VARCHAR(50);
DESCRIBE events;
ALTER TABLE events
CHANGE COLUMN `ï»¿churn_event_id` churn_event_id VARCHAR(50);
DESCRIBE tickets:
ALTER TABLE tickets
CHANGE COLUMN `ï»¿ticket_id` ticket_id VARCHAR(50);

SELECT COUNT(*)
FROM accounts
WHERE account_id IS NULL;

SELECT COUNT(*)
FROM subscription
WHERE account_id IS NULL;

SELECT COUNT(*)
FROM accounts a
JOIN subscription s
ON a.account_id = s.account_id;

SELECT COUNT(*)
FROM accounts a
JOIN subscription s
ON a.account_id = s.account_id;

--  Revenue by Plan
SELECT
    plan_tier,
    SUM(mrr_amount) AS total_mrr
FROM subscription
GROUP BY plan_tier
ORDER BY total_mrr DESC;

-- Revenue by Industry
SELECT
    a.industry,
    SUM(s.mrr_amount) AS total_mrr
FROM accounts a
JOIN subscription s
ON a.account_id = s.account_id
GROUP BY a.industry
ORDER BY total_mrr DESC;

-- Churn by Plan
SELECT
    plan_tier,
    ROUND(AVG(churn_flag) * 100, 2) AS churn_rate
FROM subscription
GROUP BY plan_tier;

-- Most Used Features
SELECT
    feature_name,
    SUM(usage_count) AS total_usage
FROM usage_data
GROUP BY feature_name
ORDER BY total_usage DESC;

-- Ticket Analysis
SELECT
    priority,
    AVG(resolution_time_hours) AS avg_resolution_time
FROM tickets
GROUP BY priority;

-- Window Function
SELECT
    account_id,
    SUM(mrr_amount) AS revenue,
    RANK() OVER (
        ORDER BY SUM(mrr_amount) DESC
    ) AS revenue_rank
FROM subscription
GROUP BY account_id;

