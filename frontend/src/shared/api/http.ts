import axios from 'axios'

import router from '../../app/router'
import { clearSessionMarker } from '../utils/sessionCookie'

const baseURL =
  import.meta.env.VITE_API_BASE_URL?.replace(/\/$/, '') ??
  'https://localhost:7001/api'

export const http = axios.create({
  baseURL,
  withCredentials: true,
  headers: {
    Accept: 'application/json',
  },
})

http.interceptors.response.use(
  (response) => response,
  async (error) => {
    const isUnauthorized = error.response?.status === 401
    const isLoginRequest = error.config?.url
      ?.replace(/\?.*$/, '')
      .endsWith('/auth/login')

    if (isUnauthorized && !isLoginRequest) {
      clearSessionMarker()

      if (router.currentRoute.value.name !== 'login') {
        await router.replace({ name: 'login' })
      }
    }

    return Promise.reject(error)
  },
)
