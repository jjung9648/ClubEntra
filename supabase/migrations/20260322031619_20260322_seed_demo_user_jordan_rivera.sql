/*
  # Seed Demo User: Jordan Rivera

  ## Summary
  Creates a complete demo account for Jordan Rivera (jordan.rivera@calpoly.edu)
  with realistic data across all major features of ClubEntra.

  ## Changes

  ### Profile
  - Updates Jordan Rivera's profile: CS junior at Cal Poly SLO, student ID CP-20240892, officer role

  ### Clubs (3)
  - ACM (Association for Computing Machinery) — Technology club
  - ECSJC (Engineering & CS Journal Club) — Academic club
  - Robotics Club — Engineering club

  ### Club Memberships
  - Jordan is officer in ACM, member in ECSJC, president in Robotics Club

  ### Club Funds
  - ACM: $2,000 IRA fund
  - ECSJC: $3,100 ASI fund
  - Robotics Club: $3,125 DOC fund with tracked spending

  ### Events (6)
  - Spring Hackathon, Tech Talk, Officer Meeting (ACM)
  - Robot Build Day, Regional Competition (Robotics)
  - End-of-Year Social (ECSJC)

  ### RSVPs
  - Jordan marked "going" on 4 events

  ### Fund Transactions (5)
  - Realistic spending entries across clubs

  ### Funding Requests (3)
  - One approved, two pending

  ### Announcements (2)
  - One pinned in ACM, one in Robotics Club

  ## Notes
  - Uses DO $$ ... END $$ block to reference the demo user's UUID dynamically
  - ON CONFLICT DO NOTHING / DO UPDATE used for idempotency
*/

DO $$
DECLARE
  v_user_id uuid;
  v_acm_id uuid := gen_random_uuid();
  v_ecsjc_id uuid := gen_random_uuid();
  v_robotics_id uuid := gen_random_uuid();
  v_acm_fund_id uuid := gen_random_uuid();
  v_ecsjc_fund_id uuid := gen_random_uuid();
  v_robotics_fund_id uuid := gen_random_uuid();
  v_event1_id uuid := gen_random_uuid();
  v_event2_id uuid := gen_random_uuid();
  v_event3_id uuid := gen_random_uuid();
  v_event4_id uuid := gen_random_uuid();
  v_event5_id uuid := gen_random_uuid();
  v_event6_id uuid := gen_random_uuid();
BEGIN
  -- Get the demo user's real UUID
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'jordan.rivera@calpoly.edu';

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Demo user jordan.rivera@calpoly.edu not found in auth.users';
  END IF;

  -- ─── Update Profile ───────────────────────────────────────────────────────
  INSERT INTO public.profiles (
    id, full_name, username, major, graduation_year, university,
    student_id, student_role, bio, avatar_url, created_at, updated_at
  ) VALUES (
    v_user_id,
    'Jordan Rivera',
    'jrivera',
    'Computer Science',
    2026,
    'Cal Poly San Luis Obispo',
    'CP-20240892',
    'officer',
    'Junior CS student passionate about software engineering, open source, and building things that matter. Officer in ACM, president of Robotics Club.',
    'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    username = EXCLUDED.username,
    major = EXCLUDED.major,
    graduation_year = EXCLUDED.graduation_year,
    university = EXCLUDED.university,
    student_id = EXCLUDED.student_id,
    student_role = EXCLUDED.student_role,
    bio = EXCLUDED.bio,
    avatar_url = EXCLUDED.avatar_url,
    updated_at = now();

  -- ─── Create Clubs ─────────────────────────────────────────────────────────
  INSERT INTO public.clubs (
    id, name, description, short_description, category,
    logo_url, banner_url, university, is_active, is_public,
    member_count, founded_year, contact_email, website,
    meeting_schedule, location, created_by, total_funds
  ) VALUES
  (
    v_acm_id,
    'ACM',
    'The Association for Computing Machinery at Cal Poly SLO is one of the largest CS organizations on campus. We host hackathons, tech talks, workshops, and networking events to help students grow as engineers and connect with industry professionals.',
    'Cal Poly''s largest CS org — hackathons, tech talks, and more.',
    'Technology',
    'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=800',
    'Cal Poly San Luis Obispo',
    true, true, 142, 2003,
    'acm@calpoly.edu', 'https://acm.calpoly.edu',
    'Thursdays 6–8 PM', 'Building 14, Room 232',
    v_user_id, 2000
  ),
  (
    v_ecsjc_id,
    'ECSJC',
    'The Engineering & CS Journal Club meets weekly to read, discuss, and present cutting-edge research papers in computer science and engineering. A great space for students who want to stay current with academic literature and sharpen their research skills.',
    'Weekly paper discussions on CS & engineering research.',
    'Academic',
    'https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/2041540/pexels-photo-2041540.jpeg?auto=compress&cs=tinysrgb&w=800',
    'Cal Poly San Luis Obispo',
    true, true, 38, 2018,
    'ecsjc@calpoly.edu', '',
    'Tuesdays 5–6:30 PM', 'Engineering Building, Room 407',
    v_user_id, 3100
  ),
  (
    v_robotics_id,
    'Robotics Club',
    'Cal Poly Robotics Club designs, builds, and competes with autonomous robots. From ground vehicles to aerial drones, our members get hands-on experience with mechanical design, embedded systems, computer vision, and control theory.',
    'Building and competing with autonomous robots since 2005.',
    'Engineering',
    'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&w=400',
    'https://images.pexels.com/photos/2085831/pexels-photo-2085831.jpeg?auto=compress&cs=tinysrgb&w=800',
    'Cal Poly San Luis Obispo',
    true, true, 67, 2005,
    'robotics@calpoly.edu', 'https://robotics.calpoly.edu',
    'Wednesdays 7–9 PM & Saturdays 10 AM–2 PM', 'Engineering West, Room 102',
    v_user_id, 3125
  )
  ON CONFLICT (id) DO NOTHING;

  -- ─── Club Memberships ─────────────────────────────────────────────────────
  INSERT INTO public.club_members (club_id, user_id, role, status, joined_at) VALUES
    (v_acm_id,      v_user_id, 'officer',   'active', now() - interval '18 months'),
    (v_ecsjc_id,    v_user_id, 'member',    'active', now() - interval '10 months'),
    (v_robotics_id, v_user_id, 'president', 'active', now() - interval '24 months')
  ON CONFLICT DO NOTHING;

  -- ─── Club Funds ───────────────────────────────────────────────────────────
  INSERT INTO public.club_funds (id, club_id, fund_type, balance, funds_used, updated_by, year) VALUES
    (v_acm_fund_id,      v_acm_id,      'IRA',       2000, 450,  v_user_id, 2026),
    (v_ecsjc_fund_id,    v_ecsjc_id,    'ASI',       3100, 220,  v_user_id, 2026),
    (v_robotics_fund_id, v_robotics_id, 'DOC',       3125, 1075, v_user_id, 2026)
  ON CONFLICT (id) DO NOTHING;

  -- ─── Events ───────────────────────────────────────────────────────────────
  INSERT INTO public.events (
    id, club_id, title, description, location,
    start_time, end_time, is_public, max_attendees, rsvp_count,
    image_url, event_type, created_by
  ) VALUES
  (
    v_event1_id, v_acm_id,
    'Spring Hackathon 2026',
    'Our annual 24-hour hackathon open to all Cal Poly students. Build something amazing, win prizes, and have fun. Teams of up to 4. Food and drinks provided.',
    'Engineering Plaza',
    now() + interval '14 days',
    now() + interval '15 days',
    true, 200, 87,
    'https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg?auto=compress&cs=tinysrgb&w=800',
    'workshop', v_user_id
  ),
  (
    v_event2_id, v_acm_id,
    'Tech Talk: Building Scalable APIs',
    'Industry engineer from Stripe will walk through how to design and scale REST and GraphQL APIs. Q&A session after. Great for anyone interested in backend engineering.',
    'Building 14, Room 232',
    now() + interval '5 days',
    now() + interval '5 days' + interval '2 hours',
    true, 60, 44,
    'https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=800',
    'workshop', v_user_id
  ),
  (
    v_event3_id, v_acm_id,
    'Officer Meeting — Spring Planning',
    'Monthly officer check-in. Agenda: hackathon logistics, budget review, spring quarter calendar, and new member outreach strategy.',
    'Building 14, Room 218',
    now() + interval '3 days',
    now() + interval '3 days' + interval '90 minutes',
    false, 12, 9,
    'https://images.pexels.com/photos/3183150/pexels-photo-3183150.jpeg?auto=compress&cs=tinysrgb&w=800',
    'meeting', v_user_id
  ),
  (
    v_event4_id, v_robotics_id,
    'Robot Build Day',
    'Full Saturday build session to finalize the chassis and sensor array for Regional Competition. All members welcome. Bring your tools and your ideas.',
    'Engineering West, Room 102',
    now() + interval '8 days',
    now() + interval '8 days' + interval '5 hours',
    false, 30, 22,
    'https://images.pexels.com/photos/2085831/pexels-photo-2085831.jpeg?auto=compress&cs=tinysrgb&w=800',
    'workshop', v_user_id
  ),
  (
    v_event5_id, v_robotics_id,
    'Regional Robotics Competition',
    'We''re competing in the SoCal Regional Autonomous Vehicle Challenge. Cheer on our team as we go head-to-head with 12 other universities.',
    'Cal Poly Pomona, Engineering Pavilion',
    now() + interval '30 days',
    now() + interval '31 days',
    true, 50, 18,
    'https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg?auto=compress&cs=tinysrgb&w=800',
    'competition', v_user_id
  ),
  (
    v_event6_id, v_ecsjc_id,
    'End-of-Year Social',
    'Celebrate the end of the academic year with the ECSJC crew. Food, games, and a recap of our favorite papers from the year. Bring a friend!',
    'Poly Canyon Village, Outdoor Lounge',
    now() + interval '45 days',
    now() + interval '45 days' + interval '3 hours',
    true, 80, 31,
    'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=800',
    'social', v_user_id
  )
  ON CONFLICT (id) DO NOTHING;

  -- ─── RSVPs (Jordan going to 4 events) ────────────────────────────────────
  INSERT INTO public.event_rsvps (event_id, user_id, status) VALUES
    (v_event1_id, v_user_id, 'going'),
    (v_event2_id, v_user_id, 'going'),
    (v_event3_id, v_user_id, 'going'),
    (v_event4_id, v_user_id, 'going')
  ON CONFLICT DO NOTHING;

  -- ─── Fund Transactions (5) ────────────────────────────────────────────────
  INSERT INTO public.fund_transactions (
    club_fund_id, club_id, fund_type, year,
    description, amount, event_name, event_date, attendee_count, created_by
  ) VALUES
  (
    v_acm_fund_id, v_acm_id, 'IRA', 2026,
    'Pizza and beverages for weekly workshop night',
    150, 'Weekly Workshop', '2026-02-14', 45, v_user_id
  ),
  (
    v_acm_fund_id, v_acm_id, 'IRA', 2026,
    'Printed flyers and poster boards for spring hackathon promo',
    85, 'Spring Hackathon 2026', '2026-03-01', 0, v_user_id
  ),
  (
    v_acm_fund_id, v_acm_id, 'IRA', 2026,
    'HDMI adapters and whiteboard markers for tech talk room setup',
    215, 'Tech Talk Series', '2026-03-10', 60, v_user_id
  ),
  (
    v_robotics_fund_id, v_robotics_id, 'DOC', 2026,
    'Servo motors and mounting hardware for robot arm prototype',
    425, 'Robot Build Day', '2026-02-22', 18, v_user_id
  ),
  (
    v_robotics_fund_id, v_robotics_id, 'DOC', 2026,
    'Team registration fee and travel reimbursement for regional competition',
    650, 'Regional Robotics Competition', '2026-04-12', 8, v_user_id
  )
  ON CONFLICT DO NOTHING;

  -- ─── Funding Requests (3) ─────────────────────────────────────────────────
  INSERT INTO public.funding_requests (
    club_id, title, description, amount, category, status, priority, submitted_by
  ) VALUES
  (
    v_acm_id,
    'Spring Hackathon Catering & Supplies',
    'Request for food, drinks, and event supplies for our 24-hour Spring Hackathon expecting 150–200 attendees. Covers 3 meals and 2 snack breaks.',
    1800, 'event', 'approved', 'high', v_user_id
  ),
  (
    v_robotics_id,
    'New Sensor Array — LIDAR Upgrade',
    'Requesting funds to upgrade our robot''s LIDAR sensor system for improved obstacle detection. This will be critical for the Regional Competition in April.',
    975, 'equipment', 'pending', 'urgent', v_user_id
  ),
  (
    v_ecsjc_id,
    'Research Paper Access Subscriptions',
    'Request to purchase one-year subscriptions to IEEE Xplore and ACM Digital Library for the club, enabling access to full-text research papers for our weekly discussions.',
    320, 'supplies', 'pending', 'normal', v_user_id
  )
  ON CONFLICT DO NOTHING;

  -- ─── Announcements (2) ────────────────────────────────────────────────────
  INSERT INTO public.announcements (club_id, title, content, author_id, is_pinned) VALUES
  (
    v_acm_id,
    'Spring Hackathon Registration is OPEN!',
    'Hey ACM fam! Registration for our Spring Hackathon is officially open. Spots are limited to 200 participants — grab your team of up to 4 and sign up before April 1st. There will be prizes for top 3 teams, plus category awards for Best UI, Most Creative, and Best First-Time Hacker. Food and swag provided. See you there!',
    v_user_id,
    true
  ),
  (
    v_robotics_id,
    'Regional Competition — Final Prep Schedule',
    'Robotics team — we''re in the final stretch before Regionals. Here''s the plan: Build Days every Saturday in April, full system test on April 5th, depart for Cal Poly Pomona on April 11th. If you''re on the travel roster, make sure you''ve submitted your availability form. Hype up, let''s bring home a trophy!',
    v_user_id,
    false
  )
  ON CONFLICT DO NOTHING;

END $$;
