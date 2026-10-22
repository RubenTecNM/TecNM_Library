<script setup lang="ts">
import { computed, ref, useAttrs, useId } from 'vue'

defineOptions({ inheritAttrs: false })

const props = withDefaults(
  defineProps<{
    id?: string
    label: string
    error?: string
    hint?: string
    as?: 'input' | 'select' | 'textarea'
    modelValue?: string
    options?: { value: string; label: string }[]
  }>(),
  {
    as: 'input',
    modelValue: '',
  },
)

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const attrs = useAttrs()
const generatedId = useId()
const controlId = computed(() => props.id || generatedId)
const hintId = computed(() => `${controlId.value}-hint`)
const errorId = computed(() => `${controlId.value}-error`)
const describedBy = computed(() => {
  const ids = typeof attrs['aria-describedby'] === 'string' ? attrs['aria-describedby'].split(' ') : []

  if (props.hint) ids.push(hintId.value)
  if (props.error) ids.push(errorId.value)

  return ids.length ? ids.join(' ') : undefined
})

const control = ref<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement | null>(null)

function updateValue(event: Event): void {
  emit('update:modelValue', (event.target as HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement).value)
}

function focus(): void {
  control.value?.focus()
}

defineExpose({ focus })
</script>

<template>
  <div class="field">
    <label :for="controlId">{{ label }}</label>
    <component
      :is="as"
      ref="control"
      v-bind="attrs"
      :id="controlId"
      :value="modelValue"
      :aria-invalid="error ? 'true' : undefined"
      :aria-describedby="describedBy"
      @input="updateValue"
    >
      <template v-if="as === 'select'"><option v-for="option in options" :key="option.value" :value="option.value">{{ option.label }}</option><slot name="options" /></template>
    </component>
    <span v-if="hint" :id="hintId" class="hint">{{ hint }}</span>
    <span v-if="error" :id="errorId" class="error">{{ error }}</span>
  </div>
</template>
