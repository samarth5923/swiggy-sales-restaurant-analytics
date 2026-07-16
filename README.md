# 🍽️ Swiggy Sales & Restaurant Analytics

A SQL-based data analytics project that analyzes Swiggy restaurant data to uncover business insights related to restaurant performance, pricing trends, cuisine distribution, customer ratings, and location-based patterns. The project follows a **Star Schema** data warehouse design and demonstrates practical SQL concepts used in real-world analytics.

---

# 📌 Project Objective

The objective of this project is to transform raw restaurant data into a structured analytical database and answer key business questions using SQL. The project focuses on:

- Restaurant Performance Analysis
- Pricing Analysis
- Category Analysis
- Dish Analysis
- Rating Analysis
- Location Analysis

---

# 📂 Dataset Overview

The dataset contains restaurant menu information from Swiggy, where each record represents a restaurant–dish combination.

### Dataset Attributes

- Restaurant Name
- State
- City
- Location
- Category
- Dish Name
- Price (INR)
- Rating
- Order Date

---

# 🏗️ Database Design

The project follows a **Star Schema** consisting of one fact table and five dimension tables.

### Fact Table

- `fact_swiggy_orders`

### Dimension Tables

- `dim_date`
- `dim_restaurant`
- `dim_location`
- `dim_category`
- `dim_dish`

---

# 🛠️ SQL Concepts Used

- Data Cleaning
- INNER JOIN
- GROUP BY
- Aggregate Functions
- CASE Statements
- Common Table Expressions (CTEs)
- Window Functions
- Date Functions
- ORDER BY
- LIMIT

---

# 📊 Business Questions Solved

### Restaurant Performance
- Highest Rated Restaurants
- Restaurants with Maximum Menu Items
- Average Menu Price by Restaurant

### Pricing Analysis
- Average Dish Price
- Price Bucket Distribution
- Most Expensive Dishes

### Category Analysis
- Top Food Categories
- Category-wise Menu Distribution

### Dish Analysis
- Highest Rated Dishes
- Average Dish Ratings

### Location Analysis
- Restaurant Distribution by Location
- Location-wise Menu Analysis

### Rating Analysis
- Average Customer Rating
- Rating Distribution

---

# 📈 Key Insights

- Identified top-performing restaurants based on customer ratings.
- Analyzed pricing trends across restaurants and food categories.
- Compared menu availability across different locations.
- Identified highly rated dishes and popular cuisines.
- Generated actionable business insights using SQL.

---

# 📁 Repository Structure

```
swiggy-sales-restaurant-analytics
│
├── Dataset
│   └── swiggy_orders.csv
│
├── SQL
│   ├── create_tables.sql
│   ├── data_cleaning.sql
│   ├── star_schema.sql
│   └── analysis_queries.sql
│
├── ERD
│   └── star_schema.png
│
├── Images
│   ├── highest_rated_restaurants.png
│   ├── top_categories.png
│   ├── price_bucket_analysis.png
│   └── rating_analysis.png
│
├── Report
│   └── Swiggy_SQL_Project_Report.pdf
│
└── README.md
```

---

# 💻 Technologies Used

- SQL
- PostgreSQL
- Microsoft Excel
- Star Schema Data Modelling

---

# 📄 Project Report

A detailed project report describing the dataset, business requirements, database design, SQL analysis, and key insights is available in the **Report** folder.

---

# 📌 ER Diagram

The complete Star Schema diagram is available in the **ERD** folder.

---

# 🚀 Future Enhancements

- Develop an interactive Power BI dashboard.
- Automate the ETL pipeline for incremental data loading.
- Integrate transaction-level order data for advanced sales analysis.
- Expand the data model with customer and delivery dimensions.

---

## 👨‍💻 Author

**Samarth Jain**

B.Tech, Mechanical Engineering  
Netaji Subhas University of Technology (NSUT)

LinkedIn: *(Add your profile link)*

GitHub: *(Add your GitHub profile link)*
