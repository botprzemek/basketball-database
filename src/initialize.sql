DROP DATABASE IF EXISTS basketball;

CREATE DATABASE IF NOT EXISTS basketball;

CREATE USER IF NOT EXISTS basketball WITH PASSWORD NULL;

ALTER DATABASE basketball OWNER TO basketball;

CREATE TYPE basketball.position AS ENUM ('PG', 'SG', 'SF', 'PF', 'C');

CREATE TYPE basketball.main_hand AS ENUM ('LEFT', 'RIGHT', 'AMBIDEXTROUS');

CREATE TABLE IF NOT EXISTS basketball.tenants (
    id           UUID NOT NULL UNIQUE PRIMARY KEY,
    name         STRING NOT NULL UNIQUE,
    display_name STRING DEFAULT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS basketball.groups (
    id           UUID NOT NULL UNIQUE PRIMARY KEY,
    tenant_id    UUID NOT NULL REFERENCES basketball.tenants(id) ON DELETE CASCADE,
    name         STRING NOT NULL UNIQUE,
    display_name STRING DEFAULT NULL,
    description  STRING DEFAULT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS basketball.permissions (
    id         UUID NOT NULL UNIQUE PRIMARY KEY,
    group_id   UUID NOT NULL REFERENCES basketball.groups(id) ON DELETE CASCADE,
    resource   STRING NOT NULL,
    can_read   BOOLEAN DEFAULT TRUE,
    can_write  BOOLEAN DEFAULT FALSE,
    can_update BOOLEAN DEFAULT FALSE,
    can_delete BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS basketball.identities (
    id           UUID NOT NULL UNIQUE PRIMARY KEY,
    first_name   STRING NOT NULL,
    last_name    STRING NOT NULL,
    email        STRING DEFAULT NULL,
    phone        STRING NOT NULL,
    birth_date   DATE NOT NULL,
    pesel_number STRING NOT NULL UNIQUE,
    created_at   TIMESTAMP NOT NULL DEFAULT now(),
    updated_at   TIMESTAMP DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS basketball.users (
    id             UUID NOT NULL UNIQUE PRIMARY KEY,
    identity_id    UUID REFERENCES basketball.identities(id) ON DELETE CASCADE,
    group_id       UUID REFERENCES basketball.groups(id) ON DELETE CASCADE,
    tenant_id      UUID NOT NULL REFERENCES basketball.tenants(id) ON DELETE CASCADE,
    username       STRING NOT NULL UNIQUE,
    recovery_email STRING DEFAULT NULL,
    password       STRING NOT NULL,
    refresh_token  STRING DEFAULT NULL,
    verify_token   STRING DEFAULT NULL,
    logged_at      TIMESTAMP DEFAULT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT now(),
    updated_at     TIMESTAMP DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS basketball.users_groups (
    user_id UUID NOT NULL REFERENCES basketball.users(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES basketball.groups(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS basketball.teams (
    id         UUID NOT NULL UNIQUE PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES basketball.users(id) ON DELETE CASCADE,
    name       STRING NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS basketball.players (
    id          UUID NOT NULL UNIQUE PRIMARY KEY,
    identity_id UUID NOT NULL UNIQUE REFERENCES basketball.identities(id) ON DELETE CASCADE,
    team_id     UUID NOT NULL REFERENCES basketball.teams(id) ON DELETE CASCADE,
    nickname    STRING DEFAULT NULL,
    number      INT NOT NULL,
    position    basketball.position NOT NULL,
    height      DECIMAL(5, 2) DEFAULT NULL,
    weight      DECIMAL(5, 2) DEFAULT NULL,
    wingspan    DECIMAL(5, 2) DEFAULT NULL,
    main_hand   basketball.main_hand DEFAULT 'RIGHT',
    created_at  TIMESTAMP NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP DEFAULT NULL
);

INSERT INTO basketball.tenants (id, name, display_name) VALUES
    ('00000000-0000-0000-0000-000000000001', 'default', 'Default Tenant');

INSERT INTO basketball.groups (id, tenant_id, name, display_name, description) VALUES
    ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'admin', 'Admin Group', 'Administrators of the tenant'),
    ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'guest', 'Guest Group', 'Guest users with limited access');

INSERT INTO basketball.permissions (id, group_id, resource, can_read, can_write, can_update, can_delete) VALUES
    ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002', 'players', true, true, true, true),
    ('00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', 'players', true, false, false, false);

INSERT INTO basketball.identities (id, first_name, last_name, email, phone, birth_date, pesel_number) VALUES
    ('00000000-0000-0000-0000-000000000006', 'Adam', 'Silver', 'adam.silver@example.com', '555-000-0001', '1962-04-25', '12345678901'),
    ('00000000-0000-0000-0000-000000000007', 'Frank', 'Wallace', 'frank.wallace@example.com', '555-000-0002', '1988-07-14', '98765432109');

INSERT INTO basketball.users (id, identity_id, group_id, tenant_id, username, password) VALUES
    ('00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'adam.silver', 'password_hash_1'),
    ('00000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'frank.wallace', 'password_hash_2');

INSERT INTO basketball.teams (id, user_id, name) VALUES
    ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000008', 'Golden State Warriors');

INSERT INTO basketball.identities (id, first_name, last_name, email, phone, birth_date, pesel_number) VALUES
    ('00000000-0000-0000-0000-000000000011', 'Stephen', 'Curry', 'scurry@gsw.com', '555-123-4567', '1988-03-14', '12345678902'),
    ('00000000-0000-0000-0000-000000000012', 'Klay', 'Thompson', 'kthompson@gsw.com', '555-123-4568', '1990-02-08', '12345678903'),
    ('00000000-0000-0000-0000-000000000013', 'Draymond', 'Green', 'dgreen@gsw.com', '555-123-4569', '1990-03-04', '12345678904'),
    ('00000000-0000-0000-0000-000000000014', 'Andrew', 'Wiggins', 'awiggins@gsw.com', '555-123-4570', '1995-02-23', '12345678905'),
    ('00000000-0000-0000-0000-000000000015', 'Kevon', 'Looney', 'klooney@gsw.com', '555-123-4571', '1996-02-06', '12345678906'),
    ('00000000-0000-0000-0000-000000000016', 'Chris', 'Paul', 'cpaul@gsw.com', '555-123-4572', '1985-05-06', '12345678907'),
    ('00000000-0000-0000-0000-000000000017', 'Jonathan', 'Kuminga', 'jkuminga@gsw.com', '555-123-4573', '2002-10-06', '12345678908'),
    ('00000000-0000-0000-0000-000000000018', 'Moses', 'Moody', 'mmoody@gsw.com', '555-123-4574', '2002-05-31', '12345678909'),
    ('00000000-0000-0000-0000-000000000019', 'Gary', 'Payton', 'gpayton@gsw.com', '555-123-4575', '1992-12-01', '12345678910'),
    ('00000000-0000-0000-0000-000000000020', 'Dario', 'Saric', 'dsaric@gsw.com', '555-123-4576', '1994-04-08', '12345678911'),
    ('00000000-0000-0000-0000-000000000021', 'Brandon', 'Podzimski', 'bpodzimski@gsw.com', '555-123-4577', '2003-06-02', '12345678912'),
    ('00000000-0000-0000-0000-000000000022', 'Trayce', 'Jackson-Davis', 'tjackson@gsw.com', '555-123-4578', '2000-02-22', '12345678913');

INSERT INTO basketball.players (id, identity_id, team_id, nickname, number, position, height, weight, wingspan, main_hand) VALUES
    ('00000000-0000-0000-0000-000000000023', '00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000010', 'Chef Curry', 30, 'PG', 1.88, 84, 1.91, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000024', '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000010', 'Klay', 11, 'SG', 1.98, 97, 2.01, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000025', '00000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000010', 'Dray', 23, 'PF', 1.98, 104, 2.14, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000026', '00000000-0000-0000-0000-000000000014', '00000000-0000-0000-0000-000000000010', 'Wiggs', 22, 'SF', 2.01, 91, 2.13, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000027', '00000000-0000-0000-0000-000000000015', '00000000-0000-0000-0000-000000000010', 'Loon', 5, 'C', 2.06, 102, 2.22, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000016', '00000000-0000-0000-0000-000000000010', 'CP3', 3, 'PG', 1.83, 79, 1.90, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000029', '00000000-0000-0000-0000-000000000017', '00000000-0000-0000-0000-000000000010', 'Kuminga', 00, 'SF', 2.03, 102, 2.16, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000030', '00000000-0000-0000-0000-000000000018', '00000000-0000-0000-0000-000000000010', 'Moses', 4, 'SG', 1.96, 93, 2.10, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000031', '00000000-0000-0000-0000-000000000019', '00000000-0000-0000-0000-000000000010', 'GP2', 8, 'SG', 1.91, 88, 2.06, 'LEFT'),
    ('00000000-0000-0000-0000-000000000032', '00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000010', 'Saric', 20, 'PF', 2.08, 102, 2.19, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000033', '00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000010', 'BP', 2, 'SG', 1.93, 91, 2.11, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000034', '00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000010', 'TJD', 32, 'PF', 2.06, 106, 2.13, 'RIGHT');
