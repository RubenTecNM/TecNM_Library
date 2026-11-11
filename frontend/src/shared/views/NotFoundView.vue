<script setup lang="ts">
import { useRouter } from 'vue-router'
import { UiButton, UiCard, UiPageHeader, UiText, UiToggle } from '../components'
import { useTheme } from '../composables/useTheme'

const router = useRouter()
const { dark } = useTheme()

function goHome() {
  router.push('/')
}
</script>

<template>
  <div class="not-found-page">
    <header class="not-found-header">
      <UiText as="div" class="not-found-brand">
        TecNM<UiText as="small">Campus Monclova</UiText>
      </UiText>
      <UiToggle v-model="dark" type="switch" label="Modo oscuro" class="theme" />
    </header>
    <main class="not-found-main">
      <UiCard class="not-found-card">
        <UiPageHeader
          title="404 · Página no encontrada"
          description="La ruta solicitada no existe, fue movida o no está disponible."
        />
        <div class="not-found-content">
          <UiText variant="body" class="not-found-message">
            Verifica que la dirección ingresada sea correcta o regresa a la página principal del sistema.
          </UiText>
          <div class="not-found-actions">
            <UiButton variant="primary" @click="goHome">
              Volver al inicio
            </UiButton>
          </div>
        </div>
      </UiCard>
    </main>
    <footer class="not-found-footer">
      <UiText variant="body">Tecnológico Nacional de México · Campus Monclova</UiText>
    </footer>
  </div>
</template>

<style scoped>
.not-found-page {
  min-height: 100dvh;
  display: flex;
  flex-direction: column;
}
.not-found-header {
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
.not-found-brand {
  font-size: 22px;
  font-weight: 700;
  line-height: 1.3;
}
.not-found-brand small {
  display: block;
  color: var(--color-white);
  font-size: 12px;
  font-weight: 400;
}
.not-found-main {
  flex: 1;
  display: grid;
  place-items: center;
  padding: 48px 16px;
}
.not-found-card {
  width: min(100%, 520px);
  border-top: 4px solid var(--color-accent);
}
.not-found-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-top: 16px;
}
.not-found-message {
  color: var(--color-text-muted);
}
.not-found-actions {
  display: flex;
  justify-content: flex-end;
}
.not-found-footer {
  padding: 24px 16px;
  text-align: center;
  background: var(--color-footer-bg);
}
.not-found-footer p {
  margin: auto;
  color: var(--color-white);
}
@media (max-width: 640px) {
  .not-found-header {
    padding: 16px;
  }
  .not-found-main {
    padding: 32px 16px;
  }
  .not-found-actions {
    justify-content: stretch;
  }
  .not-found-actions button {
    width: 100%;
  }
}
</style>
