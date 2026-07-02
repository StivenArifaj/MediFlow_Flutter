-- ============================================================
-- MediFlow — Emergency Alerts
-- Run this in Supabase SQL Editor
-- ============================================================

-- Drop existing if re-running
DROP TABLE IF EXISTS public.emergency_alerts CASCADE;

-- Create table
CREATE TABLE public.emergency_alerts (
  id              uuid        PRIMARY KEY
                              DEFAULT gen_random_uuid(),
  patient_id      uuid        NOT NULL
                              REFERENCES public.profiles(id)
                              ON DELETE CASCADE,
  caregiver_id    uuid        NOT NULL
                              REFERENCES public.profiles(id)
                              ON DELETE CASCADE,
  message         text,
  is_acknowledged boolean     NOT NULL DEFAULT false,
  acknowledged_at timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Index for fast caregiver queries
CREATE INDEX idx_emergency_alerts_caregiver
  ON public.emergency_alerts(caregiver_id, is_acknowledged);

CREATE INDEX idx_emergency_alerts_patient
  ON public.emergency_alerts(patient_id, created_at DESC);

-- Enable RLS
ALTER TABLE public.emergency_alerts
  ENABLE ROW LEVEL SECURITY;

-- Patient can INSERT their own alerts
CREATE POLICY "patient_can_send_alert"
  ON public.emergency_alerts FOR INSERT
  WITH CHECK (
    patient_id = auth.uid()
    AND caregiver_id = (
      SELECT caregiver_id FROM public.profiles
      WHERE id = auth.uid()
    )
  );

-- Both patient and caregiver can SELECT
CREATE POLICY "alert_parties_can_read"
  ON public.emergency_alerts FOR SELECT
  USING (
    patient_id = auth.uid()
    OR caregiver_id = auth.uid()
  );

-- Only caregiver can UPDATE (acknowledge)
CREATE POLICY "caregiver_can_acknowledge"
  ON public.emergency_alerts FOR UPDATE
  USING (caregiver_id = auth.uid())
  WITH CHECK (
    caregiver_id = auth.uid()
    AND is_acknowledged = true
  );

-- Rate limiting function: max 3 alerts per 10 min
-- per patient (prevents accidental spam)
CREATE OR REPLACE FUNCTION public.check_alert_rate_limit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  recent_count int;
BEGIN
  SELECT COUNT(*) INTO recent_count
  FROM public.emergency_alerts
  WHERE patient_id = NEW.patient_id
    AND created_at > now() - INTERVAL '10 minutes';

  IF recent_count >= 3 THEN
    RAISE EXCEPTION
      'rate_limit: Too many alerts. Please wait before sending another.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER enforce_alert_rate_limit
  BEFORE INSERT ON public.emergency_alerts
  FOR EACH ROW
  EXECUTE FUNCTION public.check_alert_rate_limit();

-- Enable realtime
ALTER PUBLICATION supabase_realtime
  ADD TABLE public.emergency_alerts;

GRANT ALL ON public.emergency_alerts TO authenticated;
