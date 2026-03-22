/*
  # Auto-create profile on user signup via trigger

  ## Problem
  When a new user signs up, the client tries to insert a profile row immediately
  after auth.signUp(). However, if email confirmation is enabled the session is
  not yet active, so auth.uid() returns null and the RLS INSERT policy
  (auth.uid() = id) blocks the insert.

  ## Solution
  Create a SECURITY DEFINER trigger function on auth.users that automatically
  creates the matching profile row using the metadata supplied during signUp.
  This runs with elevated privileges so RLS does not interfere.

  ## Changes
  - New function: public.handle_new_user() — reads full_name, university,
    student_id, student_role, club_name, major from raw_user_meta_data and
    inserts a profiles row.
  - New trigger: on_auth_user_created — fires AFTER INSERT ON auth.users.
*/

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    full_name,
    university,
    student_id,
    student_role,
    club_name,
    major,
    username,
    bio,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'university', ''),
    COALESCE(NEW.raw_user_meta_data->>'student_id', ''),
    COALESCE(NEW.raw_user_meta_data->>'student_role', 'member'),
    COALESCE(NEW.raw_user_meta_data->>'club_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'major', ''),
    COALESCE(NEW.raw_user_meta_data->>'username', ''),
    COALESCE(NEW.raw_user_meta_data->>'bio', ''),
    now(),
    now()
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
