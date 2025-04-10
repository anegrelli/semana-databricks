# 🤖 AI/BI Genie – Gold Layer Exploration with 10 Tables

This guide helps you or your students explore the Information Delivery layer using **Databricks AI/BI Genie** with a **lean, powerful 10-table dataset**.

---

## ✅ Selected Tables for Genie (10)

These 10 tables give you **full coverage of user, order, and status analytics** with minimal overhead.

| Table                    | Purpose                                           |
|--------------------------|---------------------------------------------------|
| `bsat_users_enriched`    | Clean user dimension (name, job, birthdate)       |
| `latest_order_status`    | Latest known status of each order                 |
| `pit_user_order_status`  | Snapshot: user + order + status                   |
| `bridge_order_status_flow` | Status history of each order                    |
| `blink_user_order_activity` | Aggregated metrics per user                    |
| `ref_country`            | Maps country codes to readable names              |
| `fact_orders`            | Star schema fact table                            |
| `dim_users`              | Star schema user dimension                        |
| `obt_orders`             | One Big Table for fast dashboarding               |
| `vw_user_insights`       | Genie-friendly view combining user + metrics      |

---

## 🧠 Example Questions to Ask Genie

Use these natural language questions to explore the models. Genie will interpret and generate SQL based on the tables you've selected.

### 🔹 Exploratory Insights

1. **How many total orders were placed by each company type?**

2. **What is the average number of orders per user?**

3. **Show me the latest status for each order.**

4. **Which countries have the most active users?**

5. **Who are the users with the earliest first orders?**

6. **What is the most common order status per country?**

7. **Show a list of users with their job title and order activity.**

8. **What is the total number of orders placed by users in 'Brasil'?**

9. **Which orders had a status flow containing 'Canceled'?**

10. **Who are the users with the most total orders?**

---

## 💡 Tips for Students

- 🧠 **Watch the generated SQL**: Click “View SQL” to learn how Genie interprets your questions.
- 🔍 **Start simple**: Ask for counts, filters, or top 10s.
- 🧩 **Use descriptive fields**: Genie understands `company_type`, `status`, `country_name`, etc.
- ⚡ **Compare Star Schema vs OBT**:
    - Try asking the same question to `fact_orders` + `dim_users` and to `obt_orders`.

---

## 📚 Optional Views to Add for Simplicity

| View                  | Purpose                                  |
|-----------------------|------------------------------------------|
| `vw_user_insights`    | Combines user metadata and order metrics |
| `vw_orders_summary`   | Aggregated status rollup for dashboards  |

---

Happy querying! 🧠✨