<script setup lang="ts">defineProps<{ label: string; value: string | number; description?: string }>()</script>
<template><div><p>{{ label }}</p><div class="metric-number">{{ value }}</div><p v-if="description">{{ description }}</p></div></template>
