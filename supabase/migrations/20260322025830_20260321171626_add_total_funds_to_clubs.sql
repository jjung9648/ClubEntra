/*
  # Add total_funds to clubs table
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'clubs' AND column_name = 'total_funds'
  ) THEN
    ALTER TABLE clubs ADD COLUMN total_funds numeric(12,2) NOT NULL DEFAULT 0;
  END IF;
END $$;
