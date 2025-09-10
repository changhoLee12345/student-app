import { createApp } from "vue";
import App from "./App.vue";
import router from "./router";
// import commonMixin from "./mixins/commonMixin.js";

createApp(App) //
  .use(router)
  // .mixin(commonMixin)
  .mount("#app");
