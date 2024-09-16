DROP TABLE IF EXISTS todo;

CREATE TABLE todo (
    "id" UUID PRIMARY KEY NOT NULL,
    "todo_text" VARCHAR(255) NOT NULL,
    "created_date_time" TIMESTAMP DEFAULT NOW()::date,
    "completed_date_time" TIMESTAMP DEFAULT NULL
);
