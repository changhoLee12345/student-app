USE dev;

-- 학생테이블.
drop table students;
CREATE TABLE students
  (
     id            INT auto_increment PRIMARY KEY,
     name          VARCHAR(255) NOT NULL,
     grade         VARCHAR(50),
     study_hours   INT,
     special_notes TEXT,
     created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

-- 1. attendance(출석) 테이블 생성
DROP TABLE attendance;
CREATE TABLE attendance
  (
     id                     INT auto_increment PRIMARY KEY,
     student_id             INT NOT NULL,
     check_in_time          DATETIME NOT NULL,
     check_out_time         DATETIME,
     study_duration_minutes INT,
     auto_check_out_time    DATETIME,
     created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
     FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
  );

-- ALTER TABLE attendance ADD COLUMN auto_check_out_time DATETIME;

-- 2. 보강 테이블.
drop table make_up_hours;
CREATE TABLE make_up_hours (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    attendance_id INT NOT NULL,
    make_up_minutes INT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (attendance_id) REFERENCES attendance(id) ON DELETE CASCADE
);

-- 백업하기.
CREATE TABLE students_backup AS
SELECT * FROM students;

ALTER TABLE students
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE attendance
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

-- 백업 테이블의 데이터를 변경된 원본 테이블에 다시 삽입합니다.
-- 기존 컬럼은 그대로 가져오고, 새로 추가된 컬럼에는 NULL을 지정합니다.
INSERT INTO students (id, name, grade, study_hours, special_notes)
SELECT id, name, grade, study_hours, special_notes FROM students_backup;

TRUNCATE TABLE students;





