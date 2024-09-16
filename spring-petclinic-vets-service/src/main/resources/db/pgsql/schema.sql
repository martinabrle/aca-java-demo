CREATE TABLE IF NOT EXISTS vets (
  "id" SERIAL PRIMARY KEY NOT NULL,
  "first_name" VARCHAR(30),
  "last_name" VARCHAR(30)
);

CREATE INDEX IF NOT EXISTS vets_last_name_idx ON vets ( "last_name" );

CREATE TABLE IF NOT EXISTS specialties (
  "id" SERIAL PRIMARY KEY NOT NULL ,
  "name" VARCHAR(80)
);

CREATE INDEX IF NOT EXISTS specialties_name_idx ON specialties ( "name" );

CREATE TABLE IF NOT EXISTS vet_specialties (
  "vet_id" INT NOT NULL,
  "specialty_id" INT NOT NULL,
  FOREIGN KEY ("vet_id") REFERENCES vets("id"),
  FOREIGN KEY ("specialty_id") REFERENCES specialties("id"),
  UNIQUE ("vet_id","specialty_id")
);
