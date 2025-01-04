export type UserRole = 'founder' | 'admin' | 'member';

export interface User {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  role: UserRole;
  contribution_score: number;
  created_at: string;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  description: string;
}

export interface File {
  id: string;
  name: string;
  url: string;
  size: number;
  type: string;
  category_id: string;
  user_id: string;
  created_at: string;
  downloads: number;
}

export interface ForumPost {
  id: string;
  title: string;
  content: string;
  user_id: string;
  created_at: string;
  updated_at: string;
}