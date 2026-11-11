import axios from 'axios'

const baseURL =
  import.meta.env.VITE_API_BASE_URL?.replace(/\/$/, '') ??
  '/api'

export const http = axios.create({
  baseURL,
  headers: {
    Accept: 'application/json',
  },
})
