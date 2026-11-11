<script setup lang="ts">
import { RouterView } from 'vue-router'
import { UiHeader, UiShell, UiSidebar, UiToggle } from '../../shared/components'
import { useTheme } from '../../shared/composables/useTheme'
import { headerNavigation, mainLayoutConfig, sidebarNavigation } from './mainLayout.config'

const { dark } = useTheme()
</script>

<template>
  <UiShell :show-header="mainLayoutConfig.showHeader" :show-sidebar="mainLayoutConfig.showSidebar">
    <template #header>
      <UiHeader v-bind="mainLayoutConfig.header" :items="headerNavigation">
        <UiToggle v-model="dark" type="switch" label="Modo oscuro" class="theme" />
      </UiHeader>
    </template>
    <template #sidebar>
      <UiSidebar v-bind="mainLayoutConfig.sidebar" :items="sidebarNavigation" note="Identidad institucional. Excelencia técnica. Solidez académica.">
        <UiToggle v-if="!mainLayoutConfig.showHeader" v-model="dark" type="switch" label="Modo oscuro" />
      </UiSidebar>
    </template>
    <RouterView />
    <template #footer>
      <span>Tecnológico Nacional de México</span>
      <span>Campus Monclova</span>
    </template>
  </UiShell>
</template>
