CREATE DATABASE PROJECT_1;
USE PROJECT_1;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_category
		FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE inventory (
    product_id INT PRIMARY KEY REFERENCES products(product_id) ON DELETE CASCADE,
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) CHECK (status IN ('Pending','Shipped','Delivered','Cancelled')),
    total_amount DECIMAL(10,2) CHECK (total_amount >= 0),
    
    CONSTRAINT fk_customer
		FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

CREATE TABLE order_items (
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    payment_method VARCHAR(50),
    amount DECIMAL(10,2) CHECK (amount > 0),
    payment_status VARCHAR(50),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* Sample Data */
INSERT INTO customers (full_name, email, phone) VALUES
('Priya Sharma', 'amit.sharma@gmail.com', '9876543212'),
('Amit Patel', 'priya.patel@gmail.com', '9123456770'),
('Rahul Verma', 'rahul.verma@gmail.com', '9988776655'),
('Sneha Iyer', 'sneha.iyer@gmail.com', '9090909090'),
('Karan Mehta', 'karan.mehta@gmail.com', '8888888888');

INSERT INTO categories (name)
VALUES 
('Electronics'), 
('Clothing'),
('Home Appliances'),
('Books');

INSERT INTO products (name, description, price, category_id) VALUES
('Laptop', 'Gaming Laptop 16GB RAM', 75000.00, 1),
('Smartphone', '5G Android Smartphone', 25000.00, 1),
('T-Shirt', 'Cotton Round Neck T-Shirt', 799.00, 2),
('Jeans', 'Slim Fit Denim Jeans', 1999.00, 2),
('Microwave', '800W Microwave Oven', 8500.00, 3),
('Vacuum Cleaner', 'Bagless Vacuum Cleaner', 12000.00, 3),
('SQL Basics Book', 'Learn SQL from scratch', 599.00, 4),
('Data Structures Book', 'Advanced DSA concepts', 899.00, 4);

INSERT INTO inventory (product_id, stock_quantity) VALUES
(1, 50),
(2, 200),
(3, 100),
(4, 60);

INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES
(1, '2026-03-01 10:15:00', 'Delivered', 100799.00),
(2, '2026-03-02 14:30:00', 'Shipped', 25999.00),
(3, '2026-03-02 16:45:00', 'Pending', 1399.00),
(4, '2026-03-03 11:20:00', 'Delivered', 8500.00),
(5, '2026-03-03 18:00:00', 'Cancelled', 12000.00),
(1, '2026-03-04 09:00:00', 'Delivered', 899.00);

INSERT INTO order_items VALUES
(1, 1, 1, 75000.00),
(1, 2, 1, 25000.00),
(1, 3, 1, 799.00);

INSERT INTO order_items VALUES
(2, 2, 1, 25000.00),
(2, 4, 1, 1999.00);

INSERT INTO order_items VALUES
(3, 3, 1, 799.00),
(3, 7, 1, 599.00);

INSERT INTO order_items VALUES
(4, 5, 1, 8500.00);

INSERT INTO order_items VALUES
(5, 6, 1, 12000.00);

INSERT INTO order_items VALUES
(6, 8, 1, 899.00);

INSERT INTO payments (order_id, payment_method, amount, payment_status) VALUES
(1, 'Credit Card', 100799.00, 'Completed'),
(2, 'UPI', 25999.00, 'Completed'),
(3, 'Debit Card', 1398.00, 'Pending'),
(4, 'Net Banking', 8500.00, 'Completed'),
(5, 'UPI', 12000.00, 'Refunded'),
(6, 'Credit Card', 899.00, 'Completed');

/* JOIN Queries */

-- 1. Customer Oredr History --
SELECT c.full_name, o.order_id, o.order_date, o.total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- 2. Detailed Sales Report --
SELECT 
    o.order_id,
    c.full_name,
    p.name AS product_name,
    oi.quantity,
    oi.price_at_purchase,
    (oi.quantity * oi.price_at_purchase) AS total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- 3. Total Sales Per Product --
SELECT 
    p.name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.price_at_purchase) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.name
ORDER BY total_revenue DESC;

-- 4. VIEW for sales summary --
CREATE VIEW sales_summary AS
SELECT 
    DATE(order_date) AS sale_date,
    SUM(total_amount) AS daily_sales
FROM orders
GROUP BY DATE(order_date);

SELECT * FROM sales_summary;