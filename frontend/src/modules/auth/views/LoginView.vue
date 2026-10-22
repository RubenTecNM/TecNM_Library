<script setup lang="ts">
import { UiCard, UiPageHeader, UiText, UiToggle } from '../../../shared/components'
import { useTheme } from '../../../shared/composables/useTheme'
import LoginForm from '../components/LoginForm.vue'

const { dark } = useTheme()
</script>

<template>
  <div class="login-page">
    <header class="login-header">
      <UiText as="div" class="login-brand">TecNM<UiText as="small">Campus Monclova</UiText></UiText>
      <UiToggle v-model="dark" type="switch" label="Modo oscuro" class="theme" />
    </header>
    <main class="login-main">
      <UiCard class="login-card">
        <UiPageHeader title="Iniciar sesión" description="Ingresa con tus credenciales institucionales." />
        <LoginForm />
      </UiCard>
    </main>
    <footer class="login-footer">
      <UiText variant="body">Tecnológico Nacional de México · Campus Monclova</UiText>
    </footer>
  </div>
</template>

<style scoped>
.login-page {
  min-height: 100dvh;
  display: flex;
  flex-direction: column;
}
.login-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 16px;
  padding: 16px 32px;
  color: var(--color-white);
  background: var(--color-header-bg);
  border-bottom: 1px solid var(--color-border);
}
.login-brand { font-size: 22px; font-weight: 700; line-height: 1.3; }
.login-brand small { display: block; color: var(--color-white); font-size: 12px; font-weight: 400; }
.login-main { flex: 1; display: grid; place-items: center; padding: 48px 16px; }
.login-card { width: min(100%, 460px); border-top: 4px solid var(--color-accent); }
.login-footer { padding: 24px 16px; text-align: center; background: var(--color-footer-bg); }
.login-footer p { margin: auto; color: var(--color-white); }
@media (max-width: 640px) {
  .login-header { padding: 16px; }
  .login-main { padding: 32px 16px; }
}
</style>
