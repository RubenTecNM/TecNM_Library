<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    tone?: 'success' | 'warning' | 'danger' | 'info' | 'purple'
  }>(),
  {
    tone: 'info',
  },
)

const toneClass = computed(() => (props.tone === 'danger' ? 'error-state' : props.tone))
</script>

<template>
  <span class="badge" :class="toneClass"><slot /></span>
</template>
