-- Количество операций по каждому счету
SELECT account_id, COUNT(*) AS operation_count
FROM operations
GROUP BY account_id
LIMIT 20;


-- Средняя процентная ставка по клиентам
SELECT AVG(percentage) AS avg_interest_rate FROM interest_rates;


-- Суммарный баланс всех счетов в банке по валютам
SELECT SUM(a.balance) AS total_balance, c.currency_code
FROM accounts a
JOIN currencies c ON a.currency_code = c.currency_code 
GROUP BY c.currency_code
LIMIT 3;


-- Клиенты с максимальным балансом по валютам
SELECT c.client_id, c.last_name, c.first_name, a.balance, cur.currency_name
FROM accounts a
JOIN clients c ON a.client_id = c.client_id
JOIN currencies cur ON a.currency_code = cur.currency_code
WHERE a.balance = (
    SELECT MAX(a2.balance)
    FROM accounts a2
    WHERE a2.currency_code = a.currency_code
)
LIMIT 3;


-- Баланс клиентов, у которых больше одного счета
SELECT c.client_id, c.last_name, c.first_name, SUM(a.balance) AS total_balance, a.currency_code
FROM clients c
JOIN accounts a ON c.client_id = a.client_id
GROUP BY c.client_id, a.currency_code
HAVING COUNT(a.account_id) > 1
ORDER BY c.client_id ASC
LIMIT 20;


-- Ранжирование клиентов по суммарному балансу на долларовых счетах
SELECT c.client_id, c.last_name, c.first_name, SUM(a.balance) AS total_balance, a.currency_code,
       RANK() OVER (ORDER BY SUM(a.balance) DESC) AS rank
FROM clients c
JOIN accounts a ON c.client_id = a.client_id
WHERE a.currency_code = 'USD'
GROUP BY c.client_id, a.currency_code 
LIMIT 20;