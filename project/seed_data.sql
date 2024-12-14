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
),
full_names AS (
    SELECT
        (SELECT first_name FROM first_names ORDER BY RANDOM() + GENERATE_SERIES LIMIT 1) AS first_name,
        (SELECT last_name FROM last_names ORDER BY RANDOM() + GENERATE_SERIES LIMIT 1) AS last_name
    FROM GENERATE_SERIES(1, 2000)
    ORDER BY RANDOM() + GENERATE_SERIES
)
INSERT INTO clients (first_name, last_name, phone_number, email, created_at)
SELECT * FROM 
(
	SELECT DISTINCT ON (email)
	    f.first_name,
	    f.last_name,
	    CONCAT('+7', (900 + FLOOR(RANDOM() * 100))::INT,
	        (1000000 + FLOOR(RANDOM() * 9000000))::INT
	    ) AS phone_number, -- Все совпадения случайны!
	    CONCAT(LOWER(f.first_name), '.', LOWER(f.last_name), (FLOOR(RANDOM() * 100))::INT, '@example.com') AS email,
	    NOW() - (FLOOR(RANDOM() * 365) || ' days')::INTERVAL - INTERVAL '2 years' AS created_at 
	FROM full_names f
	LIMIT 200
)
ORDER BY RANDOM()
ON CONFLICT (phone_number) DO NOTHING; -- Скипаем строку, если номер уже существует


INSERT INTO account_types (account_type_name)
VALUES
    ('Savings'),
    ('Credit'),
   	('Current');


WITH random_clients AS (
    SELECT client_id
    FROM clients
    ORDER BY RANDOM()
    LIMIT 200
)
INSERT INTO accounts (client_id, account_type_id, currency_code, balance, opened_at)
SELECT * FROM (
	SELECT 
	    rc.client_id,
	    act.account_type_id account_type_id,
	    c.currency_code AS currency_code,
	    FLOOR(RANDOM() * 10000)::NUMERIC(15, 2) AS balance,
	    NOW() - (FLOOR(RANDOM() * 365) || ' days')::INTERVAL - INTERVAL '1 year' AS opened_at
	FROM random_clients rc
	JOIN account_types act ON TRUE
	JOIN currencies c ON TRUE
)
ORDER BY RANDOM()
LIMIT 500
ON CONFLICT (client_id, account_type_id, currency_code) DO NOTHING
RETURNING client_id, account_type_id, currency_code;


WITH random_accounts AS (
    (SELECT (SELECT account_id FROM accounts ORDER BY RANDOM() + GENERATE_SERIES LIMIT 1)
    FROM GENERATE_SERIES(1, 1000))
),
random_operation_type AS (
    SELECT operation_type_id
    FROM operation_types
    LIMIT 4
)
INSERT INTO operations (account_id, operation_type_id, amount, occurred_at)
SELECT * FROM (
	SELECT 
	    ra.account_id,
	    rot.operation_type_id,
		(FLOOR(RANDOM() * 10000) + 1)::NUMERIC(15, 2) AS amount,
		NOW() - (FLOOR(RANDOM() * 90) || ' days')::INTERVAL AS occurred_at 
	FROM random_accounts ra
	JOIN random_operation_type rot ON TRUE
)
ORDER BY RANDOM()
LIMIT 5000;


WITH valid_accounts AS (
    SELECT account_id
    FROM accounts
    WHERE account_type_id IN (1, 2) -- Только для Savings и Credit
    ORDER BY RANDOM()
    LIMIT 150
)
INSERT INTO interest_rates (account_id, percentage)
SELECT 
    va.account_id,
    RANDOM() * 20 AS percentage 
FROM valid_accounts va
JOIN accounts a ON va.account_id = a.account_id;
