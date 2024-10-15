DROP DATABASE IF EXISTS basketball;

CREATE DATABASE IF NOT EXISTS basketball;

CREATE USER IF NOT EXISTS basketball WITH PASSWORD NULL;

ALTER DATABASE basketball OWNER TO basketball;

CREATE TYPE basketball.position AS ENUM ('PG', 'SG', 'SF', 'PF', 'C');

CREATE TYPE basketball.main_hand AS ENUM ('LEFT', 'RIGHT', 'AMBIDEXTROUS');

CREATE TABLE IF NOT EXISTS basketball.identities (
     id           UUID NOT NULL UNIQUE PRIMARY KEY,
     first_name   STRING NOT NULL,
     last_name    STRING NOT NULL,
     email        STRING DEFAULT NULL,
     phone        STRING NOT NULL,
     birth_date   DATE NOT NULL,
     pesel_number STRING NOT NULL UNIQUE,
     created_at     TIMESTAMP NOT NULL DEFAULT now(),
     updated_at     TIMESTAMP DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS basketball.users (
    id             UUID NOT NULL UNIQUE PRIMARY KEY,
    identity_id    UUID REFERENCES basketball.identities(id) ON DELETE CASCADE,
    email          STRING NOT NULL UNIQUE,
    recovery_email STRING DEFAULT NULL,
    password       STRING NOT NULL,
    refresh_token  STRING DEFAULT NULL,
    verify_token   STRING DEFAULT NULL,
    logged_at      TIMESTAMP DEFAULT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT now(),
    updated_at     TIMESTAMP DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS basketball.players (
    id          UUID NOT NULL UNIQUE PRIMARY KEY,
    identity_id UUID NOT NULL UNIQUE REFERENCES basketball.identities(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES basketball.users(id) ON DELETE CASCADE,
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
