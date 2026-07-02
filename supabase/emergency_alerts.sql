-- Emergency alerts: linked patient -> caregiver.
-- Run this in the Supabase SQL editor once.

create table if not exists public.emergency_alerts (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.profiles(id) on delete cascade,
  caregiver_id uuid not null references public.profiles(id) on delete cascade,
  message text,
  acknowledged boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.emergency_alerts enable row level security;

create policy "patient inserts own alerts"
  on public.emergency_alerts for insert
  with check (auth.uid() = patient_id);

create policy "involved users read alerts"
  on public.emergency_alerts for select
  using (auth.uid() = patient_id or auth.uid() = caregiver_id);

create policy "caregiver acknowledges alerts"
  on public.emergency_alerts for update
  using (auth.uid() = caregiver_id);

-- Realtime so the caregiver dashboard gets alerts instantly
alter publication supabase_realtime add table public.emergency_alerts;
