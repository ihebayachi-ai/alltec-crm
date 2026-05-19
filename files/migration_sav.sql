-- ═══════════════════════════════════════════════════════════════════
-- ZENTIQ / AllTEC — Migration table tickets_sav
-- Ajoute les colonnes SAV manquantes à la table existante
-- Supabase SQL Editor → New Query → Coller → Run
-- ═══════════════════════════════════════════════════════════════════

-- Ajouter les colonnes manquantes (IF NOT EXISTS évite les erreurs si déjà présentes)
ALTER TABLE public.tickets_sav
  ADD COLUMN IF NOT EXISTS numero              text,
  ADD COLUMN IF NOT EXISTS date_reception      date,
  ADD COLUMN IF NOT EXISTS tel_client          text,
  ADD COLUMN IF NOT EXISTS agence              text,
  ADD COLUMN IF NOT EXISTS appareil            text,
  ADD COLUMN IF NOT EXISTS numero_serie        text,
  ADD COLUMN IF NOT EXISTS panne_declaree      text,
  ADD COLUMN IF NOT EXISTS etat_visuel         text,
  ADD COLUMN IF NOT EXISTS technicien          text,
  ADD COLUMN IF NOT EXISTS facture_ref         text,
  ADD COLUMN IF NOT EXISTS decision            text,
  ADD COLUMN IF NOT EXISTS diagnostic          text,
  ADD COLUMN IF NOT EXISTS rapport_diagnostic  text,
  ADD COLUMN IF NOT EXISTS montant_devis       numeric(10,3) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS accord_client       boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS detail_reparation   text,
  ADD COLUMN IF NOT EXISTS rapport_test        text,
  ADD COLUMN IF NOT EXISTS test_ok             boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS sms_envoye          boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS date_cloture        date,
  ADD COLUMN IF NOT EXISTS facture_sav_num     text;

-- Index utiles
CREATE INDEX IF NOT EXISTS idx_tickets_sav_statut  ON public.tickets_sav(statut);
CREATE INDEX IF NOT EXISTS idx_tickets_sav_created ON public.tickets_sav(created_at DESC);

-- S'assurer que RLS autorise l'accès anon
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'tickets_sav' AND policyname = 'allow_all_tickets_sav'
  ) THEN
    ALTER TABLE public.tickets_sav ENABLE ROW LEVEL SECURITY;
    CREATE POLICY "allow_all_tickets_sav"
      ON public.tickets_sav FOR ALL
      USING (true) WITH CHECK (true);
  END IF;
END $$;

-- Vérification : liste des colonnes après migration
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'tickets_sav'
ORDER BY ordinal_position;
