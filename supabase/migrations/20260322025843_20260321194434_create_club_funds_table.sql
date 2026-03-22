/*
  # Create club_funds table
*/

CREATE TABLE IF NOT EXISTS club_funds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id uuid NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  fund_type text NOT NULL CHECK (fund_type IN ('IRA', 'DOC', 'ASI', 'Club Fund')),
  balance numeric(14,2) NOT NULL DEFAULT 0,
  updated_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  updated_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (club_id, fund_type)
);

ALTER TABLE club_funds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Active club members can view club funds"
  ON club_funds FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = club_funds.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.status = 'active'
    )
  );

CREATE POLICY "Officers can insert club funds"
  ON club_funds FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = club_funds.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.status = 'active'
        AND club_members.role IN ('officer', 'president', 'admin')
    )
  );

CREATE POLICY "Officers can update club funds"
  ON club_funds FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = club_funds.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.status = 'active'
        AND club_members.role IN ('officer', 'president', 'admin')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = club_funds.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.status = 'active'
        AND club_members.role IN ('officer', 'president', 'admin')
    )
  );

CREATE POLICY "Presidents and admins can delete club funds"
  ON club_funds FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM club_members
      WHERE club_members.club_id = club_funds.club_id
        AND club_members.user_id = auth.uid()
        AND club_members.status = 'active'
        AND club_members.role IN ('president', 'admin')
    )
  );

CREATE INDEX IF NOT EXISTS club_funds_club_id_idx ON club_funds(club_id);
