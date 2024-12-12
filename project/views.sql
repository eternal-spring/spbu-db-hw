DROP VIEW IF EXISTS clients_info;
DROP MATERIALIZED VIEW IF EXISTS clients_currency_operations_count;


--Количество счетов клиента и тотальный баланс для каждой валюты
CREATE OR REPLACE VIEW clients_info AS 
SELECT c.client_id, c.first_name, c.last_name, COUNT(a.account_id) total_accounts, 
	COALESCE((SUM(a.balance) FILTER (WHERE a.currency_code = 'USD'))::VARCHAR(10), '-') AS total_dollar_balance,
    COALESCE((SUM(a.balance) FILTER (WHERE a.currency_code = 'EUR'))::VARCHAR(10), '-') AS total_euro_balance,
    COALESCE((SUM(a.balance) FILTER (WHERE a.currency_code = 'RUB'))::VARCHAR(10), '-') AS total_ruble_balance
FROM clients c 
LEFT JOIN accounts a ON c.client_id = a.client_id
GROUP BY c.client_id
ORDER BY c.client_id ASC;

SELECT * FROM clients_info LIMIT 5;


--Ранжирование клиентов по числу операций в каждой валюте
CREATE MATERIALIZED VIEW IF NOT EXISTS clients_currency_operations_count AS
SELECT c.client_id, COUNT(o.operation_id) AS total_operations, o.currency_code,
	ROW_NUMBER() OVER (PARTITION BY o.currency_code ORDER BY COUNT(o.operation_id) DESC) AS rank
FROM clients c 
JOIN accounts a ON c.client_id = a.client_id 
JOIN operations o ON a.account_id = o.account_id 
GROUP BY c.client_id, o.currency_code
ORDER BY rank, o.currency_code ASC;

SELECT * FROM clients_currency_operations_count LIMIT 15;