-- Database

DROP DATABASE IF EXISTS basketball;

CREATE DATABASE IF NOT EXISTS basketball;

-- Types

CREATE TYPE basketball.position AS ENUM ('PG', 'SG', 'SF', 'PF', 'C');

CREATE TYPE basketball.main_hand AS ENUM ('LEFT', 'RIGHT', 'AMBIDEXTROUS');

-- Tables

CREATE TABLE basketball.actions (
    id         UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    name       VARCHAR(63) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS basketball.resources (
    id         UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    name       VARCHAR(63) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS basketball.permissions (
    id          UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    action_id   UUID NOT NULL,
    resource_id UUID NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT now(),
    updated_at  TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (action_id) REFERENCES basketball.actions(id) ON DELETE CASCADE,
    FOREIGN KEY (resource_id) REFERENCES basketball.resources(id) ON DELETE CASCADE,
    INDEX (action_id, resource_id),
    UNIQUE (action_id, resource_id)
);

CREATE TABLE IF NOT EXISTS basketball.teams (
    id         UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    name       VARCHAR(63) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP DEFAULT NULL,
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS basketball.identities (
    id            UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    first_name    VARCHAR(63) NOT NULL,
    last_name     VARCHAR(63) NOT NULL,
    email         VARCHAR(127) DEFAULT NULL,
    phone         VARCHAR(10) DEFAULT NULL,
    birth_date    DATE DEFAULT NULL,
    social_number VARCHAR(63) DEFAULT NULL UNIQUE,
    created_at    TIMESTAMP NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS basketball.users (
    id                 UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    identity_id        UUID NOT NULL UNIQUE,
    username           VARCHAR(63) NOT NULL UNIQUE,
    recovery_email     VARCHAR(127) DEFAULT NULL,
    password           VARCHAR(255) NOT NULL,
    refresh_token      VARCHAR(255) DEFAULT NULL,
    verification_token VARCHAR(255) NOT NULL,
    logged_at          TIMESTAMP DEFAULT NULL,
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id),
    FOREIGN KEY (identity_id) REFERENCES basketball.identities(id) ON DELETE CASCADE,
    INDEX (username)
);

CREATE TABLE IF NOT EXISTS basketball.users_permissions (
    user_id        UUID NOT NULL,
    permissions_id UUID NOT NULL,
    FOREIGN KEY (user_id) REFERENCES basketball.users(id) ON DELETE CASCADE,
    FOREIGN KEY (permissions_id) REFERENCES basketball.permissions(id) ON DELETE CASCADE,
    INDEX (user_id, permissions_id),
    UNIQUE (user_id, permissions_id)
);

CREATE TABLE basketball.access_logs (
    id          UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL,
    action_id   UUID NOT NULL,
    resource_id UUID NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES basketball.users(id) ON DELETE CASCADE,
    FOREIGN KEY (action_id) REFERENCES basketball.actions(id) ON DELETE CASCADE,
    FOREIGN KEY (resource_id) REFERENCES basketball.resources(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS basketball.players (
    id          UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),
    identity_id UUID NOT NULL UNIQUE,
    team_id     UUID NOT NULL,
    nickname    VARCHAR(63) DEFAULT NULL,
    number      INT NOT NULL CHECK (number BETWEEN 0 AND 99),
    position    basketball.position NOT NULL,
    height      DECIMAL(5, 2) DEFAULT NULL,
    weight      DECIMAL(5, 2) DEFAULT NULL,
    wingspan    DECIMAL(5, 2) DEFAULT NULL,
    main_hand   basketball.main_hand NOT NULL DEFAULT 'RIGHT',
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id),
    FOREIGN KEY (identity_id) REFERENCES basketball.identities(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES basketball.teams(id) ON DELETE CASCADE,
    INDEX (identity_id, team_id)
);

-- Grants

CREATE USER IF NOT EXISTS basketball WITH PASSWORD NULL;

ALTER DATABASE basketball OWNER TO basketball;

GRANT ALL ON DATABASE basketball TO basketball;

GRANT ALL ON TABLE basketball.* TO basketball;

-- Seedlings

INSERT INTO basketball.actions (name) VALUES
    ('CREATE'),
    ('READ'),
    ('UPDATE'),
    ('DELETE'),
    ('ALL');

INSERT INTO basketball.resources (name) VALUES
    ('teams'),
    ('players'),
    ('users');

INSERT INTO basketball.permissions (action_id, resource_id)
SELECT actions.id, resources.id
FROM basketball.actions
CROSS JOIN basketball.resources;

INSERT INTO basketball.teams (name) VALUES
    ('Golden State Warriors'),
    ('Los Angeles Lakers');

INSERT INTO basketball.identities (first_name, last_name, email, birth_date) VALUES
    ('Adam', 'Silver', 'adam.silver@nba.com', '1962-04-25'),
    ('Frank', 'Wallace', 'frank.wallace@nba.com', '1988-07-14');

INSERT INTO basketball.users (identity_id, username, password, verification_token) VALUES
    (
        (SELECT id FROM basketball.identities WHERE email = 'adam.silver@nba.com'),
        'adam.silver',
        'hashed_password',
        'verification_token'
    ),
    (
        (SELECT id FROM basketball.identities WHERE email = 'frank.wallace@nba.com'),
        'frank.wallace',
        'hashed_password',
        'verification_token'
    );

-- INSERT INTO basketball.users_permissions (user_id, permissions_id) VALUES
--     (
--         (SELECT id FROM basketball.users WHERE username = 'adam.silver'),
--         (SELECT id FROM basketball.permissions WHERE  = 'adam.silver@nba.com')
--     ),
--     (
--         (SELECT id FROM basketball.identities WHERE email = 'adam.silver@nba.com'),
--         (SELECT id FROM basketball.identities WHERE email = 'adam.silver@nba.com')
--     ),
--     (
--         (SELECT id FROM basketball.identities WHERE email = 'adam.silver@nba.com'),
--         (SELECT id FROM basketball.identities WHERE email = 'adam.silver@nba.com')
--     );

INSERT INTO basketball.identities (first_name, last_name, email, birth_date) VALUES
    ('Stephen', 'Curry', 'stephen.curry@nba.com', '1988-03-14'),
    ('Klay', 'Thompson', 'klay.thompson@nba.com', '1990-02-08'),
    ('Draymond', 'Green', 'draymond.green@nba.com', '1990-03-04'),
    ('Andrew', 'Wiggins', 'andrew.wiggins@nba.com', '1995-02-23'),
    ('Jordan', 'Poole', 'jordan.poole@nba.com', '1999-06-19'),
    ('James', 'Wiseman', 'james.wiseman@nba.com', '2001-03-31'),
    ('Kevon', 'Looney', 'kevon.looney@nba.com', '1996-02-06'),
    ('Otto', 'Porter Jr.', 'otto.porter@nba.com', '1993-06-03'),
    ('Gary', 'Payton II', 'gary.payton@nba.com', '1992-05-02'),
    ('Juan', 'Toscano-Anderson', 'juan.toscano@nba.com', '1993-04-02'),
    ('Nemanja', 'Bjelica', 'nemanja.bjelica@nba.com', '1988-05-20'),
    ('Moses', 'Moody', 'moses.moody@nba.com', '2002-06-05'),
    ('LeBron', 'James', 'lebron.james@nba.com', '1984-12-30'),
    ('Anthony', 'Davis', 'anthony.davis@nba.com', '1993-03-11'),
    ('Russell', 'Westbrook', 'russell.westbrook@nba.com', '1988-11-12'),
    ('Carmelo', 'Anthony', 'carmelo.anthony@nba.com', '1984-05-29'),
    ('Dwight', 'Howard', 'dwight.howard@nba.com', '1985-12-08'),
    ('Rajon', 'Rondo', 'rajon.rondo@nba.com', '1986-02-22'),
    ('Talen', 'Horton-Tucker', 'talen.horton@nba.com', '2001-11-25'),
    ('Kendrick', 'Nunn', 'kendrick.nunn@nba.com', '1995-08-03'),
    ('Avery', 'Bradley', 'avery.bradley@nba.com', '1990-11-26'),
    ('Wayne', 'Ellington', 'wayne.ellington@nba.com', '1987-04-29'),
    ('Stanley', 'Johnson', 'stanley.johnson@nba.com', '1996-05-29'),
    ('Sasha', 'Vujacic', 'sasha.vujacic@nba.com', '1984-11-08');

INSERT INTO basketball.players (identity_id, team_id, nickname, number, position, height, weight, wingspan, main_hand) VALUES
    (
       (SELECT id FROM basketball.identities WHERE email = 'stephen.curry@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Steph', 30, 'PG', 1.91, 86.18, 2.01, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'klay.thompson@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Klay', 11, 'SG', 1.93, 98.00, 2.01, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'draymond.green@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Dray', 23, 'PF', 1.98, 102.06, 2.06, 'LEFT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'andrew.wiggins@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Wiggs', 22, 'SF', 1.98, 97.03, 2.05, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'jordan.poole@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'JP', 3, 'SG', 1.88, 84.00, 1.98, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'james.wiseman@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Wiseman', 33, 'C', 2.13, 102.06, 2.24, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'kevon.looney@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Looney', 5, 'C', 1.98, 102.06, 2.06, 'LEFT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'otto.porter@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Otto', 32, 'SF', 1.98, 98.00, 2.03, 'LEFT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'gary.payton@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'GP2', 0, 'PG', 1.85, 84.00, 1.85, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'juan.toscano@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Juan', 95, 'SF', 1.93, 91.00, 1.98, 'LEFT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'nemanja.bjelica@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Nemanja', 8, 'PF', 2.06, 102.06, 2.07, 'LEFT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'moses.moody@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Golden State Warriors'),
       'Moses', 4, 'SG', 1.93, 84.00, 1.98, 'RIGHT'
    ),
                                                                                                                           (
       (SELECT id FROM basketball.identities WHERE email = 'lebron.james@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'King James', 6, 'SF', 1.98, 113.40, 2.13, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'anthony.davis@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'AD', 3, 'PF', 2.06, 115.00, 2.13, 'LEFT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'russell.westbrook@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Russ', 0, 'PG', 1.91, 91.00, 1.95, 'LEFT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'carmelo.anthony@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Melo', 7, 'SF', 1.98, 102.06, 2.01, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'dwight.howard@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Dwight', 39, 'C', 2.06, 120.00, 2.15, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'rajon.rondo@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Rondo', 9, 'PG', 1.85, 82.00, 1.95, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'talen.horton@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Talen', 5, 'SG', 1.93, 84.00, 1.98, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'kendrick.nunn@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Kendrick', 12, 'PG', 1.83, 84.00, 1.92, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'avery.bradley@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Avery', 11, 'SG', 1.85, 77.00, 1.93, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'wayne.ellington@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Wayne', 2, 'SG', 1.93, 93.00, 1.98, 'RIGHT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'stanley.johnson@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Stanley', 12, 'SF', 1.98, 95.00, 1.98, 'LEFT'
    ),
    (
       (SELECT id FROM basketball.identities WHERE email = 'sasha.vujacic@nba.com'),
       (SELECT id FROM basketball.teams WHERE name = 'Los Angeles Lakers'),
       'Sasha', 18, 'SG', 1.96, 89.00, 1.98, 'RIGHT'
    );