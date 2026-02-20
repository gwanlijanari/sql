postgres=# create role rl_client with password '111';
alter role rl_client LOGIN;
grant connect on database "it9_24_1shvartsim" to rl_client;
ERROR:  role "rl_client" already exists
ALTER ROLE
GRANT

postgres=# create role rl_pharmacist with password '222';
alter role rl_pharmacist LOGIN;
grant connect on database "it9_24_1shvartsim" to rl_pharmacist;
CREATE ROLE
ALTER ROLE
GRANT

postgres=# create role rl_supplier with password '333';
alter role rl_supplier LOGIN;
grant connect on database "it9_24_1shvartsim" to rl_supplier;
CREATE ROLE
ALTER ROLE
GRANT

postgres=# create role rl_admin with password '123';
alter role rl_admin LOGIN;
grant connect on database "it9_24_1shvartsim" to rl_admin;
CREATE ROLE
ALTER ROLE
GRANT

CREATE TABLE indications (
    indication_id SERIAL PRIMARY KEY,
    indication_name VARCHAR(50)
);

CREATE TABLE products (
    article INTEGER PRIMARY KEY,
    name VARCHAR(100),
    supplier VARCHAR(100),
    country VARCHAR(100),
    brand VARCHAR(100),
    price INT
);

CREATE TABLE product_indication (
    indication_id INTEGER REFERENCES indications(indication_id) ON DELETE CASCADE,
    article INTEGER REFERENCES products(article) ON DELETE CASCADE,
    PRIMARY KEY (indication_id, article)
);

CREATE TABLE contraindications (
    contraindication_id SERIAL PRIMARY KEY,
    contraindication_name VARCHAR(50)
);

CREATE TABLE product_contraindication (
    contraindication_id INTEGER REFERENCES contraindications(contraindication_id),
    article INTEGER REFERENCES products(article),
    PRIMARY KEY (contraindication_id, article)
);

CREATE TABLE clients (
    phone_number VARCHAR(50) PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    middle_name VARCHAR(50),
    login VARCHAR(50),
    password VARCHAR(50),
    passport_number INT,
    passport_series INT
);

CREATE TABLE employees (
    login VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    password VARCHAR(50) NOT NULL
);

CREATE TABLE suppliers (
    company_name VARCHAR(50) PRIMARY KEY,
    company_address VARCHAR(50),
    representative_first_name VARCHAR(50),
    representative_last_name VARCHAR(50),
    representative_middle_name VARCHAR(50)
);

it9_24_1shvartsim=# CREATE TABLE supplier_contracts (
    contract_number VARCHAR(50) PRIMARY KEY,
    article INTEGER REFERENCES products(article) ON DELETE CASCADE,
    estimate_number VARCHAR(50),
    representative_last_name VARCHAR(50),
    representative_first_name VARCHAR(50),
    representative_middle_name VARCHAR(50),
    company_address VARCHAR(50),
    company_name VARCHAR(50) REFERENCES suppliers(company_name) ON DELETE CASCADE
);

CREATE TABLE orders (
    order_number VARCHAR(50) PRIMARY KEY,
    client_phone VARCHAR(50) REFERENCES clients(phone_number) ON DELETE CASCADE,
    employee_login VARCHAR(50) REFERENCES employees(login) ON DELETE SET NULL,
    article INTEGER REFERENCES products(article) ON DELETE CASCADE
);