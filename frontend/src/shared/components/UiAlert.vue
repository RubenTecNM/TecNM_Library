<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    tone?: 'success' | 'warning' | 'danger' | 'info'
    title?: string
  }>(),
  {
    tone: 'info',
    title: '',
  },
)

const toneClass = computed(() => (props.tone === 'danger' ? 'error-state' : props.tone))
</script>

<template>
  <div class="message" :class="toneClass" role="status">
    <svg v-if="tone === 'success'" viewBox="0 0 24 24" aria-hidden="true">
      <circle cx="12" cy="12" r="9" />
      <path d="m8 12 3 3 5-6" />
    </svg>
    <svg v-else-if="tone === 'warning'" viewBox="0 0 24 24" aria-hidden="true">
      <path d="m12 3 10 18H2L12 3Zm0 6v5m0 3v.1" />
    </svg>
    <svg v-else-if="tone === 'danger'" viewBox="0 0 24 24" aria-hidden="true">
      <circle cx="12" cy="12" r="9" />
      <path d="m9 9 6 6m0-6-6 6" />
    </svg>
    <svg v-else viewBox="0 0 24 24" aria-hidden="true">
      <circle cx="12" cy="12" r="9" />
      <path d="M12 11v6m0-10v.1" />
    </svg>
    <div>
      <strong v-if="title">{{ title }}</strong>
      <slot name="body"><slot /></slot>
    </div>
  </div>
</template>
