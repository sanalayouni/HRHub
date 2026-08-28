import { apiClient } from "./client";
import type { RequestFilters, RequestListItem } from "./types";

export async function fetchDecisions(filters: RequestFilters = {}) {
  const { data } = await apiClient.get<RequestListItem[]>("/decisions", {
    params: filters,
  });
  return data;
}
