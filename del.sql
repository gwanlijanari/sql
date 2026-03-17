CREATE OR REPLACE PROCEDURE delete_tables()
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
    
END;
$$;

CREATE OR REPLACE PROCEDURE prc_ClearAllTables()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM orders;
    DELETE FROM supplier_contracts;
    DELETE FROM product_contraindication;
    DELETE FROM product_indication;
    DELETE FROM contraindications;
    DELETE FROM products;
    DELETE FROM indications;
    DELETE FROM clients;
    DELETE FROM employees;
    DELETE FROM suppliers;
END;
$$;