import Vue from 'vue'
import Vuex from 'vuex'
import VuexPersistence from 'vuex-persist'
import modules from './modules'

Vue.use(Vuex)

const persistence = new VuexPersistence({
  key: 'VuetifyBoilerplateVuex',
  storage: window.localStorage,
  reducer: ({
    account,
    setting: { appPermanentNavigation, appPrimaryColor, appThemeDark, appMultipleTabs },
  }) => ({
    account,
    setting: { appPermanentNavigation, appPrimaryColor, appThemeDark, appMultipleTabs },
  }),
})

export default new Vuex.Store({
  plugins: [
    persistence.plugin,
  ],
  modules,
  state () {
    return {
      dialogAddresses: [8,16],
      dialogAddress: 8,
      ipAddress: "192.168.4.1",
    }
  },
  mutations: {
    address (state,payload) {
      console.log("mutation",payload)
      state.dialogAddress=payload
    },
  },
})
