-- Создание таблицы сотрудников employees
-- Эта таблица хранит данные о сотрудниках:
-- идентификатор,
-- имя,
-- должность,
-- отдел,
-- зарплату и идентификатор руководителя.


CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);

-- Пример данных
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

--SELECT * FROM employees LIMIT 5;

CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

-- Пример данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 1, 20, '2024-10-15'),
    (2, 2, 15, '2024-10-16'),
    (3, 1, 10, '2024-10-17'),
    (3, 3, 5, '2024-10-20'),
    (4, 2, 8, '2024-10-21'),
    (2, 1, 12, '2024-11-01');

--SELECT * FROM sales LIMIT 5;


CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- Пример данных
INSERT INTO products (name, price)
VALUES
    ('Product A', 150.00),
    ('Product B', 200.00),
    ('Product C', 100.00);


--SELECT * FROM products LIMIT 3;


-- Временная таблица
CREATE TEMP TABLE sales_temp AS
SELECT * FROM sales;

--SELECT * from sales_temp LIMIT 3;

DROP TABLE sales_temp;

-- Задание 1. Придумайте временную таблицу с использованием группировки данных

-- Продажи товаров за последний месяц
CREATE TEMP TABLE current_month_sales AS
SELECT product_id, SUM(quantity) AS total_sales
FROM sales
WHERE date_part('month', sale_date) = date_part('month', CURRENT_DATE)
GROUP BY product_id;

-- Проверим данные
--SELECT * FROM current_month_sales LIMIT 5;

DROP TABLE current_month_sales;


-- Views
CREATE VIEW sales_view AS
SELECT * FROM sales;

DROP VIEW sales_view;

-- Common Table Expressions
-- CTE для иерархического запроса сотрудников
-- Запрос для отображения иерархии сотрудников: менеджер и его подчиненные.
--WITH employee_hierarchy AS (
--    SELECT e1.name AS manager, e2.name AS employee
--    FROM employees e1
--    JOIN employees e2 ON e1.employee_id = e2.manager_id
--)
--SELECT * FROM employee_hierarchy LIMIT 5;

-- DROP TABLE employee_hierarchy;


-- Задание 2: CTE для вычисления средней зарплаты по отделам

-- Решение 1
--WITH department_avg_salary AS (
--    SELECT department, AVG(salary) AS avg_salary
--    FROM employees
--    GROUP BY department
--)
--SELECT * FROM department_avg_salary;


-- ИНДЕКСЫ
--EXPLAIN ANALYZE
--SELECT * FROM employees WHERE department = 'Sales';

-- Индекс для ускорения запросов по полю department
-- Индекс поможет быстрее выполнять запросы, которые фильтруют по отделам.
--CREATE INDEX idx_department ON employees(department);

-- Пример запроса с использованием индекса
--EXPLAIN ANALYZE
--SELECT * FROM employees WHERE department = 'Sales';

-- Удаление индекса
--DROP INDEX idx_department;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

--EXPLAIN ANALYZE
--SELECT * FROM employees WHERE department = 'Sales';

-- Индекс для ускорения запросов по полю department
-- Индекс поможет быстрее выполнять запросы, которые фильтруют по отделам.
--CREATE INDEX idx_department ON employees(department);

-- Пример запроса с использованием индекса
--EXPLAIN ANALYZE
--SELECT * FROM employees WHERE department = 'Sales';

-- Удаление индекса
--DROP INDEX idx_department;



-- Трассировка запросов
--EXPLAIN ANALYZE
--SELECT product_id, SUM(quantity) AS total_sales
--FROM sales
--WHERE date_part('month', sale_date) = date_part('month', CURRENT_DATE)
--GROUP BY product_id
--ORDER BY total_sales DESC
--LIMIT 5;


-- Задание 3:
-- Индекс для sales по полю sale_date
-- Сделать запрос продаж за выбранный период

--DROP INDEX IF EXISTS idx_sale_date;
--
--CREATE INDEX idx_sale_date ON sales(sale_date);
--
---- Пример запроса для проверки индекса
--SELECT * FROM sales WHERE sale_date BETWEEN '2024-11-01' AND '2024-11-30' LIMIT 5;
--

-- Домашнее задание  №3

-- Создайте временную таблицу high_sales_products, которая будет содержать продукты, проданные в количестве более 10 единиц за последние 7 дней.
-- Выведите данные из таблицы high_sales_products.
DROP TABLE IF EXISTS high_sales_products;

CREATE TEMP TABLE high_sales_products AS
SELECT p.product_id, p.name AS product_name, SUM(s.quantity) AS total_quantity_sold
FROM products p JOIN sales s ON p.product_id = s.product_id 
WHERE s.sale_date >= CURRENT_DATE - INTERVAL '7 days' 
GROUP BY p.product_id
HAVING SUM(s.quantity) > 10;

SELECT * FROM high_sales_products LIMIT 5;

-- Создайте CTE employee_sales_stats, который посчитает общее количество продаж и среднее количество продаж для каждого сотрудника за последние 30 дней.
-- Напишите запрос, который выводит сотрудников с количеством продаж выше среднего по компании.
WITH employee_sales_stats AS (
	SELECT e.employee_id, e.name, SUM(s.quantity) AS total_quantity_sold, AVG(s.quantity) AS avg_quantity_sold
	FROM employees e JOIN sales s ON e.employee_id = s.employee_id
	WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
	GROUP BY e.employee_id, e.name
)
SELECT * FROM employee_sales_stats WHERE total_quantity_sold >= (SELECT AVG(total_quantity_sold)
    FROM employee_sales_stats) LIMIT 5;

-- Используя CTE, создайте иерархическую структуру, показывающую всех сотрудников, которые подчиняются конкретному менеджеру.
WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, name, position, manager_id, 1 AS level
    FROM employees
    WHERE employee_id = 1

    UNION ALL

    SELECT e.employee_id, e.name, e.position, e.manager_id, eh.level + 1 AS level
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy ORDER BY level, employee_id LIMIT 10;

-- Напишите запрос с CTE, который выведет топ-3 продукта по количеству продаж за текущий месяц и за прошлый месяц. В результатах должно быть указано, к какому месяцу относится каждая запись.
WITH monthly_sales AS (
    SELECT p.product_id, p.name, TO_CHAR(DATE_TRUNC('month', s.sale_date), 'Month') AS month, SUM(s.quantity) AS total_quantity
    FROM products p JOIN sales s ON p.product_id = s.product_id
    WHERE s.sale_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
    GROUP BY p.product_id, DATE_TRUNC('month', sale_date)
),
top_products AS (
    SELECT name, month, total_quantity, RANK() OVER (PARTITION BY month ORDER BY total_quantity DESC) AS rank
    FROM monthly_sales
)
SELECT rank, name, month, total_quantity
FROM top_products
WHERE rank <= 3
ORDER BY month, total_quantity DESC LIMIT 6;

-- Создайте индекс для таблицы sales по полю employee_id и sale_date, чтобы ускорить запросы, которые фильтруют данные по сотрудникам и датам.
DROP INDEX IF EXISTS idx_employee_id_sale_date;

CREATE INDEX idx_employee_id_sale_date ON sales(employee_id, sale_date);

-- Проверьте, как наличие индекса влияет на производительность следующего запроса, используя EXPLAIN ANALYZE.

-- Используя EXPLAIN, проанализируйте запрос, который находит общее количество проданных единиц каждого продукта.
EXPLAIN ANALYZE
SELECT product_id, SUM(quantity)
FROM sales
GROUP BY product_id
LIMIT 5;
    
--Индекс не используется, потому что он не содержит поля product_id, и запрос не содержит фильтрацию по employee_id и sale_date