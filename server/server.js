const express = require("express");
const cors = require("cors");
const studentRoutes = require("./routes/studentRoutes");
const connection = require("./db");

const app = express();

const os = require("os");

const network = os.networkInterfaces();
const IP =
  (network["enp7s0"] && network["enp7s0"][0].address) ||
  (network["이더넷"] && network["이더넷"][1].address) ||
  (network["Wi-Fi"] && network["Wi-Fi"][1].address) ||
  "127.0.0.1";

const PORT = 3000;

app.use(cors());
app.use(express.json());

// API 라우터 연결
app.use("/api/students", studentRoutes);

// 서버 시작
app.listen(PORT, () => {
  console.log(`Server is running on http://${IP}:${PORT}`);
});
