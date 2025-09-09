USE dev;

CREATE TABLE students
  (
     id            INT auto_increment PRIMARY KEY,
     name          VARCHAR(255) NOT NULL,
     grade         VARCHAR(50),
     study_hours   INT,
     special_notes TEXT
  );

-- 기존 students 테이블은 그대로 둡니다.
-- CREATE TABLE students (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     name VARCHAR(255) NOT NULL,
--     grade VARCHAR(50),
--     study_hours INT,
--     special_notes TEXT
-- );

-- 1. attendance(출석) 테이블 생성
DROP TABLE attendance;
CREATE TABLE attendance
  (
     id                     INT auto_increment PRIMARY KEY,
     student_id             INT NOT NULL,
     check_in_time          DATETIME NOT NULL,
     check_out_time         DATETIME,
     study_duration_minutes INT,
     FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
  );

ALTER TABLE attendance
  ADD COLUMN auto_check_out_time DATETIME;

SELECT *
FROM   students;

DELETE FROM students
WHERE  id = 1;

SELECT * -- date_add(a.check_out_time, interval (select study_hours from students s where s.id = a.student_id) minute)
FROM   attendance a;

DELETE FROM attendance
WHERE  1 = 1
AND    id > 0;

update attendance a 
set a.check_out_time = date_add(a.check_in_time, interval (select study_hours from students s where s.id = a.student_id) minute),
    a.study_duration_minutes = (select study_hours from students s where s.id = a.student_id)
where a.check_out_time is not null
and   a.id = 18;

SELECT s.id,
       s.name,
       s.grade,
       s.study_hours,
       s.special_notes,
       a.check_in_time,
       a.check_out_time
FROM   students s
       JOIN attendance a
         ON s.id = a.student_id
WHERE  Date(a.check_in_time) = Curdate();

