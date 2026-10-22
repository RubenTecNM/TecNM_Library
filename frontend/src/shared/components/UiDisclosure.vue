<script setup lang="ts">defineProps<{ title: string }>()</script>
<template><details><summary>{{ title }}</summary><slot /></details></template>
