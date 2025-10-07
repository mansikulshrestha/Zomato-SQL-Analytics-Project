# 🍽️ Zomato SQL Analytics Project

This project performs **comprehensive data analysis** on a Zomato-style food delivery database using **MySQL**.  
It covers database design, data exploration, and key business insights across customers, restaurants, and orders.

---

## 📊 Project Overview

The SQL scripts in this repository allow you to:

- Set up a relational Zomato database schema.  
- Perform **Exploratory Data Analysis (EDA)**.  
- Analyze customer behavior, restaurant performance, and order trends.  
- Measure **AOV (Average Order Value)**, **customer LTV**, and **YoY/MoM growth**.

---

## 🧱 Database Schema

The project includes five main tables:

| Table Name | Description |
|-------------|--------------|
| `customers` | Stores customer details and registration dates |
| `orders` | Tracks all customer food orders |
| `restaurants` | Contains restaurant data like city and timings |
| `riders` | Stores delivery partner details |
| `deliveries` | Tracks delivery status and timings |

---

## ⚙️ Key Analyses Performed

### 🔍 Exploratory Data Analysis (EDA)
- Null value detection for data quality checks.  
- Quick data preview for all entities.

### 👥 Customer Insights
- Top 3 dishes per customer in the last 2 years.  
- Lifetime value (LTV) and spending ranks.  
- Average order value and customer segmentation.

### 🕓 Time-Based Analysis
- Orders bucketed into 2-hour slots to identify **peak times**.  
- Day-of-week ordering trends.  
- Year-over-year and month-over-month growth.

### 🍴 Restaurant Performance
- Rank restaurants by **AOV**, **order volume**, and **max order value**.

### 💰 Price Band Analysis
- Group orders into **Low**, **Medium**, and **High** price bands.  
- Rank popularity and average spend in each category.

---

## 📈 Growth Analysis

Includes both **YoY** and **MoM** metrics for:

- Total Orders 📦  
- Total Order Value 💵  

Helps identify growth trends and performance fluctuations over time.

---

## 🧩 SQL Features Used

- **Window functions**: `RANK()`, `DENSE_RANK()`, `LAG()`  
- **Aggregations**: `SUM()`, `AVG()`, `COUNT()`  
- **CTEs** for modular and readable analysis  
- **CASE** statements for price segmentation  

---

## 🗂️ How to Use

1. Run the setup commands to create the `zomato` database and tables.  
2. Insert mock or real data into tables.  
3. Execute each analysis section in order for step-by-step insights.

---

## 🧠 Author

**Mansi Kulshrestha**  
 Aspiring Data Analyst  
📍 Agra, Uttar Pradesh  
🔗 [LinkedIn Profile](https://www.linkedin.com/in/mansi-kulshrestha/)

---

## ⭐️ Show Support

If you found this helpful, please ⭐️ the repo and share feedback!
