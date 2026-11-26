import React from 'react'
import ReactDOM from 'react-dom/client'

import App from './app/App'
import { installChunkLoadRecovery } from './shared/runtime/chunk-load-recovery'
import './styles/index.css'

installChunkLoadRecovery({ buildId: __BOMACH_BUILD_ID__ })

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
