const express = require("express");
const cors = require("cors");
const studentRoutes = require("./routes/studentRoutes");
const connection = require("./db");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// API 라우터 연결
app.use("/api/students", studentRoutes);

// 서버 시작
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
