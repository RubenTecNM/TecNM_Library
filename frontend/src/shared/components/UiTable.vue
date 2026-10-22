<script setup lang="ts" generic="T extends { id: string | number }">
defineProps<{ label: string; columns: { key: keyof T & string; label: string }[]; rows: T[]; selected?: string | number }>()
</script>
<template>
  <div class="table-wrap" tabindex="0" role="region" :aria-label="label">
    <table><thead><tr><th v-for="column in columns" :key="column.key" scope="col">{{ column.label }}</th></tr></thead>
      <tbody><tr v-for="row in rows" :key="row.id" :class="{ selected: row.id === selected }"><td v-for="column in columns" :key="column.key"><slot :name="`cell-${column.key}`" :row="row" :value="row[column.key]">{{ row[column.key] }}</slot></td></tr></tbody>
    </table>
  </div>
</template>
