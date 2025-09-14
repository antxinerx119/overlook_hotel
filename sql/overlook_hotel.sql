-- Overlook Hotel - PostgreSQL (English)
-- Run with psql, e.g.:
--   psql -U postgres -f sql/overlook_hotel.sql

-- Optional: create database then connect (requires psql)
-- CREATE DATABASE overlook_hotel;
-- \connect overlook_hotel

BEGIN;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

-- Core entities (translated)

CREATE TABLE IF NOT EXISTS customer (
    id              bigserial PRIMARY KEY,
    email           text NOT NULL UNIQUE,
    password        text NOT NULL,
    last_name       text NOT NULL,
    first_name      text NOT NULL
);

CREATE TABLE IF NOT EXISTS room (
    id          bigserial PRIMARY KEY,
    room_number integer NOT NULL UNIQUE,
    room_type   text NOT NULL,
    price       numeric(10,2) NOT NULL CHECK (price >= 0),
    floor       integer NOT NULL
);

CREATE TABLE IF NOT EXISTS manager (
    id              bigserial PRIMARY KEY,
    email           text NOT NULL UNIQUE,
    password        text NOT NULL,
    access_level    smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS employee (
    id              bigserial PRIMARY KEY,
    last_name       text NOT NULL,
    first_name      text NOT NULL,
    position        text NOT NULL,
    salary          numeric(10,2) NOT NULL CHECK (salary >= 0),
    manager_id      bigint NOT NULL REFERENCES manager(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS loyalty_program (
    -- 1:1 with customer (customer may have 0 or 1)
    customer_id   bigint PRIMARY KEY REFERENCES customer(id) ON DELETE CASCADE,
    points        integer NOT NULL DEFAULT 0 CHECK (points >= 0),
    loyalty_level text NOT NULL,
    enrolled_at   date NOT NULL
);

CREATE TABLE IF NOT EXISTS hotel_event (
    id               bigserial PRIMARY KEY,
    name             text NOT NULL,
    start_date       date NOT NULL,
    end_date         date NOT NULL,
    description      text,
    organizer_id     bigint REFERENCES employee(id) ON DELETE SET NULL,
    CHECK (end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS facility (
    id             bigserial PRIMARY KEY,
    name           text NOT NULL,
    facility_type  text NOT NULL,
    availability   text NOT NULL
);

CREATE TABLE IF NOT EXISTS feedback (
    id           bigserial PRIMARY KEY,
    rating       smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment_text text,
    created_at   date NOT NULL DEFAULT CURRENT_DATE,
    response     text,
    customer_id  bigint NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    room_id      bigint NOT NULL REFERENCES room(id) ON DELETE CASCADE
);

-- Associative relations

-- Booking: Customer 0..N <-> 0..N Room, with attributes
CREATE TABLE IF NOT EXISTS booking (
    id           bigserial PRIMARY KEY,
    customer_id  bigint NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    room_id      bigint NOT NULL REFERENCES room(id) ON DELETE CASCADE,
    start_date   date NOT NULL,
    end_date     date NOT NULL,
    status       text NOT NULL,
    CHECK (end_date > start_date)
);

CREATE INDEX IF NOT EXISTS idx_booking_customer ON booking(customer_id);
CREATE INDEX IF NOT EXISTS idx_booking_room ON booking(room_id);
CREATE INDEX IF NOT EXISTS idx_booking_dates ON booking(room_id, start_date, end_date);

-- Manage: Manager 1..N <-> 0..N Room (N:N)
CREATE TABLE IF NOT EXISTS manager_room (
    manager_id  bigint NOT NULL REFERENCES manager(id) ON DELETE CASCADE,
    chambre_id      bigint NOT NULL REFERENCES chambre(id) ON DELETE CASCADE,
    PRIMARY KEY (manager_id, room_id)
);

-- Participate: Customer 0..N <-> 0..N Hotel Event (N:N)
CREATE TABLE IF NOT EXISTS event_participation (
    client_id     bigint NOT NULL REFERENCES client(id) ON DELETE CASCADE,
    event_id     bigint NOT NULL REFERENCES hotel_event(id) ON DELETE CASCADE,
    PRIMARY KEY (customer_id, event_id)
);

-- Use: Customer 0..N <-> 0..N Facility (N:N)
CREATE TABLE IF NOT EXISTS facility_usage (
    client_id       bigint NOT NULL REFERENCES client(id) ON DELETE CASCADE,
    facility_id   bigint NOT NULL REFERENCES facility(id) ON DELETE CASCADE,
    PRIMARY KEY (customer_id, facility_id)
);

COMMIT;

