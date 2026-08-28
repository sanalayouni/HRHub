import { apiClient } from "./client";
import type {
  EmployeeCreate,
  EmployeeListItem,
  EmployeeOut,
  EmployeeUpdate,
  RequestListItem,
} from "./types";

export async function fetchEmployees(params: { search?: string; department?: string } = {}) {
  const { data } = await apiClient.get<EmployeeListItem[]>("/employees", { params });
  return data;
}

export async function fetchEmployee(id: string) {
  const { data } = await apiClient.get<EmployeeOut>(`/employees/${id}`);
  return data;
}

export async function createEmployee(payload: EmployeeCreate) {
  const { data } = await apiClient.post<EmployeeOut>("/employees", payload);
  return data;
}

export async function updateEmployee(id: string, payload: EmployeeUpdate) {
  const { data } = await apiClient.patch<EmployeeOut>(`/employees/${id}`, payload);
  return data;
}

export async function deleteEmployee(id: string) {
  await apiClient.delete(`/employees/${id}`);
}

export async function fetchEmployeeRequests(id: string) {
  const { data } = await apiClient.get<RequestListItem[]>(`/employees/${id}/requests`);
  return data;
}
