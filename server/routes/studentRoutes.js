const express = require("express");
const router = express.Router();
const connection = require("../db");

// 모든 학생 정보 조회 (등록 탭용)
router.get("/", (req, res) => {
  const query = "SELECT * FROM students";
  connection.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// 오늘 입실한 학생 정보 조회 (입퇴실 탭용)
// server/routes/studentRoutes.js

// 오늘 입실한 학생 정보 조회 (입퇴실 탭용)
router.get("/status", (req, res) => {
  const query = `
        SELECT
            s.id,
            s.name,
            s.grade,
            s.study_hours,
            s.special_notes,
            a.check_in_time,
            a.check_out_time,
            a.auto_check_out_time
        FROM
            students s
        JOIN
            attendance a ON s.id = a.student_id
        WHERE
            DATE(a.check_in_time) = CURDATE()
        ORDER BY
            a.check_out_time IS NOT NULL,  -- 퇴실한 학생(NULL이 아닌 경우)이 뒤로
            a.check_in_time DESC;          -- 입실 시간 최신순으로 정렬
    `;
  connection.query(query, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// 학생 정보 추가
router.post("/", (req, res) => {
  const { name, grade, study_hours, special_notes } = req.body;
  const checkQuery = `
        SELECT id FROM students
        WHERE name = ? AND grade = ?
    `;
  connection.query(checkQuery, [name, grade], (err, results) => {
    if (err)
      return res
        .status(500)
        .json({ error: "데이터베이스 오류가 발생했습니다." });

    if (results.length > 0) {
      return res.status(409).json({ error: "이 학생은 이미 등록되었습니다." });
    }

    const query =
      "INSERT INTO students (name, grade, study_hours, special_notes) VALUES (?, ?, ?, ?)";
    connection.query(
      query,
      [name, grade, study_hours, special_notes],
      (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ message: "학생이 성공적으로 등록되었습니다." });
      }
    );
  });
});

// 학생 정보 수정 (새로운 기능)
router.put("/:id", (req, res) => {
  const { id } = req.params;
  const { name, grade, study_hours, special_notes } = req.body;
  const query =
    "UPDATE students SET name = ?, grade = ?, study_hours = ?, special_notes = ? WHERE id = ?";
  connection.query(
    query,
    [name, grade, study_hours, special_notes, id],
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      if (result.affectedRows === 0) {
        return res
          .status(404)
          .json({ error: "수정할 학생을 찾을 수 없습니다." });
      }
      res.json({ message: "학생 정보가 성공적으로 수정되었습니다." });
    }
  );
});

// 학생 입실 처리
router.post("/checkin", (req, res) => {
  const { studentId } = req.body;

  const checkQuery = `
        SELECT id FROM attendance 
        WHERE student_id = ? 
        AND DATE(check_in_time) = CURDATE()
        AND check_out_time IS NULL;
    `;

  connection.query(checkQuery, [studentId], (err, results) => {
    if (err)
      return res
        .status(500)
        .json({ error: "데이터베이스 오류가 발생했습니다." });

    if (results.length > 0) {
      return res
        .status(409)
        .json({ error: "이 학생은 이미 오늘 입실 처리되었습니다." });
    }

    const getStudyHoursQuery = "SELECT study_hours FROM students WHERE id = ?";
    connection.query(getStudyHoursQuery, [studentId], (err, studentResults) => {
      if (err)
        return res
          .status(500)
          .json({ error: "학생 정보 조회 중 오류가 발생했습니다." });

      if (studentResults.length === 0) {
        return res.status(404).json({ error: "학생을 찾을 수 없습니다." });
      }

      const studyHours = studentResults[0].study_hours;
      const checkInTime = new Date();
      const autoCheckOutTime = new Date(
        checkInTime.getTime() + studyHours * 60000
      );

      const insertQuery =
        "INSERT INTO attendance (student_id, check_in_time, auto_check_out_time) VALUES (?, ?, ?)";
      connection.query(
        insertQuery,
        [studentId, checkInTime, autoCheckOutTime],
        (err, result) => {
          if (err)
            return res
              .status(500)
              .json({ error: "입실 처리 중 오류가 발생했습니다." });
          res.status(201).json({ message: "입실 처리가 완료되었습니다!" });
        }
      );
    });
  });
});

// 학생 퇴실 처리
router.post("/checkout", (req, res) => {
  const { studentId } = req.body;
  const checkOutTime = new Date();

  const findQuery =
    "SELECT id, check_in_time FROM attendance WHERE student_id = ? AND check_out_time IS NULL ORDER BY check_in_time DESC LIMIT 1";
  connection.query(findQuery, [studentId], (err, results) => {
    if (err || results.length === 0) {
      return res.status(404).json({ error: "학생이 입실 상태가 아닙니다." });
    }
    const attendanceId = results[0].id;
    const checkInTime = new Date(results[0].check_in_time);

    const durationMs = checkOutTime.getTime() - checkInTime.getTime();
    const durationMinutes = Math.floor(durationMs / 60000);

    const updateQuery =
      "UPDATE attendance SET check_out_time = ?, study_duration_minutes = ? WHERE id = ?";
    connection.query(
      updateQuery,
      [checkOutTime, durationMinutes, attendanceId],
      (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: "퇴실 처리가 완료되었습니다!" });
      }
    );
  });
});

module.exports = router;
