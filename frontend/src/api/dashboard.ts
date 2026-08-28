import { apiClient } from "./client";
import type { DashboardSummary } from "./types";

export async function fetchDashboardSummary() {
  const { data } = await apiClient.get<DashboardSummary>("/dashboard/summary");
  return data;
}
