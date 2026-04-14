--тест 1 Ввод существующего лекарственного средства, с выводом сообщения об ошибке
CREATE OR REPLACE FUNCTION doubleName()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM products WHERE name = NEW.name) THEN
        RAISE EXCEPTION 'Указанное название уже есть в таблице!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_unique_medicine_name
BEFORE INSERT ON products
FOR EACH ROW
EXECUTE FUNCTION doubleName();



--тест 2 Автоматическое формирование номера рецепта

CREATE OR REPLACE FUNCTION IxNumCreate()
RETURNS TRIGGER AS $$
DECLARE
    next_val INT;
    year_part TEXT;
BEGIN
    year_part := to_char(NEW.issue_date, 'YY');

    SELECT count(*) + 1 INTO next_val FROM prescriptions;

    NEW.prescription_number := 'РЦ-ПР/' || year_part || '/' || lpad(next_val::text, 10, '0');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_prescription_number
BEFORE INSERT ON prescriptions
FOR EACH ROW
WHEN (NEW.prescription_number IS NULL)
EXECUTE FUNCTION IxNumCreate();



--тест 3 Удаление существующего медицинского учреждения
CREATE OR REPLACE FUNCTION deletePharmacy()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM doctors WHERE institution_id = OLD.institution_id) THEN
        RAISE EXCEPTION 'Выбранное медицинское учреждение не может быть удалено, т.к. на основании него есть созданные врачи.';
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_delete_institution
BEFORE DELETE ON medical_institutions
FOR EACH ROW
EXECUTE FUNCTION deletePharmacy();



--тест 4 Добавление к аптечному пункту, уже распределённого сотрудника

CREATE OR REPLACE FUNCTION check_employee_exists()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM employee_point 
        WHERE point_id = NEW.point_id AND employee_login = NEW.employee_login
    ) THEN
        RAISE EXCEPTION 'Указанный сотрудник уже есть.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_check_double_employee
BEFORE INSERT ON employee_point
FOR EACH ROW
EXECUTE FUNCTION check_employee_exists();


CREATE OR REPLACE FUNCTION addDoubleEmployee()
RETURNS TEXT AS $$
BEGIN

    DELETE FROM employee_point WHERE point_id = 'АП-001' AND employee_login = 'PetrovPP';

    INSERT INTO employee_point (point_id, employee_login) 
    VALUES ('АП-001', 'PetrovPP') ; 

    INSERT INTO employee_point (point_id, employee_login) 
    VALUES ('АП-001', 'PetrovPP');
    
    RETURN 'второй появился без ошибки';


EXCEPTION WHEN OTHERS THEN
    IF SQLERRM LIKE '%Указанный сотрудник уже есть%' THEN
        RETURN 'Указанный сотрудник уже есть';
    END IF;
END;
$$ LANGUAGE plpgsql;
