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



SELECT *
FROM   students;

DELETE FROM students
WHERE  id = 1;

SELECT date(a.check_in_time), curdate(), a.* -- date_add(a.check_out_time, interval (select study_hours from students s where s.id = a.student_id) minute)
FROM   attendance a;

DELETE FROM attendance
WHERE  1 = 1
AND    id > 0;

update attendance a 
set a.check_out_time = date_add(a.check_in_time, interval (select study_hours from students s where s.id = a.student_id) minute),
    a.study_duration_minutes = (select study_hours from students s where s.id = a.student_id)
where a.check_out_time is not null
and   a.id = 18;

select *
from make_up_hours
where is_completed = false;

select * from (
select make_up_minutes from make_up_hours where student_id = 1
union all
select study_hours from students where id = 1) a
limit 1;

select a.make_up_minutes 
from (select make_up_minutes, 1 as priority from make_up_hours where student_id = 1 and is_completed = 0
      union all
      select study_hours as make_up_minutes, 2 as priority from students where id = 1) a
order by a.priority asc
limit 1;

update make_up_hours
set is_completed = true
where id = 1;

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

