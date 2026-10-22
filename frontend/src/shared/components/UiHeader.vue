<script setup lang="ts">
import UiBrand from './UiBrand.vue'
import UiNavigation from './UiNavigation.vue'
import type { BrandOptions, NavigationItem } from './navigation'

withDefaults(defineProps<BrandOptions & { items: NavigationItem[] }>(), { showTitle: true, showLogo: true })
</script>

<template>
  <header class="topbar">
    <UiBrand :title="title" :subtitle="subtitle" :logo="logo" :show-title="showTitle" :show-logo="showLogo" />
    <UiNavigation :items="items" variant="header" label="Navegación principal" />
    <div v-if="$slots.default" class="header-actions"><slot /></div>
  </header>
</template>

<style scoped>
.topbar { flex-wrap: wrap; }
.header-actions { display: flex; align-items: center; flex-wrap: wrap; gap: 12px; margin-left: auto; }
</style>
