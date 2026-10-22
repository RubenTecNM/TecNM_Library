import { ref, watch } from 'vue'

const dark = ref(window.matchMedia('(prefers-color-scheme: dark)').matches)
watch(dark, (value) => {
  document.documentElement.dataset.theme = value ? 'dark' : 'light'
}, { immediate: true })

export function useTheme() {
  return { dark }
}
