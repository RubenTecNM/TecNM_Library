<script setup lang="ts">
defineProps<{ title: string; description?: string; version?: string; eyebrow?: string }>()
</script>
<template><div class="intro"><div><div v-if="eyebrow" class="eyebrow">{{ eyebrow }}</div><h1>{{ title }}</h1><p v-if="description">{{ description }}</p></div><span v-if="version" class="version">{{ version }}</span><slot /></div></template>
