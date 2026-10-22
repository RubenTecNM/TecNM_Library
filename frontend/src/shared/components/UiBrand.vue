<script setup lang="ts">
import { RouterLink } from 'vue-router'
import tecnmLogo from '../assets/tecnm-isologo.svg'
import type { BrandOptions } from './navigation'

withDefaults(defineProps<BrandOptions>(), {
  title: 'TecNM',
  subtitle: 'Campus Monclova',
  showTitle: true,
  showLogo: true,
  logo: tecnmLogo,
})
</script>

<template>
  <RouterLink v-if="showTitle || showLogo" class="brand" to="/" :aria-label="title">
    <img v-if="showLogo" class="brand-logo" :src="logo" alt="" width="40" height="58">
    <span v-if="showTitle">{{ title }}<small v-if="subtitle">{{ subtitle }}</small></span>
  </RouterLink>
</template>

<style scoped>
.brand { min-width: 0; }
.brand span { overflow-wrap: anywhere; }
.brand-logo { flex-shrink: 0; object-fit: contain; background: var(--color-white); border-radius: 4px; padding: 3px; }
</style>
