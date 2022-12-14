<template>
  <div class="t-search" :id="`${state.id}`">
    <v-autocomplete
      :attach="`#${state.id}`"
      autofocus
      :cache-items="false"
      clearable
      color="primary"
      flat
      height="30"
      hide-no-data
      :items="state.searchResults"
      item-text="name"
      :loading="state.loading"
      :menu-props="{
        attach: `#${state.id}`,
        contentClass: 'elevation-0_',
        maxHeight: 520,
        maxWidth: 350,
        transition: 'slide-y-transition',
      }"
      placeholder="Enter address to search"
      return-object
      solo
      v-model="state.place"
      @change="select"
      @update:search-input="search"
    >
      <template #item="{ item }">
        <v-list-item-content>
          <v-list-item-title>{{ item.name }}</v-list-item-title>
          <v-list-item-subtitle>{{ item.address }}</v-list-item-subtitle>
          <v-list-item-subtitle>{{ item.phone }}</v-list-item-subtitle>
        </v-list-item-content>
      </template>
    </v-autocomplete>

    <TMarker v-if="position.length" :position="position" />
  </div>
</template>

<script>
import _ from 'lodash-es'
import TMarker from './TMarker.vue'
import { computed, defineComponent, reactive } from '@vue/composition-api'
import { useInject, useService } from './composable'

export default defineComponent({
  name: 'TSearch',
  components: {
    TMarker,
  },
  setup () {
    const state = reactive({
      id: `t-search${Date.now()}`,
      loading: false,
      searchResults: [],
      place: null,
    })
    const position = computed(() => {
      if (!state.place) return []
      return [
        state.place.latLng.lat,
        state.place.latLng.lng,
      ]
    })
    const service = useService()
    const map = useInject()

    const search = _.debounce(async (query) => {
      if (!query) return
      if (state.place && state.place === query) return
      try {
        state.loading = true
        const searchResults = await service.searchPlaces(query)
        state.searchResults = searchResults.type === 'CITY_LIST' ? [] : searchResults.detail.pois
      } finally {
        state.loading = false
      }
    }, 200)

    const select = (e) => {
      if (!e) return
      const latLngBounds = new qq.maps.LatLngBounds()
      latLngBounds.extend(e.latLng)
      map.fitBounds(latLngBounds)
      map.panTo(e.latLng)
    }

    return { state, search, select, position }
  },
})
</script>

<style lang="scss">
.t-search {
  height: 30px;
  left: 75px;
  position: absolute;
  top: 40px;
  width: 350px;
  z-index: 2;
}
</style>
