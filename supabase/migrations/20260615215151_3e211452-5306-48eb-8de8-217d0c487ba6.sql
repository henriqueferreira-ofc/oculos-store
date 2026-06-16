
CREATE SEQUENCE IF NOT EXISTS public.ordens_servico_numero_seq START WITH 1;

CREATE TABLE public.ordens_servico (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  numero INTEGER NOT NULL UNIQUE DEFAULT nextval('public.ordens_servico_numero_seq'),
  nome TEXT NOT NULL,
  fone TEXT,
  entrada NUMERIC(12,2),
  valor_total NUMERIC(12,2),
  lentes TEXT,
  armacao TEXT,
  alt TEXT,
  cor TEXT,
  od_esf TEXT, od_cil TEXT, od_eixo TEXT, od_dp TEXT,
  oe_esf TEXT, oe_cil TEXT, oe_eixo TEXT, oe_dp TEXT,
  adicao TEXT,
  status TEXT NOT NULL DEFAULT 'aberta' CHECK (status IN ('aberta','pronta','entregue')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER SEQUENCE public.ordens_servico_numero_seq OWNED BY public.ordens_servico.numero;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.ordens_servico TO authenticated;
GRANT USAGE ON SEQUENCE public.ordens_servico_numero_seq TO authenticated;
GRANT ALL ON public.ordens_servico TO service_role;
GRANT ALL ON SEQUENCE public.ordens_servico_numero_seq TO service_role;

ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view all OS"
  ON public.ordens_servico FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert OS"
  ON public.ordens_servico FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can update OS"
  ON public.ordens_servico FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can delete OS"
  ON public.ordens_servico FOR DELETE TO authenticated USING (true);

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql SET search_path = public;

CREATE TRIGGER update_ordens_servico_updated_at
  BEFORE UPDATE ON public.ordens_servico
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE INDEX idx_ordens_servico_nome ON public.ordens_servico (lower(nome));
CREATE INDEX idx_ordens_servico_numero ON public.ordens_servico (numero DESC);
