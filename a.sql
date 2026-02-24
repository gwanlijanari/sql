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
    CREATE TABLE IF NOT EXISTS indications (
        indication_id SERIAL PRIMARY KEY,
        indication_name VARCHAR(50)
    );

    CREATE TABLE IF NOT EXISTS products (
        article INTEGER PRIMARY KEY,
        name VARCHAR(100),
        supplier VARCHAR(100),
        country VARCHAR(100),
        brand VARCHAR(100),
        price INT
    );

    CREATE TABLE IF NOT EXISTS product_indication (
        indication_id INTEGER REFERENCES indications(indication_id) ON DELETE CASCADE,
        article INTEGER REFERENCES products(article) ON DELETE CASCADE,
        PRIMARY KEY (indication_id, article)
    );

    CREATE TABLE IF NOT EXISTS contraindications (
        contraindication_id SERIAL PRIMARY KEY,
        contraindication_name VARCHAR(50)
    );

    CREATE TABLE IF NOT EXISTS product_contraindication (
        contraindication_id INTEGER REFERENCES contraindications(contraindication_id),
        article INTEGER REFERENCES products(article),
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

    CREATE TABLE IF NOT EXISTS suppliers (
        company_name VARCHAR(50) PRIMARY KEY,
        company_address VARCHAR(50),
        representative_first_name VARCHAR(50),
        representative_last_name VARCHAR(50),
        representative_middle_name VARCHAR(50)
    );

    CREATE TABLE IF NOT EXISTS supplier_contracts (
        contract_number VARCHAR(50) PRIMARY KEY,
        article INTEGER REFERENCES products(article) ON DELETE CASCADE,
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
        article INTEGER REFERENCES products(article) ON DELETE CASCADE
    );
END;
$$;

CREATE OR REPLACE PROCEDURE recreate_tables()
LANGUAGE plpgsql
AS $$
BEGIN
    DROP SCHEMA public CASCADE;
    
    CREATE SCHEMA public;
    
    GRANT ALL ON SCHEMA public TO public;
    GRANT ALL ON SCHEMA public TO postgres;
    
    CALL create_all_tables();
END;
$$;