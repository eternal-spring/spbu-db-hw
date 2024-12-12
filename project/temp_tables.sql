DROP TABLE IF EXISTS top_clients;
DROP TABLE IF EXISTS biggest_ruble_deposits_last_month;


-- Топ клиентов по балансу на долларовых счетах
CREATE TEMP TABLE IF NOT EXISTS top_clients AS
SELECT c.client_id, c.first_name, c.last_name, SUM(a.balance) AS total_balance
FROM clients c 
JOIN accounts a ON c.client_id = a.client_id
WHERE a.currency_code = 'USD'
GROUP BY c.client_id
ORDER BY total_balance DESC
LIMIT 10;

SELECT * FROM top_clients;


-- Самые крупные пополнения рублёвых счетов за последний месяц
CREATE TEMP TABLE IF NOT EXISTS biggest_ruble_deposits_last_month AS
SELECT o.operation_id, a.account_id, c.client_id, CONCAT(c.first_name, ' ', c.last_name) client_name, o.amount, o.occured_at
FROM operations o 
JOIN operation_types ot ON o.operation_type_id = ot.operation_type_id
JOIN accounts a ON o.account_id = a.account_id
JOIN clients c ON a.client_id = c.client_id
WHERE ot.operation_name = 'Deposit' AND o.occured_at >= NOW() - INTERVAL '1 month' AND o.currency_code = 'RUB'
ORDER BY o.amount DESC 
LIMIT 10;

SELECT * FROM biggest_ruble_deposits_last_month;

