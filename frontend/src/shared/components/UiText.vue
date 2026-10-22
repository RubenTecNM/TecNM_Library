<script setup lang="ts">
withDefaults(defineProps<{ as?: string; variant?: 'default' | 'body' | 'display' | 'caption' | 'eyebrow' }>(), { as: 'p', variant: 'default' })
</script>
<template><component :is="as" class="ui-text" :class="variant === 'eyebrow' ? 'eyebrow' : `ui-text--${variant}`"><slot /></component></template>
