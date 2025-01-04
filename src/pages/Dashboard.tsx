import { useAuth } from '../contexts/AuthContext';

export default function Dashboard() {
  const { user } = useAuth();

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">
        Welcome, {user?.first_name}!
      </h1>
      {/* Dashboard content will be implemented next */}
    </div>
  );
}