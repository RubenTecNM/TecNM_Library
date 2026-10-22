<script setup lang="ts">
import { useAttrs, useId } from 'vue'

defineOptions({ inheritAttrs: false })

const props = withDefaults(
  defineProps<{
    label: string
    min?: number
    max?: number
  }>(),
  {
    min: 0,
    max: 100,
  },
)

const model = defineModel<number>({ default: 0 })
const attrs = useAttrs()
const id = useId()
</script>

<template>
  <div class="field">
    <label :for="id">{{ label }}</label>
    <input
      v-bind="attrs"
      :id="id"
      v-model.number="model"
      type="range"
      :min="props.min"
      :max="props.max"
    />
  </div>
</template>
