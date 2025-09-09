import { createRouter, createWebHistory } from "vue-router";
import HomePage from "../App.vue";
import ManagePage from "../views/ManageView.vue";

const routes = [
  {
    path: "/",
    name: "HomePage",
    component: HomePage,
  },
  {
    path: "/manage",
    name: "ManagePage",
    component: ManagePage,
  },
];

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes,
});

export default router;
