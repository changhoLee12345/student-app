import { createApp } from "vue";
import App from "./App.vue";
import router from "./router"; // 라우터 임포트
import StudentCard from "./components/StudentCard.vue";

const app = createApp(App);
app.use(router); // 라우터 사용 선언
app.component("StudentCard", StudentCard);
app.mount("#app");
