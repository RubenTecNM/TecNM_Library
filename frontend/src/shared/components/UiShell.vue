<script setup lang="ts">
withDefaults(defineProps<{ showHeader?: boolean; showSidebar?: boolean }>(), {
  showHeader: true,
  showSidebar: true,
})
</script>

<template>
  <div class="app-shell">
    <slot v-if="showHeader" name="header" />
    <div class="layout" :class="{ 'layout--content-only': !showSidebar }">
      <slot v-if="showSidebar" name="sidebar" />
      <main id="inicio" class="ui-main"><slot /></main>
    </div>
    <footer v-if="$slots.footer" class="ui-footer"><slot name="footer" /></footer>
  </div>
</template>

<style scoped>
.app-shell { min-height: 100dvh; display: flex; flex-direction: column; }
.layout {
  --sidebar-width: 216px;
  width: 100%;
  max-width: none;
  margin: 0;
  flex: 1;
  grid-template-columns: var(--sidebar-width) minmax(0, 1fr);
}
.ui-main { width: 100%; }
@media (max-width: 1100px) {
  .layout { --sidebar-width: 180px; }
}
.layout--content-only { grid-template-columns: minmax(0, 1fr); }
</style>
