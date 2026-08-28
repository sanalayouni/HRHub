import { apiClient } from "./client";

export interface LoginResponse {
  access_token: string;
  token_type: string;
}

export async function login(email: string, password: string) {
  const { data } = await apiClient.post<LoginResponse>("/auth/login", { email, password });
  return data;
}

export interface MeResponse {
  email: string;
  company: string;
}

export async function fetchMe() {
  const { data } = await apiClient.get<MeResponse>("/auth/me");
  return data;
}
