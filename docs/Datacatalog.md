# Data Catalog for Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics.

---

### 1. **gold.dim_customer**
- **Purpose:** Stores cusomter details enriched with demographic and geographic data.
- **Column:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_key | BIGINT | Surrogate key uniquely identifying each customer record in dimension table|
| customer_id  | INT | Unique numerical identifier assigned to each customer |
| customer_number |NVARCHAR(50)| Alphanumeric identifier representing the customer, used for tracking and referencing. |
| customer_firstname | NVARCHAR(50) | The customer's first name, as recorded in system |
| customer_lastname | NVARCHAR(50)| The customer's last name or family's name |
| marital_status | NVARCHAR(50) | The custmoer's marital status (eg: 'Single','Married')|
|gender| NVARCHAR(50)|The gender of customer (eg:'Female','Male','n/a')|
|create_date|DATE| The date and time when customer record was created in system|
|brithday|DATE| Brithday of customer, formatted as YYYY-MM-DD (eg:'2016-12-01')|
| country | NVARCHAR(50) | The country of residence for customer (eg: 'Australia')|

### 2. **gold.dim_prodcut**

- **Purpose:** Store product information and their attribute
- **Column:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| prodcut_key | BIGINT | Surrogate key uniquely identifying each product record in dimension table|
| product_id  | INT |  A unique identifier assigned to the product used for tracking and referencing |
| category_id |NVARCHAR(50)| A unique identifier for product's category,linking to its high-level classification|
| product_code | NVARCHAR(50) | A structured alphanumeric code representing the product, often used for categorization or inventory. |
| product_name | NVARCHAR(50)| Descriptive name of the product, including key details such as type, color, and size. |
| category_name | NVARCHAR(50) | Descriptive name of the product's category|
| sub_category_name | NVARCHAR(50)| A more detailed classification of the product within the category, such as product type.  |
| maintenance | NVARCHAR(50) | Indicates whether the product requires maintenance (e.g., 'Yes', 'No').     |
| product_cost | INT |  The cost or base price of the product, measured in monetary units.     |
| product_line | NVARCHAR(50) |The specific product line or series to which the product belongs (e.g., Road, Mountain).| 
| product_start_date | DATE |The date when the product became available for sale or use, stored in|

### 3. **gold.fact_sales**
- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | A unique alphanumeric identifier for each sales order (e.g., 'SO54496').                      |
| product_key     | INT           | Surrogate key linking the order to the product dimension table.                               |
| customer_key    | INT           | Surrogate key linking the order to the customer dimension table.                              |
| order_date      | DATE          | The date when the order was placed.                                                           |
| shipping_date   | DATE          | The date when the order was shipped to the customer.                                          |
| due_date        | DATE          | The date when the order payment was due.                                                      |
| sales_amount    | INT           | The total monetary value of the sale for the line item, in whole currency units (e.g., 25).   |
| quantity        | INT           | The number of units of the product ordered for the line item (e.g., 1).                       |
| price           | INT           | The price per unit of the product for the line item, in whole currency units (e.g., 25).      |
