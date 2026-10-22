export type UserRole = 'Admin' | 'User'

export interface LoginRequest {
  username: string
  password: string
}

export interface UserResponse {
  id: string
  username: string
  email: string
  name: string
  role: UserRole
}
