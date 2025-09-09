<template>
  <div class="status-view">
    <h2>학생 상태 현황</h2>

    <!-- 새로고침 게이지 -->
    <div class="refresh-bar-container">
      <div class="refresh-bar" :style="{ width: progressPercent + '%' }"></div>
    </div>
    <div class="refresh-info">
      다음 새로고침까지: <strong>{{ countdown }}초</strong>
    </div>

    <!-- 학생 상태 -->
    <div class="student-grid">
      <student-card
        v-for="student in studentsStatus"
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
      studentsStatus: [],
      countdown: 60,
      intervalId: null,
    };
  },
  computed: {
    progressPercent() {
      return (this.countdown / 60) * 100;
    },
  },
  created() {
    this.fetchStatus();
    this.startCountdown();
  },
  methods: {
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
    startCountdown() {
      this.countdown = 60;
      if (this.intervalId) clearInterval(this.intervalId);

      this.intervalId = setInterval(() => {
        if (this.countdown > 0) {
          this.countdown--;
        } else {
          this.countdown = 60;
        }
      }, 1000);
    },
    startTimer(student) {
      //   if (this.timers[student.id]) {
      //     clearInterval(this.timers[student.id]);
      //   }

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
          // 알림창으로 변경하여 사용자에게 직접 알립니다.
          //   alert(`${student.name}의 예상 학습 시간이 종료되었습니다!`);
          // 여기서 fetchStatus()를 제거하여 무한 루프를 방지합니다.
        }
      }, 1000);
      //   this.timers[student.id] = timerId;
    },
  },
  beforeUnmount() {
    if (this.intervalId) clearInterval(this.intervalId);
  },
};
</script>

<style scoped>
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
.student-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 20px;
  padding: 20px;
}
</style>
