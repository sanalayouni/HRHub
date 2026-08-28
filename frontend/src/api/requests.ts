import { apiClient } from "./client";
import type {
  DecisionDecideIn,
  DecisionOut,
  RequestDetail,
  RequestFilters,
  RequestListItem,
} from "./types";

export async function fetchRequests(filters: RequestFilters = {}) {
  const { data } = await apiClient.get<RequestListItem[]>("/requests", {
    params: filters,
  });
  return data;
}

export async function fetchRequest(id: string) {
  const { data } = await apiClient.get<RequestDetail>(`/requests/${id}`);
  return data;
}

export async function decideRequest(id: string, payload: DecisionDecideIn) {
  const { data } = await apiClient.post<DecisionOut>(
    `/requests/${id}/decision`,
    payload
  );
  return data;
}
