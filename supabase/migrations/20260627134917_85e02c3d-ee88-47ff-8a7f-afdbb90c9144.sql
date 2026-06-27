
CREATE TYPE public.despesa_categoria AS ENUM ('mercadoria','laboratorio','marmitas','produtos_diversos');

CREATE TABLE public.despesas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  categoria public.despesa_categoria NOT NULL,
  descricao text,
  valor numeric NOT NULL DEFAULT 0,
  data_despesa date NOT NULL DEFAULT CURRENT_DATE,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.despesas TO authenticated;
GRANT ALL ON public.despesas TO service_role;

ALTER TABLE public.despesas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view despesas" ON public.despesas
  FOR SELECT TO authenticated USING (public.has_role(auth.uid(),'admin'));
CREATE POLICY "Admins can insert despesas" ON public.despesas
  FOR INSERT TO authenticated WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE POLICY "Admins can update despesas" ON public.despesas
  FOR UPDATE TO authenticated USING (public.has_role(auth.uid(),'admin')) WITH CHECK (public.has_role(auth.uid(),'admin'));
CREATE POLICY "Admins can delete despesas" ON public.despesas
  FOR DELETE TO authenticated USING (public.has_role(auth.uid(),'admin'));

CREATE TRIGGER update_despesas_updated_at
  BEFORE UPDATE ON public.despesas
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE INDEX idx_despesas_data ON public.despesas(data_despesa);
CREATE INDEX idx_despesas_categoria ON public.despesas(categoria);
