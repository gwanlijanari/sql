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
    
    DROP TABLE IF EXISTS orders ;
    DROP TABLE IF EXISTS supplier_contracts ;
    DROP TABLE IF EXISTS product_contraindication ;
    DROP TABLE IF EXISTS product_indication ;
    DROP TABLE IF EXISTS contraindications ;
    DROP TABLE IF EXISTS indications ;
    DROP TABLE IF EXISTS suppliers ;
    DROP TABLE IF EXISTS employees ;
    DROP TABLE IF EXISTS clients ;
    DROP TABLE IF EXISTS products ;
    
    CALL create_tables_with_indexes();
END;
$$;
