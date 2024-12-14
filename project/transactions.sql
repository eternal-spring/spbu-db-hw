SELECT * FROM accounts a 
WHERE currency_code = 'RUB' AND balance >= 1000 
ORDER BY account_id ASC 
LIMIT 2;

--|account_id|client_id|account_type_id|currency_code|balance|opened_at              |
--|----------|---------|---------------|-------------|-------|-----------------------|
--|4         |149      |1              |RUB          |11 594 |2023-01-24 17:46:52.244|
--|7         |175      |2              |RUB          |7 850  |2023-04-21 17:46:52.244|


BEGIN;

DO $$
DECLARE
	account_id_from INT;
	account_id_to INT;
BEGIN
	SELECT account_id 
	INTO account_id_from
    FROM accounts
    WHERE currency_code = 'RUB' AND balance >= 1000
	ORDER BY account_id ASC 
	LIMIT 1 OFFSET 0;

    SELECT account_id 
	INTO account_id_to
    FROM accounts
    WHERE currency_code = 'RUB' AND balance >= 1000
	ORDER BY account_id ASC 
	LIMIT 1 OFFSET 1;

    CALL transfer_funds(account_id_from, account_id_to, 1000);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- New operation logged: Account ID: 4, Type ID: 4, Amount: 1000.00, Occurred At: 2024-12-14 19:08:23.359633
-- New operation logged: Account ID: 7, Type ID: 3, Amount: 1000.00, Occurred At: 2024-12-14 19:08:23.359633

SELECT * FROM accounts a 
WHERE currency_code = 'RUB' AND balance >= 1000 
ORDER BY account_id ASC 
LIMIT 2;

--|account_id|client_id|account_type_id|currency_code|balance|opened_at              |
--|----------|---------|---------------|-------------|-------|-----------------------|
--|4         |149      |1              |RUB          |10 594 |2023-01-24 17:46:52.244|
--|7         |175      |2              |RUB          |8 850  |2023-04-21 17:46:52.244|

ROLLBACK;

SELECT * FROM accounts a 
WHERE currency_code = 'RUB' AND balance >= 1000 
ORDER BY account_id ASC 
LIMIT 2;

--|account_id|client_id|account_type_id|currency_code|balance|opened_at              |
--|----------|---------|---------------|-------------|-------|-----------------------|
--|4         |149      |1              |RUB          |11 594 |2023-01-24 17:46:52.244|
--|7         |175      |2              |RUB          |7 850  |2023-04-21 17:46:52.244|


BEGIN;

DO $$
DECLARE
	account_id_from INT;
	account_id_to INT;
BEGIN
	SELECT account_id 
	INTO account_id_from
    FROM accounts
    WHERE currency_code = 'RUB' AND balance < 1000
	ORDER BY account_id ASC 
	LIMIT 1 OFFSET 0;

    SELECT account_id 
	INTO account_id_to
    FROM accounts
    WHERE currency_code = 'RUB' AND balance < 1000
	ORDER BY account_id ASC 
	LIMIT 1 OFFSET 1;

    CALL transfer_funds(account_id_from, account_id_to, 1000);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- Transaction failed: Insufficient funds in account 2

COMMIT;


BEGIN;

DO $$
DECLARE
	account_id_from INT;
	account_id_to INT;
BEGIN
	SELECT account_id 
	INTO account_id_from
    FROM accounts
    WHERE currency_code = 'RUB' AND balance < 1000 AND account_type_id = 2 -- Credit
	ORDER BY account_id ASC 
	LIMIT 1;

    SELECT account_id 
	INTO account_id_to
    FROM accounts
    WHERE currency_code = 'RUB' AND balance > 1000
	ORDER BY account_id ASC 
	LIMIT 1;

    CALL transfer_funds(account_id_from, account_id_to, 1000);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- New operation logged: Account ID: 152, Type ID: 4, Amount: 1000.00, Occurred At: 2024-12-14 19:08:23.576428
-- New operation logged: Account ID: 4, Type ID: 3, Amount: 1000.00, Occurred At: 2024-12-14 19:08:23.576428

COMMIT;


BEGIN;

DO $$
DECLARE
	account_id_from INT;
	account_id_to INT;
BEGIN
	SELECT account_id 
	INTO account_id_from
    FROM accounts
    WHERE currency_code = 'EUR' AND balance > 1000
	ORDER BY account_id ASC 
	LIMIT 1;

    SELECT account_id 
	INTO account_id_to
    FROM accounts
    WHERE currency_code = 'RUB' AND balance > 1000
	ORDER BY account_id ASC 
	LIMIT 1;

    CALL transfer_funds(account_id_from, account_id_to, 1000);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- Transaction failed: Currency mismatch: account 8 has EUR and account 4 has RUB

COMMIT;


BEGIN;

DO $$
BEGIN
    CALL transfer_funds(100000, 1, 1000);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- Transaction failed: Account with id 100000 does not exist

COMMIT;


BEGIN;

DO $$
DECLARE
	account_id_to INT;
BEGIN
	SELECT a.account_id 
	INTO account_id_to
    FROM accounts a
	JOIN interest_rates ir ON a.account_id = ir.account_id
    WHERE account_type_id = 1 -- Savings
	ORDER BY a.account_id ASC 
	LIMIT 1;

    CALL accrue_interest(account_id_to);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- New operation logged: Account ID: 2, Type ID: 5, Amount: 7.95, Occurred At: 2024-12-14 19:08:23.579199

COMMIT;


BEGIN;

DO $$
DECLARE
	account_id_to INT;
BEGIN
	SELECT account_id 
	INTO account_id_to
    FROM accounts
    WHERE account_type_id = 3 -- Current
	ORDER BY account_id ASC 
	LIMIT 1;

    CALL accrue_interest(account_id_to);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- Transaction failed: Account 3 does not have an associated interest rate

COMMIT;


BEGIN;

DO $$
DECLARE
	account_id_to INT;
BEGIN
	SELECT a.account_id 
	INTO account_id_to
    FROM accounts a
	JOIN interest_rates ir ON a.account_id = ir.account_id
    WHERE account_type_id = 2 -- Credit
	ORDER BY a.account_id ASC 
	LIMIT 1;

    CALL accrue_interest(account_id_to);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- Transaction failed: Interest Accrual operations can only be applied to Savings accounts

COMMIT;


BEGIN;

DO $$
DECLARE
	account_id_to INT;
BEGIN
	SELECT a.account_id 
	INTO account_id_to
    FROM accounts a
	JOIN interest_rates ir ON a.account_id = ir.account_id
    WHERE account_type_id = 2 -- Credit
	ORDER BY a.account_id ASC 
	LIMIT 1;

    CALL deduct_interest(account_id_to);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- New operation logged: Account ID: 11, Type ID: 6, Amount: 20.93, Occurred At: 2024-12-14 19:08:23.582145

COMMIT;


BEGIN;

DO $$
DECLARE
	account_id_to INT;
BEGIN
	SELECT a.account_id 
	INTO account_id_to
    FROM accounts a
	WHERE account_type_id = 3 -- Current
	ORDER BY a.account_id ASC 
	LIMIT 1;

    CALL deduct_interest(account_id_to);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- Transaction failed: Account 3 does not have an associated interest rate

COMMIT;


BEGIN;

DO $$
DECLARE
	account_id_to INT;
BEGIN
	SELECT a.account_id 
	INTO account_id_to
    FROM accounts a
	JOIN interest_rates ir ON a.account_id = ir.account_id
    WHERE account_type_id = 1 -- Savings
	ORDER BY a.account_id ASC 
	LIMIT 1;

    CALL deduct_interest(account_id_to);
	EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Transaction failed: %', SQLERRM;
END;
$$;

-- Transaction failed: Interest Deduction operations can only be applied to Credit accounts

COMMIT;


SELECT * FROM operations ORDER BY operation_id DESC LIMIT 5;

--|operation_id|account_id|operation_type_id|amount|occurred_at            |
--|------------|----------|-----------------|------|-----------------------|
--|4 056       |11        |6                |20,93 |2024-12-14 19:08:23.582|
--|4 054       |2         |5                |7,95  |2024-12-14 19:08:23.579|
--|4 053       |4         |3                |1 000 |2024-12-14 19:08:23.576|
--|4 052       |152       |4                |1 000 |2024-12-14 19:08:23.576|
--|4 047       |11        |6                |22,16 |2024-12-14 19:03:33.290|

-- Последние 4 операции соответствуют подтверждённым транзакциям