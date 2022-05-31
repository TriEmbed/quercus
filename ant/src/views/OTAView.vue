<template>
  <v-container>
    <v-layout text-xs-center wrap>
      <v-flex xs12 sm6 offset-sm3>
        <ota-component/>
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>
import otaComponent from '../components/OTA.vue';

export default {
  components: {
    otaComponent,
  },

};
</script>
