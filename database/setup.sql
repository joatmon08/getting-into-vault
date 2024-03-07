set time zone 'UTC';
create extension pgcrypto;

CREATE TABLE products (
    id VARCHAR(255) PRIMARY KEY NOT NULL,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL
);

INSERT INTO products (id, name, description) VALUES ('2310d6be-0e80-11ed-861d-0242ac120002', 'Vault', 'Secrets management');
INSERT INTO products (id, name, description) VALUES ('b3bdc008-be8d-4e52-bd0e-73053b397322', 'Boundary', 'Modern privileged access management');
INSERT INTO products (id, name, description) VALUES ('ed7d5231-55cd-4691-920d-34a8004bcb9f', 'Terraform', 'Infrastructure as code');