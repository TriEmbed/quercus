<template>
  <div class="app-setting">
    <v-navigation-drawer
      app
      :value="appSetting"
      fixed
      right
      temporary
      @input="handleInput"
      ref="drawer"
    >
      <!-- / Header -->
      <v-toolbar
        :height="appHeaderHeight"
        slot="prepend"
        color="primary lighten-1"
      >
        <v-toolbar-title>Personalize</v-toolbar-title>
      </v-toolbar>

      <!-- / Content -->
      <v-container>
        <v-layout column>
          <v-flex>
            <v-subheader class="px-1 my-2">
              Navigation bar settings
            </v-subheader>
            <v-switch
              color="primary"
              :input-value="appPermanentNavigation"
              label="Navigation bar fixed left"
              @change="toggleAppPermanentNavigation"
            />
          </v-flex>

          <v-flex>
            <v-subheader class="px-1 my-2">
              Exterior
            </v-subheader>
            <v-switch
              color="primary"
              :input-value="appThemeDark"
              label="Dark Mode"
              @change="toggleAppThemeDark"
            />
          </v-flex>

          <v-flex>
            <v-subheader class="px-1 my-2">
              Tab Mode
            </v-subheader>
            <v-switch
              color="primary"
              :input-value="appMultipleTabs"
              label="Multiple tabs"
              @change="toggleAppMultipleTabs"
            />
          </v-flex>

          <v-flex>
            <v-subheader class="px-1 my-2">
              Theme color settings
            </v-subheader>
            <div class="color-option">
              <v-layout wrap>
                <label
                  v-for="(colorConfig, colorName) in colors"
                  :key="colorName"
                  class="app-setting__label flex xs6 pa-1"
                  v-show="!filterColors.includes(colorName)"
                >
                  <input
                    type="radio"
                    name="colorConfig"
                    :checked="colorConfig.base === appPrimaryColor"
                    @input="setAppPrimaryColor(colorConfig.base)"
                  >
                  <span class="app-setting__item bg">
                    <span class="overlay">
                      <span class="material-icons">check</span>
                    </span>
                    <span class="app-setting__item-header" :class="colorName" />
                    <span class="app-setting__item-header" :class="colorName" />
                    <span class="white" />
                  </span>
                </label>
              </v-layout>
            </div>
          </v-flex>
        </v-layout>
      </v-container>
    </v-navigation-drawer>
  </div>
</template>

<script>
import colors from 'vuetify/lib/util/colors'
import mixin from './LayoutMixin.vue'

export default {
  name: 'AppSetting',
  mixins: [mixin],
  data: () => ({
    drawer: false,
    colors: colors,
    filterColors: ['blueGrey', 'lightBlue', 'lightGreen', 'deepPurple', 'deepOrange', 'shades'],
  }),
  methods: {
    handleInput () {
      // HACK
      if (this.$refs.drawer.isActive !== this.appSetting) {
        this.toggleAppSetting()
      }
    },
  },
}
</script>

<style lang="scss">
.app-setting {
  &__trigger-btn {
    top: 50% !important;
  }

  &__label {
    cursor: pointer;
    display: block;
    position: relative;
  }

  &__label input[type='radio'] {
    display: none;
  }

  &__label input[type='radio'] + span {
    position: relative;
  }

  &__label input[type='radio'] + span > .overlay {
    background-color: rgba(0, 0, 0, 0.3);
    bottom: 0;
    color: #fff;
    display: none;
    height: 100%;
    left: 0;
    line-height: 30px;
    position: absolute;
    right: 0;
    text-align: center;
    top: 0;
    width: 100%;
  }

  &__label input[type='radio']:checked + span > .overlay {
    display: block;
  }

  &__label .bg {
    background-color: #f1f1f1;
  }

  &__item {
    box-shadow: 0 0 2px rgba(0, 0, 0, 0.1);
    display: block;
    margin-bottom: 15px;
    overflow: hidden;
  }

  &__item-header {
    height: 10px;
  }

  &__item > span {
    display: inline-block;
    height: 20px;
    width: 50%;
  }
}
</style>
