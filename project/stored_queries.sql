DROP FUNCTION IF EXISTS client_report(INT);
DROP FUNCTION IF EXISTS account_last_operations_report(INT);


-- Все аккаунты клиента с балансом
CREATE OR REPLACE FUNCTION client_report(id INT)
RETURNS TABLE (
    account_id INT,
    account_type_name VARCHAR(50),
    currency_name VARCHAR(20),
    balance NUMERIC(15, 2),
    last_operation TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.account_id, act.account_type_name, cur.currency_name, a.balance,
       (SELECT MAX(o.occured_at)
        FROM operations o
        WHERE o.account_id = a.account_id)
    FROM accounts a
	JOIN account_types act ON a.account_type_id = act.account_type_id
    JOIN currencies cur ON a.currency_code = cur.currency_code
    WHERE a.client_id = id
	LIMIT 10;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM client_report(1);


-- Последние операции над счетом
CREATE OR REPLACE FUNCTION account_last_operations_report(id INT)
RETURNS TABLE (
	operation_id BIGINT,
	operation_name VARCHAR(50),
	amount NUMERIC(15, 2),
	occured_at TIMESTAMP
) AS $$
BEGIN 
	RETURN QUERY
	SELECT o.operation_id, ot.operation_name, o.amount, o.occured_at
	FROM operations o
	JOIN operation_types ot ON o.operation_type_id = ot.operation_type_id
	WHERE o.account_id = id
	ORDER BY occured_at DESC 
	LIMIT 10;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM account_last_operations_report(1)
