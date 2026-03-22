/*
  # Fix Events RLS Policies
*/

DROP POLICY IF EXISTS "Anyone can view public events" ON events;
DROP POLICY IF EXISTS "Officers can create events" ON events;
DROP POLICY IF EXISTS "Officers can update events" ON events;
DROP POLICY IF EXISTS "Officers can delete events" ON events;

CREATE POLICY "Anyone can view public events"
  ON events FOR SELECT
  TO authenticated
  USING (
    is_public = true
    OR EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = events.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.status = 'active'
    )
  );

CREATE POLICY "Officers can create events"
  ON events FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = created_by
    AND EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = events.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.role = ANY (ARRAY['president', 'officer', 'admin'])
        AND club_members.status = 'active'
    )
  );

CREATE POLICY "Officers can update events"
  ON events FOR UPDATE
  TO authenticated
  USING (
    auth.uid() = created_by
    OR EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = events.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.role = ANY (ARRAY['president', 'officer', 'admin'])
        AND club_members.status = 'active'
    )
  )
  WITH CHECK (
    auth.uid() = created_by
    OR EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = events.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.role = ANY (ARRAY['president', 'officer', 'admin'])
        AND club_members.status = 'active'
    )
  );

CREATE POLICY "Officers can delete events"
  ON events FOR DELETE
  TO authenticated
  USING (
    auth.uid() = created_by
    OR EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = events.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.role = ANY (ARRAY['president', 'officer', 'admin'])
        AND club_members.status = 'active'
    )
  );
