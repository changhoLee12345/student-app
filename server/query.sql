use dev;

SELECT *
FROM   students;

DELETE FROM students
WHERE  id = 1;

SELECT date(a.check_in_time), curdate(), a.* -- date_add(a.check_out_time, interval (select study_hours from students s where s.id = a.student_id) minute)
FROM   attendance a;

DELETE FROM attendance
WHERE  1 = 1
AND    id = 4;

update attendance a 
set a.check_out_time = date_add(a.check_in_time, interval (select study_hours from students s where s.id = a.student_id) minute),
    a.study_duration_minutes = (select study_hours from students s where s.id = a.student_id)
where a.check_out_time is not null
and   a.id = 18;

select *
from make_up_hours
where 1 = 1
-- and   is_completed = false
;

update make_up_hours
set is_completed = true
where id = 3;

select * from (
select make_up_minutes from make_up_hours where student_id = 1
union all
select study_hours from students where id = 1) a
limit 1;

select a.make_up_minutes 
from (select make_up_minutes, 1 as priority from make_up_hours where student_id = 2 and is_completed = 0
      union all
      select study_hours as make_up_minutes, 2 as priority from students where id = 2) a
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

