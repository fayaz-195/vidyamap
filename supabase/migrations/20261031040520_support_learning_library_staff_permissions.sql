-- Index author foreign keys and honor explicitly assigned learning-library staff access.
create index if not exists learning_resources_created_by_idx on public.learning_resources(created_by) where created_by is not null;
create index if not exists learning_resources_updated_by_idx on public.learning_resources(updated_by) where updated_by is not null;
create index if not exists learning_questions_created_by_idx on public.learning_questions(created_by) where created_by is not null;
create index if not exists learning_questions_updated_by_idx on public.learning_questions(updated_by) where updated_by is not null;
create or replace function public.learning_library_is_admin()
returns boolean language sql stable set search_path=public as $$
 select exists(
  select 1 from public.profiles p
  where p.id=(select auth.uid()) and p.is_active=true
   and (
    p.is_founder=true or p.role::text='platform_admin'
    or (p.role::text='counsellor' and exists(
      select 1 from public.admin_staff_access a
      where a.user_id=p.id and coalesce(a.feature_permissions->>'learningLibrary','false')='true'
    ))
   )
 );
$$;
revoke all on function public.learning_library_is_admin() from public;
grant execute on function public.learning_library_is_admin() to authenticated;
