import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import './index.css'
import App from './App.jsx'
import { TobNavBarProvider } from './context/TopNavBarContext.jsx'
import {NotificationContextProvider} from './context/NotificationContext.jsx'
import { QueryClient,QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient();

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <NotificationContextProvider>
        <TobNavBarProvider>
          <BrowserRouter>
              <App />
          </BrowserRouter>
        </TobNavBarProvider>
      </NotificationContextProvider>
    </QueryClientProvider>
  </StrictMode>,
)
