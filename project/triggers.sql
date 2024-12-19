DROP TRIGGER IF EXISTS trigger_update_account_balance ON operations;
DROP TRIGGER IF EXISTS trigger_restrict_negative_balance ON accounts;
DROP TRIGGER IF EXISTS trigger_validate_operation_account_type ON operations;
DROP TRIGGER IF EXISTS trigger_check_account_exists ON operations;
DROP TRIGGER IF EXISTS trigger_log_new_operation ON operations;


-- При совершении операции обновляется баланс на счёте
CREATE OR REPLACE FUNCTION update_account_balance()
RETURNS TRIGGER AS $$
DECLARE 
	current_operation_sign CHAR(1);
BEGIN 
	SELECT operation_sign
	INTO current_operation_sign
	FROM operation_types
	WHERE operation_type_id = NEW.operation_type_id;

	UPDATE accounts a
		SET balance = CASE 
			WHEN current_operation_sign = '+' THEN balance + NEW.amount
			ELSE balance - NEW.amount
		END
		WHERE a.account_id = NEW.account_id;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_account_balance
BEFORE INSERT ON operations
FOR EACH ROW 
EXECUTE FUNCTION update_account_balance();


-- Отрицательный баланс - только для кредитных счетов
CREATE OR REPLACE FUNCTION restrict_negative_balance()
RETURNS TRIGGER AS $$
BEGIN 
	IF NEW.balance < 0 AND 
		(SELECT account_type_name FROM account_types WHERE account_type_id = NEW.account_type_id) != 'Credit' 
		THEN RAISE EXCEPTION 'Insufficient funds in account %', NEW.account_id;
    END IF;

   	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_restrict_negative_balance
BEFORE INSERT OR UPDATE ON accounts
FOR EACH ROW 
EXECUTE FUNCTION restrict_negative_balance();


-- Начисление процентов только для накопительных счетов, списание - только для кредитных
CREATE OR REPLACE FUNCTION validate_operation_account_type()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.operation_type_id = (SELECT operation_type_id FROM operation_types WHERE operation_name = 'Interest Accrual')
       AND NEW.account_id NOT IN (
           SELECT account_id FROM accounts WHERE account_type_id = (SELECT account_type_id FROM account_types WHERE account_type_name = 'Savings')
       ) THEN
        RAISE EXCEPTION 'Interest Accrual operations can only be applied to Savings accounts';
    END IF;

    IF NEW.operation_type_id = (SELECT operation_type_id FROM operation_types WHERE operation_name = 'Interest Deduction')
       AND NEW.account_id NOT IN (
           SELECT account_id FROM accounts WHERE account_type_id = (SELECT account_type_id FROM account_types WHERE account_type_name = 'Credit')
       ) THEN
        RAISE EXCEPTION 'Interest Deduction operations can only be applied to Credit accounts';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_operation_account_type
BEFORE INSERT ON operations
FOR EACH ROW
EXECUTE FUNCTION validate_operation_account_type();


-- Запрет операций для несуществующих счетов
CREATE OR REPLACE FUNCTION check_account_exists()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT * FROM accounts WHERE account_id = NEW.account_id) THEN
        RAISE EXCEPTION 'Account with id % does not exist', NEW.account_id;
    END IF;

    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_account_exists
BEFORE INSERT ON operations
FOR EACH ROW
EXECUTE FUNCTION check_account_exists();


-- Логирование операций
CREATE OR REPLACE FUNCTION log_new_operation()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'New operation logged: Account ID: %, Type ID: %, Amount: %, Occurred At: %',
        NEW.account_id, 
        NEW.operation_type_id, 
        NEW.amount, 
        NEW.occurred_at;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_new_operation
AFTER INSERT ON operations
FOR EACH ROW
EXECUTE FUNCTION log_new_operation();