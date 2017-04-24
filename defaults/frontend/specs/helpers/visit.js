/* eslint-disable import/no-extraneous-dependencies */

import nightmare from 'nightmare'
import url from 'url'

const BASE_URL = url.format({
  protocol: process.env.PROTOCOL || 'http',
  hostname: process.env.APP_HOST || 'localhost',
  port: process.env.PORT || 3000
})

const DEBUG = process.env.DEBUG || false

export default function (path = '') {
  const location = url.resolve(BASE_URL, path)

  const page = nightmare({
    show: DEBUG,
    pollInterval: 50
  })

  return page.goto(location)
}
