import React from 'react'
import ReactDOM from 'react-dom'
import injectTapEventPlugin from 'react-tap-event-plugin'

injectTapEventPlugin()

it('returns true', () => {
  expect(true).toEqual(true)
})
