-- Overlook Hotel - PostgreSQL Schema (aligned with JPA model)
-- Usage:
--   psql -U postgres -f sql/overlook_hotel.sql

BEGIN;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

-- Core entities -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS guests (
    id             bigserial PRIMARY KEY,
    email          text NOT NULL UNIQUE,
    password       text NOT NULL,
    first_name     text NOT NULL,
    last_name      text NOT NULL,
    phone_number   text,
    birth_date     date,
    nationality    text
);

CREATE TABLE IF NOT EXISTS managers (
    id            bigserial PRIMARY KEY,
    email         text NOT NULL UNIQUE,
    password      text NOT NULL,
    access_level  smallint NOT NULL,
    department    text,
    phone_number  text,
    first_name    text NOT NULL,
    last_name     text NOT NULL,
    hire_date     date,
    salary        numeric(10,2) CHECK (salary >= 0)
);

CREATE TABLE IF NOT EXISTS employees (
    id            bigserial PRIMARY KEY,
    email         text NOT NULL UNIQUE,
    password      text NOT NULL,
    first_name    text NOT NULL,
    last_name     text NOT NULL,
    phone_number  text,
    position      text NOT NULL,
    hire_date     date,
    salary        numeric(10,2) CHECK (salary >= 0),
    manager_id    bigint REFERENCES managers(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS rooms (
    id           bigserial PRIMARY KEY,
    room_number  integer NOT NULL UNIQUE,
    room_type    text NOT NULL,
    room_status  text NOT NULL,
    floor        integer NOT NULL,
    capacity     integer NOT NULL CHECK (capacity > 0),
    nightly_rate numeric(10,2) NOT NULL CHECK (nightly_rate >= 0),
    manager_id   bigint REFERENCES managers(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS reservations (
    id                bigserial PRIMARY KEY,
    code              text NOT NULL UNIQUE,
    created_at        timestamptz NOT NULL,
    check_in_date     date NOT NULL,
    check_out_date    date NOT NULL,
    guest_count       integer NOT NULL CHECK (guest_count > 0),
    status            text NOT NULL,
    total_amount      numeric(10,2) CHECK (total_amount >= 0),
    guest_id          bigint NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
    room_id           bigint NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    employee_id       bigint REFERENCES employees(id) ON DELETE SET NULL,
    CHECK (check_out_date > check_in_date)
);

-- Supporting domain --------------------------------------------------------

CREATE TABLE IF NOT EXISTS loyalty_program (
    guest_id      bigint PRIMARY KEY REFERENCES guests(id) ON DELETE CASCADE,
    points        integer NOT NULL DEFAULT 0 CHECK (points >= 0),
    loyalty_level text NOT NULL,
    enrolled_at   date NOT NULL
);

CREATE TABLE IF NOT EXISTS hotel_events (
    id            bigserial PRIMARY KEY,
    name          text NOT NULL,
    start_date    date NOT NULL,
    end_date      date NOT NULL,
    description   text,
    organizer_id  bigint REFERENCES employees(id) ON DELETE SET NULL,
    CHECK (end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS facilities (
    id            bigserial PRIMARY KEY,
    name          text NOT NULL,
    facility_type text NOT NULL,
    availability  text NOT NULL
);

CREATE TABLE IF NOT EXISTS feedback (
    id           bigserial PRIMARY KEY,
    rating       smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment_text text,
    created_at   date NOT NULL DEFAULT CURRENT_DATE,
    response     text,
    guest_id     bigint NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
    room_id      bigint NOT NULL REFERENCES rooms(id) ON DELETE CASCADE
);

-- Associative relations ----------------------------------------------------

CREATE TABLE IF NOT EXISTS manager_team (
    manager_id bigint NOT NULL REFERENCES managers(id) ON DELETE CASCADE,
    employee_id bigint NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    PRIMARY KEY (manager_id, employee_id)
);

CREATE TABLE IF NOT EXISTS event_participation (
    guest_id bigint NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
    event_id bigint NOT NULL REFERENCES hotel_events(id) ON DELETE CASCADE,
    PRIMARY KEY (guest_id, event_id)
);

CREATE TABLE IF NOT EXISTS facility_usage (
    guest_id    bigint NOT NULL REFERENCES guests(id) ON DELETE CASCADE,
    facility_id bigint NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    used_on     date NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (guest_id, facility_id, used_on)
);

CREATE INDEX IF NOT EXISTS idx_reservations_guest ON reservations(guest_id);
CREATE INDEX IF NOT EXISTS idx_reservations_room ON reservations(room_id);
CREATE INDEX IF NOT EXISTS idx_reservations_dates ON reservations(room_id, check_in_date, check_out_date);

COMMIT;
