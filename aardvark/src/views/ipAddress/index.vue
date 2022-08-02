<template>
  <v-container class="fill-height" fluid>
    <v-row align="center" justify="center">
      <v-col cols="12" sm="8" md="4">
        <v-form ref="form">
          <v-card class="elevation-12">
            <v-toolbar color="primary" dark flat>
              <v-toolbar-title>SSID form</v-toolbar-title>
              <v-spacer />
            </v-toolbar>

            <v-card-text>
              <v-text-field
                autofocus
                label="ssid"
                name="ssid"
                prepend-icon="person"
                :rules="[v => !!v || 'please enter SSID']"
                type="text"
                validate-on-blur
                v-model="formData.ssid"
              />
              <v-text-field
                id="password"
                label="Password"
                name="password"
                prepend-icon="lock"
                :rules="[v => !!v || 'Please enter password']"
                type="password"
                validate-on-blur
                v-model="formData.password"
              />
            </v-card-text>

            <v-card-actions>
              <v-spacer />
              <v-btn
                color="primary"
                :loading="loading"
                type="submit"
                @click.prevent="handleSubmit"
              >
                Log in
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-form>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { mapActions } from 'vuex'
import { AccountActions } from '@/store/modules/account'

export default {
  name: 'IpAddress',
  data: () => ({
    formData: {
      ssid: '',
      password: '',
    },
    loading: false,
  }),
  methods: {
    ...mapActions('account', {
      login: AccountActions.LOGIN,
    }),
    async handleSubmit () {
      if (!this.$refs.form.validate()) return
      try {
        this.loading = true
        await this.login(this.formData)
      } finally {
        this.loading = false
      }
    },
  },
  mounted () {
    setTimeout(() => {
      this.formData = {
        ssid: 'ap-ssid',
        password: 'h97rpXts8@qzj7wp',
      }
    }, 450)
  },
}
</script>

<style lang="scss">

</style>
