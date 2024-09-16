CREATE TABLE IF NOT EXISTS types (
  "id" SERIAL PRIMARY KEY NOT NULL,
  "name" VARCHAR(80)
);

CREATE INDEX IF NOT EXISTS types_name_idx ON types ( "name" );

CREATE TABLE IF NOT EXISTS owners (
  "id" SERIAL PRIMARY KEY NOT NULL,
  "first_name" VARCHAR(30),
  "last_name" VARCHAR(30),
  "address" VARCHAR(255),
  "city" VARCHAR(80),
  "telephone" VARCHAR(20)
);

CREATE INDEX IF NOT EXISTS owners_last_name_idx ON owners ( "last_name" );

CREATE TABLE IF NOT EXISTS pets (
  "id" SERIAL PRIMARY KEY NOT NULL,
  "name" VARCHAR(30),
  "birth_date" DATE,
  "type_id" INT NOT NULL,
  "owner_id" INT NOT NULL,
  FOREIGN KEY ("owner_id") REFERENCES owners("id"),
  FOREIGN KEY ("type_id") REFERENCES types("id")
);

CREATE INDEX IF NOT EXISTS pets_name_idx ON pets ( "name" );
