<script setup lang="ts">
import { isAxiosError } from 'axios'
import { nextTick, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import UiAlert from '../../../shared/components/UiAlert.vue'
import UiButton from '../../../shared/components/UiButton.vue'
import UiField from '../../../shared/components/UiField.vue'
import { login } from '../api/authApi'

const route = useRoute()
const router = useRouter()

const username = ref('')
const password = ref('')
const usernameError = ref('')
const passwordError = ref('')
const formMessage = ref('')
const isSubmitting = ref(false)
const usernameField = ref<{ focus: () => void } | null>(null)
const passwordField = ref<{ focus: () => void } | null>(null)

function clearUsernameError(): void {
  usernameError.value = ''
  formMessage.value = ''
}

function clearPasswordError(): void {
  passwordError.value = ''
  formMessage.value = ''
}

async function submit(): Promise<void> {
  if (isSubmitting.value) return

  usernameError.value = username.value.trim() ? '' : 'Ingresa tu usuario.'
  passwordError.value = password.value ? '' : 'Ingresa tu contraseña.'
  formMessage.value = ''

  if (usernameError.value || passwordError.value) {
    formMessage.value = 'Completa los campos señalados.'
    await nextTick()
    ;(usernameError.value ? usernameField.value : passwordField.value)?.focus()
    return
  }

  isSubmitting.value = true

  try {
    await login({ username: username.value.trim(), password: password.value })

    const redirect = route.query.redirect
    const destination =
      typeof redirect === 'string' && /^\/(?!\/)/.test(redirect)
        ? redirect
        : '/'

    await router.replace(destination)
  } catch (error) {
    if (isAxiosError(error) && error.response?.status === 401) {
      formMessage.value = 'El usuario o la contraseña no son correctos.'
    } else if (isAxiosError(error) && error.response?.status === 400) {
      formMessage.value = 'Revisa los datos e intenta nuevamente.'
    } else {
      formMessage.value =
        'No fue posible iniciar sesión. Verifica tu conexión e intenta nuevamente.'
    }
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <form class="ui-form" :aria-busy="isSubmitting" novalidate @submit.prevent="submit">
    <UiField
      id="username"
      ref="usernameField"
      v-model="username"
      label="Usuario"
      :error="usernameError"
      name="username"
      type="text"
      autocomplete="username"
      autocapitalize="none"
      spellcheck="false"
      required
      :disabled="isSubmitting"
      @update:model-value="clearUsernameError"
    />

    <UiField
      id="password"
      ref="passwordField"
      v-model="password"
      label="Contraseña"
      :error="passwordError"
      name="password"
      type="password"
      autocomplete="current-password"
      required
      :disabled="isSubmitting"
      @update:model-value="clearPasswordError"
    />

    <UiAlert
      v-if="isSubmitting"
      tone="info"
      title="Verificando credenciales…"
      aria-live="polite"
      aria-atomic="true"
    />
    <UiAlert
      v-else-if="formMessage"
      tone="danger"
      :title="formMessage"
      aria-live="polite"
      aria-atomic="true"
    />

    <UiButton type="submit" :loading="isSubmitting" :disabled="isSubmitting">
      {{ isSubmitting ? 'Ingresando…' : 'Ingresar' }}
    </UiButton>
  </form>
</template>
