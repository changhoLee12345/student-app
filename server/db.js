const mysql = require("mysql2");

const connection = mysql.createConnection({
  host: "localhost",
  user: "dev01",
  password: "dev01", // MySQL 비밀번호를 입력하세요
  database: "dev",
});

connection.connect((err) => {
  if (err) {
    console.error("Error connecting to MySQL:", err);
    return;
  }
  console.log("Connected to MySQL database!");
});

module.exports = connection;
