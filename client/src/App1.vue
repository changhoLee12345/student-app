<template>
  <div class="container">
    <h1 class="main-title">⭐ 꼬마 탐험가들의 학습 기록 ⭐</h1>

    <div class="tabs">
      <button class="tab-btn active" data-tab="info-tab">
        📝 학생 정보 등록
      </button>
      <button class="tab-btn" data-tab="checkin-tab">🚀 입퇴실 관리</button>
    </div>

    <div id="info-tab" class="tab-content active">
      <div class="card info-card">
        <h2>새로운 탐험가 등록</h2>
        <div class="form-group">
          <label for="infoStudentName">이름:</label>
          <input type="text" id="infoStudentName" placeholder="김민준" />
        </div>
        <div class="form-group">
          <label for="studentGrade">학년:</label>
          <input type="text" id="studentGrade" placeholder="3학년" />
        </div>
        <div class="form-group">
          <label for="studyHours">예상 학습 시간 (분):</label>
          <input
            type="number"
            id="studyHours"
            min="10"
            max="240"
            step="10"
            value="60"
          />
        </div>
        <div class="form-group">
          <label for="specialNotes">특이사항:</label>
          <textarea
            id="specialNotes"
            rows="3"
            placeholder="예: 알레르기, 집중력이 뛰어남, 조용한 환경 선호 등"
          ></textarea>
        </div>
        <button id="addStudentBtn" class="primary-btn">
          ✨ 탐험가 등록하기
        </button>
      </div>
      <div class="card registered-card">
        <h2>등록된 탐험가들</h2>
        <div class="student-list-container">
          <ul id="registeredStudentList"></ul>
        </div>
      </div>
    </div>

    <div id="checkin-tab" class="tab-content">
      <div class="checkin-controls">
        <label for="studentNameSelect" class="control-label"
          >탐험가 선택:</label
        >
        <select id="studentNameSelect"></select>
        <button id="checkInBtn" class="action-btn checkin-btn">입실</button>
        <button id="checkOutBtn" class="action-btn checkout-btn">퇴실</button>
      </div>
      <div class="student-grid" id="student-grid"></div>
    </div>
  </div>
</template>

<style>
body {
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
  background-color: #fce4ec; /* 연한 분홍색 배경 */
  color: #333;
  padding: 20px;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: 100vh;
}

.container {
  background-color: #fff;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  padding: 30px;
  width: 100%;
  max-width: 1200px;
}

.main-title {
  text-align: center;
  color: #d81b60; /* 진한 분홍색 */
  margin-bottom: 30px;
  font-size: 2.5em;
  font-weight: bold;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.tabs {
  display: flex;
  justify-content: center;
  margin-bottom: 25px;
}

.tab-btn {
  padding: 12px 25px;
  border: none;
  background-color: #f0f4c3; /* 연한 노랑색 */
  color: #555;
  cursor: pointer;
  font-size: 1.1em;
  font-weight: bold;
  transition: background-color 0.3s, color 0.3s;
  border-radius: 10px 10px 0 0;
  position: relative;
  top: 1px;
}

.tab-btn.active {
  background-color: #d4e157; /* 밝은 노랑색 */
  color: #444;
}

.tab-content {
  display: none;
  padding: 20px;
  border: 2px solid #d4e157;
  border-radius: 0 0 10px 10px;
}

.tab-content.active {
  display: block;
}

/* 카드 스타일 */
.card {
  background-color: #fff;
  border-radius: 15px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);
  padding: 25px;
  margin-bottom: 20px;
}

.info-card {
  border: 2px dashed #9ccc65; /* 초록색 점선 테두리 */
}

.form-group {
  display: flex;
  flex-direction: column;
  margin-bottom: 15px;
}

.form-group label {
  font-weight: bold;
  color: #66bb6a;
  margin-bottom: 5px;
}

.form-group input {
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 1em;
}

.primary-btn {
  padding: 12px 25px;
  background-color: #4caf50;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  transition: transform 0.2s, background-color 0.2s;
}

.primary-btn:hover {
  background-color: #45a049;
  transform: translateY(-2px);
}

.student-list-container {
  max-height: 250px;
  overflow-y: auto;
}

#registeredStudentList {
  list-style-type: none;
  padding: 0;
}

#registeredStudentList li {
  background-color: #e8f5e9;
  padding: 10px 15px;
  margin-bottom: 8px;
  border-radius: 8px;
  font-weight: 500;
}

/* 입퇴실 탭 스타일 */
.checkin-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  margin-bottom: 25px;
}

.checkin-controls select,
.checkin-controls button {
  padding: 10px;
  border-radius: 8px;
  border: 1px solid #ddd;
  font-size: 1em;
}

.checkin-btn {
  background-color: #ff9800; /* 주황색 */
  color: white;
  font-weight: bold;
  border: none;
}

.checkout-btn {
  background-color: #f44336;
  color: white;
  font-weight: bold;
  border: none;
}

.control-label {
  font-weight: bold;
  color: #333;
}

/* 그리드 및 카드 스타일은 기존과 동일 */
.student-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 20px;
  padding: 20px;
  border-radius: 10px;
  background-color: #fcfcfc;
  box-shadow: inset 0 0 10px rgba(0, 0, 0, 0.05);
}

.student-card {
  background-color: #f7f7f7;
  border-radius: 12px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  padding: 20px;
  text-align: left;
  transition: transform 0.3s ease-in-out, box-shadow 0.3s ease-in-out;
  border-left: 6px solid #ffb74d; /* 입실 상태 */
}

.student-card:hover {
  transform: scale(1.03);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
}

.card-name {
  font-size: 1.3em;
  font-weight: bold;
  color: #5d4037;
  margin-bottom: 5px;
}

.card-info {
  font-size: 0.9em;
  color: #8d6e63;
}

.card-time {
  font-size: 0.8em;
  color: #a1887f;
  margin-top: 5px;
}

.status-out {
  border-left-color: #e57373; /* 퇴실 상태 */
  background-color: #fff8e1;
}

.graph-bar-wrapper {
  width: 100%;
  height: 8px;
  background-color: #e0e0e0;
  border-radius: 5px;
  margin-top: 15px;
  overflow: hidden;
}

.graph-bar {
  height: 100%;
  background-color: #ffc107;
  transition: width 0.5s ease, background-color 0.5s ease;
}

.remaining-time-text {
  font-size: 0.75em;
  color: #d32f2f;
  font-weight: bold;
  margin-top: 5px;
  text-align: right;
}

.tooltip {
  position: absolute;
  top: -10px; /* 카드 위로 위치 */
  left: 50%;
  transform: translateX(-50%) translateY(-100%);
  background-color: #555;
  color: white;
  padding: 10px;
  border-radius: 8px;
  white-space: pre-wrap; /* 줄바꿈 유지 */
  text-align: left;
  font-size: 0.85em;
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.3s ease, transform 0.3s ease;
  z-index: 10;
}

/* 툴팁 꼬리표 */
.tooltip::after {
  content: "";
  position: absolute;
  top: 100%;
  left: 50%;
  margin-left: -5px;
  border-width: 5px;
  border-style: solid;
  border-color: #555 transparent transparent transparent;
}

.student-card:hover .tooltip {
  opacity: 1;
  visibility: visible;
  transform: translateX(-50%) translateY(-110%);
}
</style>
