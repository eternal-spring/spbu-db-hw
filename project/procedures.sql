DROP PROCEDURE IF EXISTS transfer_funds(INT, INT, NUMERIC);
DROP PROCEDURE IF EXISTS accrue_interest(INT);
DROP PROCEDURE IF EXISTS deduct_interest(INT);


-- Перевод денежных средств
CREATE OR REPLACE PROCEDURE transfer_funds(
	account_id_from INT,
	account_id_to INT,
	amount NUMERIC(15, 2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    currency_from TEXT;
    currency_to TEXT;
BEGIN
    SELECT currency_code 
	INTO currency_from
    FROM accounts
    WHERE account_id = account_id_from;

    SELECT currency_code 
	INTO currency_to
    FROM accounts
    WHERE account_id = account_id_to;

	IF currency_from IS NULL THEN
		RAISE EXCEPTION 'Account with id % does not exist', account_id_from;
    END IF;

	IF currency_to IS NULL THEN
		RAISE EXCEPTION 'Account with id % does not exist', account_id_to;
    END IF;

    IF currency_from IS DISTINCT FROM currency_to THEN
        RAISE EXCEPTION 'Currency mismatch: account % has % and account % has %',
        account_id_from, currency_from, account_id_to, currency_to;
    END IF;

	INSERT INTO operations (account_id, operation_type_id, amount)
	VALUES (
		account_id_from, 
		(SELECT operation_type_id FROM operation_types WHERE operation_name = 'Transfer Out'), 
		amount
	), (
		account_id_to, 
		(SELECT operation_type_id FROM operation_types WHERE operation_name = 'Transfer In'), 
		amount
	);
	
END;
$$;


-- Начисление процентов
CREATE OR REPLACE PROCEDURE accrue_interest(
	account_id_to INT
)
LANGUAGE plpgsql
AS $$
DECLARE 
	interest_rate NUMERIC(5, 2);
	interest_amount NUMERIC;
BEGIN
	SELECT percentage INTO interest_rate
	FROM interest_rates ir
	WHERE ir.account_id = account_id_to;

	IF interest_rate IS NULL THEN
        RAISE EXCEPTION 'Account % does not have an associated interest rate', account_id_to;
    END IF;

	SELECT balance * interest_rate / 100 INTO interest_amount
	FROM accounts a
	WHERE a.account_id = account_id_to;

	INSERT INTO operations (account_id, operation_type_id, amount)
	VALUES (
		account_id_to,
		(SELECT operation_type_id FROM operation_types WHERE operation_name = 'Interest Accrual'),
		interest_amount
	);
END;
$$;


-- Вычет процентов
CREATE OR REPLACE PROCEDURE deduct_interest(
	account_id_to INT
)
LANGUAGE plpgsql
AS $$
DECLARE 
	interest_rate NUMERIC(5, 2);
	interest_amount NUMERIC;
BEGIN
	SELECT percentage INTO interest_rate
	FROM interest_rates ir
	WHERE ir.account_id = account_id_to;

	IF interest_rate IS NULL THEN
        RAISE EXCEPTION 'Account % does not have an associated interest rate', account_id_to;
    END IF;

	SELECT balance * interest_rate / 100 INTO interest_amount
	FROM accounts a
	WHERE a.account_id = account_id_to;

	INSERT INTO operations (account_id, operation_type_id, amount)
	VALUES (
		account_id_to,
		(SELECT operation_type_id FROM operation_types WHERE operation_name = 'Interest Deduction'),
		interest_amount
	);
END;
$$;