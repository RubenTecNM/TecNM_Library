import { http } from '../../../shared/api/http'
import type { LoginRequest, UserResponse } from '../types/auth'

export async function login(credentials: LoginRequest): Promise<UserResponse> {
  const { data } = await http.post<UserResponse>('/auth/login', credentials)
  return data
}

export async function me(): Promise<UserResponse> {
  const { data } = await http.get<UserResponse>('/auth/me')
  return data
}

export async function logout(): Promise<void> {
  await http.post('/auth/logout')
}
