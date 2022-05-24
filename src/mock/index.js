import Adaptor from 'axios-mock-adapter'
import request from '@/utils/request'
import _ from 'lodash-es'

const adaptor = new Adaptor(request, { delayResponse: 300 })

adaptor.onPost(/api\/login/).reply(config => {
  const { username } = JSON.parse(config.data)
  return [200, {
    username,
    token: 'ac21ebab-bddc-41a3-bef5-4ecf3325c888',
    permissions: [],
    menus: [
      {
        text: 'Home',
        icon: 'home',
        hidden: false,
        to: '/home',
        permissions: [],
        type: 'VIEW',
        resource: 'home/index',
      },
      {
        text: 'Esp',
        icon: 'Esp',
        hidden: false,
        to: '/eps',
        permissions: [],
        type: 'VIEW',
        resource: 'home/index',
        children: [
          {
            text: 'project list',
            hidden: false,
            to: '/project/list',
            permissions: [],
            type: 'VIEW',
            resource: 'project/index',
          },
          {
            text: 'Status',
            hidden: false,
            to: '/project/status',
            permissions: [],
            type: 'VIEW',
            resource: 'project/status',
          },
        ],
      },
      {
        text: 'Project Management',
        icon: 'apps',
        hidden: false,
        to: '/project',
        permissions: [],
        type: 'MENU',
        resource: '',
        children: [
          {
            text: 'item list',
            hidden: false,
            to: '/project/list',
            permissions: [],
            type: 'VIEW',
            resource: 'project/index',
          },
          {
            text: 'i2c',
            hidden: false,
            to: '/project/i2c',
            permissions: [],
            type: 'VIEW',
            resource: 'project/i2c',
          },
          {
            text: 'Status',
            hidden: false,
            to: '/project/status',
            permissions: [],
            type: 'VIEW',
            resource: 'project/status',
          },
        ],
      },
      {
        text: 'Tencent Map',
        icon: 'place',
        hidden: false,
        to: '/map',
        permissions: [],
        type: 'VIEW',
        resource: 'map/index',
      },
      {
        text: '404',
        icon: 'priority_high',
        hidden: false,
        to: '404_test',
        redirect: '/exception/404',
        permissions: [],
        type: 'VIEW',
        resource: '',
      },
    ],

  }]
})

const item = (id = 1) => ({
  id,
  name: Math.random().toString(36).substring(7),
  time: (Math.random() * 30 + 40).toFixed(0),
  category: Math.random() > 0.5 ? 'Public Projects' : 'Other Projects',
  percent: (Math.random() * 30 + 40).toFixed(0),
  price: (Math.random() * 400 + 100).toFixed(0),
  occupy: Math.random() > 0.5,
  type: ['Foot Dao', 'Body Massage', 'Traditional Chinese Medicine', 'SPA', 'Package'][`${Math.abs(Math.random() - 0.5)}`[2]],
  tags: ['dehumidification', 'blood circulation', 'sleep aid', 'ventilation', 'beauty'][`${Math.abs(Math.random() - 0.5)}`[2]],
  lastModifyTime: (function (d) {
    const Y = d.getFullYear()
    const M = d.getMonth() + 1
    const D = d.getDate()
    const H = d.getHours()
    const m = d.getMinutes()
    const s = d.getSeconds()
    const pad = num => num.toString().padStart(2, '0')
    return `${Y}-${pad(M)}-${pad(D)} ${pad(H)}:${pad(m)}:${pad(s)}`
  })(new Date(+(new Date()) - Math.floor(Math.random()*10000000000))),
})

adaptor.onPost(/\/api\/project/).reply(200)
adaptor.onPut(/\/api\/project/).reply(200)
adaptor.onDelete(/\/api\/project\/\d+/).reply(200)
adaptor.onGet(/\/api\/project\/\d+/).reply(200, item())
adaptor.onGet(/\/api\/project\/list/).reply(config => {
  const { sortBy = [], sortDesc = [], itemsPerPage = 15 } = config.params

  const items = _.orderBy(
    Array(itemsPerPage).fill(null).map((__, i) => item(i)),
    sortBy,
    sortDesc.map(desc => desc ? 'desc' : 'asc'),
  )

  return [200, { total: itemsPerPage * 3 + 3, items }]
})
