<script setup lang="ts">
import { nextTick, onMounted, ref, useAttrs, useId, watch } from 'vue'

defineOptions({ inheritAttrs: false })

defineProps<{
  title: string
}>()

const model = defineModel<boolean>({ default: false })
const attrs = useAttrs()
const dialog = ref<HTMLDialogElement | null>(null)
const titleId = useId()
let previouslyFocused: HTMLElement | null = null

async function openDialog(): Promise<void> {
  await nextTick()
  if (!dialog.value || dialog.value.open) return

  previouslyFocused = document.activeElement instanceof HTMLElement ? document.activeElement : null
  dialog.value.showModal()
}

function restoreFocus(): void {
  const target = previouslyFocused
  previouslyFocused = null
  target?.focus()
}

function closeDialog(): void {
  if (!dialog.value?.open) {
    restoreFocus()
    return
  }

  dialog.value.close()
}

function syncModelFromDialog(): void {
  model.value = false
  restoreFocus()
}

function syncDialog(): void {
  if (model.value) {
    void openDialog()
  } else {
    closeDialog()
  }
}

watch(model, syncDialog)
onMounted(syncDialog)
</script>

<template>
  <dialog
    ref="dialog"
    v-bind="attrs"
    :aria-labelledby="titleId"
    @cancel="model = false"
    @close="syncModelFromDialog"
  >
    <h2 :id="titleId">{{ title }}</h2>
    <div v-if="model"><slot /></div>
    <div v-if="$slots.actions" class="row"><slot name="actions" /></div>
  </dialog>
</template>
