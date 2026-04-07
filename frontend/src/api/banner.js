import service from '@/utils/request'

/**
 * 获取轮播图列表
 * @returns {Promise}
 */
export function getBannerList() {
  return service({
    url: '/api/banner/list',
    method: 'get'
  })
}
