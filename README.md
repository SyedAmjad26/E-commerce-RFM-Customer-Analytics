# E-Commerce Customer Segmentation & RFM Analysis Dashboard

## Project Overview
An end-to-end data analytics project designed to identify high-value customers and predict churn risk using RFM (Recency, Frequency, Monetary) analysis. The architecture spans from raw data ingestion and advanced RFM logic engineered entirely in PostgreSQL, flowing into a dynamic Star Schema data model visualized in Power BI.

## Tech Stack
*   **Database & ELT:** PostgreSQL (pgAdmin), SQL Window Functions, Views
*   **Visualization & Modeling:** Power BI (DAX, Power Query)
*   **Architecture:** Star Schema, Custom UI Themes, Bookmarks

## Data Architecture & Workflow
1.  **Database Creation & ELT (PostgreSQL):**
    *   Imported 1M+ rows of raw transactional data into PostgreSQL.
    *   Handled data type conversions, null values, and exact duplicate removal using `ROW_NUMBER()` partitioning.
    *   Engineered a `cleaned_transactions_view` to serve as the primary Fact table.

2.  **RFM Modeling & Segmentation (PostgreSQL):**
    *   Calculated Recency (days since last purchase), Frequency (distinct invoice count), and Monetary (Quantity * Price) values per customer ID directly in SQL.
    *   Applied `NTILE(4)` quantile scoring logic to assign numerical RFM scores.
    *   Categorized customers into business-defined segments (*Champions, Loyal, At Risk, Needs Attention, New,* and *Lost*) using `CASE WHEN` statements.
    *   Defined a strict Churn flag (`isChurned = TRUE`) for >90 days of inactivity.
    *   Stored this final aggregated logic as `rfm_customer_segments_view`.

3.  **Data Modeling (Power BI):**
    *   Built a rigorous Star Schema connecting the `cleaned_transactions_view` (Fact) to a dedicated `Calendar` table and `rfm_customer_segments_view` (Dimensions) via one-to-many relationships.
    *   Generated custom chronological sorting columns to prevent alphabetical timeline errors.

## Key DAX Measures
DAX was utilized to ensure cross-filtering worked correctly across the relational model, overriding standard static table limitations.

*   **Dynamic Churn Percentage:** 
    Calculates the exact churn rate for any filtered timeframe by isolating churned IDs within the active transactional context.
    ```dax
    Churn Percentage = 
    DIVIDE(
        CALCULATE(
            DISTINCTCOUNT('cleaned_transactions_view'[customerId]), 
            'rfm_customer_segments_view'[isChurned] = TRUE
        ),
        DISTINCTCOUNT('cleaned_transactions_view'[customerId])
    )
    ```
*   **Diverging Retention Logic:**
    Forces lost customer columns below the zero-baseline on column charts by dynamically multiplying by -1 based on the evaluation context.
    ```dax
    Diverging Customers = 
    IF(
        SELECTEDVALUE('rfm_customer_segments_view'[isChurned]) = TRUE(),
        [Total Customers] * -1,
        [Total Customers]
    )
    ```

## Dashboard Features
<img width="1092" height="682" alt="page-1-Revenue" src="https://github.com/user-attachments/assets/75391e30-8565-469d-8a92-8773db6fffe9" />
<img width="1093" height="683" alt="page-1-Customer" src="https://github.com/user-attachments/assets/cbd0fa2d-ddc7-482d-97f4-e2703b4130bc" />
<img width="1097" height="685" alt="page-2-rfm-segment" src="https://github.com/user-attachments/assets/46ae6342-3f2f-4114-94e8-a9a77ad70856" />
<img width="1093" height="685" alt="page-2-rfm-country" src="https://github.com/user-attachments/assets/c74daa88-a33b-4648-985d-adfb8b72377a" />



*   **Bookmark Navigation:** Implemented UI toggles to switch seamlessly between Revenue-focused and Customer-focused analytics on a single page without breaking cross-filtering states.
*   **Diverging Churn Visualization:** Engineered DAX-driven column charts that force "Lost" customer volumes below the zero-baseline, providing immediate visual contrast between retained and churned accounts.
*   **Dynamic Time-Series Filtering:** Integrated hierarchical date slicers (Year, Quarter, Month) to allow stakeholders to interactively drill down into historical churn rates, segment growth, and average customer value.

## How to View
1. Download the `ecommerce_rfm_dashboard.pbix` file from the `dashboard/` directory.
2. Open with Power BI Desktop.
3. Review the backend database architecture and RFM logic in the `sql_scripts/` directory.
