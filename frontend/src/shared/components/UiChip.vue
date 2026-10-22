<script setup lang="ts">
withDefaults(
  defineProps<{
    pressed?: boolean
  }>(),
  {
    pressed: false,
  },
)
</script>

<template>
  <button class="chip" type="button" :aria-pressed="pressed">
    <slot />
  </button>
</template>
