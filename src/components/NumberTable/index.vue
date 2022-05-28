<template>
  <div class="data-table fill-width fill-height d-flex flex-column">
    <CssStyle :content="fixedColumnsStyle" />

    <v-form v-show="true">
      <!--      <slot name="search" />-->

      <div class="d-flex flex-row pb-1 px-2">
        <!--        <slot name="actions" />-->
        <!--        <v-spacer />-->
        <v-select
          id="i2cActive"
          @change="changeRoute"
          :value="address"
          :items="addresses"
        />
        <v-btn class="mr-2" depressed tile type="submit" @click.stop.prevent="refresh(true)">
          Inquire
        </v-btn>
        <v-btn depressed tile @click="refresh()">
          refresh
        </v-btn>
      </div>
    </v-form>

    <div
      id="myDynamicTable"
      class="flex-grow-1 overflow-hidden"
      :style="{ position: 'relative' }"
      :show-menu="false"
      :items="items"
      :item-key="itemKey"
      locale="zh-cn"
      :multi-sort="multiSort"
      :options="options"
      ref="table"
      :server-items-length="total || 0"
      :no-data-text="loading ? 'Loading...' : 'No data'"
      @update:options="fetch($event)"
    >
      <VLoading absolute :value="loading" />
    </div>
  </div>
</template>

<script>
import VLoading from '@/components/VImplements/VLoading.vue'
import CssStyle from '@/components/CssStyle/index.vue'
import store from '@/store/index.js'
// this is handle by router index.js

export default {
  name: 'NumberTable',
  components: {
    VLoading,
    CssStyle,
  },
  props: {
    loadData: {
      type: Function,
      default: () => Promise.resolve(),
      required: true,
    },
    headers: {
      type: Array,
      default: () => [],
      required: false,
    },
    itemKey: {
      type: String,
      default: 'id',
      required: true,
    },
    multiSort: {
      type: Boolean,
      default: false,
    },
    defaultOptions: {
      type: Object,
      default: () => ({}),
    },
  },
  data () {
    return {
      selection: store.state.dialogAddress,
      items: [1, 2],
      loading: false,
      options: Object.assign({
        itemsPerPage: 20,
        page: 1,
        sortBy: [],
        sortDesc: [],
      }, this.defaultOptions),
      $tableWrapper: null,
      total: 0,
    }
  },
  computed: {
    address () {
      console.log("computed")
      return store.state.dialogAddress
    },

    addresses () {
      return store.state.dialogAddresses
    },
    fixedColumnsStyle () {

      const {left = [], right = []} = this.pickFixedColumns()
      return [
        ...this.calcFixedColumnCls(left, true),
        ...this.calcFixedColumnCls(right, false),
      ].join('\r\n')
    },
  },
  mounted () {
    console.log("store.state.address",store.state.dialogAddress)
    this.fetch(
    )
  },
  methods: {
    changeRoute (selectObj=store.state.dialogAddresses[0] ) {
      if (selectObj )
        store.commit('address', selectObj)
      console.log("select :",selectObj)ls+

    },
    /** @param { i2cScan: any[] } val**/
    addTable: function (stuff) {
      let val
      const key = Object.keys(stuff)[0]
      let rows=8;
      if (key === 'i2cscan') {
        console.log("found")
        console.log("vals", stuff, key);
        val = stuff.i2cscan
      }

      const width = 16
      const myTableDiv = document.getElementById('myDynamicTable')
      while (myTableDiv.firstChild) {
        myTableDiv.removeChild(myTableDiv.firstChild)
      }
      const table = document.createElement('TABLE')
      table.border = '0'
      const tableBody = document.createElement('TBODY')
      table.appendChild(tableBody)
      tableBody.appendChild(document.createElement('th'))

      for (let j = 0; j < width; j++) {
        const th = document.createElement('th')
        th.style.fontWeight = 'bolder'
        if (j < 0x10) {
          th.innerText = '0x0' + (j).toString(16)
        } else {
          th.innerText = '0x' + (j).toString(16)
        }
        tableBody.appendChild(th)
      }
      let cur = 0

      for (let i = 0; i < rows; i++) {
        const tr = document.createElement('TR')
        tr.innerText = '0x' + (i * 16).toString(16)

        tableBody.appendChild(tr)

        for (let j = 0; j < width; j++) {
          const td = document.createElement('TD')
          td.width = '40'
          td.style.textAlign = 'center'

          if (val[cur] === (i * 16 + j)) {
            //  const child = val[cur++]
            // td.addEventListener('click', function () {
            //   alert('click')
            // })
            // td.addEventListener('contextmenu', function (event) {
            //   event.preventDefault()
            //   const ctxMenu = document.getElementById('ctxMenu')
            //   ctxMenu.style.display = 'block'
            //   ctxMenu.style.width = '100px'
            //   ctxMenu.style.height = '100px'
            //   ctxMenu.style.left = (event.pageX) + 'px'
            //   ctxMenu.style.top = (event.pageY) + 'px'
            // })
            td.appendChild(document.createTextNode(val[cur++]))
          } else {
            td.appendChild(document.createTextNode('.'))
          }
          tr.appendChild(td)
        }
      }
      myTableDiv.appendChild(table)
    },
    async fetch (payload = {}) {

      try {
        this.loading = true
        const {items, total} = await this.loadData(Object.assign(this.options, payload))
        Object.assign(this, {items, total})
        await this.$nextTick()
        // await this.scrollToTop()


      } catch (e) {
        this.items = []
        this.total = 0
        throw e
      } finally {
        this.addTable(this.items)
        this.loading = false
      }
    },
    refresh (firstPage = false) {
      if (firstPage && this.options.page !== 1) {
        this.options.page = 1
      } else {
        this.fetch(this.options)
      }
    },
    scrollToTop () {
      this.$tableWrapper = this.$tableWrapper || this.$refs['table'].$el.getElementsByClassName('v-data-table__wrapper')[0]
      return this.$vuetify.goTo(0, {
        container: this.$tableWrapper,
      })
    },
    pickFixedColumns () {
      if ([0, 1].includes(this.headers.length)) {
        return {}
      }

      const [left] = this.headers
      const [right] = this.headers.slice(-1)
      return {
        left: left.fixed ? [1] : [],
        right: right.fixed ? [1] : [],
      }
    },
    // TODO: calc multiple sticky items' left / right
    calcFixedColumnCls (cols = [], left = false) {
      const rootSelector = '.data-table:not(.v-data-table--mobile)'
      const nth = num => `nth${left ? '' : '-last'}-child(${num})`

      return cols.map(col => `
        ${rootSelector} tbody tr > td:${nth(col)},
        ${rootSelector} thead tr > th:${nth(col)} {
          background: var(--background-color);
          position: sticky;
          ${left ? 'left' : 'right'}: 0;
          z-index: 2;
        }

        ${rootSelector} tbody tr:hover > td:${nth(col)} {
          background: inherit;
        }

        ${rootSelector} thead > tr > th:${nth(col)} {
          z-index: 3;
        }
      `)
    },
  },
}
</script>

<style lang="scss">
.theme--dark .data-table {
  --background-color: #1e1e1e;
}

.data-table {
  --background-color: #fff;
  position: static !important;

  .v-pagination {
    text-align: right !important;
    width: auto !important;
  }

  .v-toolbar__content {
    padding-bottom: 0;
    padding-top: 0;
  }

  .v-data-footer {
    font-size: 14px;
  }

  th,
  td {
    /* stylelint-disable-next-line */
    @extend .text-no-wrap !optional;
  }
}
</style>
