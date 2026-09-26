CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE ecommerce_sales (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID INT,
    Country VARCHAR(100),
    Revenue DECIMAL(12,2)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Manasa A/Downloads/ecommerce_sales_cleaned.csv'
INTO TABLE ecommerce_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN CustomerID = 0 THEN 1 ELSE 0 END) AS zero_customer_ids,
    SUM(Revenue) AS total_revenue
FROM ecommerce_sales;

DROP TABLE ecommerce_sales;

CREATE TABLE ecommerce_sales (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID INT NULL,
    Country VARCHAR(100),
    Revenue DECIMAL(15,4)
);

LOAD DATA LOCAL INFILE 'C:/Users/Manasa A/Downloads/ecommerce_sales_cleaned.csv'
INTO TABLE ecommerce_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, @CustomerID, Country, Revenue)
SET CustomerID = NULLIF(@CustomerID, '');
DROP TABLE ecommerce_sales;
USE ecommerce_analytics;

SHOW TABLES;
CREATE TABLE ecommerce_sales (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID INT NULL,
    Country VARCHAR(100),
    Revenue DECIMAL(12,2)
);
LOAD DATA LOCAL INFILE 'C:/Users/Manasa A/Downloads/ecommerce_sales_cleaned.csv'
INTO TABLE ecommerce_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, @CustomerID, Country, @Revenue)
SET
    CustomerID = NULLIF(@CustomerID, ''),
    Revenue = ROUND(@Revenue, 2);
    
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS missing_customer_ids,
    SUM(CASE WHEN CustomerID = 0 THEN 1 ELSE 0 END) AS zero_customer_ids,
    SUM(Revenue) AS total_revenue
FROM ecommerce_sales;

SELECT
    SUM(Revenue) AS total_revenue,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    SUM(Quantity) AS total_units_sold
FROM ecommerce_sales;

SELECT
    ROUND(SUM(Revenue) / COUNT(DISTINCT InvoiceNo), 2) AS average_order_value
FROM ecommerce_sales;

SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
GROUP BY Country
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    Description,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE Description NOT IN ('POSTAGE', 'DOTCOM POSTAGE', 'Manual')
GROUP BY Description
ORDER BY total_revenue DESC
LIMIT 10;
SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS month,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY month;
SELECT
    CustomerID,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_orders DESC
LIMIT 10;
SELECT
    COUNT(DISTINCT CustomerID) AS total_customers
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL;
SELECT
    ROUND(SUM(Revenue) / COUNT(DISTINCT CustomerID), 2) AS avg_revenue_per_customer
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL;
SELECT
    CustomerID,
    DATEDIFF(
        '2011-12-10',
        MAX(InvoiceDate)
    ) AS recency_days
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY recency_days ASC
LIMIT 10;
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS frequency
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY frequency DESC
LIMIT 10;
SELECT
    CustomerID,
    ROUND(SUM(Revenue), 2) AS monetary
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY monetary DESC
LIMIT 10;

SELECT
    CustomerID,
    DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    ROUND(SUM(Revenue), 2) AS monetary
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;

SELECT
    CustomerID,
    DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
    NTILE(5) OVER (
        ORDER BY DATEDIFF('2011-12-10', MAX(InvoiceDate)) ASC
    ) AS r_score
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;

SELECT
    CustomerID,
    DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
    6 - NTILE(5) OVER (
        ORDER BY DATEDIFF('2011-12-10', MAX(InvoiceDate)) ASC
    ) AS r_score
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    NTILE(5) OVER (
        ORDER BY COUNT(DISTINCT InvoiceNo) ASC
    ) AS f_score
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;

SELECT
    CustomerID,
    ROUND(SUM(Revenue), 2) AS monetary,
    NTILE(5) OVER (
        ORDER BY SUM(Revenue) ASC
    ) AS m_score
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;

SELECT
    CustomerID,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_score
FROM (
    SELECT
        CustomerID,
        6 - NTILE(5) OVER (
            ORDER BY DATEDIFF('2011-12-10', MAX(InvoiceDate)) ASC
        ) AS r_score,
        NTILE(5) OVER (
            ORDER BY COUNT(DISTINCT InvoiceNo) ASC
        ) AS f_score,
        NTILE(5) OVER (
            ORDER BY SUM(Revenue) ASC
        ) AS m_score
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS rfm_scores;

SELECT
    CASE
        WHEN rfm_score BETWEEN 13 AND 15 THEN 'Champions'
        WHEN rfm_score BETWEEN 10 AND 12 THEN 'Loyal / Potential Loyalists'
        WHEN rfm_score BETWEEN 7 AND 9 THEN 'Needs Attention'
        WHEN rfm_score BETWEEN 4 AND 6 THEN 'At Risk'
        WHEN rfm_score = 3 THEN 'Lost'
    END AS segment,
    COUNT(*) AS customer_count
FROM (
    SELECT
        CustomerID,
        (
            6 - NTILE(5) OVER (
                ORDER BY DATEDIFF('2011-12-10', MAX(InvoiceDate)) ASC
            )
            + NTILE(5) OVER (
                ORDER BY COUNT(DISTINCT InvoiceNo) ASC
            )
            + NTILE(5) OVER (
                ORDER BY SUM(Revenue) ASC
            )
        ) AS rfm_score
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS rfm_data
GROUP BY segment
ORDER BY customer_count DESC;

WITH customer_rfm AS (
    SELECT
        CustomerID,
        DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        SUM(Revenue) AS monetary
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
ranked AS (
    SELECT
        CustomerID,
        recency,
        frequency,
        monetary,
        ROW_NUMBER() OVER (ORDER BY recency ASC, CustomerID ASC) AS r_rank,
        ROW_NUMBER() OVER (ORDER BY frequency ASC, CustomerID ASC) AS f_rank,
        ROW_NUMBER() OVER (ORDER BY monetary ASC, CustomerID ASC) AS m_rank
    FROM customer_rfm
)
SELECT
    CustomerID,
    recency,
    frequency,
    ROUND(monetary, 2) AS monetary,
    r_rank,
    f_rank,
    m_rank
FROM ranked
LIMIT 10;

SELECT
    CustomerID,
    recency,
    r_rank,
    6 - CEIL(r_rank / 867.6) AS r_score
FROM (
    SELECT
        CustomerID,
        DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
        ROW_NUMBER() OVER (
            ORDER BY DATEDIFF('2011-12-10', MAX(InvoiceDate)) ASC, CustomerID ASC
        ) AS r_rank
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS ranked_r;

SELECT
    CustomerID,
    frequency,
    f_rank,
    CEIL(f_rank / 867.6) AS f_score
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        ROW_NUMBER() OVER (
            ORDER BY COUNT(DISTINCT InvoiceNo) ASC, CustomerID ASC
        ) AS f_rank
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS ranked_f;

SELECT
    CustomerID,
    monetary,
    m_rank,
    CEIL(m_rank / 867.6) AS m_score
FROM (
    SELECT
        CustomerID,
        SUM(Revenue) AS monetary,
        ROW_NUMBER() OVER (
            ORDER BY SUM(Revenue) ASC, CustomerID ASC
        ) AS m_rank
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS ranked_m;

WITH customer_rfm AS (
    SELECT
        CustomerID,
        DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        SUM(Revenue) AS monetary
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
ranked AS (
    SELECT
        CustomerID,
        recency,
        frequency,
        monetary,
        ROW_NUMBER() OVER (ORDER BY recency ASC, CustomerID ASC) AS r_rank,
        ROW_NUMBER() OVER (ORDER BY frequency ASC, CustomerID ASC) AS f_rank,
        ROW_NUMBER() OVER (ORDER BY monetary ASC, CustomerID ASC) AS m_rank
    FROM customer_rfm
)
SELECT
    CustomerID,
    6 - CEIL(r_rank / 867.6) AS r_score,
    CEIL(f_rank / 867.6) AS f_score,
    CEIL(m_rank / 867.6) AS m_score,
    (6 - CEIL(r_rank / 867.6))
        + CEIL(f_rank / 867.6)
        + CEIL(m_rank / 867.6) AS rfm_score
FROM ranked;

WITH customer_rfm AS (
    SELECT
        CustomerID,
        DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        SUM(Revenue) AS monetary
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
ranked AS (
    SELECT
        CustomerID,
        ROW_NUMBER() OVER (ORDER BY recency ASC, CustomerID ASC) AS r_rank,
        ROW_NUMBER() OVER (ORDER BY frequency ASC, CustomerID ASC) AS f_rank,
        ROW_NUMBER() OVER (ORDER BY monetary ASC, CustomerID ASC) AS m_rank
    FROM customer_rfm
),
rfm_scores AS (
    SELECT
        CustomerID,
        6 - CEIL(r_rank / 867.6) AS r_score,
        CEIL(f_rank / 867.6) AS f_score,
        CEIL(m_rank / 867.6) AS m_score
    FROM ranked
)
SELECT
    CASE
        WHEN r_score + f_score + m_score BETWEEN 13 AND 15
            THEN 'Champions'
        WHEN r_score + f_score + m_score BETWEEN 10 AND 12
            THEN 'Loyal / Potential Loyalists'
        WHEN r_score + f_score + m_score BETWEEN 7 AND 9
            THEN 'Needs Attention'
        WHEN r_score + f_score + m_score BETWEEN 4 AND 6
            THEN 'At Risk'
        WHEN r_score + f_score + m_score = 3
            THEN 'Lost'
    END AS segment,
    COUNT(*) AS customer_count
FROM rfm_scores
GROUP BY segment
ORDER BY customer_count DESC;

USE ecommerce_analytics;
WITH customer_rfm AS (
    SELECT
        CustomerID,
        DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        SUM(Revenue) AS monetary
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT
    MIN(recency) AS min_recency,
    MAX(recency) AS max_recency,
    MIN(frequency) AS min_frequency,
    MAX(frequency) AS max_frequency,
    MIN(monetary) AS min_monetary,
    MAX(monetary) AS max_monetary
FROM customer_rfm;

WITH customer_rfm AS (
    SELECT
        CustomerID,
        DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        SUM(Revenue) AS monetary
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),
ranked AS (
    SELECT
        CustomerID,
        recency,
        frequency,
        monetary,
        ROW_NUMBER() OVER (ORDER BY recency ASC, CustomerID ASC) AS r_rank,
        ROW_NUMBER() OVER (ORDER BY frequency ASC, CustomerID ASC) AS f_rank,
        ROW_NUMBER() OVER (ORDER BY monetary ASC, CustomerID ASC) AS m_rank
    FROM customer_rfm
)
SELECT
    r_rank,
    recency,
    f_rank,
    frequency,
    m_rank,
    ROUND(monetary, 2) AS monetary
FROM ranked
WHERE r_rank IN (868, 869, 1735, 1736, 2602, 2603, 3469, 3470)
   OR f_rank IN (868, 869, 1735, 1736, 2602, 2603, 3469, 3470)
   OR m_rank IN (868, 869, 1735, 1736, 2602, 2603, 3469, 3470)
ORDER BY r_rank;


WITH customer_rfm AS (
    SELECT
        CustomerID,
        DATEDIFF('2011-12-10', MAX(InvoiceDate)) AS recency,
        COUNT(DISTINCT InvoiceNo) AS frequency,
        SUM(Revenue) AS monetary
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
),

ranked AS (
    SELECT
        CustomerID,
        recency,
        frequency,
        monetary,

        ROW_NUMBER() OVER (
            ORDER BY recency ASC, CustomerID ASC
        ) AS r_rank,

        ROW_NUMBER() OVER (
            ORDER BY frequency ASC, CustomerID ASC
        ) AS f_rank,

        ROW_NUMBER() OVER (
            ORDER BY monetary ASC, CustomerID ASC
        ) AS m_rank

    FROM customer_rfm
),

scored AS (
    SELECT
        CustomerID,

        CASE
            WHEN r_rank BETWEEN 1 AND 868 THEN 5
            WHEN r_rank BETWEEN 869 AND 1735 THEN 4
            WHEN r_rank BETWEEN 1736 AND 2603 THEN 3
            WHEN r_rank BETWEEN 2604 AND 3470 THEN 2
            ELSE 1
        END AS R_score,

        CASE
            WHEN f_rank BETWEEN 1 AND 868 THEN 1
            WHEN f_rank BETWEEN 869 AND 1735 THEN 2
            WHEN f_rank BETWEEN 1736 AND 2603 THEN 3
            WHEN f_rank BETWEEN 2604 AND 3470 THEN 4
            ELSE 5
        END AS F_score,

        CASE
            WHEN m_rank BETWEEN 1 AND 868 THEN 1
            WHEN m_rank BETWEEN 869 AND 1735 THEN 2
            WHEN m_rank BETWEEN 1736 AND 2603 THEN 3
            WHEN m_rank BETWEEN 2604 AND 3470 THEN 4
            ELSE 5
        END AS M_score

    FROM ranked
),

segmented AS (
    SELECT
        CustomerID,
        R_score,
        F_score,
        M_score,
        R_score + F_score + M_score AS RFM_score,

        CASE
            WHEN R_score + F_score + M_score >= 13
                THEN 'Champions'
            WHEN R_score + F_score + M_score >= 10
                THEN 'Loyal / Potential Loyalists'
            WHEN R_score + F_score + M_score >= 7
                THEN 'Needs Attention'
            WHEN R_score + F_score + M_score >= 4
                THEN 'At Risk'
            ELSE 'Lost'
        END AS segment

    FROM scored
)

SELECT
    segment,
    COUNT(*) AS customer_count
FROM segmented
GROUP BY segment
ORDER BY
    CASE segment
        WHEN 'At Risk' THEN 1
        WHEN 'Needs Attention' THEN 2
        WHEN 'Loyal / Potential Loyalists' THEN 3
        WHEN 'Champions' THEN 4
        WHEN 'Lost' THEN 5
    END;
    
    WITH customer_orders AS (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_type;

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS order_count
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY order_count DESC
LIMIT 10;

SELECT
    CustomerID,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    ROUND(
        COUNT(DISTINCT InvoiceNo) / COUNT(DISTINCT CustomerID),
        2
    ) AS avg_orders_per_customer
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL;

SELECT
    ROUND(SUM(Revenue) / COUNT(DISTINCT CustomerID), 2) AS avg_revenue_per_customer
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL;

SELECT
    Country,
    COUNT(DISTINCT CustomerID) AS customer_count
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY Country
ORDER BY customer_count DESC
LIMIT 10;

SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY Country
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    Country,
    COUNT(DISTINCT CustomerID) AS customer_count,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(SUM(Revenue) / COUNT(DISTINCT CustomerID), 2) AS avg_revenue_per_customer
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY Country
ORDER BY avg_revenue_per_customer DESC
LIMIT 10;

SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS purchase_month,
    COUNT(DISTINCT CustomerID) AS customer_count
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY purchase_month
ORDER BY purchase_month;

SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS purchase_month,
    COUNT(DISTINCT CustomerID) AS customer_count,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE CustomerID IS NOT NULL
GROUP BY purchase_month
ORDER BY purchase_month;

WITH customer_first_purchase AS (
    SELECT
        CustomerID,
        MIN(DATE_FORMAT(InvoiceDate, '%Y-%m')) AS first_purchase_month
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT
    DATE_FORMAT(e.InvoiceDate, '%Y-%m') AS purchase_month,
    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(e.InvoiceDate, '%Y-%m') = c.first_purchase_month
        THEN e.CustomerID
    END) AS new_customers,
    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(e.InvoiceDate, '%Y-%m') > c.first_purchase_month
        THEN e.CustomerID
    END) AS returning_customers
FROM ecommerce_sales e
JOIN customer_first_purchase c
    ON e.CustomerID = c.CustomerID
WHERE e.CustomerID IS NOT NULL
GROUP BY purchase_month
ORDER BY purchase_month;

WITH customer_first_purchase AS (
    SELECT
        CustomerID,
        MIN(DATE_FORMAT(InvoiceDate, '%Y-%m')) AS first_purchase_month
    FROM ecommerce_sales
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT
    DATE_FORMAT(e.InvoiceDate, '%Y-%m') AS purchase_month,
    COUNT(DISTINCT e.CustomerID) AS total_customers,
    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(e.InvoiceDate, '%Y-%m') > c.first_purchase_month
        THEN e.CustomerID
    END) AS returning_customers,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN DATE_FORMAT(e.InvoiceDate, '%Y-%m') > c.first_purchase_month
            THEN e.CustomerID
        END) * 100.0
        / COUNT(DISTINCT e.CustomerID),
        2
    ) AS returning_customer_percentage
FROM ecommerce_sales e
JOIN customer_first_purchase c
    ON e.CustomerID = c.CustomerID
WHERE e.CustomerID IS NOT NULL
GROUP BY purchase_month
ORDER BY purchase_month;