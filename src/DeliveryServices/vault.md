# 🧠 Information Delivery: Star Schema vs. One Big Table (OBT)

This section demonstrates two patterns for building the **Information Delivery (Gold)** layer on top of a Business Data Vault (BDV):

---

## ⭐ Star Schema

**Purpose:** Clean, modular, reusable dimensional modeling for analytics and self-service.

### 🧱 Structure:
- `fact_orders`: main fact table
- `dim_users`: describes users
- `dim_country`: enriches user data

### ✅ Pros:
- Easy to scale (add new dimensions)
- Clear lineage
- Works well with BI tools (Power BI, Looker, etc.)
- Reuse dimensions across many facts

### ❌ Cons:
- Requires more joins
- Slightly more complex to query
- May be slower with large joins

---

## 🧱 One Big Table (OBT)

**Purpose:** Flattened dataset optimized for dashboard speed and ML feature consumption.

### 🧾 Structure:
- `obt_orders`: all necessary columns denormalized into one wide table

### ✅ Pros:
- Fast for dashboard tools
- Fewer joins (great for performance)
- Simpler for non-technical consumers

### ❌ Cons:
- Hard to maintain
- Duplicate logic across models
- Larger storage footprint

---
