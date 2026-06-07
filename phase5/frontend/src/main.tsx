import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { Toaster } from 'react-hot-toast'
import App from './App.tsx'
import './index.css'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
    <Toaster
      position="top-right"
      toastOptions={{
        style: {
          background: '#1c1917',
          color: '#f9edd8',
          border: '1px solid #7c4220',
          fontFamily: 'DM Sans, sans-serif',
          fontSize: '14px',
        },
        success: { iconTheme: { primary: '#60a567', secondary: '#1c1917' } },
        error: { iconTheme: { primary: '#dc2626', secondary: '#1c1917' } },
      }}
    />
  </StrictMode>,
)
