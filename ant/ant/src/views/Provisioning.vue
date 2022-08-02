<template>
  <v-container>
    <v-layout text-xs-center wrap>
      <v-flex xs12 sm6 offset-sm3>
        <provisionComponent/>
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>
import provisionComponent from '../components/Provision.vue';

export default {
  components: {
    provisionComponent,
  },

};
</script>
