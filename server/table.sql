
USE dev;

CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    grade VARCHAR(50),
    study_hours INT,
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

drop table attendance;
-- 1. attendance(출석) 테이블 생성
CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT not null,
    check_in_time DATETIME NOT NULL,
    check_out_time DATETIME,
    study_duration_minutes INT,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);
ALTER TABLE attendance
ADD COLUMN auto_check_out_time DATETIME;

select *
from  students;

delete from students
where id = 1;

select *
from attendance;

delete from attendance
where 1=1
and id > 0;

SELECT
            s.id,
            s.name,
            s.grade,
            s.study_hours,
            s.special_notes,
            a.check_in_time,
            a.check_out_time
        FROM
            students s
        JOIN
            attendance a ON s.id = a.student_id
        WHERE
            DATE(a.check_in_time) = CURDATE();