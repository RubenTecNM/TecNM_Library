<script setup lang="ts">
import { isAxiosError } from 'axios'
import { computed, onMounted, ref } from 'vue'
import {
  UiAlert, UiBadge, UiBasePage, UiButton, UiCallout, UiCard, UiChip, UiColorPalette,
  UiDialog, UiDisclosure, UiDivider, UiField, UiLayout, UiMetric,
  UiRadio, UiRange, UiTable, UiText, UiToast, UiToggle, UiTypeSample,
} from '../../../shared/components'
import { useTheme } from '../../../shared/composables/useTheme'
import { colorTokens } from '../../../shared/styles/colorTokens'
import { me } from '../api/authApi'
import type { UserResponse } from '../types/auth'

const user = ref<UserResponse | null>(null)
const errorMessage = ref('')
const isLoading = ref(true)

const roleLabel = computed(() =>
  user.value?.role === 'Admin' ? 'Administrador' : 'Usuario',
)

async function loadSession(): Promise<void> {
  isLoading.value = true
  errorMessage.value = ''

  try {
    user.value = await me()
  } catch (error) {
    if (!isAxiosError(error) || error.response?.status !== 401) {
      errorMessage.value =
        'No fue posible consultar la sesión. Verifica tu conexión e intenta nuevamente.'
    }
  } finally {
    isLoading.value = false
  }
}

onMounted(loadSession)


const { dark } = useTheme()
const theme = computed(() => dark.value ? 'dark' : 'light')
const previewOpen = ref(false)
const toast = ref<InstanceType<typeof UiToast> | null>(null)
const filter = ref('Todos')
const project = ref('')
const department = ref('Dirección general')
const date = ref('2026-09-10')
const email = ref('direccion@')
const notes = ref('')
const notifyTeam = ref(true)
const attachSummary = ref(false)
const visibility = ref('internal')
const reminders = ref(true)
const priority = ref(65)
const emailError = computed(() => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value) ? '' : 'Escribe un correo completo, por ejemplo, nombre@empresa.com.')
const palette = [
  { token: '--color-primary', label: 'Primario' }, { token: '--color-accent', label: 'Acento' },
  { token: '--color-bg-main', label: 'Lienzo' }, { token: '--color-surface-white', label: 'Superficie' },
  { token: '--color-text-primary', label: 'Texto principal' }, { token: '--color-border', label: 'Borde' },
]
const tokens = colorTokens.map(token => ({ token, label: token }))
const statuses = [
  { tone: 'success', label: 'Aprobado' }, { tone: 'warning', label: 'Pendiente' },
  { tone: 'danger', label: 'Crítico' }, { tone: 'info', label: 'En proceso' },
  { tone: 'purple', label: 'Auditoría' },
] as const
const columns = [
  { key: 'document', label: 'Documento' }, { key: 'owner', label: 'Responsable' },
  { key: 'status', label: 'Estado' }, { key: 'updated', label: 'Actualización' },
] as const
const rows = [
  { id: 1, document: 'Informe de gestión', owner: 'Mariana López', status: 'Aprobado', tone: 'success', updated: '10 sep 2026' },
  { id: 2, document: 'Presupuesto operativo', owner: 'Carlos Mendoza', status: 'Pendiente', tone: 'warning', updated: '09 sep 2026' },
  { id: 3, document: 'Control de cumplimiento', owner: 'Ana Torres', status: 'Auditoría', tone: 'purple', updated: '08 sep 2026' },
] as const
function notify(message: string) { toast.value?.show(message) }
function selectFilter(value: string) {
  filter.value = value
  notify(`Filtro de ejemplo seleccionado: ${value}.`)
}
</script>

<template>
    <UiBasePage fluid :title="user ? `Bienvenido, ${user.name}` : 'Bienvenido a TecNM'"
      description="Tu cuenta institucional y los componentes de nuestra plataforma.">
    <UiLayout id="cuenta" class="account-section" :aria-busy="isLoading">
      <UiAlert v-if="isLoading" tone="info" title="Consultando sesión…" />
      <UiCard v-else-if="user" title="Datos de la cuenta">
        <dl class="identity-list">
          <div><dt>Nombre</dt><dd>{{ user.name }}</dd></div>
          <div><dt>Usuario</dt><dd>{{ user.username }}</dd></div>
          <div><dt>Correo</dt><dd>{{ user.email }}</dd></div>
          <div><dt>Rol</dt><dd>{{ roleLabel }}</dd></div>
        </dl>
      </UiCard>
      <UiAlert v-else tone="danger" title="No se pudo cargar la cuenta">
        <UiText>{{ errorMessage }}</UiText>
        <UiButton @click="loadSession">Intentar nuevamente</UiButton>
      </UiAlert>
    </UiLayout>
    <UiCard id="colores" title="Paleta de color" :description="dark ? 'Modo oscuro' : 'Modo claro'">
      <UiColorPalette :tokens="palette" :theme="theme" />
      <UiDisclosure title="Ver todos los colores y tokens del tema"><UiColorPalette :tokens="tokens" :theme="theme" compact /></UiDisclosure>
    </UiCard>
    <UiLayout kind="grid">
      <UiLayout>
        <UiCard id="botones" title="Botones y acciones" description="Radio de 8 px">
          <UiLayout kind="row">
            <UiButton @click="notify('Cambios guardados en esta demostración.')">Guardar cambios</UiButton>
            <UiButton variant="accent" @click="notify('Informe generado en esta demostración.')">Generar informe</UiButton>
          </UiLayout>
          <UiLayout kind="row">
            <UiButton variant="secondary" @click="previewOpen = true">Abrir diálogo</UiButton>
            <UiButton variant="danger" @click="notify('Ejemplo de acción destructiva. No se eliminó ningún dato.')">Eliminar</UiButton>
            <UiButton disabled>Desactivado</UiButton>
          </UiLayout>
          <UiDivider />
          <UiLayout kind="row" role="group" aria-label="Filtros de ejemplo">
            <UiChip v-for="item in ['Todos', 'Aprobados', 'Pendientes']" :key="item" :pressed="filter === item" @click="selectFilter(item)">{{ item }}</UiChip>
          </UiLayout>
        </UiCard>
        <UiCard id="controles" title="Controles de formulario" description="Radio de 8 px">
          <UiField v-model="project" label="Nombre del proyecto" placeholder="Ej. Informe trimestral" />
          <UiLayout kind="fields">
            <UiField v-model="department" label="Departamento" as="select" :options="['Dirección general', 'Finanzas', 'Auditoría'].map(value => ({ value, label: value }))" />
            <UiField v-model="date" label="Fecha de revisión" type="date" />
          </UiLayout>
          <UiField v-model="email" label="Correo de contacto" type="email" :error="emailError" />
          <UiField v-model="notes" label="Observaciones" as="textarea" rows="2" placeholder="Añade contexto para el equipo…" />
          <UiLayout kind="row"><UiToggle v-model="notifyTeam" label="Notificar al equipo" /><UiToggle v-model="attachSummary" label="Adjuntar resumen" /></UiLayout>
          <UiLayout kind="row" role="group" aria-label="Visibilidad">
            <UiRadio v-model="visibility" name="visibility" value="internal" label="Interno" />
            <UiRadio v-model="visibility" name="visibility" value="shared" label="Compartido" />
          </UiLayout>
          <UiDivider />
          <UiToggle v-model="reminders" type="switch" label="Activar recordatorios" />
          <UiRange v-model="priority" label="Nivel de prioridad" :min="0" :max="100" />
        </UiCard>
      </UiLayout>
      <UiLayout>
        <UiCard id="mensajes" title="Mensajes y estados" description="Color con significado">
          <UiAlert tone="success" title="Cambios guardados">La información del proyecto está actualizada.</UiAlert>
          <UiAlert tone="warning" title="Revisión pendiente">Verifica los datos antes de aprobar el informe.</UiAlert>
          <UiAlert tone="danger" title="No se pudo guardar">Comprueba tu conexión y vuelve a intentarlo.</UiAlert>
          <UiAlert tone="info" title="Informe en proceso">Recibirás una notificación cuando esté disponible.</UiAlert>
          <UiDivider />
          <UiLayout kind="row"><UiBadge v-for="status in statuses" :key="status.tone" :tone="status.tone">{{ status.label }}</UiBadge></UiLayout>
        </UiCard>
        <UiCard id="datos" title="Resumen ejecutivo" metric>
          <template #header><UiBadge tone="success">Actualizado</UiBadge></template>
          <UiMetric label="Documentos aprobados" value="1,248" description="Indicador de ejemplo · Cifra de 36 px y acento superior de 4 px." />
          <UiCallout title="Recomendación">Prioriza los documentos pendientes antes del cierre del periodo.</UiCallout>
        </UiCard>
      </UiLayout>
    </UiLayout>
    <UiCard id="tabla" title="Tabla de seguimiento" description="Datos ilustrativos · Segunda fila seleccionada" class="ui-space">
      <UiTable label="Tabla de documentos" :columns="[...columns]" :rows="[...rows]" :selected="2">
        <template #cell-status="{ row }"><UiBadge :tone="row.tone">{{ row.status }}</UiBadge></template>
      </UiTable>
    </UiCard>
    <UiLayout kind="grid">
      <UiCard id="tipografia" title="Jerarquía tipográfica" description="Sans serif">
        <UiTypeSample><UiText as="div" variant="display">Claridad para decidir.</UiText><UiText as="small" variant="caption">Título · 700 · tracking −0.025 em</UiText></UiTypeSample>
        <UiTypeSample><UiText as="h3">Información que mantiene el orden</UiText><UiText as="small" variant="caption">Encabezado · 600</UiText></UiTypeSample>
        <UiTypeSample><UiText as="div" variant="eyebrow">Reporte ejecutivo</UiText><UiText>Una lectura serena, con una altura de línea de 1.6 y una jerarquía de texto consistente.</UiText></UiTypeSample>
        <UiTypeSample><UiText as="span" variant="caption">Metadatos de ejemplo · 12 px · Texto atenuado</UiText></UiTypeSample>
      </UiCard>
      <UiCard id="elevacion" title="Superficies y elevación" description="Radios de 12 px">
        <UiLayout>
          <UiText>Sombras difusas en modo claro. Superficies y bordes luminosos en modo oscuro.</UiText>
          <UiCard elevation="floating">
            <UiText as="h3">Panel flotante</UiText>
            <UiText class="floating-description">Segunda capa de elevación para menús y paneles.</UiText>
            <UiButton variant="secondary" @click="previewOpen = true">Ver capa de diálogo</UiButton>
          </UiCard>
        </UiLayout>
      </UiCard>
    </UiLayout>
    </UiBasePage>
  <UiDialog v-model="previewOpen" title="Revisión del informe">
    <UiText>Ejemplo de diálogo con la tercera capa de elevación, borde definido y fondo translúcido.</UiText>
    <template #actions><UiButton autofocus @click="previewOpen = false">Cerrar diálogo</UiButton></template>
  </UiDialog>
  <UiToast ref="toast" />
</template>

<style scoped>
.account-section { margin-bottom: 24px; scroll-margin-top: 24px; }
.identity-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  margin: 0;
}

.identity-list > div {
  min-width: 0;
  padding: 1rem 1.25rem;
  border-bottom: 1px solid var(--color-border-light);
}

.identity-list > div:nth-child(odd) {
  border-right: 1px solid var(--color-border-light);
}

.identity-list > div:nth-last-child(-n + 2) {
  border-bottom: 0;
}

.identity-list dt {
  margin-bottom: 0.25rem;
  color: var(--color-text-secondary);
  font-size: 0.875rem;
}

.identity-list dd {
  margin: 0;
  overflow-wrap: anywhere;
  font-size: 1.125rem;
}


@media (max-width: 640px) {
  .identity-list { grid-template-columns: 1fr; }
  .identity-list > div,
  .identity-list > div:nth-child(odd),
  .identity-list > div:nth-last-child(-n + 2) {
    border-right: 0;
    border-bottom: 1px solid var(--color-border-light);
  }
  .identity-list > div:last-child { border-bottom: 0; }
}
</style>
