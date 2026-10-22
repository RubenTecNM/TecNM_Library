<script setup lang="ts">
import { useAttrs, useId } from 'vue'

defineOptions({ inheritAttrs: false })

const props = defineProps<{
  value: string
  name?: string
  label: string
}>()

const model = defineModel<string>({ default: '' })
const attrs = useAttrs()
const id = useId()
</script>

<template>
  <label class="option" :for="id">
    <input
      v-bind="attrs"
      :id="id"
      v-model="model"
      type="radio"
      :name="name"
      :value="value"
    />
    <span>{{ label }}</span>
  </label>
</template>
