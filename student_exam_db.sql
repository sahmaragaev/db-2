DROP VIEW IF EXISTS student_exam_view CASCADE;
DROP VIEW IF EXISTS student_exam_inner_join CASCADE;
DROP MATERIALIZED VIEW IF EXISTS exam_performance_summary CASCADE;

DROP TABLE IF EXISTS normalized_scores CASCADE;
DROP TABLE IF EXISTS exam_performance CASCADE;
DROP TABLE IF EXISTS students CASCADE;

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE exam_performance (
    performance_id SERIAL PRIMARY KEY,
    student_id INTEGER REFERENCES students(student_id),
    exam_date DATE NOT NULL,
    
    
    listening_score NUMERIC(3,1) 
        CHECK (listening_score BETWEEN 0 AND 9),
    reading_score NUMERIC(3,1) 
        CHECK (reading_score BETWEEN 0 AND 9),
    writing_score NUMERIC(3,1) 
        CHECK (writing_score BETWEEN 0 AND 9),
    speaking_score NUMERIC(3,1) 
        CHECK (speaking_score BETWEEN 0 AND 9)
);

ALTER TABLE students 
ADD COLUMN registration_date DATE;

CREATE VIEW student_exam_view AS
SELECT 
    s.student_id,
    s.full_name,
    e.exam_date,
    (e.listening_score + e.reading_score + 
     e.writing_score + e.speaking_score) / 4 AS overall_band_score
FROM 
    students s
JOIN 
    exam_performance e ON s.student_id = e.student_id;

CREATE MATERIALIZED VIEW exam_performance_summary AS
SELECT 
    AVG(listening_score) AS avg_listening,
    AVG(reading_score) AS avg_reading,
    AVG(writing_score) AS avg_writing,
    AVG(speaking_score) AS avg_speaking
FROM 
    exam_performance;

CREATE TABLE normalized_scores AS
SELECT 
    student_id,
    exam_date,
    
    (listening_score - MIN(listening_score) OVER ()) / 
    NULLIF((MAX(listening_score) OVER () - MIN(listening_score) OVER ()), 0) AS normalized_listening
FROM 
    exam_performance;

BEGIN;
    SAVEPOINT student_registration;

    INSERT INTO students (full_name, email, registration_date)
    VALUES ('Rafael Fiziev', 'rafael@ufc.com', CURRENT_DATE);
    
    INSERT INTO exam_performance (
        student_id, 
        exam_date, 
        listening_score, 
        reading_score, 
        writing_score, 
        speaking_score
    ) VALUES (
        (SELECT student_id FROM students WHERE email = 'maria.r@example.com'),
        CURRENT_DATE,
        6.5, 7.0, 6.0, 7.5
    );

    COMMIT;

CREATE VIEW student_exam_inner_join AS
SELECT 
    s.student_id,
    s.full_name,
    e.exam_date,
    e.speaking_score
FROM 
    students s
INNER JOIN 
    exam_performance e ON s.student_id = e.student_id;

INSERT INTO students (full_name, email, registration_date)
VALUES 
    ('Shahmar Aghayev', 'sahmar@novalingua.org', '2024-01-15'),
    ('Casey Muratori', 'casey@novalingua.org', '2023-02-20');

INSERT INTO exam_performance (
    student_id, 
    exam_date, 
    listening_score, 
    reading_score, 
    writing_score, 
    speaking_score
) VALUES 
    (1, '2024-06-15', 7.0, 6.5, 6.0, 7.5),
    (2, '2023-07-20', 6.5, 7.0, 6.5, 7.0);
