import Turbolinks from 'turbolinks'
import WebpackerReact from 'webpacker-react'
import injectTapEventPlugin from 'react-tap-event-plugin'

injectTapEventPlugin()

Turbolinks.start()

WebpackerReact.setup({})
