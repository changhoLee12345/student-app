<template>
  <div class="status-view">
    <h2>입실 상태 현황</h2>

    <!-- 탭 버튼 -->
    <div class="tabs">
      <button
        class="tab-btn"
        :class="{ active: activeTab === 'checkin' }"
        @click="activeTab = 'checkin'"
      >
        📝 입실 현황
      </button>
      <button
        class="tab-btn"
        :class="{ active: activeTab === 'checkout' }"
        @click="activeTab = 'checkout'"
      >
        🚀 퇴실 현황
      </button>
    </div>

    <!-- 새로고침 게이지 -->
    <div class="refresh-bar-container">
      <div class="refresh-bar" :style="{ width: progressPercent + '%' }"></div>
    </div>
    <div class="refresh-info">
      현재 시간: <strong>{{ currentTime.toLocaleTimeString() }}</strong>
    </div>

    <!-- 학생 상태 -->
    <div class="student-grid">
      <student-card
        v-for="student in displayedStudents"
        :key="student.id"
        :student="student"
        fromView="status"
      />
    </div>
  </div>
</template>

<script>
import axios from "axios";
import StudentCard from "../components/StudentCard.vue";

const ip = "192.168.0.99";
const API_URL = `http://${ip}:3000/api/students`;

export default {
  name: "StatusView",
  components: { StudentCard },
  data() {
    return {
      activeTab: "checkin", // 현재 선택된 탭
      studentsStatus: [],
      countdown: 60,
      intervalId: null,
      currentTime: new Date(),
    };
  },
  computed: {
    progressPercent() {
      return (this.countdown / 60) * 100;
    },
    // 입실 학생
    checkinStudents() {
      return this.studentsStatus.filter(
        (s) => s.check_in_time && !s.check_out_time
      );
    },
    // 퇴실 학생
    checkoutStudents() {
      return this.studentsStatus.filter((s) => s.check_out_time);
    },
    // 현재 탭에 맞는 학생
    displayedStudents() {
      return this.activeTab === "checkin"
        ? this.checkinStudents
        : this.checkoutStudents;
    },
  },
  created() {
    this.fetchStatus();
    this.startCountdown();
  },
  methods: {
    // 학생 상태 가져오기
    async fetchStatus() {
      try {
        const response = await axios.get(`${API_URL}/status`);
        // timeLeft 초기화
        this.studentsStatus = response.data.map((student) => ({
          ...student,
          timeLeft: 0,
        }));
        // 입실 상태인 학생만 타이머 시작
        this.studentsStatus.forEach((student) => {
          if (student.check_in_time && !student.check_out_time) {
            this.startTimer(student);
          }
        });
      } catch (error) {
        console.error("Failed to fetch students status:", error);
      }
    },

    // 전체 새로고침 및 시간 업데이트
    startCountdown() {
      this.countdown = 60;
      if (this.intervalId) clearInterval(this.intervalId);

      this.intervalId = setInterval(() => {
        if (this.countdown > 0) {
          this.countdown--;
        } else {
          this.countdown = 60;
          this.fetchStatus(); // 1분마다 새로고침
        }
        this.currentTime = new Date();
      }, 1000);
    },

    // 학생별 퇴실까지 남은 시간 계산
    startTimer(student) {
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
        }
      }, 1000);
    },
  },
  beforeUnmount() {
    if (this.intervalId) clearInterval(this.intervalId);
  },
};
</script>

<style scoped>
/* 탭 스타일 */
.tabs {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}
.tab-btn {
  padding: 12px 25px;
  border: none;
  background-color: #f0f4c3;
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
  background-color: #d4e157;
  color: #444;
}

/* 새로고침 게이지 */
.refresh-bar-container {
  width: 100%;
  height: 20px;
  background-color: #eee;
  border-radius: 10px;
  overflow: hidden;
  margin: 10px 0;
}
.refresh-bar {
  height: 100%;
  background-color: #4caf50;
  transition: width 1s linear;
}
.refresh-info {
  margin: 10px 0;
  font-size: 18px;
  color: #333;
}

/* 학생 그리드 */
.student-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 20px;
  padding: 20px;
}
</style>
