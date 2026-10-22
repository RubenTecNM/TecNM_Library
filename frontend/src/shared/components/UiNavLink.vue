<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import type { NavigationLink } from './navigation'

const props = defineProps<{ item: NavigationLink }>()
const route = useRoute()
const router = useRouter()
const active = computed(() => {
  const target = router.resolve(props.item.to)
  return route.path === target.path && route.hash === target.hash
})
</script>

<template>
  <RouterLink v-slot="{ href, navigate }" :to="item.to" custom>
    <a :href="href" :class="{ active }" :aria-current="active ? 'location' : undefined" @click="navigate">{{ item.label }}</a>
  </RouterLink>
</template>
