-- Домашнее задание
-- 1. Создать триггеры со всеми возможными ключевыми словами, а также рассмотреть операционные триггеры
CREATE OR REPLACE FUNCTION check_department()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.department NOT IN ('Sales', 'IT') THEN
        RAISE EXCEPTION 'Несуществующий отдел: %', NEW.department;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_department
BEFORE INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION check_department();

CREATE OR REPLACE FUNCTION log_bulk_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Массовое удаление из employees';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_bulk_delete
BEFORE DELETE ON employees
FOR EACH STATEMENT
EXECUTE FUNCTION log_bulk_delete();

ALTER TABLE sales
DROP CONSTRAINT sales_employee_id_fkey;


ALTER TABLE sales
ADD CONSTRAINT sales_employee_id_fkey
FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
ON DELETE SET NULL ON UPDATE CASCADE;

DELETE FROM employees WHERE department = 'Sales';

CREATE VIEW view_employees AS
SELECT employee_id, name, position, department
FROM employees;

CREATE OR REPLACE FUNCTION insert_into_employees()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employees (name, position, department, salary)
    VALUES (NEW.name, NEW.position, NEW.department, 100000);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_insert_into_view
INSTEAD OF INSERT ON view_employees
FOR EACH ROW
EXECUTE FUNCTION insert_into_employees();

INSERT INTO view_employees (name, position, department)
VALUES ('Alice Smith', 'Data Scientist', 'IT');

SELECT * FROM employees WHERE name = 'Alice Smith';

-- 2. Попрактиковаться в созданиях транзакций (привести пример успешной и фейл транзакции, объяснить в комментариях почему она зафейлилась)
-- Успешная транзакция
INSERT INTO employees (name, position, department, salary)
VALUES ('Donald Trump', 'Manager', 'Sales', 80000);

-- Несуществующий отдел
INSERT INTO employees (name, position, department, salary)
VALUES ('Kamala Harris', 'Manager', 'Marketing', 80000);

-- 3. Использовать RAISE для логирования
CREATE OR REPLACE FUNCTION log_update_events()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Изменение записи: % -> %', OLD.name, NEW.name;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_updates
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_update_events();

UPDATE employees
SET name = 'Boris Johnson'
WHERE employee_id = 1;
