USE northwind;


CREATE VIEW vw_CustomerTotalRevenue AS
SELECT 
    c.company_name AS customer_name, 
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total_revenue
FROM dbo.customers c
JOIN dbo.orders o ON c.customer_id = o.customer_id
JOIN dbo.order_details od ON o.order_id = od.order_id
GROUP BY c.company_name;


CREATE VIEW vw_CustomersWithAtLeast3Orders AS
SELECT 
    c.company_name AS customer_name, 
    COUNT(o.order_id) AS order_count
FROM dbo.customers c
JOIN dbo.orders o ON c.customer_id = o.customer_id
GROUP BY c.company_name
HAVING COUNT(o.order_id) >= 3;


CREATE VIEW vw_CustomerAvgOrderValue AS
SELECT 
    c.company_name AS customer_name, 
    AVG(order_total.order_sum) AS average_amount
FROM dbo.customers c
JOIN dbo.orders o ON c.customer_id = o.customer_id
JOIN (
    SELECT order_id, SUM((unit_price * quantity) * (1 - discount)) AS order_sum
    FROM dbo.order_details
    GROUP BY order_id
) order_total ON o.order_id = order_total.order_id
GROUP BY c.company_name;


CREATE VIEW vw_ProductTotalRevenue AS
SELECT 
    p.product_name, 
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS total_revenue
FROM dbo.products p
JOIN dbo.order_details od ON p.product_id = od.product_id
GROUP BY p.product_name;


CREATE VIEW vw_ProductTotalQuantity AS
SELECT 
    p.product_name, 
    SUM(od.quantity) AS total_quantity_sold
FROM dbo.products p
JOIN dbo.order_details od ON p.product_id = od.product_id
GROUP BY p.product_name;


CREATE VIEW vw_OrdersPerDay AS
SELECT 
    CAST(order_date AS DATE) AS order_date, 
    COUNT(order_id) AS order_count
FROM dbo.orders
GROUP BY CAST(order_date AS DATE);


CREATE VIEW vw_DailySales AS
SELECT 
    CAST(o.order_date AS DATE) AS order_date, 
    SUM((od.unit_price * od.quantity) * (1 - od.discount)) AS daily_sales_amount
FROM dbo.orders o
JOIN dbo.order_details od ON o.order_id = od.order_id
GROUP BY CAST(o.order_date AS DATE);


CREATE VIEW vw_RevenueByShipVia AS
SELECT 
    ship_via AS payment_method, 
    SUM(freight) AS total_collected
FROM dbo.orders
GROUP BY ship_via;


CREATE VIEW vw_DailyPayments AS
SELECT 
    CAST(order_date AS DATE) AS payment_date, 
    SUM(freight) AS total_payment_amount
FROM dbo.orders
GROUP BY CAST(order_date AS DATE);


CREATE VIEW vw_ShipmentSummaryByCarrier AS
SELECT 
    s.company_name AS carrier_name, 
    COUNT(o.order_id) AS shipment_count, 
    MIN(o.shipped_date) AS first_shipping_date, 
    MAX(o.shipped_date) AS last_shipping_date
FROM dbo.shippers s
JOIN dbo.orders o ON s.shipper_id = o.ship_via
GROUP BY s.company_name;


CREATE VIEW vw_OrdersShippingStatus AS
SELECT 
    o.order_id, 
    c.company_name AS customer_name, 
    o.order_date,
    CASE 
        WHEN o.shipped_date IS NOT NULL THEN 'shipped'
        ELSE 'not_shipped'
    END AS shipped_status
FROM dbo.orders o
JOIN dbo.customers c ON o.customer_id = c.customer_id;


CREATE VIEW vw_ProductPriceRankBand AS
SELECT 
    product_name, 
    unit_price AS price,
    CASE 
        WHEN unit_price < 20 THEN 'budget'
        WHEN unit_price BETWEEN 20 AND 50 THEN 'standard'
        ELSE 'premium'
    END AS price_band
FROM dbo.products;
