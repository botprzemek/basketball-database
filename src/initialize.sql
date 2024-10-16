DROP DATABASE IF EXISTS basketball;

CREATE DATABASE IF NOT EXISTS basketball;

CREATE TYPE basketball.position AS ENUM ('PG', 'SG', 'SF', 'PF', 'C');

CREATE TYPE basketball.main_hand AS ENUM ('LEFT', 'RIGHT', 'AMBIDEXTROUS');

CREATE TABLE IF NOT EXISTS basketball.tenants (
    id         UUID NOT NULL UNIQUE PRIMARY KEY,
    name       VARCHAR(63) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS basketball.identities (
    id            UUID NOT NULL UNIQUE PRIMARY KEY,
    first_name    VARCHAR(63) NOT NULL,
    last_name     VARCHAR(63) NOT NULL,
    email         VARCHAR(127) DEFAULT NULL,
    phone         VARCHAR(10) DEFAULT NULL,
    birth_date    DATE DEFAULT NULL,
    social_number VARCHAR(63) DEFAULT NULL UNIQUE,
    created_at    TIMESTAMP NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS basketball.users (
    id                 UUID NOT NULL UNIQUE PRIMARY KEY,
    identity_id        UUID NOT NULL UNIQUE REFERENCES basketball.identities(id) ON DELETE CASCADE,
    tenant_id          UUID NOT NULL REFERENCES basketball.tenants(id) ON DELETE CASCADE,
    username           VARCHAR(63) NOT NULL UNIQUE,
    recovery_email     VARCHAR(127) DEFAULT NULL,
    password           VARCHAR(255) NOT NULL,
    refresh_token      VARCHAR(255) DEFAULT NULL,
    verification_token VARCHAR(255) NOT NULL,
    logged_at          TIMESTAMP DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS basketball.teams (
    id         UUID NOT NULL UNIQUE PRIMARY KEY,
    user_id    UUID NOT NULL REFERENCES basketball.users(id) ON DELETE CASCADE,
    name       VARCHAR(63) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP DEFAULT NULL,
    INDEX (user_id)
);

CREATE TABLE IF NOT EXISTS basketball.players (
    id          UUID NOT NULL UNIQUE PRIMARY KEY,
    identity_id UUID NOT NULL UNIQUE REFERENCES basketball.identities(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES basketball.users(id) ON DELETE CASCADE,
    team_id     UUID NOT NULL REFERENCES basketball.teams(id) ON DELETE CASCADE,
    nickname    VARCHAR(63) DEFAULT NULL,
    number      INT NOT NULL CHECK (number BETWEEN 0 AND 99),
    position    basketball.position NOT NULL,
    height      DECIMAL(5, 2) DEFAULT NULL,
    weight      DECIMAL(5, 2) DEFAULT NULL,
    wingspan    DECIMAL(5, 2) DEFAULT NULL,
    main_hand   basketball.main_hand NOT NULL DEFAULT 'RIGHT',
    INDEX (identity_id, user_id, team_id)
);

INSERT INTO basketball.tenants (id, name) VALUES
    ('00000000-0000-0000-0000-000000000001', 'nba');

INSERT INTO basketball.identities (id, first_name, last_name, email, phone, birth_date, social_number) VALUES
    ('00000000-0000-0000-0000-000000000002', 'Adam', 'Silver', 'adam.silver@nba.com', '5550000001', '1962-04-25', '12345678901'),
    ('00000000-0000-0000-0000-000000000003', 'Frank', 'Wallace', 'frank.wallace@nba.com', '5550000002', '1988-07-14', '12345678902');

INSERT INTO basketball.users (id, identity_id, tenant_id, username, password, verification_token) VALUES
    ('00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'adam.silver', 'password_hash_1', 'verification-token-1'),
    ('00000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'frank.wallace', 'password_hash_2', 'verification-token-2');

INSERT INTO basketball.teams (id, user_id, name) VALUES
    ('00000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000004', 'Golden State Warriors');

INSERT INTO basketball.identities (id, first_name, last_name, email, phone, birth_date, social_number) VALUES
    ('00000000-0000-0000-0000-000000000007', 'Stephen', 'Curry', 'scurry@gsw.com', '5551234567', '1988-03-14', '12345678903'),
    ('00000000-0000-0000-0000-000000000008', 'Klay', 'Thompson', 'kthompson@gsw.com', '5551234568', '1990-02-08', '12345678904'),
    ('00000000-0000-0000-0000-000000000009', 'Draymond', 'Green', 'dgreen@gsw.com', '5551234569', '1990-03-04', '12345678905'),
    ('00000000-0000-0000-0000-000000000010', 'Andrew', 'Wiggins', 'awiggins@gsw.com', '5551234570', '1995-02-23', '12345678906'),
    ('00000000-0000-0000-0000-000000000011', 'Kevon', 'Looney', 'klooney@gsw.com', '5551234571', '1996-02-06', '12345678907'),
    ('00000000-0000-0000-0000-000000000012', 'Chris', 'Paul', 'cpaul@gsw.com', '5551234572', '1985-05-06', '12345678908'),
    ('00000000-0000-0000-0000-000000000013', 'Jonathan', 'Kuminga', 'jkuminga@gsw.com', '5551234573', '2002-10-06', '12345678909'),
    ('00000000-0000-0000-0000-000000000014', 'Moses', 'Moody', 'mmoody@gsw.com', '5551234574', '2002-05-31', '12345678910'),
    ('00000000-0000-0000-0000-000000000015', 'Gary', 'Payton', 'gpayton@gsw.com', '5551234575', '1992-12-01', '12345678911'),
    ('00000000-0000-0000-0000-000000000016', 'Dario', 'Saric', 'dsaric@gsw.com', '5551234576', '1994-04-08', '12345678912'),
    ('00000000-0000-0000-0000-000000000017', 'Brandon', 'Podzimski', 'bpodzimski@gsw.com', '5551234577', '2003-06-02', '12345678913'),
    ('00000000-0000-0000-0000-000000000018', 'Trayce', 'Jackson-Davis', 'tjackson@gsw.com', '5551234578', '2000-02-22', '12345678914');

INSERT INTO basketball.players (id, identity_id, user_id, team_id, nickname, number, position, height, weight, wingspan, main_hand) VALUES
    ('00000000-0000-0000-0000-000000000019', '00000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'Chef Curry', 30, 'PG', 1.88, 84, 1.91, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000020', '00000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'Klay', 11, 'SG', 1.98, 97, 2.01, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000021', '00000000-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'Dray', 23, 'PF', 1.98, 104, 2.14, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000022', '00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'Wiggs', 22, 'SF', 2.01, 91, 2.13, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000023', '00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'Loon', 5, 'C', 2.06, 102, 2.22, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000024', '00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'CP3', 3, 'PG', 1.83, 79, 1.90, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000025', '00000000-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'Kuminga', 00, 'SF', 2.03, 102, 2.16, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000026', '00000000-0000-0000-0000-000000000014', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'Moses', 4, 'SG', 1.96, 93, 2.10, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000027', '00000000-0000-0000-0000-000000000015', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'GP2', 8, 'SG', 1.91, 88, 2.06, 'LEFT'),
    ('00000000-0000-0000-0000-000000000028', '00000000-0000-0000-0000-000000000016', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'Saric', 20, 'PF', 2.08, 102, 2.19, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000029', '00000000-0000-0000-0000-000000000017', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'BP', 2, 'SG', 1.93, 91, 2.11, 'RIGHT'),
    ('00000000-0000-0000-0000-000000000030', '00000000-0000-0000-0000-000000000018', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000006', 'TJD', 32, 'PF', 2.06, 106, 2.13, 'RIGHT');

CREATE VIEW basketball.players_identities AS
    SELECT
        players.id,
        players.identity_id,
        players.user_id,
        players.team_id,
        identities.first_name,
        identities.last_name,
        players.nickname,
        players.number,
        players.position,
        players.height,
        players.weight,
        players.wingspan,
        players.main_hand
    FROM basketball.players, basketball.identities
    WHERE players.identity_id = identities.id;

-- CREATE VIEW basketball.teams_players AS
--     SELECT * FROM basketball.players_identities, basketball.teams GROUP BY teams.name, players_identities.last_name ORDER BY players_identities.last_name;

CREATE USER IF NOT EXISTS basketball WITH PASSWORD NULL;

ALTER DATABASE basketball OWNER TO basketball;

GRANT ALL ON DATABASE basketball TO basketball;

GRANT ALL ON TABLE basketball.* TO basketball;