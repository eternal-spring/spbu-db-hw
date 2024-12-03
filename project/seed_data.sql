INSERT INTO currencies (currency_code, currency_name)
VALUES
	('USD', 'US Dollar'),
	('EUR', 'Euro'),
	('RUB', 'Russian Ruble');


INSERT INTO operation_types (operation_name, operation_sign)
VALUES 
    ('Deposit', '+'),            
    ('Withdrawal', '-'),
    ('Transfer In', '+'),
    ('Transfer Out', '-'),
    ('Interest Accrual', '+'),
    ('Interest Deduction', '-');


-- Заполним таблицу клиентов рандомными данными

WITH first_names AS (
    SELECT UNNEST(ARRAY['Alexander', 'Mikhail', 'Dmitry', 'Sergey', 'Ivan', 'Konstantin', 'Stepan', 'Andrey', 'Vladimir', 'Oleg', 'Denis', 'Anton', 'Grigoriy', 'Yuriy', 'Nikolay', 'Vladislav', 'Maxim', 'Daniil', 'Pavel', 'Artyom']) AS first_name
),
last_names AS (
    SELECT UNNEST(ARRAY['Ivanov', 'Petrov', 'Smirnov', 'Kuznetsov', 'Popov', 'Vasiliev', 'Mikhailov', 'Fedorov', 'Nikolaev']) AS last_name
)
INSERT INTO clients (first_name, last_name, phone_number, email, created_at)
SELECT 
    f.first_name,
    l.last_name,
    CONCAT('+7', (900 + FLOOR(RANDOM() * 100))::INT,
        (1000000 + FLOOR(RANDOM() * 9000000))::INT
    ) AS phone_number, -- Все совпадения случайны!
    CONCAT(LOWER(f.first_name), '.', LOWER(l.last_name), '@example.com') AS email,
    NOW() - (FLOOR(RANDOM() * 365) || ' days')::INTERVAL - INTERVAL '2 years' AS created_at 
FROM first_names f
CROSS JOIN last_names l
ORDER BY RANDOM() DESC
LIMIT 200
ON CONFLICT (phone_number) DO NOTHING; -- Скипаем строку, если номер уже существует


INSERT INTO account_types (account_type_name)
VALUES
    ('Savings'),
    ('Credit'),
   	('Current');


WITH random_clients AS (
    SELECT client_id, ROW_NUMBER() OVER (ORDER BY RANDOM()) AS rn
    FROM clients
    LIMIT 300
)
INSERT INTO accounts (client_id, account_type_id, currency_code, balance, opened_at)
SELECT 
    rc.client_id,
    act.account_type_id account_type_id,
    c.currency_code AS currency_code,
    FLOOR(RANDOM() * 10000) AS balance,
    NOW() - (FLOOR(RANDOM() * 365) || ' days')::INTERVAL - INTERVAL '1 year' AS opened_at
FROM random_clients rc
JOIN account_types act ON TRUE
JOIN currencies c ON TRUE
ORDER BY RANDOM() DESC
LIMIT 300
ON CONFLICT (client_id, account_type_id, currency_code) DO NOTHING
RETURNING client_id, account_type_id, currency_code;



WITH random_accounts AS (
    SELECT account_id
    FROM accounts
    ORDER BY RANDOM()
    LIMIT 300
),
random_operation_type AS (
    SELECT operation_type_id
    FROM operation_types
    LIMIT 4
)
INSERT INTO operations (account_id, operation_type_id, amount, currency_code, occured_at)
SELECT 
    ra.account_id,
    rot.operation_type_id,
	FLOOR(RANDOM() * 1000) + 1 AS amount,
	c.currency_code,
    NOW() - (FLOOR(RANDOM() * 90) || ' days')::INTERVAL AS occured_at 
FROM random_accounts ra
JOIN random_operation_type rot ON TRUE
JOIN currencies c ON TRUE
ORDER BY RANDOM() DESC
LIMIT 1000;


WITH valid_accounts AS (
    SELECT account_id
    FROM accounts
    WHERE account_type_id IN (1, 2) -- Только для Savings и Credit
    ORDER BY RANDOM()
    LIMIT 50
)
INSERT INTO interest_rates (account_id, percentage)
SELECT 
    va.account_id,
    RANDOM() * 0.2 AS percentage 
FROM valid_accounts va
JOIN accounts a ON va.account_id = a.account_id;
