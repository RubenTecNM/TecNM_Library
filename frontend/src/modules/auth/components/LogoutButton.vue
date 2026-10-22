<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { UiButton } from '../../../shared/components'
import { clearSessionMarker } from '../../../shared/utils/sessionCookie'
import { logout } from '../api/authApi'

const router = useRouter()
const isLoggingOut = ref(false)

async function endSession(): Promise<void> {
  if (isLoggingOut.value) return

  isLoggingOut.value = true

  try {
    await logout()
  } catch {
    // The local session marker must disappear even if the API is unavailable.
  } finally {
    clearSessionMarker()
    await router.replace({ name: 'login' })
    isLoggingOut.value = false
  }
}

</script>

<template>
  <UiButton variant="secondary" :loading="isLoggingOut" :disabled="isLoggingOut" @click="endSession">
    {{ isLoggingOut ? 'Cerrando sesión…' : 'Cerrar sesión' }}
  </UiButton>
</template>
