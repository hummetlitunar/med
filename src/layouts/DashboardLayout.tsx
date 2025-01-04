import { Navigate, Outlet, Link, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { 
  StethoscopeIcon, 
  LayoutDashboardIcon, 
  FolderIcon, 
  MessageSquareIcon, 
  UserIcon,
  LogOutIcon
} from 'lucide-react';
import { clsx } from 'clsx';

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboardIcon },
  { name: 'Files', href: '/files', icon: FolderIcon },
  { name: 'Forum', href: '/forum', icon: MessageSquareIcon },
  { name: 'Profile', href: '/profile', icon: UserIcon },
];

export default function DashboardLayout() {
  const { user, loading, signOut } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="animate-pulse">Loading...</div>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="fixed inset-y-0 left-0 w-64 bg-white border-r border-gray-200">
        <div className="flex items-center space-x-2 px-6 py-4 border-b">
          <StethoscopeIcon className="h-6 w-6 text-primary-600" />
          <span className="text-xl font-semibold text-gray-900">MedCollab</span>
        </div>
        
        <nav className="mt-6 px-3">
          {navigation.map((item) => {
            const Icon = item.icon;
            return (
              <Link
                key={item.name}
                to={item.href}
                className={clsx(
                  'flex items-center px-3 py-2 text-sm font-medium rounded-md my-1',
                  location.pathname === item.href
                    ? 'bg-primary-50 text-primary-700'
                    : 'text-gray-700 hover:bg-gray-50'
                )}
              >
                <Icon className="mr-3 h-5 w-5" />
                {item.name}
              </Link>
            );
          })}
          
          <button
            onClick={() => signOut()}
            className="flex items-center px-3 py-2 text-sm font-medium rounded-md text-gray-700 hover:bg-gray-50 w-full mt-4"
          >
            <LogOutIcon className="mr-3 h-5 w-5" />
            Sign Out
          </button>
        </nav>
      </div>

      {/* Main content */}
      <div className="pl-64">
        <main className="p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
}