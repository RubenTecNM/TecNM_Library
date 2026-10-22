<script setup lang="ts">defineProps<{ title?: string }>()</script>
<template><div class="recommendation"><strong v-if="title">{{ title }}</strong><br v-if="title"><slot /></div></template>
