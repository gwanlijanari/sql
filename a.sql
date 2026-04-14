create role rl_client with password '111';
alter role rl_client LOGIN;
grant connect on database "it9_24_1shvartsim" to rl_client;


create role rl_pharmacist with password '222';
alter role rl_pharmacist LOGIN;
grant connect on database "it9_24_1shvartsim" to rl_pharmacist;
CREATE ROLE
ALTER ROLE
GRANT

create role rl_supplier with password '333';
alter role rl_supplier LOGIN;
grant connect on database "it9_24_1shvartsim" to rl_supplier;
CREATE ROLE
ALTER ROLE
GRANT

create role rl_admin with password '123';
alter role rl_admin LOGIN;
grant connect on database "it9_24_1shvartsim" to rl_admin;
CREATE ROLE
ALTER ROLE
GRANT
CREATE OR REPLACE PROCEDURE create_tables()
LANGUAGE plpgsql
AS $$
BEGIN

    CREATE TABLE IF NOT EXISTS pharmacy_points (
        point_id VARCHAR(20) PRIMARY KEY, 
    );


    CREATE TABLE IF NOT EXISTS medical_institutions (
        institution_id SERIAL PRIMARY KEY,
        name VARCHAR(255) UNIQUE NOT NULL
    );

    CREATE TABLE IF NOT EXISTS doctor_profiles (
        profile_id SERIAL PRIMARY KEY,
        profile_name VARCHAR(100) UNIQUE NOT NULL
    );

    CREATE TABLE IF NOT EXISTS doctors (
        doctor_id SERIAL PRIMARY KEY,
        last_name VARCHAR(50) NOT NULL,
        first_name VARCHAR(50) NOT NULL,
        middle_name VARCHAR(50) DEFAULT 'Нет данных',
        profile_id INTEGER REFERENCES doctor_profiles(profile_id),
        institution_id INTEGER REFERENCES medical_institutions(institution_id)
    );

    CREATE TABLE IF NOT EXISTS indications (
        indication_id SERIAL PRIMARY KEY,
        indication_name VARCHAR(50)
    );


CREATE TABLE IF NOT EXISTS products (
    article VARCHAR(20) PRIMARY KEY,  
    name VARCHAR(100) UNIQUE,
    supplier VARCHAR(100),
    country VARCHAR(100),
    brand VARCHAR(100),
    price INT,
    is_prescription BOOLEAN DEFAULT FALSE 
);

    CREATE TABLE IF NOT EXISTS product_indication (
        indication_id INTEGER REFERENCES indications(indication_id) ON DELETE CASCADE,
        article VARCHAR(20) REFERENCES products(article) ON DELETE CASCADE,  
        PRIMARY KEY (indication_id, article)
    );

    CREATE TABLE IF NOT EXISTS contraindications (
        contraindication_id SERIAL PRIMARY KEY,
        contraindication_name VARCHAR(50)
    );

    CREATE TABLE IF NOT EXISTS product_contraindication (
        contraindication_id INTEGER REFERENCES contraindications(contraindication_id),
        article VARCHAR(20) REFERENCES products(article), 
        PRIMARY KEY (contraindication_id, article)
    );


    CREATE TABLE IF NOT EXISTS clients (
        phone_number VARCHAR(50) PRIMARY KEY,
        last_name VARCHAR(50),
        first_name VARCHAR(50),
        middle_name VARCHAR(50),
        login VARCHAR(50),
        password VARCHAR(50),
        passport_number INT,
        passport_series INT
    );

    CREATE TABLE IF NOT EXISTS employees (
        login VARCHAR(50) PRIMARY KEY,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        middle_name VARCHAR(50),
        password VARCHAR(50) NOT NULL
    );

    CREATE TABLE IF NOT EXISTS employee_point (
    point_id VARCHAR(20) REFERENCES pharmacy_points(point_id),
    employee_login VARCHAR(50) REFERENCES employees(login),
    PRIMARY KEY (point_id, employee_login)
    );


    CREATE TABLE IF NOT EXISTS suppliers (
        company_name VARCHAR(50) PRIMARY KEY,
        company_address VARCHAR(50),
        representative_first_name VARCHAR(50),
        representative_last_name VARCHAR(50),
        representative_middle_name VARCHAR(50)
    );


    CREATE TABLE IF NOT EXISTS supplier_contracts (
        contract_number VARCHAR(50) PRIMARY KEY,
        article VARCHAR(20) REFERENCES products(article) ON DELETE CASCADE, 
        estimate_number VARCHAR(50),
        representative_last_name VARCHAR(50),
        representative_first_name VARCHAR(50),
        representative_middle_name VARCHAR(50),
        company_address VARCHAR(50),
        company_name VARCHAR(50) REFERENCES suppliers(company_name) ON DELETE CASCADE
    );


    CREATE TABLE IF NOT EXISTS orders (
        order_number VARCHAR(50) PRIMARY KEY,
        client_phone VARCHAR(50) REFERENCES clients(phone_number) ON DELETE CASCADE,
        employee_login VARCHAR(50) REFERENCES employees(login) ON DELETE SET NULL,
        article VARCHAR(20) REFERENCES products(article) ON DELETE CASCADE 
    );

    CREATE TABLE IF NOT EXISTS prescriptions (
        prescription_number VARCHAR(25) PRIMARY KEY, 
        client_phone VARCHAR(50) REFERENCES clients(phone_number),
        doctor_id INTEGER REFERENCES doctors(doctor_id),
        issue_date DATE NOT NULL,
        validity_period_months INT CHECK (validity_period_months > 0) 
    );

    CREATE TABLE IF NOT EXISTS prescription_items (
        prescription_number VARCHAR(25) REFERENCES prescriptions(prescription_number),
        article VARCHAR(20) REFERENCES products(article),
        dosage VARCHAR(100),
        daily_dose VARCHAR(100),
        PRIMARY KEY (prescription_number, article)
    );


    CREATE TABLE IF NOT EXISTS prescription_sales (
        sale_id SERIAL PRIMARY KEY,
        prescription_number VARCHAR(25) REFERENCES prescriptions(prescription_number),
        article VARCHAR(20) REFERENCES products(article),
        sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );


    CREATE INDEX IF NOT EXISTS idx_product_indication_indication_id ON product_indication(indication_id);
    CREATE INDEX IF NOT EXISTS idx_product_indication_article ON product_indication(article);
    
    CREATE INDEX IF NOT EXISTS idx_product_contraindication_contraindication_id ON product_contraindication(contraindication_id);
    CREATE INDEX IF NOT EXISTS idx_product_contraindication_article ON product_contraindication(article);
    
    CREATE INDEX IF NOT EXISTS idx_supplier_contracts_article ON supplier_contracts(article);
    CREATE INDEX IF NOT EXISTS idx_supplier_contracts_company_name ON supplier_contracts(company_name);
    
    CREATE INDEX IF NOT EXISTS idx_orders_client_phone ON orders(client_phone);
    CREATE INDEX IF NOT EXISTS idx_orders_employee_login ON orders(employee_login);
    CREATE INDEX IF NOT EXISTS idx_orders_article ON orders(article);
    
    CREATE INDEX IF NOT EXISTS idx_clients_login ON clients(login);
    CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);

END;
$$;

CREATE OR REPLACE PROCEDURE recreate_tables()
LANGUAGE plpgsql
AS $$
BEGIN
    DROP INDEX IF EXISTS idx_orders_client_phone;
    DROP INDEX IF EXISTS idx_orders_employee_login;
    DROP INDEX IF EXISTS idx_orders_article;
    DROP INDEX IF EXISTS idx_supplier_contracts_article;
    DROP INDEX IF EXISTS idx_supplier_contracts_company_name;
    DROP INDEX IF EXISTS idx_product_contraindication_contraindication_id;
    DROP INDEX IF EXISTS idx_product_contraindication_article;
    DROP INDEX IF EXISTS idx_product_indication_indication_id;
    DROP INDEX IF EXISTS idx_product_indication_article;
    DROP INDEX IF EXISTS idx_clients_login;
    DROP INDEX IF EXISTS idx_products_name;
    
    ALTER TABLE IF EXISTS orders 
        DROP CONSTRAINT IF EXISTS orders_client_phone_fkey,
        DROP CONSTRAINT IF EXISTS orders_employee_login_fkey,
        DROP CONSTRAINT IF EXISTS orders_article_fkey;
    
    ALTER TABLE IF EXISTS supplier_contracts 
        DROP CONSTRAINT IF EXISTS supplier_contracts_article_fkey,
        DROP CONSTRAINT IF EXISTS supplier_contracts_company_name_fkey;
    
    ALTER TABLE IF EXISTS product_contraindication 
        DROP CONSTRAINT IF EXISTS product_contraindication_contraindication_id_fkey,
        DROP CONSTRAINT IF EXISTS product_contraindication_article_fkey;
    
    ALTER TABLE IF EXISTS product_indication 
        DROP CONSTRAINT IF EXISTS product_indication_indication_id_fkey,
        DROP CONSTRAINT IF EXISTS product_indication_article_fkey;
    
    DROP TABLE IF EXISTS orders CASCADE;
    DROP TABLE IF EXISTS supplier_contracts CASCADE;
    DROP TABLE IF EXISTS product_contraindication CASCADE;
    DROP TABLE IF EXISTS product_indication CASCADE;
    DROP TABLE IF EXISTS contraindications CASCADE;
    DROP TABLE IF EXISTS indications CASCADE;
    DROP TABLE IF EXISTS suppliers CASCADE;
    DROP TABLE IF EXISTS employees CASCADE;
    DROP TABLE IF EXISTS clients CASCADE;
    DROP TABLE IF EXISTS products CASCADE;
    


    DROP TABLE IF EXISTS prescription_sales CASCADE;
    DROP TABLE IF EXISTS prescription_items CASCADE;
    DROP TABLE IF EXISTS prescriptions CASCADE;
    DROP TABLE IF EXISTS doctors CASCADE;
    DROP TABLE IF EXISTS doctor_profiles CASCADE;
    DROP TABLE IF EXISTS medical_institutions CASCADE;

    CALL create_tables();  
END;
$$;

CREATE OR REPLACE PROCEDURE prc_LoadSampleData ()
LANGUAGE plpgsql
AS $$
BEGIN



INSERT INTO suppliers (company_name, company_address, representative_first_name, representative_last_name, representative_middle_name) VALUES
('Формацевт Помощь', 'г. Москва, ул. Серпуховская д.15, стр. 1', 'Игорь', 'Семёнов', 'Аркадьевич'),
('Аптека - доставка', 'г. Москва, ул. Арбатская, д. 83, стр.3', 'Сергей', 'Николаев', 'Валерьевич');

INSERT INTO indications (indication_name) VALUES 
('Острая или тянущая боль в областях локтей'),
('Пульсирующая боль в височной области'),
('Кашель, сонливость, выделения из носовой полости'),
('Растяжения, ушибы, подтёки'),
('Заложенность носа, покраснения конечностей и глаз'),
('Отёк конечностей'),
('Тянущая и ноющая боль в сгибах конечностей');

INSERT INTO products (article, name, supplier, country, brand, price) VALUES
('ЛП-0000001', 'Авапасипам', 'Формацевт Помощь', 'Россия', 'Препарат+', 150),
('ЛП-0000002', 'Фротувазол', 'Аптека - доставка', 'Турция', 'Фармакология', 1200),
('ЛП-0000003', 'Валокардолин', 'Формацевт Помощь', 'Россия', 'Нужная помощь', 250),
('ЛП-0000004', 'Редрогедоран', 'Формацевт Помощь', 'Россия', 'Фармакология', 950),
('ЛП-0000005', 'Рамеростам', 'Аптека - доставка', 'Россия', 'Препарат+', 541),
('ЛП-0000006', 'Картитозанол', 'Аптека - доставка', 'Россия', 'Фармакология', 470),
('ЛП-0000007', 'Флютозипам', 'Аптека - доставка', 'Белоруссия', 'Фармакология', 140);

INSERT INTO product_indication (indication_id, article) VALUES
(1, 'ЛП-0000001'), 
(2, 'ЛП-0000002'), 
(3, 'ЛП-0000003'),
(4, 'ЛП-0000004'), 
(5, 'ЛП-0000005'), 
(6, 'ЛП-0000006'), 
(7, 'ЛП-0000007'); 

INSERT INTO contraindications (contraindication_name) VALUES 
('Аллергия на витамин С'), ('Непереносимость гамма элементов'), ('Сердечная слабость'),
('Почечная недостаточность'), ('Расстройство желудка'), ('Непереносимость глюкозы'), ('Аллергия на травы');

INSERT INTO product_contraindication (contraindication_id, article) VALUES
(1, 'ЛП-0000001'),
(2, 'ЛП-0000002'),
(3, 'ЛП-0000003'), 
(4, 'ЛП-0000004'),
(5, 'ЛП-0000005'),
(6, 'ЛП-0000006'),
(7, 'ЛП-0000007'); 

INSERT INTO clients (phone_number, last_name, first_name, middle_name, login, password, passport_number, passport_series) VALUES
('+7(943)733-82-16', 'Алексеев', 'Максим', 'Анатольевич', 'AlekseevMA', 'Paw0rd', 723547, 4632),
('+7(983)772-15-11', 'Иванова', 'Ирина', 'Дмитриевна', 'IvanovaID', 'Paw0rd', 885247, 4611),
('+7(992)528-14-83', 'Владимиров', 'Андрей', 'Кириллович', 'VladimirovAK', 'Paw0rd', 787136, 4366),
('+7(924)662-72-12', 'Георгиев', 'Владимир', 'Валерьевич', 'GeorgievVV', 'Paw0rd', 992217, 4577);

INSERT INTO employees (login, first_name, last_name, middle_name, password) VALUES
('IvanovII', 'Иван', 'Иванов', 'Иванович', 'Paw0rd'),
('PetrovPP', 'Пётр', 'Петров', 'Петрович', 'Paw0rd'),
('DmitrievDD', 'Дмитрий', 'Дмитриев', 'Дмитриевич', 'Paw0rd');

INSERT INTO supplier_contracts (contract_number, article, estimate_number, representative_last_name, representative_first_name, representative_middle_name, company_address, company_name) VALUES
('ДП-00000001-23/25', 'ЛП-0000001', 'СнП-000000001/23', 'Семёнов', 'Игорь', 'Аркадьевич', 'г. Москва, ул. Серпуховская д.15, стр. 1', 'Формацевт Помощь'),
('ДП-00000001-23/25', 'ЛП-0000003', 'СнП-000000001/23', 'Семёнов', 'Игорь', 'Аркадьевич', 'г. Москва, ул. Серпуховская д.15, стр. 1', 'Формацевт Помощь'),
('ДП-00000001-23/25', 'ЛП-0000004', 'СнП-000000002/23', 'Семёнов', 'Игорь', 'Аркадьевич', 'г. Москва, ул. Серпуховская д.15, стр. 1', 'Формацевт Помощь'),
('ДП-00000002-23/26', 'ЛП-0000002', 'СнП-000000003/23', 'Николаев', 'Сергей', 'Валерьевич', 'г. Москва, ул. Арбатская, д. 83, стр.3', 'Аптека - доставка'),
('ДП-00000002-23/26', 'ЛП-0000005', 'СнП-000000003/23', 'Николаев', 'Сергей', 'Валерьевич', 'г. Москва, ул. Арбатская, д. 83, стр.3', 'Аптека - доставка'),
('ДП-00000002-23/26', 'ЛП-0000006', 'СнП-000000003/23', 'Николаев', 'Сергей', 'Валерьевич', 'г. Москва, ул. Арбатская, д. 83, стр.3', 'Аптека - доставка'),
('ДП-00000002-23/26', 'ЛП-0000007', 'СнП-000000003/23', 'Николаев', 'Сергей', 'Валерьевич', 'г. Москва, ул. Арбатская, д. 83, стр.3', 'Аптека - доставка');

INSERT INTO orders (order_number, client_phone, employee_login, article) VALUES
('ЗК000000001', '+7(943)733-82-16', 'IvanovII', 'ЛП-0000002'),
('ЗК000000002', '+7(983)772-15-11', 'IvanovII', 'ЛП-0000001'),
('ЗК000000003', '+7(924)662-72-12', 'PetrovPP', 'ЛП-0000001'),
('ЗК000000004', '+7(992)528-14-83', 'DmitrievDD', 'ЛП-0000005'),
('ЗК000000005', '+7(983)772-15-11', 'DmitrievDD', 'ЛП-0000006');

INSERT INTO medical_institutions (name) VALUES 
('ГКБ № 10'), 
('ГКБ № 31')  ;

INSERT INTO doctor_profiles (profile_name) VALUES 
('Терапевт'), 
('Травматолог')  ;

INSERT INTO doctors (last_name, first_name, middle_name, profile_id, institution_id) VALUES
('Петров', 'Роман', 'Дмитриевич', 1, 1),
('Георгиев', 'Олег', 'Владимирович', 2, 2)  ;

INSERT INTO products (article, name, is_prescription) VALUES
('ЛП-0000001', 'Препарат 1', FALSE),
('ЛП-0000002', 'Фротувазол', TRUE),
('ЛП-0000003', 'Препарат 3', FALSE),
('ЛП-0000004', 'Картитозанол', TRUE),
('ЛП-0000005', 'Препарат 5', FALSE),
('ЛП-0000006', 'Флютиозипам', TRUE),
('ЛП-0000007', 'Препарат 7', TRUE)  ;

INSERT INTO clients (phone_number, last_name, first_name, middle_name) VALUES
('89001112233', 'Алексеев', 'М.', 'А.'),
('89004445566', 'Иванова', 'И.', 'Д.')  ;

INSERT INTO prescriptions (prescription_number, client_phone, doctor_id, issue_date, validity_period_months) VALUES
('РЦ-ПР/23/0000000001', '89001112233', 1, '2023-07-08', 6),
('РЦ-ПР/23/0000000002', '89004445566', 2, '2023-09-10', 12),
('РЦ-ПР/23/0000000003', '89004445566', 2, '2023-08-20', 1)  ;

INSERT INTO prescription_items (prescription_number, article, dosage, daily_dose) VALUES
('РЦ-ПР/23/0000000001', 'ЛП-0000002', '30 т, 5 мг', '3 р/д, по 1 т'),
('РЦ-ПР/23/0000000002', 'ЛП-0000002', '60 т, 5 мг', '2 р/д по 2 т'),
('РЦ-ПР/23/0000000003', 'ЛП-0000004', '200 мл', '3 р/д мазать'),
('РЦ-ПР/23/0000000003', 'ЛП-0000006', '100 мл', 'Мазать утром и вечером');

INSERT INTO prescription_sales (prescription_number, article, sale_date) VALUES
('РЦ-ПР/23/0000000001', 'ЛП-0000002', '2023-07-09'),
('РЦ-ПР/23/0000000001', 'ЛП-0000002', '2023-08-10'),
('РЦ-ПР/23/0000000001', 'ЛП-0000002', '2023-09-11'),
('РЦ-ПР/23/0000000001', 'ЛП-0000002', '2023-10-09'),
('РЦ-ПР/23/0000000002', 'ЛП-0000002', '2023-09-12'),
('РЦ-ПР/23/0000000002', 'ЛП-0000002', '2023-10-16'),
('РЦ-ПР/23/0000000003', 'ЛП-0000004', '2023-08-15'),
('РЦ-ПР/23/0000000003', 'ЛП-0000004', '2023-09-17'),
('РЦ-ПР/23/0000000003', 'ЛП-0000006', '2023-08-17'),
('РЦ-ПР/23/0000000003', 'ЛП-0000006', '2023-09-19');

INSERT INTO pharmacy_points (point_id) VALUES
('АП-001'),
('АП-002');

END;
$$;

SELECT 
    o.order_number AS "Номер заказа",
    c.last_name || ' ' || c.first_name AS "ФИО Клиента",
    p.name AS "Лекарство",
    p.price AS "Цена",
    s.company_name AS "Поставщик",
    i.indication_name AS "Показание"
FROM orders o
JOIN clients c ON o.client_phone = c.phone_number
JOIN products p ON o.article = p.article
JOIN suppliers s ON p.supplier = s.company_name
JOIN product_indication pi ON p.article = pi.article
JOIN indications i ON pi.indication_id = i.indication_id  
ORDER BY o.order_number;
