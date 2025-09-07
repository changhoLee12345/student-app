<template>
  <div
    class="student-card"
    :class="{ 'status-out': isCheckOut }"
    @mouseenter="showTooltip = true"
    @mouseleave="showTooltip = false"
  >
    <div class="card-name" :class="{ 'blinking-text': isTimeLow }">
      {{ student.name }}
    </div>
    <div class="card-info">
      <span>{{ student.grade }}학년</span> |
      <span>{{ student.study_hours }}분 학습</span>
    </div>
    <div class="card-time">입실: {{ formattedCheckInTime }}</div>
    <div class="card-time">
      {{ isCheckOut ? "퇴실" : "예상" }}: {{ formattedCheckOutTime }}
    </div>
    <div class="graph-bar-wrapper">
      <div class="graph-bar" :style="graphStyle"></div>
    </div>
    <div class="remaining-time-text">{{ remainingTimeText }}</div>
    <div v-if="student.special_notes && showTooltip" class="tooltip">
      {{ student.special_notes }}
    </div>
  </div>
</template>

<script>
export default {
  props: {
    student: Object,
  },
  data() {
    return {
      showTooltip: false,
    };
  },
  computed: {
    isCheckOut() {
      return !!this.student.check_out_time;
    },
    formattedCheckInTime() {
      if (!this.student.check_in_time) return "-";
      return new Date(this.student.check_in_time).toLocaleTimeString("ko-KR", {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
      });
    },
    formattedCheckOutTime() {
      const time = this.isCheckOut
        ? this.student.check_out_time
        : this.student.auto_check_out_time;
      if (!time) return "-";
      return new Date(time).toLocaleTimeString("ko-KR", {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
      });
    },
    timeLeftPercentage() {
      if (this.isCheckOut || !this.student.timeLeft) return 0;
      const totalDuration = this.student.study_hours * 60 * 1000;
      const elapsedDuration = totalDuration - this.student.timeLeft;
      return (elapsedDuration / totalDuration) * 100;
    },
    graphStyle() {
      const percentage = this.timeLeftPercentage;
      const color = `hsl(${120 - percentage * 1.2}, 70%, 50%)`;
      return {
        width: `${percentage}%`,
        backgroundColor: color,
      };
    },
    remainingTimeText() {
      if (this.isCheckOut) return "활동 종료";
      if (!this.student.timeLeft) return "";
      const minutes = Math.floor(this.student.timeLeft / 60000);
      const seconds = Math.floor((this.student.timeLeft % 60000) / 1000);
      return `${minutes}분 ${seconds}초 남음`;
    },
    isTimeLow() {
      if (this.isCheckOut || !this.student.timeLeft) {
        return false;
      }
      const threeMinutesInMs = 3 * 60 * 1000;
      return this.student.timeLeft < threeMinutesInMs;
    },
  },
};
</script>

<style scoped>
/* 깜빡이는 애니메이션 정의 */
@keyframes blink-animation {
  0% {
    opacity: 1;
  }
  50% {
    opacity: 0.3;
  }
  100% {
    opacity: 1;
  }
}

/* 3분 미만일 때 적용될 클래스 */
.blinking-text {
  animation: blink-animation 1s infinite;
  color: #ff5722;
}

/* 기존 style.css의 학생 카드 관련 스타일을 모두 여기에 붙여넣으세요 */
.student-card {
  position: relative;
  background-color: #f7f7f7;
  border-radius: 12px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  padding: 20px;
  text-align: left;
  transition: transform 0.3s ease-in-out, box-shadow 0.3s ease-in-out;
  border-left: 6px solid #ffb74d; /* 입실 상태 */
}

/* 퇴실한 학생 카드의 비활성화 스타일 */
.student-card.status-out {
  background-color: #e0e0e0;
  border-left-color: #bdbdbd; /* 회색 테두리 */
  color: #757575; /* 텍스트 색상 연하게 */
  opacity: 0.8;
  box-shadow: none;
  pointer-events: none; /* 클릭 이벤트 비활성화 */
}

/* 호버 효과 제거 */
.student-card.status-out:hover {
  transform: none;
  box-shadow: none;
}
</style>
