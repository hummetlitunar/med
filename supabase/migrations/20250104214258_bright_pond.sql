/*
  # Initial Schema Setup for Medical Students' Collaboration Platform

  1. New Tables
    - profiles
      - Extends auth.users with additional user information
      - Stores user roles and contribution scores
    - categories
      - For organizing educational content
    - files
      - Stores file metadata and references to storage
    - forum_posts
      - For discussion functionality
    
  2. Security
    - RLS policies for each table
    - Role-based access control
*/

-- Create custom types
CREATE TYPE user_role AS ENUM ('founder', 'admin', 'member');

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL,
  role user_role DEFAULT 'member'::user_role,
  contribution_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create files table
CREATE TABLE IF NOT EXISTS files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  url TEXT NOT NULL,
  size INTEGER NOT NULL,
  type TEXT NOT NULL,
  category_id UUID REFERENCES categories(id),
  user_id UUID REFERENCES auth.users(id),
  downloads INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create forum_posts table
CREATE TABLE IF NOT EXISTS forum_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_posts ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Categories policies
CREATE POLICY "Categories are viewable by authenticated users"
  ON categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only founders and admins can manage categories"
  ON categories FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('founder', 'admin')
    )
  );

-- Files policies
CREATE POLICY "Files are viewable by authenticated users"
  ON files FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only founders and admins can manage files"
  ON files FOR INSERT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('founder', 'admin')
    )
  );

-- Forum posts policies
CREATE POLICY "Forum posts are viewable by authenticated users"
  ON forum_posts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can create forum posts"
  ON forum_posts FOR INSERT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own forum posts"
  ON forum_posts FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Insert default categories
INSERT INTO categories (name, slug, description) VALUES
  ('Medical Courses', 'medical-courses', 'General medical course materials'),
  ('Exam Preparation', 'exam-prep', 'Resources for exam preparation'),
  ('Clinical Skills', 'clinical-skills', 'Materials for clinical skills development'),
  ('Research', 'research', 'Research papers and materials'),
  ('General Information', 'general-info', 'General medical information and updates');

-- Profiles için INSERT trigger ekle
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, first_name, last_name, email, role)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'first_name',
    new.raw_user_meta_data->>'last_name',
    new.email,
    'member'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();