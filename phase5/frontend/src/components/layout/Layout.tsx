import { useState } from 'react'
import {
  LayoutDashboard, Users, Map, CalendarDays, UserCircle,
  ClipboardList, CreditCard, MapPin, Search, Cpu,
  Menu, X, Compass, ChevronRight
} from 'lucide-react'
import type { Page } from '../../App'

const navItems: { id: Page; label: string; icon: React.ReactNode; description: string }[] = [
  { id: 'dashboard',     label: 'Dashboard',     icon: <LayoutDashboard size={18} />, description: 'Overview & stats' },
  { id: 'guides',        label: 'Guides',         icon: <Users size={18} />,           description: 'Tour guide management' },
  { id: 'routes',        label: 'Routes',         icon: <Map size={18} />,             description: 'Route definitions' },
  { id: 'tours',         label: 'Tours',          icon: <CalendarDays size={18} />,    description: 'Guided tour instances' },
  { id: 'customers',     label: 'Customers',      icon: <UserCircle size={18} />,      description: 'Customer database' },
  { id: 'registrations', label: 'Registrations',  icon: <ClipboardList size={18} />,  description: 'Tour registrations' },
  { id: 'payments',      label: 'Payments',       icon: <CreditCard size={18} />,      description: 'Payment records' },
  { id: 'locations',     label: 'Locations',      icon: <MapPin size={18} />,          description: 'Route locations' },
  { id: 'queries',       label: 'Analytics',      icon: <Search size={18} />,          description: 'Phase 2 queries' },
  { id: 'programs',      label: 'Programs',       icon: <Cpu size={18} />,             description: 'Phase 4 functions' },
]

interface Props {
  currentPage: Page
  onNavigate: (page: Page) => void
  children: React.ReactNode
}

export default function Layout({ currentPage, onNavigate, children }: Props) {
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const current = navItems.find(n => n.id === currentPage)

  return (
    <div className="flex h-screen overflow-hidden bg-[#0f0d0b]">
      {/* Sidebar */}
      <aside
        className={`${sidebarOpen ? 'w-60' : 'w-16'} flex-shrink-0 flex flex-col transition-all duration-300 ease-in-out
          bg-[#120e0b] border-r border-[#2d2318]`}
      >
        {/* Logo */}
        <div className="flex items-center gap-3 px-4 py-5 border-b border-[#2d2318]">
          <div className="w-8 h-8 rounded-lg bg-[#d08530] flex items-center justify-center flex-shrink-0">
            <Compass size={16} className="text-[#0f0d0b]" />
          </div>
          {sidebarOpen && (
            <div className="overflow-hidden">
              <div className="font-display font-bold text-[#f9edd8] text-sm leading-tight whitespace-nowrap">TourGuide</div>
              <div className="text-[10px] text-[#8a7560] whitespace-nowrap">Management System</div>
            </div>
          )}
        </div>

        {/* Nav */}
        <nav className="flex-1 py-4 px-2 overflow-y-auto space-y-0.5">
          {navItems.map(item => (
            <button
              key={item.id}
              onClick={() => onNavigate(item.id)}
              className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-left transition-all duration-150
                ${currentPage === item.id
                  ? 'bg-[#d08530]/15 text-[#e8c07e] border border-[#d08530]/30'
                  : 'text-[#8a7560] hover:text-[#c9b99a] hover:bg-[#1c1917]'
                }`}
              title={!sidebarOpen ? item.label : undefined}
            >
              <span className="flex-shrink-0">{item.icon}</span>
              {sidebarOpen && (
                <span className="text-sm font-medium whitespace-nowrap overflow-hidden">{item.label}</span>
              )}
              {sidebarOpen && currentPage === item.id && (
                <ChevronRight size={14} className="ml-auto opacity-70" />
              )}
            </button>
          ))}
        </nav>

        {/* Toggle */}
        <div className="p-3 border-t border-[#2d2318]">
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="w-full flex items-center justify-center p-2 rounded-lg text-[#8a7560] hover:text-[#c9b99a] hover:bg-[#1c1917] transition-colors"
          >
            {sidebarOpen ? <X size={16} /> : <Menu size={16} />}
          </button>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 flex flex-col overflow-hidden">
        {/* Topbar */}
        <header className="flex items-center justify-between px-6 py-4 border-b border-[#2d2318] bg-[#0f0d0b] flex-shrink-0">
          <div>
            <h1 className="font-display text-xl font-bold text-[#f9edd8]">{current?.label}</h1>
            <p className="text-xs text-[#8a7560]">{current?.description}</p>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-[#60a567] animate-pulse" />
            <span className="text-xs text-[#8a7560]">Connected</span>
          </div>
        </header>

        {/* Page content */}
        <div className="flex-1 overflow-y-auto p-6">
          {children}
        </div>
      </main>
    </div>
  )
}
