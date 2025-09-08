<template>
  <div id="app">
    <div class="container">
      <h1 class="main-title">⭐ 꼬마 탐험가들의 학습 기록 ⭐</h1>

      <div class="tabs">
        <button
          class="tab-btn"
          :class="{ active: activeTab === 'info' }"
          @click="activeTab = 'info'"
        >
          📝 학생 정보 등록
        </button>
        <button
          class="tab-btn"
          :class="{ active: activeTab === 'checkin' }"
          @click="activeTab = 'checkin'"
        >
          🚀 입퇴실 관리
        </button>
        <button
          class="tab-btn"
          :class="{ active: activeTab === 'edit' }"
          @click="activeTab = 'edit'"
        >
          ✏️ 학생 정보 수정
        </button>
      </div>

      <div
        id="info-tab"
        class="tab-content"
        :class="{ active: activeTab === 'info' }"
      >
        <div class="card info-card">
          <h2>새로운 탐험가 등록</h2>
          <div class="form-group">
            <label for="infoStudentName">이름:</label>
            <input type="text" v-model="newStudent.name" placeholder="김민준" />
          </div>
          <div class="form-group">
            <label for="studentGrade">학년:</label>
            <input type="text" v-model="newStudent.grade" placeholder="3학년" />
          </div>
          <div class="form-group">
            <label for="studyHours">예상 학습 시간 (분):</label>
            <input
              type="number"
              v-model="newStudent.studyHours"
              min="10"
              max="240"
              step="10"
            />
          </div>
          <div class="form-group">
            <label for="specialNotes">특이사항:</label>
            <textarea
              v-model="newStudent.specialNotes"
              rows="3"
              placeholder="예: 알레르기, 집중력이 뛰어남 등"
            ></textarea>
          </div>
          <button @click="addStudent" class="primary-btn">
            ✨ 탐험가 등록하기
          </button>
        </div>
        <div class="card registered-card">
          <h2>등록된 탐험가들</h2>
          <div class="student-table-container">
            <table>
              <thead>
                <tr>
                  <th>이름</th>
                  <th>학년</th>
                  <th>예상 학습 시간</th>
                  <th>특이사항</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="student in paginatedStudents" :key="student.id">
                  <td>{{ student.name }}</td>
                  <td>{{ student.grade }}</td>
                  <td>{{ student.study_hours }}분</td>
                  <td>{{ student.special_notes }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="pagination">
            <button @click="prevPage" :disabled="currentPage === 1">
              이전
            </button>
            <span>{{ currentPage }} / {{ totalPages }}</span>
            <button @click="nextPage" :disabled="currentPage === totalPages">
              다음
            </button>
          </div>
        </div>
      </div>

      <div
        id="checkin-tab"
        class="tab-content"
        :class="{ active: activeTab === 'checkin' }"
      >
        <div class="checkin-controls">
          <label for="studentNameSelect" class="control-label"
            >탐험가 선택:</label
          >
          <select v-model="selectedStudent">
            <option disabled value="">탐험가를 선택하세요</option>
            <option
              v-for="student in registeredStudents"
              :key="student.id"
              :value="student.id"
            >
              {{ student.name }} ({{ student.grade }}학년)
            </option>
          </select>
          <button @click="checkIn" class="action-btn checkin-btn">입실</button>
          <button @click="checkOut" class="action-btn checkout-btn">
            퇴실
          </button>
        </div>
        <div class="student-grid">
          <student-card
            v-for="student in studentsStatus"
            :key="student.id"
            :student="student"
          />
        </div>
      </div>

      <div
        id="edit-tab"
        class="tab-content"
        :class="{ active: activeTab === 'edit' }"
      >
        <div class="card edit-card">
          <h2>탐험가 정보 수정</h2>

          <div class="form-group">
            <label for="searchStudent">탐험가 검색:</label>
            <input
              type="text"
              id="searchStudent"
              v-model="searchQuery"
              placeholder="수정할 탐험가 이름을 입력하세요"
              @focus="searchQuery = ''"
            />
            <ul v-if="filteredStudents.length > 0" class="search-results">
              <li
                v-for="student in filteredStudents"
                :key="student.id"
                @click="selectStudentFromSearch(student)"
              >
                {{ student.name }} ({{ student.grade }}학년)
              </li>
            </ul>
          </div>

          <div v-if="selectedStudentToEdit.id" class="edit-form">
            <div class="form-group">
              <label for="editStudentName">이름:</label>
              <input type="text" v-model="selectedStudentToEdit.name" />
            </div>
            <div class="form-group">
              <label for="editStudentGrade">학년:</label>
              <input type="text" v-model="selectedStudentToEdit.grade" />
            </div>
            <div class="form-group">
              <label for="editStudyHours">예상 학습 시간 (분):</label>
              <input
                type="number"
                v-model="selectedStudentToEdit.study_hours"
              />
            </div>
            <div class="form-group">
              <label for="editSpecialNotes">특이사항:</label>
              <textarea
                v-model="selectedStudentToEdit.special_notes"
                rows="3"
              ></textarea>
            </div>
            <button @click="updateStudent" class="primary-btn">
              ✔️ 정보 업데이트
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import StudentCard from "./components/StudentCard.vue";

let API_URL = "http://localhost:3000/api/students";

export default {
  name: "App",
  components: {
    StudentCard,
  },
  data() {
    return {
      activeTab: "info",
      newStudent: {
        name: "",
        grade: "",
        studyHours: 60,
        specialNotes: "",
      },
      registeredStudents: [],
      selectedStudent: "",
      selectedStudentToEdit: {},
      studentsStatus: [],
      timers: {},
      // Pagination Data
      currentPage: 1,
      itemsPerPage: 10,
      searchQuery: "", // New data property to store the search text
      // We'll also need a way to track the selected student's ID for updating
      selectedStudentToEditId: null,
    };
  },
  created() {
    // this.fetchStudents();
    // this.fetchStatus();
    this.fetchIpAddress().then(() => {
      // IP 주소를 가져온 후 데이터를 불러옵니다.
      this.fetchStudents();
      this.fetchStatus();
    });
  },
  computed: {
    totalPages() {
      return Math.ceil(this.registeredStudents.length / this.itemsPerPage);
    },
    paginatedStudents() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.registeredStudents.slice(start, end);
    },
    filteredStudents() {
      if (!this.searchQuery) {
        return [];
      }
      const query = this.searchQuery.toLowerCase();
      return this.registeredStudents.filter((student) =>
        student.name.toLowerCase().includes(query)
      );
    },
  },
  methods: {
    async fetchStudents() {
      try {
        const response = await axios.get(API_URL);
        this.registeredStudents = response.data;
      } catch (error) {
        console.error("Failed to fetch students:", error);
      }
    },
    async fetchStatus() {
      try {
        const response = await axios.get(`${API_URL}/status`);
        this.studentsStatus = response.data.map((student) => ({
          ...student,
          timeLeft: 0,
        }));
        this.studentsStatus.forEach((student) => {
          if (student.check_in_time && !student.check_out_time) {
            this.startTimer(student);
          }
        });
      } catch (error) {
        console.error("Failed to fetch students status:", error);
      }
    },
    async addStudent() {
      try {
        const newStudentData = {
          name: this.newStudent.name,
          grade: this.newStudent.grade,
          study_hours: this.newStudent.studyHours,
          special_notes: this.newStudent.specialNotes,
        };
        await axios.post(API_URL, newStudentData);
        alert("학생이 등록되었습니다!");
        this.fetchStudents();
        this.newStudent = {
          name: "",
          grade: "",
          studyHours: 60,
          specialNotes: "",
        };
      } catch (error) {
        console.error("Failed to add student:", error);
        alert("학생 등록에 실패했습니다.");
      }
    },
    async checkIn() {
      if (!this.selectedStudent) {
        alert("학생을 선택해주세요.");
        return;
      }
      try {
        const response = await axios.post(`${API_URL}/checkin`, {
          studentId: this.selectedStudent,
        });
        alert(response.data.message);
        this.fetchStatus();
      } catch (error) {
        console.error("Failed to check in:", error);
        alert(
          error.response?.data?.error || "입실 처리 중 오류가 발생했습니다."
        );
      }
    },
    async checkOut() {
      if (!this.selectedStudent) {
        alert("학생을 선택해주세요.");
        return;
      }
      try {
        const response = await axios.post(`${API_URL}/checkout`, {
          studentId: this.selectedStudent,
        });
        alert(response.data.message);
        this.fetchStatus();
      } catch (error) {
        console.error("Failed to check out:", error);
        alert(
          error.response?.data?.error || "퇴실 처리 중 오류가 발생했습니다."
        );
      }
    },
    async updateStudent() {
      if (!this.selectedStudentToEdit.id) {
        alert("수정할 학생을 선택해주세요.");
        return;
      }
      try {
        await axios.put(`${API_URL}/${this.selectedStudentToEdit.id}`, {
          name: this.selectedStudentToEdit.name,
          grade: this.selectedStudentToEdit.grade,
          study_hours: this.selectedStudentToEdit.study_hours,
          special_notes: this.selectedStudentToEdit.special_notes,
        });
        alert("학생 정보가 수정되었습니다!");
        this.fetchStudents();
      } catch (error) {
        console.error("Failed to update student:", error);
        alert("학생 정보 수정에 실패했습니다.");
      }
    },
    startTimer(student) {
      if (this.timers[student.id]) {
        clearInterval(this.timers[student.id]);
      }
      const checkOutDate = new Date(student.auto_check_out_time);
      const timerId = setInterval(() => {
        const now = new Date();
        const timeLeft = Math.max(0, checkOutDate.getTime() - now.getTime());
        const targetStudent = this.studentsStatus.find(
          (s) => s.id === student.id
        );
        if (targetStudent) {
          targetStudent.timeLeft = timeLeft;
        }
        if (timeLeft === 0) {
          clearInterval(timerId);
          alert(`${student.name}의 예상 학습 시간이 종료되었습니다!`);
          this.fetchStatus();
        }
      }, 1000);
      this.timers[student.id] = timerId;
    },
    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
      }
    },
    prevPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
      }
    },
    selectStudentFromSearch(student) {
      // Set the selected student for editing
      this.selectedStudentToEdit = { ...student }; // Use spread operator to create a copy
      // Clear the search query after selection
      this.searchQuery = "";
    },
    // IP 주소를 가져오는 비동기 함수
    async fetchIpAddress() {
      try {
        const response = await axios.get("https://api.ipify.org?format=json");
        const publicIp = response.data.ip;
        // 로컬 IP 주소를 찾기 위한 코드
        const localIp = await this.getLocalIp();

        // 공용 IP 또는 로컬 IP를 사용하여 API URL 설정
        // 이 부분은 네트워크 환경에 따라 조정해야 할 수 있습니다.
        API_URL = `http://${localIp || publicIp}:3000/api/students`;
        console.log(`API URL이 ${API_URL}로 설정되었습니다.`);
      } catch (error) {
        console.error("IP 주소를 가져오는 데 실패했습니다:", error);
      }
    },
    // 로컬 IP를 가져오는 함수 (WebRTC 이용)
    getLocalIp() {
      return new Promise((resolve, reject) => {
        const pc = new RTCPeerConnection({ iceServers: [] });
        const noop = () => {};
        pc.createDataChannel("");
        pc.createOffer().then(pc.setLocalDescription.bind(pc)).catch(noop);
        pc.onicecandidate = (ice) => {
          if (!ice || !ice.candidate || !ice.candidate.candidate) {
            reject("Local IP not found");
            return;
          }
          const parts = ice.candidate.candidate.split(" ");
          const ip = parts[4];
          if (ip.endsWith(".local")) {
            reject("Local IP not found");
            return;
          }
          resolve(ip);
          pc.onicecandidate = noop;
        };
      });
    },
  },
  beforeUnmount() {
    for (const timerId in this.timers) {
      clearInterval(this.timers[timerId]);
    }
  },
};
</script>

<style>
/* All of your CSS from the original `style.css` file should be copied 
  and pasted directly into this style block.
*/
body {
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
  background-color: #fce4ec; /* 연한 분홍색 배경 */
  color: #333;
  padding: 10px;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: 100vh;
}

.container {
  background-color: #fff;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  padding: 20px;
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
  /* 기존 코드 */
  /* display: grid; */
  /* grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); */

  /* 한 줄에 5개씩 보이도록 수정 */
  display: grid;
  grid-template-columns: repeat(5, 1fr);
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
/* 테이블 컨테이너 스타일 */
.student-table-container {
  overflow-x: auto; /* 가로 스크롤 허용 */
  border-radius: 10px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.08);
  margin-top: 20px;
}

/* 테이블 기본 스타일 */
.student-table-container table {
  width: 100%;
  border-collapse: collapse; /* 셀 경계선 병합 */
  background-color: #fff;
  border-radius: 10px;
}

/* 테이블 헤더 스타일 */
.student-table-container th {
  background-color: #d4e157; /* 탭 버튼과 동일한 밝은 노랑색 */
  color: #444;
  padding: 12px 15px;
  text-align: left;
  font-weight: bold;
}

/* 테이블 바디 셀 스타일 */
.student-table-container td {
  padding: 12px 15px;
  border-bottom: 1px solid #f0f0f0; /* 셀 하단 구분선 */
}

/* 짝수 행 배경색 변경 (줄무늬 효과) */
.student-table-container tbody tr:nth-child(even) {
  background-color: #f9fbe7; /* 연한 노랑색 */
}

/* 테이블 행 호버 효과 */
.student-table-container tbody tr:hover {
  background-color: #f0f4c3; /* 호버 시 색상 변경 */
  transition: background-color 0.2s;
}

/* 첫 번째와 마지막 셀의 둥근 모서리 */
.student-table-container th:first-child,
.student-table-container td:first-child {
  border-radius: 10px 0 0 10px;
}

.student-table-container th:last-child,
.student-table-container td:last-child {
  border-radius: 0 10px 10px 0;
}
.search-results {
  list-style: none;
  padding: 0;
  margin-top: 5px;
  max-height: 150px;
  overflow-y: auto;
  border: 1px solid #ddd;
  border-radius: 8px;
  background-color: #fff;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
}

.search-results li {
  padding: 10px 15px;
  cursor: pointer;
  border-bottom: 1px solid #eee;
  transition: background-color 0.2s;
}

.search-results li:hover {
  background-color: #f0f4c3;
}
</style>
