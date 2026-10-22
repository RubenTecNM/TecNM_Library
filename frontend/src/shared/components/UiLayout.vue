<script setup lang="ts">
withDefaults(defineProps<{ kind?: 'grid' | 'stack' | 'row' | 'fields'; as?: string }>(), { kind: 'stack', as: 'div' })
</script>
<template><component :is="as" :class="kind"><slot /></component></template>
