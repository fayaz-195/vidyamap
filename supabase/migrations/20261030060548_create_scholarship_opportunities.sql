create table if not exists public.scholarship_opportunities (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null check (char_length(title) between 3 and 180),
  state text not null default 'India' check (state in ('Telangana','Andhra Pradesh','India')),
  scheme_type text not null default 'Scholarship' check (scheme_type in ('Scholarship','Loan support')),
  study_level text not null default 'All' check (study_level in ('School','Intermediate','UG','PG','All')),
  category text not null default 'Scholarship scheme' check (char_length(category) between 2 and 100),
  summary text not null check (char_length(summary) between 20 and 1200),
  eligibility text,
  benefits text,
  required_documents text[] not null default '{}',
  official_url text not null check (official_url ~ '^https?://'),
  application_url text check (application_url is null or application_url ~ '^https?://'),
  source_label text not null default 'Official portal',
  source_note text,
  academic_year text,
  application_start date,
  deadline date,
  deadline_note text,
  source_checked_at date,
  is_featured boolean not null default false,
  status text not null default 'draft' check (status in ('draft','published','paused','archived')),
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists scholarship_opportunities_public_idx
  on public.scholarship_opportunities (status, state, deadline);

alter table public.scholarship_opportunities enable row level security;

grant select on public.scholarship_opportunities to anon, authenticated;
grant insert, update, delete on public.scholarship_opportunities to authenticated;

create policy "Published scholarships are publicly readable"
  on public.scholarship_opportunities for select
  to anon, authenticated
  using (status = 'published');

create policy "Active platform admins can read all scholarships"
  on public.scholarship_opportunities for select
  to authenticated
  using (exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_active = true and (p.is_founder = true or p.role = 'platform_admin')));

create policy "Active platform admins can create scholarships"
  on public.scholarship_opportunities for insert
  to authenticated
  with check (exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_active = true and (p.is_founder = true or p.role = 'platform_admin')));

create policy "Active platform admins can update scholarships"
  on public.scholarship_opportunities for update
  to authenticated
  using (exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_active = true and (p.is_founder = true or p.role = 'platform_admin')))
  with check (exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_active = true and (p.is_founder = true or p.role = 'platform_admin')));

create policy "Active platform admins can archive scholarships"
  on public.scholarship_opportunities for delete
  to authenticated
  using (exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.is_active = true and (p.is_founder = true or p.role = 'platform_admin')));

insert into public.scholarship_opportunities
  (slug,title,state,scheme_type,study_level,category,summary,official_url,application_url,source_label,source_note,academic_year,deadline,deadline_note,source_checked_at,status,is_featured)
values
('telangana-epass','Telangana ePASS — Pre-Matric & Post-Matric Scholarships','Telangana','Scholarship','All','State welfare scheme','Telangana ePASS is the official starting point for state pre-matric and post-matric scholarship programmes, including tuition-fee reimbursement and maintenance support. Scheme-specific eligibility and windows differ.','https://telanganaepass.cgg.gov.in/','https://telanganaepass.cgg.gov.in/','Telangana ePASS portal','Government portal; check the current scheme window and eligibility on the portal.',null,null,'Check official portal for the active scheme deadline.',current_date,'published',true),
('ap-jnanabhumi','Andhra Pradesh Jnanabhumi — Post-Matric Scholarships','Andhra Pradesh','Scholarship','All','State welfare scheme','Andhra Pradesh Jnanabhumi provides the official student-facing scholarship workflow and information for post-matric support. Follow the portal and college welfare office instructions for fresh and renewal cases.','https://jnanabhumi.ap.gov.in/','https://jnanabhumi.ap.gov.in/','AP Jnanabhumi portal','Government portal; confirm the applicable scheme and current application instructions.',null,null,'Check official portal for the active scheme deadline.',current_date,'published',true),
('national-scholarship-portal','National Scholarship Portal (NSP)','India','Scholarship','All','Central government portal','The central portal hosts multiple ministry and department scholarships. Eligibility, documents, verification stages and application dates differ for each scheme; check the scheme-specific notice before applying.','https://scholarships.gov.in/','https://scholarships.gov.in/','National Scholarship Portal','Government of India portal; each scheme has its own timeline.',null,null,'Scheme-wise dates; check official portal.',current_date,'published',true),
('nmmss-ay-2026-27','National Means-cum-Merit Scholarship (NMMSS) — AY 2026–27','India','Scholarship','School','School education · merit-cum-means','The Ministry of Education notice for AY 2026–27 listed 31 August 2026 as the student application cut-off. That date has passed as of 30 October 2026. Check NSP for any official extension or the next cycle; do not assume applications are open.','https://scholarships.gov.in/','https://scholarships.gov.in/','NSP · Ministry of Education schedule','AY 2026–27 schedule; verify any extension on NSP. Source notice: Government circular dated 3 June 2026.','2026–27','2026-08-31','Student application deadline: 31 August 2026 (passed as of 30 October 2026).',current_date,'published',false),
('pm-vidyalaxmi','PM-Vidyalaxmi — Education Loan & Interest Support','India','Loan support','UG','Higher education finance','This is not a scholarship. It is a unified education-loan portal where eligible students can apply to banks, track loan status and claim interest subvention when eligible. It is listed separately to avoid confusing loans with grants.','https://pmvidyalaxmi.co.in/','https://pmvidyalaxmi.co.in/','PM-Vidyalaxmi portal','Official student portal; scheme rules and bank process apply.',null,null,'Portal-based process; confirm current scheme rules.',current_date,'published',false)
on conflict (slug) do nothing;

create or replace function public.set_scholarship_opportunities_updated_at()
returns trigger language plpgsql set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_scholarship_opportunities_updated_at on public.scholarship_opportunities;
create trigger set_scholarship_opportunities_updated_at
before update on public.scholarship_opportunities
for each row execute function public.set_scholarship_opportunities_updated_at();

revoke all on function public.set_scholarship_opportunities_updated_at() from public;
