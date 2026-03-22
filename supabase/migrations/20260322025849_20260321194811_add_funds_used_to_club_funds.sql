/*
  # Add funds_used column to club_funds
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'club_funds' AND column_name = 'funds_used'
  ) THEN
    ALTER TABLE club_funds ADD COLUMN funds_used numeric(14,2) NOT NULL DEFAULT 0;
  END IF;
END $$;
