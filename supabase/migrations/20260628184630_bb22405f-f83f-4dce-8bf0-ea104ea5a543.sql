
DROP TRIGGER IF EXISTS on_auth_user_created_promote_first_admin ON auth.users;
DROP TRIGGER IF EXISTS promote_first_admin_trigger ON auth.users;
DROP FUNCTION IF EXISTS public.promote_first_admin() CASCADE;
