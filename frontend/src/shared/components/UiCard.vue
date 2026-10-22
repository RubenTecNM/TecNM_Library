<script setup lang="ts">
withDefaults(defineProps<{ title?: string; description?: string; elevation?: 'card' | 'floating'; metric?: boolean }>(), { elevation: 'card' })
</script>
<template>
  <section :class="[elevation === 'floating' ? 'elevation' : 'card', { metric }]">
    <div v-if="title || $slots.header" class="section-head">
      <h2 v-if="title">{{ title }}</h2><slot name="header"><p v-if="description">{{ description }}</p></slot>
    </div>
    <slot />
  </section>
</template>
