<script setup lang="ts">
import { useAttrs, useId } from 'vue'

defineOptions({ inheritAttrs: false })

const props = withDefaults(
  defineProps<{
    label: string
    type?: 'checkbox' | 'switch'
  }>(),
  {
    type: 'checkbox',
  },
)

const model = defineModel<boolean>({ default: false })
const attrs = useAttrs()
const id = useId()
</script>

<template>
  <label class="option" :class="attrs.class" :for="id">
    <input
      v-bind="{ ...attrs, class: undefined }"
      :id="id"
      v-model="model"
      type="checkbox"
      :class="{ switch: props.type === 'switch' }"
      :role="props.type === 'switch' ? 'switch' : undefined"
    />
    <span>{{ label }}</span>
  </label>
</template>
