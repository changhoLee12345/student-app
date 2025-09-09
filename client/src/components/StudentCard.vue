<template>
  <div
    class="student-card"
    :class="{ 'status-out': isCheckOut }"
    @mouseenter="showTooltip = true"
    @mouseleave="showTooltip = false"
    @click="selectCheckoutStudent(student)"
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
    <div class="time-progress-container">
      <div class="start-time-text">{{ student.study_hours }}분</div>
      <div class="graph-bar-wrapper">
        <div class="graph-bar" :style="graphStyle"></div>
      </div>
      <div class="end-time-text">0분</div>
    </div>
    <div class="remaining-time-text">{{ remainingTimeText }}</div>
    <div
      v-if="student.special_notes && showTooltip && fromView === 'manage'"
      class="tooltip"
    >
      {{ student.special_notes }}
    </div>
  </div>
</template>

<script>
export default {
  props: {
    student: Object,
    fromView: String,
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
  methods: {
    selectCheckoutStudent(student) {
      // if (
      //   this.fromView === "manage" &&
      //   (!this.isCheckOut ||
      //     new Date(this.student.auto_check_out_time).getTime() >
      //       new Date().getTime())
      // ) {
      this.$emit("select-checkout-student", student);
      // }
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
  /* pointer-events: none; 클릭 이벤트 비활성화 */
}

/* 호버 효과 제거 */
.student-card.status-out:hover {
  transform: none;
  box-shadow: none;
}

.tooltip {
  position: absolute;
  top: -10px;
  left: 50%;
  transform: translateX(-50%) translateY(-100%);
  background-color: #555;
  color: white;
  padding: 10px;
  border-radius: 8px;
  white-space: pre-wrap;
  text-align: left;
  font-size: 0.85em;
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.3s ease, transform 0.3s ease;
  z-index: 10;
}

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

.card-name {
  font-size: 1.8em;
  font-weight: bold;
  color: #5d4037;
  margin-bottom: 5px;
}

.student-card:hover .tooltip {
  opacity: 1;
  visibility: visible;
  transform: translateX(-50%) translateY(-110%);
}

/* 🟢 추가: 학습 시간 게이지 바 컨테이너 스타일 */
.time-progress-container {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 15px;
}

.start-time-text,
.end-time-text {
  font-size: 0.8em;
  color: #616161;
  font-weight: bold;
}

.graph-bar-wrapper {
  flex-grow: 1; /* 컨테이너 내에서 남은 공간을 모두 차지하도록 설정 */
  height: 8px;
  background-color: #e0e0e0;
  border-radius: 5px;
  overflow: hidden;
}

/* 🟢 기존 .remaining-time-text 스타일 수정 */
.remaining-time-text {
  font-size: 0.75em;
  color: #d32f2f;
  font-weight: bold;
  margin-top: 5px;
  text-align: right;
  /* 기존에 'text-align: right'가 설정되어 있으므로, 이 부분은 그대로 두면 됩니다. */
}

.graph-bar {
  height: 100%;
  background-color: #ffc107;
  transition: width 0.5s ease, background-color 0.5s ease;
}
</style>
