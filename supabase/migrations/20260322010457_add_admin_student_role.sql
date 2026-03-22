/*
  # Add 'admin' to student_role allowed values

  ## Changes
  - Drops the existing CHECK constraint on `profiles.student_role`
  - Adds a new CHECK constraint that allows 'member', 'officer', and 'admin'

  ## Notes
  - Existing data is unaffected (all current values are 'member' or 'officer')
  - This allows designating a profile as an application-level admin
*/

ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_student_role_check;

ALTER TABLE profiles ADD CONSTRAINT profiles_student_role_check
  CHECK (student_role IN ('member', 'officer', 'admin'));
