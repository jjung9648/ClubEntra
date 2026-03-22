/*
  # Add 'admin' to student_role allowed values
*/

ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_student_role_check;

ALTER TABLE profiles ADD CONSTRAINT profiles_student_role_check
  CHECK (student_role IN ('member', 'officer', 'admin'));
