<script setup lang="ts">
import UiBrand from './UiBrand.vue'
import UiNavigation from './UiNavigation.vue'
import type { BrandOptions, NavigationItem } from './navigation'

withDefaults(defineProps<BrandOptions & { items: NavigationItem[]; note?: string }>(), { showTitle: true, showLogo: true })
</script>

<template>
  <aside class="ui-sidebar">
    <UiBrand :title="title" :subtitle="subtitle" :logo="logo" :show-title="showTitle" :show-logo="showLogo" />
    <UiNavigation :items="items" label="Navegación lateral" />
    <p v-if="note" class="side-note ui-text">{{ note }}</p>
    <slot />
  </aside>
</template>

<style scoped>
.ui-sidebar {
  position: sticky;
  top: 0;
  align-self: start;
  height: 100dvh;
  overflow-y: auto;
  overscroll-behavior-y: contain;
}
@media (max-width: 640px) {
  .ui-sidebar {
    position: static;
    height: auto;
    overflow-y: visible;
  }
}
.ui-sidebar > :deep(.brand) { margin-bottom: 24px; }
.ui-sidebar :deep(.brand small) { color: var(--color-text-secondary); }
</style>
