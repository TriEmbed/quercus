import request from '@/utils/request'
import axios from "axios"
import {method} from "lodash-es";
import autoconfig from "@/autoconfiguration.js"


/**
 * Added items
 * @param {Object} data
 * @return {Promise<any>}
 */
// eslint-disable-next-line no-unused-vars
export const addProject = function (data = {}, _data) {
  return request.post('/project', data)
}

/**
 * Edit item
 * @param {Object} data
 * @return {Promise<any>}
 */
// eslint-disable-next-line no-unused-vars
export const editProject = function (data = {}) {
  return request.put('/project', data)
}

/**
 * delete an item
 * @param {Number | String} id
 * @return {Promise<any>}
 */
// eslint-disable-next-line no-unused-vars
export const deleteProject = function (id, _data) {
  return request.delete(`/aardvark/${id}`)
}

/**
 * Query item details by id
 * @param {Number | String} id
 * @return {Promise<any>}
 */
// eslint-disable-next-line no-unused-vars
export const getProject = function (id, _data) {
  return request.get(`/aardvark/${id}`)
}

/**
 * Query item list
 * @param {Object} query
 * @return {Promise<any>}
 */
// eslint-disable-next-line no-unused-vars
export const getProjectList = function (query = {}, _data) {

  return request.get('/aardvark/list', { params: query })
}

// This currently doesn't work
// let BaseURL = autoconfig.localurl + '/api/v1/'


// The IP here has to be manually replaced from the ESP32 IP published via monitor output
let BaseURL ='http://192.168.1.181/api/v1/'

// eslint-disable-next-line no-unused-vars
export const getESPInfo = function (query = {} ,_data) {
  console.log("aardvark called", BaseURL)

  const k= axios({method: 'get',
    url: '/system/info',
    baseURL: BaseURL,
    responseText: 'json',
    // `timeout` specifies the number of milliseconds before the request times out.
    // If the request takes longer than `timeout`, the request will be aborted.
    timeout: 1000, // default is `0` (no timeout)
  })

  return k;
}


// eslint-disable-next-line no-unused-vars
export const getI2C = function (query = {}, _data) {
  console.log("aardvark called", BaseURL,_data)

  const k= axios({method: 'patch',
    url: '/i2c',
    baseURL: BaseURL,
    responseText: 'json',
    // `timeout` specifies the number of milliseconds before the request times out.
    // If the request takes longer than `timeout`, the request will be aborted.
    timeout: 2000, // default is `0` (no timeout)
    params: {
      ID: 12345,
    },
    data: { "i2cscan": [] },
    headers: {
      'Access-Control-Allow-Origin': 'GET, PUT, POST, DELETE, OPTIONS',
      'Content-Type': 'application/json',
    },
  })

  return k;
}



export const testI2C = function (query = {},_command_slot , _data) {
  console.log("aardvark called test", BaseURL,_command_slot, _data)

  const k= axios({method: 'patch',
    url: '/i2c',
    baseURL: BaseURL,
    responseText: 'json',
    // `timeout` specifies the number of milliseconds before the request times out.
    // If the request takes longer than `timeout`, the request will be aborted.
    timeout: 2000, // default is `0` (no timeout)
    params: {
      ID: 12345,
    },
    data: { [_command_slot]: _data },
    headers: {
      'Access-Control-Allow-Origin': 'GET, PUT, POST, DELETE, OPTIONS',
      'Content-Type': 'application/json',
    },
  })

  return k;
}


export let testI2CSet = function (query = {}, _command_slot , _address, _offset, _values) {
  console.log("aardvark called test", BaseURL,_command_slot, _address,_offset,_values)

  const k= axios({method: 'patch',
    url: '/i2c',
    baseURL: BaseURL,
    responseText: 'json',
    // `timeout` specifies the number of milliseconds before the request times out.
    // If the request takes longer than `timeout`, the request will be aborted.
    timeout: 2000, // default is `0` (no timeout)
    params: {
      ID: 12345,
    },
    data: { [_command_slot]: [ _address, _offset, _values] },
    headers: {
      'Access-Control-Allow-Origin': 'GET, PUT, POST, DELETE, OPTIONS',
      'Content-Type': 'application/json',
    },
  })

  return k;
}



