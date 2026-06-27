Project Overview

RavenStack is a fictional B2B SaaS company selling software subscriptions to businesses across industries like DevTools, FinTech, Cybersecurity, HealthTech, and EdTech.

This end-to-end data analytics project answers the most critical question every subscription business faces:


"Who is leaving, why are they leaving, and can we stop it before it happens?"



Using MySQL, Python (Pandas, Seaborn), and Power BI, I analysed 5 interconnected datasets covering 500 customers, 5,000 subscriptions, 25,000 product usage events, 2,000 support tickets, and 600 churn events — and delivered a full business intelligence solution across 5 interactive dashboards.


📁 Project Structure

ravenstack-saas-analytics/
│
├── data/
│   ├── ravenstack_accounts.csv
│   ├── ravenstack_subscriptions.csv
│   ├── ravenstack_feature_usage.csv
│   ├── ravenstack_support_tickets.csv
│   └── ravenstack_churn_events.csv
│
├── sql/
│   └── saas_queries.sql
│
├── python/
│   └── startup_growth.ipynb
│
├── powerbi/
│   └── ravenstack_dashboard.pbix
│
├── report/
│   └── RavenStack_SaaS_Analytics_Report.docx
│
└── README.md


🗃️ Dataset Description

The project uses 5 relational tables stored in a MySQL database (saas_analytics):

TableRowsDescriptionaccounts500Customer master list — industry, country, signup date, plan tier, churn flagsubscriptions5,000Revenue data — MRR, ARR, plan tier, upgrade/downgrade flags, auto-renewfeature_usage25,000Product behaviour — feature name, usage count, duration, errors, beta flagsupport_tickets2,000Support history — priority, resolution time, satisfaction score, escalationchurn_events600Churn records — reason code, refund, reactivation, preceding actions


🔧 Tools & Technologies

ToolPurposeMySQLDatabase setup, data cleaning, aggregation, joins, window functionsPython (Pandas, NumPy)Data merging, feature engineering, EDA, correlation analysisMatplotlib / SeabornData visualisation in PythonPower BIInteractive business dashboardsJupyter NotebookPython analysis environment


⚙️ SQL — What Was Done

Database Setup & Cleaning

sql-- Created database and renamed tables to clean aliases
CREATE DATABASE saas_analytics;
RENAME TABLE ravenstack_accounts TO accounts;

-- Fixed BOM encoding issue on column names
ALTER TABLE accounts
CHANGE COLUMN `ï»¿account_id` account_id VARCHAR(50);

-- Checked for nulls and duplicates
SELECT COUNT(*) FROM accounts WHERE account_id IS NULL;
SELECT customerID, COUNT(*) FROM accounts GROUP BY account_id HAVING COUNT(*) > 1;

Key Business Queries

sql-- Revenue by subscription plan
SELECT plan_tier, SUM(mrr_amount) AS total_mrr
FROM subscriptions
GROUP BY plan_tier
ORDER BY total_mrr DESC;

-- Churn rate by plan tier
SELECT plan_tier,
  ROUND(AVG(churn_flag) * 100, 2) AS churn_rate
FROM subscriptions
GROUP BY plan_tier;

-- Revenue ranking using window function
SELECT account_id,
  SUM(mrr_amount) AS revenue,
  RANK() OVER (ORDER BY SUM(mrr_amount) DESC) AS revenue_rank
FROM subscriptions
GROUP BY account_id;

-- Most used features
SELECT feature_name, SUM(usage_count) AS total_usage
FROM feature_usage
GROUP BY feature_name
ORDER BY total_usage DESC;

-- Support resolution time by priority
SELECT priority, AVG(resolution_time_hours) AS avg_resolution
FROM support_tickets
GROUP BY priority;


🐍 Python — What Was Done

1. Data Loading & Merging

All 5 datasets were loaded into Pandas DataFrames and progressively merged into a single master_df using account_id as the common key.

pythonimport pandas as pd

accounts   = pd.read_csv('data/ravenstack_accounts.csv')
subs       = pd.read_csv('data/ravenstack_subscriptions.csv')
usage      = pd.read_csv('data/ravenstack_feature_usage.csv')
tickets    = pd.read_csv('data/ravenstack_support_tickets.csv')
churn      = pd.read_csv('data/ravenstack_churn_events.csv')

# Aggregate subscriptions to account level
subs_agg = subs.groupby('account_id').agg(
    total_mrr=('mrr_amount', 'sum'),
    total_arr=('arr_amount', 'sum'),
    churn_flag=('churn_flag', 'max')
).reset_index()

# Merge into master dataframe
master_df = accounts.merge(subs_agg, on='account_id', how='left')

2. Feature Engineering

python# Customer status from end_date
master_df['customer_status'] = master_df['end_date'].apply(
    lambda x: 'Churned' if pd.notnull(x) else 'Active'
)

# Engagement Score — custom metric
master_df['engagement_score'] = (
    master_df['total_usage'] +
    (master_df['unique_features'] * 10) +
    master_df['total_usage_events']
)

# Segment customers into Low / Medium / High engagement
master_df['engagement_segment'] = pd.qcut(
    master_df['engagement_score'], q=3,
    labels=['Low', 'Medium', 'High']
)

3. Correlation Analysis

pythonimport seaborn as sns
import matplotlib.pyplot as plt

corr = master_df[['engagement_score', 'churn_flag',
                   'ticket_count', 'total_mrr']].corr()
sns.heatmap(corr, annot=True, cmap='coolwarm')
plt.title('Correlation Matrix')
plt.show()

4. Cohort Analysis

python# Group customers by signup month and track churn rate
master_df['signup_month'] = pd.to_datetime(
    master_df['signup_date']).dt.to_period('M')

cohort = master_df.groupby('signup_month').agg(
    total=('account_id', 'count'),
    churned=('churn_flag', 'sum')
).reset_index()

cohort['churn_rate'] = (cohort['churned'] / cohort['total'] * 100).round(2)


📊 Power BI Dashboards

Five interactive dashboards were built covering every major business dimension:

Dashboard 1 — SaaS Business Performance


Top-level executive view of ARR, churn count, usage trends, and revenue by country



Key Metrics: ARR $136M | Total Accounts 500 | Churn Count 486 | Total Usage 8.65K


Dashboard 2 — Customer & Subscription Analytics


Customer composition by plan, industry, country, trial status, and auto-renew



Key Metrics: Total Seats 149K | Avg MRR $2,270 | Total Subscriptions 4,967


Dashboard 3 — Product Usage Analytics


Feature adoption, usage frequency, session duration, beta feature penetration



Key Metrics: Total Usage Events 25K | Total Usage Count 251K | Beta Usage 10.18%


Dashboard 4 — Churn Analytics & Customer Retention


Churn reasons, industry breakdown, monthly trend, reactivations, pre-churn behaviour



Key Metrics: Total Churned 600 | Reactivations 61 | Avg Refund $14.42


Dashboard 5 — Support & Customer Experience


Ticket volume, resolution time, satisfaction scores, escalation rate by priority



Key Metrics: Avg Resolution 35.86 hrs | Avg Satisfaction 3.98/5 | Escalation Rate 4.75%


📈 Key Findings

💰 Revenue


Enterprise plan generates 73% of total MRR ($8.47M) despite being only 34% of subscriptions
One Enterprise subscription is worth ~10 Basic subscriptions in revenue
US accounts for 59% of all ARR — significant geographic concentration risk
Total ARR of $136M across 500 business customers


📉 Churn


Overall churn rate: ~22% (110 of 500 accounts have churned)
#1 churn reason: Missing features (114 of 600 events)
December churn spike: 133 events — more than Q1 (Jan–Mar) combined
Churn rate is identical across all plan tiers (~10%) — price is NOT the issue
123 customers upgraded before churning — "last chance" behaviour pattern
61 reactivations — 10% natural win-back rate without any dedicated programme


🖥️ Product Usage


Usage growing year-over-year (124.5K → 126K usage count)
feature_24, 27, 8 have the longest session duration — the product's stickiest features
Beta features used in only 10.18% of all usage events — undiscovered by most customers


🎫 Support


Average resolution: 35.86 hours | First response: 88.48 minutes
Escalated tickets score higher satisfaction (4.08 vs 3.98) — senior intervention works
Top revenue accounts (Company_90–99) also submit the most support tickets



💡 Business Recommendations

#RecommendationData Behind It1Fix the product roadmap — features is the #1 churn reason114/600 churn events cite missing features2Launch Q3 retention campaigns — prevent Q4 churn spike133 churns in December alone3Call every customer who upgrades within 48 hours123 customers upgraded then churned anyway4Onboard new users to features 24, 27, 8 firstThese have 53+ min avg session duration5Build a win-back programme61 natural reactivations = 10% without trying6Assign dedicated CSMs to top accountsCompany_90–99 are highest revenue AND highest ticket volume7Promote beta features activelyOnly 10.18% usage despite significant engineering investment


📊 Business Metrics Glossary

TermDefinitionMRRMonthly Recurring Revenue — money collected every month from subscriptionsARRAnnual Recurring Revenue — MRR × 12, the yearly revenue pictureChurnWhen a customer cancels their subscriptionChurn Rate(Churned customers ÷ Total customers) × 100Engagement ScoreCustom metric: total_usage + (unique_features × 10) + total_usage_eventsCohort AnalysisGrouping customers by signup month and tracking their behaviour over timeReactivationA churned customer who returns and subscribes againARR at RiskRevenue from customers showing churn warning signals


🚀 How to Run This Project

Prerequisites

Python 3.8+
MySQL 8.0+
Power BI Desktop
Jupyter Notebook

Python Libraries

bashpip install pandas numpy matplotlib seaborn jupyter

Steps

1. Set up the database

sqlCREATE DATABASE saas_analytics;
USE saas_analytics;
-- Import CSVs from /data folder into MySQL
-- Then run all queries in /sql/saas_queries.sql

2. Run the Python notebook

bashcd python
jupyter notebook startup_growth.ipynb

3. Open the Power BI dashboard

Open powerbi/ravenstack_dashboard.pbix in Power BI Desktop
Refresh data connection to point to your local MySQL instance




🙋 About This Project

This project was built as a complete end-to-end data analytics case study simulating a real-world SaaS business intelligence workflow. It covers the full analyst pipeline — from raw database setup and SQL querying through Python-based behavioural analysis to executive-ready Power BI dashboards and a professional written report.

Skills demonstrated:


Relational database design and SQL querying (DDL, DML, aggregations, joins, subqueries, window functions)
Python data wrangling and feature engineering (Pandas, NumPy)
Exploratory data analysis and correlation analysis
Custom metric design (engagement scoring)
Cohort analysis and customer segmentation
Business intelligence dashboard design (Power BI)
Data storytelling and executive communication
