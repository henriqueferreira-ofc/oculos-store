CREATE TABLE public.vendas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo text NOT NULL,
  cliente text NOT NULL,
  produto text NOT NULL,
  valor numeric NOT NULL DEFAULT 0,
  forma_pagamento text,
  data_venda date NOT NULL DEFAULT CURRENT_DATE,
  observacoes text,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.vendas TO authenticated;
GRANT ALL ON public.vendas TO service_role;

ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view all sales"
  ON public.vendas FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert sales"
  ON public.vendas FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can update sales"
  ON public.vendas FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can delete sales"
  ON public.vendas FOR DELETE TO authenticated USING (true);

CREATE TRIGGER update_vendas_updated_at
  BEFORE UPDATE ON public.vendas
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE INDEX idx_vendas_data ON public.vendas(data_venda);
CREATE INDEX idx_vendas_tipo ON public.vendas(tipo);
