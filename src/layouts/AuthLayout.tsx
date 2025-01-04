import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { StethoscopeIcon } from 'lucide-react';

export default function AuthLayout() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="animate-pulse">Loading...</div>
      </div>
    );
  }

  if (user) {
    return <Navigate to="/dashboard" replace />;
  }

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-primary-50 to-secondary-50">
      <div className="mb-8 flex items-center space-x-2">
        <StethoscopeIcon className="h-8 w-8 text-primary-600" />
        <h1 className="text-2xl font-bold text-gray-900">MedCollab</h1>
      </div>
      <div className="w-full max-w-md">
        <div className="bg-white px-8 py-10 shadow-xl rounded-lg">
          <Outlet />
        </div>
      </div>
    </div>
  );
}