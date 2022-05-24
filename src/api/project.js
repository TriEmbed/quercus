import request from '@/utils/request'
import axios from "axios"
import {method} from "lodash-es";
/**
 * Added items
 * @param {Object} data
 * @return {Promise<any>}
 */
export const addProject = function (data = {}) {
  return request.post('/project', data)
}

/**
 * Edit item
 * @param {Object} data
 * @return {Promise<any>}
 */
export const editProject = function (data = {}) {
  return request.put('/project', data)
}

/**
 * delete an item
 * @param {Number | String} id
 * @return {Promise<any>}
 */
export const deleteProject = function (id) {
  return request.delete(`/project/${id}`)
}

/**
 * Query item details by id
 * @param {Number | String} id
 * @return {Promise<any>}
 */
export const getProject = function (id) {
  return request.get(`/project/${id}`)
}

/**
 * Query item list
 * @param {Object} query
 * @return {Promise<any>}
 */
export const getProjectList = function (query = {}) {
  return request.get('/project/list', { params: query })
}

let BaseURL ='http://192.168.100.150/api/v1'

export const getESPInfo = function (query = {}) {
  console.log("project called", BaseURL)

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

