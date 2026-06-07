import { useState } from 'react'
import Layout from './components/layout/Layout'
import LoginPage from './pages/LoginPage'
import Dashboard from './pages/Dashboard'
import GuidesPage from './pages/GuidesPage'
import RoutesPage from './pages/RoutesPage'
import ToursPage from './pages/ToursPage'
import CustomersPage from './pages/CustomersPage'
import RegistrationsPage from './pages/RegistrationsPage'
import PaymentsPage from './pages/PaymentsPage'
import LocationsPage from './pages/LocationsPage'
import QueriesPage from './pages/QueriesPage'
import ProgramsPage from './pages/ProgramsPage'

export type Page =
  | 'dashboard'
  | 'guides'
  | 'routes'
  | 'tours'
  | 'customers'
  | 'registrations'
  | 'payments'
  | 'locations'
  | 'queries'
  | 'programs'

export default function App() {
  const [loggedIn, setLoggedIn] = useState(false)
  const [currentPage, setCurrentPage] = useState<Page>('dashboard')

  if (!loggedIn) {
    return <LoginPage onLogin={() => setLoggedIn(true)} />
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard': return <Dashboard onNavigate={setCurrentPage} />
      case 'guides': return <GuidesPage />
      case 'routes': return <RoutesPage />
      case 'tours': return <ToursPage />
      case 'customers': return <CustomersPage />
      case 'registrations': return <RegistrationsPage />
      case 'payments': return <PaymentsPage />
      case 'locations': return <LocationsPage />
      case 'queries': return <QueriesPage />
      case 'programs': return <ProgramsPage />
      default: return <Dashboard onNavigate={setCurrentPage} />
    }
  }

  return (
    <Layout currentPage={currentPage} onNavigate={setCurrentPage}>
      {renderPage()}
    </Layout>
  )
}
