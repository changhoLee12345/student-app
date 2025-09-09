<template>
  <div class="chart-container">
    <canvas ref="chartCanvas"></canvas>
  </div>
</template>

<script>
import { Chart, registerables } from "chart.js";
import { nextTick } from "vue";
Chart.register(...registerables);

export default {
  name: "RefreshChart",
  props: {
    refreshLogs: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      chart: null,
    };
  },
  watch: {
    refreshLogs() {
      this.renderChart();
    },
  },
  mounted() {
    this.renderChart();
  },
  methods: {
    async renderChart() {
      await nextTick();
      if (!this.$refs.chartCanvas) return;

      if (this.chart) {
        this.chart.destroy();
      }

      const ctx = this.$refs.chartCanvas.getContext("2d");
      this.chart = new Chart(ctx, {
        type: "line",
        data: {
          labels: this.refreshLogs.map((log, i) => `#${i + 1}`),
          datasets: [
            {
              label: "Refresh Time",
              data: this.refreshLogs.map((log) => log.time),
              borderColor: "#4e73df",
              backgroundColor: "rgba(78,115,223,0.2)",
              fill: true,
              tension: 0.3,
              pointRadius: 5,
            },
          ],
        },
      });
    },
  },
};
</script>

<style scoped></style>
