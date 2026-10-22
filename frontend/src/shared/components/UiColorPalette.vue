<script setup lang="ts">
import { nextTick, onMounted, ref, watch } from 'vue'
const props = withDefaults(defineProps<{ tokens: { token: string; label: string }[]; compact?: boolean; theme?: string }>(), { compact: false })
const values = ref<Record<string, string>>({})
async function refresh() {
  await nextTick()
  const style = getComputedStyle(document.documentElement)
  values.value = Object.fromEntries(props.tokens.map(({ token }) => [token, style.getPropertyValue(token).trim()]))
}
onMounted(refresh)
watch(() => [props.theme, props.tokens], refresh)
</script>
<template>
  <div :class="compact ? 'token-grid' : 'palette'">
    <div v-for="item in tokens" :key="item.token" :class="{ token: compact }" :style="{ '--swatch': `var(${item.token})` }">
      <template v-if="compact"><i aria-hidden="true" /><span>{{ item.token }}</span><code>{{ values[item.token] }}</code></template>
      <template v-else><div class="swatch-color" /><div class="swatch-name">{{ item.label }}</div><div class="swatch-value">{{ values[item.token] }}</div></template>
    </div>
  </div>
</template>
