/*
  # Add event fields to fund_transactions
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fund_transactions' AND column_name = 'event_name'
  ) THEN
    ALTER TABLE fund_transactions ADD COLUMN event_name text DEFAULT '';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fund_transactions' AND column_name = 'event_date'
  ) THEN
    ALTER TABLE fund_transactions ADD COLUMN event_date text DEFAULT '';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'fund_transactions' AND column_name = 'attendee_count'
  ) THEN
    ALTER TABLE fund_transactions ADD COLUMN attendee_count integer DEFAULT 0;
  END IF;
END $$;
