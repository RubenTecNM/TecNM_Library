<script setup lang="ts">
import { onBeforeUnmount, ref } from 'vue'
const message = ref('')
let timer: ReturnType<typeof setTimeout> | undefined
function show(text: string) {
  clearTimeout(timer)
  message.value = text
  timer = setTimeout(() => { message.value = '' }, 4000)
}
onBeforeUnmount(() => clearTimeout(timer))
defineExpose({ show })
</script>
<template><div class="ui-toast" role="status" aria-live="polite" aria-atomic="true">{{ message }}</div></template>
