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
import { deleteProject, getESPInfo } from '@/api/project'
import toast from '@/utils/toast'
const item = (id = 1,a,b) => ({
  id: id,
  name: a,
  type: b,
})
export default {
  name: 'status',
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
          text: 'Name',
          align: 'left',
          sortable: false,
          value: 'name',
        },
        {
          text: 'data',
          align: 'center',
          value: 'type',
          width: 100,
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
    format(a)
    {
      let total= 0
      return { total : total ,items: [{}]}
    },
    /**
     * Call the interface data and initialize the table
     * @return {Promise<Undefined>}
     */
    async loadData (options = {}) {
      return getESPInfo({ ...this.query, ...options }).then(r =>this.format (r.data))
    },
    /**
     * Added items
     * @return {Undefined}
     */
    handleAdd () {
      this.$refs['projectSchema'].open()
    },
    /**
     * Added project successfully
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
     * Edit project success
     * @return {Undefined}
     */
    handleEditSuccess () {
      toast.success({ message: 'Editing project successful' })
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
