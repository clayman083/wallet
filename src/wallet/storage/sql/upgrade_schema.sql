-- SET ROLE 'passport';

BEGIN;

CREATE SEQUENCE IF NOT EXISTS accounts_pk START WITH 1;

CREATE TABLE IF NOT EXISTS accounts (
    id INTEGER PRIMARY KEY default nextval('accounts_pk'),
    name VARCHAR(255) NOT NULL,
    user_id INTEGER,
    enabled BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS accounts_name_idx ON accounts (name, enabled, user_id);


CREATE SEQUENCE IF NOT EXISTS balance_pk START WITH 1;

CREATE TABLE IF NOT EXISTS balance (
    id INTEGER PRIMARY KEY default nextval('balance_pk'),
    rest NUMERIC(20, 2) NOT NULL,
    expenses NUMERIC(20, 2) NOT NULL,
    incomes NUMERIC(20, 2) NOT NULL,
    month DATE NOT NULL,
    account_id INTEGER NOT NULL REFERENCES accounts (id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IF NOT EXISTS balance_month_idx ON balance (month, account_id);


CREATE SEQUENCE IF NOT EXISTS tags_pk START WITH 1;

CREATE TABLE IF NOT EXISTS tags (
    id INTEGER PRIMARY KEY default nextval('tags_pk'),
    name VARCHAR(255) NOT NULL,
    user_id INTEGER,
    enabled BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS tags_name_idx ON tags (name, enabled, user_id);


CREATE SEQUENCE IF NOT EXISTS operations_pk START WITH 1;

CREATE TYPE operation_type AS ENUM ('income', 'expense', 'transfer');

CREATE TABLE IF NOT EXISTS operations (
    id INTEGER PRIMARY KEY default nextval('operations_pk'),
    amount NUMERIC(20, 2) NOT NULL,
    type operation_type NOT NULL,
    description VARCHAR(500) NULL,
    account_id INTEGER NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
    enabled BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP WITH TIME ZONE NOT NULL
);


CREATE TABLE IF NOT EXISTS operation_tags (
    operation_id INTEGER REFERENCES operations (id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tags (id) ON DELETE CASCADE,
    CONSTRAINT operation_tags_pk PRIMARY KEY (operation_id, tag_id)
);


CREATE SEQUENCE IF NOT EXISTS operation_details_pk START WITH 1;

CREATE TABLE IF NOT EXISTS operation_details (
    id INTEGER PRIMARY KEY default nextval('operation_details_pk'),
    name VARCHAR(255) NOT NULL,
    price_per_unit NUMERIC(20, 2) CONSTRAINT positive_price_per_unit CHECK (price_per_unit > 0),
    count NUMERIC(10, 3) CONSTRAINT positive_count CHECK (count > 0),
    total NUMERIC(20, 2) CONSTRAINT positive_total CHECK (total > 0),
    enabled BOOLEAN DEFAULT TRUE,
    created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    operation_id INTEGER NOT NULL REFERENCES operations (id)
);

-- CREATE SEQUENCE IF NOT EXISTS categories_pk START WITH 1;

-- CREATE TABLE IF NOT EXISTS categories (
--   id INTEGER PRIMARY KEY default nextval('categories_pk'),
--   name VARCHAR(255) NOT NULL,
--   user_id INTEGER,
--   enabled BOOLEAN DEFAULT TRUE,
--   created_on TIMESTAMP WITHOUT TIME ZONE NOT NULL
-- );

-- CREATE UNIQUE INDEX IF NOT EXISTS categories_name_idx ON categories (name, enabled, user_id);

-- CREATE TABLE IF NOT EXISTS operation_categories (
--   operation_id INTEGER REFERENCES operations (id) ON DELETE CASCADE,
--   category_id INTEGER REFERENCES categories (id) ON DELETE CASCADE,
--   CONSTRAINT operation_categories_pk PRIMARY KEY (operation_id, category_id)
-- );

COMMIT;
