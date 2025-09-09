<template>
  <div class="container home-page">
    <h1 class="main-title">✨ 꼬마 탐험가들의 현재 학습 현황 ✨</h1>
    <div class="student-grid">
      <student-card
        v-for="student in studentsStatus"
        :key="student.id"
        :student="student"
      />
    </div>
  </div>
</template>

<script>
import axios from "axios";
import StudentCard from "./StudentCard.vue";

const API_URL = "http://localhost:3000/api/students";

export default {
  name: "HomePage",
  components: {
    StudentCard,
  },
  data() {
    return {
      studentsStatus: [],
      timers: {},
    };
  },
  created() {
    console.log("homepage");
    this.fetchStatus();
    this.startRefreshTimer();
  },
  methods: {
    async fetchStatus() {
      try {
        const response = await axios.get(`${API_URL}/status`);
        this.studentsStatus = response.data
          .filter((student) => student.check_in_time && !student.check_out_time)
          .map((student) => ({
            ...student,
            timeLeft: 0,
          }));
        this.studentsStatus.forEach((student) => {
          this.startTimer(student);
        });
      } catch (error) {
        console.error("Failed to fetch students status:", error);
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
        }
      }, 1000);
      this.timers[student.id] = timerId;
    },
    startRefreshTimer() {
      // 1분(60초)마다 fetchStatus를 호출하여 화면을 새로고침
      this.refreshInterval = setInterval(() => {
        this.fetchStatus();
      }, 60000); // 60000ms = 1분
    },
  },
  beforeUnmount() {
    for (const timerId in this.timers) {
      clearInterval(this.timers[timerId]);
    }
    clearInterval(this.refreshInterval);
  },
};
</script>

<style scoped>
.home-page {
  padding: 40px;
}
.student-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
  padding: 20px;
}
.main-title {
  text-align: center;
  color: #4caf50;
  margin-bottom: 30px;
  font-size: 2.2em;
  font-weight: bold;
}
</style>
