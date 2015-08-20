-- Examples from 7DB book

CREATE TABLE countries (
	country_code char(2) PRIMARY KEY,
	country_name text UNIQUE
);

INSERT INTO countries (country_code, country_name)
VALUES ('us', 'United States'), ('mx', 'Mexico'), ('au', 'Australia'),
       ('gb', 'United Kingdom'), ('de', 'Germany'), ('ll', 'Loompaland');

SELECT * FROM countries;

DELETE FROM countries WHERE country_code = 'll';

CREATE TABLE cities (
	name text NOT NULL,
	postal_code varchar(9) CHECK (postal_code <> ''),
	country_code char(2) REFERENCES countries,
	PRIMARY KEY (country_code, postal_code)
);

INSERT INTO cities VALUES ('Toronto', 'M4C1B5', 'ca');

INSERT INTO cities VALUES ('Portland', '87200', 'us');

update cities set postal_code = '97205' where name = 'Portland';

select cities.* country_name from cities INNER JOIN countries ON cities.country_code = countries.country_code;

CREATE TABLE venues (
	venue_id SERIAL PRIMARY KEY,
	name varchar(255),
	street_address text,
	type char(7) CHECK (type in ('public', 'private')) DEFAULT 'public',
	postal_code varchar(9),
	country_code char(2),
	FOREIGN KEY (country_code, postal_code)
	   REFERENCES cities (country_code, postal_code) MATCH FULL
);

insert into venues (name, postal_code, country_code) values ('Crystal Ballroom', '97205', 'us');

select v.venue_id, v.name, c.name 
  from venues v inner join cities c 
       on v.postal_code = c.postal_code 
          and v.country_code = c.country_code;

insert into venues (name, postal_code, country_code) values ('Voodoo Donuts', '97205', 'us') RETURNING venue_id;

CREATE TABLE events (
	event_id SERIAL PRIMARY KEY,
	title text,
	starts timestamp,
	ends timestamp,
	venue_id integer,
	FOREIGN KEY (venue_id) REFERENCES venues (venue_id)
);

INSERT INTO events (title, starts, ends) VALUES ('LARP Club', '2012-02-15 17:30:00', '2012-02-15 19:30:00');
INSERT INTO events (title, starts, ends) VALUES ('April Fools Day', '2012-01-01 00:00:00', '2012-04-01 23:59:00');
INSERT INTO events (title, starts, ends) VALUES ('Chrismas Day', '2012-12-25 00:00:00', '2012-12-25 23:59:00');

update events set venue_id = '2' where event_id = '1';

select e.title, v.name from events e join venues v on e.venue_id = v.venue_id;

select e.title, v.name from events e left join venues v on e.venue_id = v.venue_id;

select * from events where starts >= '2012-04-01';

CREATE INDEX events_title ON events USING hash(title);

CREATE INDEX events_starts ON events USING btree (starts);

select relname from pg_class where relname in ('cities', 'events', 'venues', 'countries');

SELECT countries.country_name 
FROM events 
     JOIN venues ON events.venue_id = venues.venue_id 
     JOIN countries ON venues.country_code = countries.country_code 
WHERE events.title ILIKE 'LARP%';

alter table events add column active boolean default true;

INSERT INTO countries VALUES ('RU', 'Russia');

INSERT INTO cities VALUES ('Sant-Petersburg', '197000', 'RU');

INSERT INTO venues (name, street_address, type, postal_code,  country_code)
	VALUES ('My Place', 'Oak street', 'public', '197384', 'RU');

INSERT INTO events (title, starts, ends, venue_id)
	VALUES ('Big Party', '2016-08-28 20:00:00', '2016-08-28 23:59:59', 
		(SELECT venue_id FROM venues WHERE name = 'Cristal Ballroom')
		);

