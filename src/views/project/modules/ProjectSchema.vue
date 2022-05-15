<template>
  <FormDrawer
    flat
    :loading="loading"
    title="Edit item"
    v-model="visible"
    :width="680"
  >
    <template #content>
      <v-form ref="form">
        <v-container>
          <v-row>
            <v-col cols="12">
              <v-text-field
                v-model="formData.name"
                label="Project name"
                :rules="[v => !!v || 'Please enter a project name']"
              />
            </v-col>
          </v-row>

          <v-row>
            <v-col cols="6">
              <v-select
                v-model="formData.type"
                :items="['Foot Dao', 'Body Massage', 'Traditional Chinese Medicine', 'SPA', 'Package']"
                :rules="[v => !!v || 'Please select an item type']"
                label="Item Type"
              />
            </v-col>
            <v-col cols="6">
              <v-radio-group
                v-model="formData.category"
                :items="['Public Items', 'Other Items']"
                :rules="[v => !!v || 'Please select an item category']"
                label="Item Category"
                row
              >
                <v-radio color="primary" label="Public Items" value="Public Items" />
                <v-radio color="primary" label="Other items" value="Other items" />
              </v-radio-group>
            </v-col>
          </v-row>
          <v-col cols="6">
            <v-text-field
              v-model.number="formData.price"
              :rules="[v => !!v || 'Please enter a display price']"
              label="Display price (¥)"
            />
          </v-col>
          <v-col cols="6">
            <v-text-field
              v-model.number="formData.time"
              :rules="[v => !!v || 'Please enter the total duration']"
              label="Total duration (minutes)"
            />
          </v-col>
          <v-row>
            <v-col cols="6">
              <v-text-field
                v-model.number="formData.percent"
                type="number"
                :rules="[v => !!v || 'Please enter the cost ratio']"
                label="Cost ratio (%)"
              />
            </v-col>
            <v-col cols="6">
              <v-radio-group
                v-model="formData.occupy"
                color="primary"
                :rules="[v => typeof v === 'boolean' || 'Please choose an exclusive room']"
                label="Exclusive room"
                row
              >
                <v-radio color="primary" label="No" :value="false" />
                <v-radio color="primary" label="yes" :value="true" />
              </v-radio-group>
            </v-col>
          </v-row>
          <v-row>
            <v-col
              class="py-0"
              cols="12"
            >
              <v-text-field
                v-model="formData.tags"
                counter="12"
                label="Efficacy label"
                :rules="[
                  v => !!v || 'Please enter the efficacy label',
                  v => v && v.length <= 12 || 'Enter up to 12 characters'
                ]"
              />
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="12">
              <VImgUpload ref="upload" flat />
            </v-col>
          </v-row>
        </v-container>
      </v-form>
    </template>

    <template #actions>
      <v-spacer />
      <v-btn
        x-large
        text
        @click="close"
      >
        Cancel
      </v-btn>
      <v-btn
        x-large
        text
        type="submit"
        @click.stop.prevent="submit"
      >
        save
      </v-btn>
    </template>
  </FormDrawer>
</template>

<script>

import { addProject, editProject, getProject } from '@/api/project'
import _ from 'lodash-es'

export default {
  name: 'ProjectSchema',
  props: {},
  data: () => ({
    formData: {
      id: '',
      name: '',
      type: '',
      category: '',
      price: '',
      time: '',
      percent: '',
      occupy: null,
      tags: '',
    },
    loading: false,
    visible: false,
  }),
  methods: {
    async add () {
      await addProject(this.formData)
      this.$emit('addSuccess')
    },
    async edit () {
      await editProject(this.formData)
      this.$emit('editSuccess')
    },
    async open (id) {
      try {
        this.visible = true
        this.loading = true
        if (id) {
          const { data } = await getProject(id)
          this.formData = _.pick(data, Object.keys(this.formData))
        }
      } finally {
        this.loading = false
      }
    },
    async close () {
      this.visible = false
      await this.$nextTick()
      Object.assign(this, this.$options.data.apply(this))
      this.$refs['form'].resetValidation()
      this.$refs['upload'].reset()
    },
    async submit () {
      if (!this.$refs['form'].validate()) return
      try {
        this.loading = true
        await this.formData.id ? this.edit() : this.add()
        this.close()
      } finally {
        this.loading = false
      }
    },
  },
}
</script>

<style lang="scss">
</style>
