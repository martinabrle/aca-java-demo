CREATE TABLE IF NOT EXISTS visits (
  "id" SERIAL PRIMARY KEY NOT NULL,
  "pet_id" INT NOT NULL,
  "visit_date" TIMESTAMP,
  "description" VARCHAR(8192),
  FOREIGN KEY ("pet_id") REFERENCES pets("id")
);
