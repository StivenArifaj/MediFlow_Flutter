# Supabase Schema (source of truth — matches web app exactly)

## profiles
id uuid PK, name text, email text, role app_role default 'patient',
is_premium bool default false, language text default 'en',
is_dark_mode bool default true, notifications_enabled bool default true,
created_at timestamptz, caregiver_id uuid null, invite_code text null

## medicines
id uuid PK, user_id uuid, verified_name text, brand_name text,
generic_name text, manufacturer text, strength text, form text,
category text, quantity int, notes text, api_source text default 'manual',
expiry_date date, created_at timestamptz, is_active bool default true

## reminders
id uuid PK, medicine_id uuid, user_id uuid, time text, 
frequency text default 'daily' (daily|specific_days|interval|as_needed),
days jsonb, interval_days int, duration_type text default 'ongoing',
end_date date, duration_days int, is_active bool default true,
snooze_duration int default 15, created_at timestamptz

## history_entries
id uuid PK, reminder_id uuid null, medicine_id uuid, user_id uuid,
status text (taken|taken_late|skipped|missed), scheduled_time timestamptz,
actual_time timestamptz null, notes text null, created_at timestamptz

## health_measurements
id uuid PK, user_id uuid, type text, value numeric, 
value_secondary numeric null, unit text, notes text null,
recorded_at timestamptz, created_at timestamptz

## RLS policies (15 total — all enabled)
Pattern per table: own_all (auth.uid()=user_id, full access) + 
caregiver_read (is_caregiver_of(user_id)) + linked_patient_reads (for medicines/reminders)
profiles has special update constraints — role/caregiver_id/is_premium/email 
are locked, only name/language/dark_mode/notifications/invite_code are free.

## RPC functions (SECURITY DEFINER)
- become_caregiver()
- link_to_caregiver_by_code(_code text)
- rotate_invite_code()
- unlink_caregiver()
(Need to add: delete_my_account() — does not exist yet, must be created)
