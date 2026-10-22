<script setup lang="ts">
import UiPageHeader from './UiPageHeader.vue'

withDefaults(defineProps<{
  fluid?: boolean
  title?: string
  description?: string
}>(), { fluid: false })
</script>

<template>
  <div class="base-page" :class="{ 'base-page--fluid': fluid }">
    <slot name="header">
      <UiPageHeader v-if="title" :title="title" :description="description">
        <slot name="actions" />
      </UiPageHeader>
    </slot>
    <slot />
  </div>
</template>

<style scoped>
.base-page {
  width: 100%;
  min-width: 0;
  max-width: var(--page-max-width, 960px);
  margin-inline: auto;
}
.base-page--fluid { max-width: none; }
</style>
