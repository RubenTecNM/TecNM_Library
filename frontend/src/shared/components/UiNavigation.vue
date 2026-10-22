<script setup lang="ts">
import UiNavLink from './UiNavLink.vue'
import type { NavigationItem } from './navigation'

withDefaults(defineProps<{ items: NavigationItem[]; variant?: 'header' | 'sidebar'; label: string }>(), { variant: 'sidebar' })

function closeGroup(event: KeyboardEvent) {
  const target = event.target as HTMLElement
  const details = target.closest('details')
  if (!details) return
  details.open = false
  details.querySelector('summary')?.focus()
  event.preventDefault()
}
</script>

<template>
  <nav :class="variant === 'header' ? 'topnav' : 'sidenav'" :aria-label="label" @keydown.esc="closeGroup">
    <template v-for="item in items" :key="item.label">
      <details v-if="'children' in item" class="navigation-group">
        <summary>{{ item.label }}</summary>
        <div class="navigation-children">
          <UiNavLink v-for="child in item.children" :key="child.label" :item="child" />
        </div>
      </details>
      <UiNavLink v-else :item="item" />
    </template>
  </nav>
</template>

<style scoped>
nav a { display: block; }
.navigation-group { margin: 0; padding: 0; border: 0; position: relative; }
.navigation-group summary { padding: 10px 12px; color: inherit; font-size: 14px; }
.navigation-group[open] > summary { font-weight: 600; }
.navigation-children { display: grid; gap: 4px; padding-left: 12px; }
.topnav { display: flex; }
.topnav .navigation-children {
  position: absolute;
  top: 100%;
  left: 0;
  min-width: 200px;
  max-width: calc(100vw - 32px);
  padding: 8px;
  z-index: 3;
  color: var(--color-text-primary);
  background: var(--floating-bg);
  border: 1px solid var(--floating-border);
  border-radius: 8px;
  box-shadow: var(--floating-shadow);
}
.topnav :deep(a.active) { border-color: var(--color-accent); }
@media (max-width: 1100px) {
  .topnav { width: 100%; order: 3; margin-left: 0; }
  .topnav .navigation-children { position: static; min-width: 0; }
}
@media (max-width: 640px) {
  .sidenav { display: grid; }
}
</style>
