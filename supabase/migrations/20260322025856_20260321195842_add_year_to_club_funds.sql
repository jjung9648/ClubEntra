/*
  # Add year column to club_funds
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'club_funds' AND column_name = 'year'
  ) THEN
    ALTER TABLE club_funds ADD COLUMN year integer NOT NULL DEFAULT 2026;
  END IF;
END $$;
