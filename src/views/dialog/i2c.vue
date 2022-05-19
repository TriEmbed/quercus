<template>
  <div class="fill-height fill-width overflow-hidden">
    <DataTable
      :default-options="{
        sortBy: ['lastModifyTime'],
        sortDesc: [true],
      }"
      :headers="headers"
      item-key="id"
      :load-data="loadData"
      ref="table"
    >
      <template #search>
        <v-row class="px-4">
          <v-col class="py-0" cols="12">
            <v-text-field autofocus placeholder="Please enter a keyword query" v-model="query.name" clearable />
          </v-col>
        </v-row>
      </template>

      <template #actions>
        <v-btn class="mr-2" depressed tile @click="handleAdd">
          Add item
        </v-btn>
      </template>

      <template #[`item.number`]="{ index }">
        {{ index + 1 }}
      </template>

      <template #[`item.time`]="{ item }">
        <v-chip :color="item.time >= 60 ? 'primary' : 'dark'">
          {{ item.time }}
        </v-chip>
      </template>

      <template #[`item.occupy`]="{ item }">
        {{ item.occupy ? 'Yes' : 'No' }}
      </template>

      <template #[`item.actions`]="{ item }">
        <v-tooltip top>
          <template #activator="{ on, attrs }">
            <v-icon v-bind="attrs" v-on="on" color="blue darken-3" class="mr-4" @click="handleEdit(item.id)">
              edit
            </v-icon>
          </template>
          <span>edit</span>
        </v-tooltip>

        <v-tooltip top>
          <template #activator="{ on, attrs }">
            <v-icon v-bind="attrs" v-on="on" color="red" @click="handleDelete(item.id)">
              delete
            </v-icon>
          </template>
          <span>delete</span>
        </v-tooltip>
      </template>
    </DataTable>

    <ProjectSchema
      ref="projectSchema"
      @editSuccess="handleEditSuccess"
      @addSuccess="handleAddSuccess"
    />
  </div>
</template>

<script>
import ProjectSchema from './modules/ProjectSchema.vue'
import { deleteProject, getProjectList } from '@/api/project'
import toast from '@/utils/toast'

export default {
  name: 'ProjectList',
  components: {
    ProjectSchema,
  },
  data: () => ({
    query: {
      name: '',
    },
  }),
  computed: {
    headers () {
      console.log("her")
      return [
        {
          text: 'Number',
          align: 'center',
          sortable: false,
          value: 'number',
          width: 100,
          fixed: true,
        },
        {
          text: 'Project name',
          align: 'center',
          sortable: false,
          value: 'name',
        },
        {
          text: 'Total duration (minutes)',
          align: 'center',
          value: 'time',
          width: 100,
        },
        {
          text: 'item category',
          align: 'center',
          sortable: false,
          value: 'category',
          width: 120,
        },
        {
          text: 'Display price (¥)',
          align: 'center',
          value: 'price',
          width: 120,
        },
        {
          text: 'item type',
          align: 'center',
          sortable: false,
          value: 'type',
          width: 120,
        },
        {
          text: 'Exclusive room',
          align: 'center',
          value: 'occupy',
          width: 100,
        },
        {
          text: 'Cost ratio (%)',
          align: 'center',
          value: 'percent',
          width: 100,
        },
        {
          text: 'Update time',
          align: 'center',
          value: 'lastModifyTime',
          width: 150,
        },
        {
          text: 'Operation',
          align: 'center',
          sortable: false,
          value: 'actions',
          width: 110,
          fixed: true,
        },
      ]
    },
  },
  methods: {
    /**
     * Call the interface data and initialize the table
     * @return {Promise<Undefined>}
     */
    async loadData (options = {}) {
      return getProjectList({ ...this.query, ...options }).then(r => r.data)
    },
    /**
     * Added items
     * @return {Undefined}
     */
    handleAdd () {
      debugger
      this.$refs['projectSchema'].open()
    },
    /**
     * Added esp successfully
     * @return {Undefined}
     */
    handleAddSuccess () {
      toast.success({ message: 'Add item successfully' })
      this.query = this.$options.data.apply(this).query
      this.$refs['table'].refresh(true)
    },
    /**
     * Edit item
     * @param {Number | String} id item id
     * @return {Undefined}
     */
    handleEdit (id) {
      this.$refs['projectSchema'].open(id)
    },
    /**
     * Edit esp success
     * @return {Undefined}
     */
    handleEditSuccess () {
      toast.success({ message: 'Editing esp successful' })
      this.$refs['table'].refresh()
    },
    /**
     * delete item
     * @param {Number | String} id item id
     * @return {Promise<Undefined>}
     */
    async handleDelete (id) {
      await deleteProject(id)
      toast.success({ message: 'Delete the item successfully' })
      await this.$refs.table.refresh()
    },
  },
}
</script>

<style lang="scss">
</style>
