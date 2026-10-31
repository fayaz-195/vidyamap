-- VIDYAMAP Digital Learning Library Phase 1
create table if not exists public.learning_programs (
 id uuid primary key default gen_random_uuid(), program_key text not null unique,
 board text not null check(board in ('Telangana State Board','Andhra Pradesh State Board','Telangana Universities','Andhra Pradesh Universities')),
 education_level text not null check(education_level in ('school','intermediate','degree')),
 class_label text not null, stream text, course_code text, course_name text not null, syllabus_note text,
 display_order integer not null default 0, is_active boolean not null default true,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.learning_subjects (
 id uuid primary key default gen_random_uuid(), program_id uuid not null references public.learning_programs(id) on delete cascade,
 subject_code text, subject_name text not null, language text not null default 'English', description text,
 display_order integer not null default 0, is_active boolean not null default true,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(program_id,subject_name,language)
);
create table if not exists public.learning_chapters (
 id uuid primary key default gen_random_uuid(), subject_id uuid not null references public.learning_subjects(id) on delete cascade,
 chapter_number text, chapter_title text not null, summary text, learning_outcomes text,
 display_order integer not null default 0, is_active boolean not null default true,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(subject_id,chapter_title)
);
create table if not exists public.learning_resources (
 id uuid primary key default gen_random_uuid(), chapter_id uuid not null references public.learning_chapters(id) on delete cascade,
 resource_type text not null check(resource_type in ('notes','important_topics','previous_paper','model_paper','video','reference')),
 title text not null, content text, file_path text, external_url text, language text not null default 'English',
 academic_year text, source_name text, source_url text,
 verification_status text not null default 'draft' check(verification_status in ('draft','review','verified','rejected')),
 is_published boolean not null default false, display_order integer not null default 0,
 created_by uuid references auth.users(id) on delete set null, updated_by uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 constraint learning_resource_has_content check(coalesce(length(trim(content)),0)>0 or coalesce(length(trim(file_path)),0)>0 or coalesce(length(trim(external_url)),0)>0)
);
create table if not exists public.learning_questions (
 id uuid primary key default gen_random_uuid(), chapter_id uuid not null references public.learning_chapters(id) on delete cascade,
 question_text text not null, answer_text text, marks integer check(marks is null or marks between 1 and 100),
 difficulty text not null default 'medium' check(difficulty in ('easy','medium','hard')),
 question_type text not null default 'descriptive' check(question_type in ('mcq','short_answer','long_answer','descriptive','true_false')),
 options jsonb not null default '[]'::jsonb, correct_answer text, explanation text, source_year text, source_name text,
 verification_status text not null default 'draft' check(verification_status in ('draft','review','verified','rejected')),
 is_published boolean not null default false, display_order integer not null default 0,
 created_by uuid references auth.users(id) on delete set null, updated_by uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index if not exists learning_programs_browse_idx on public.learning_programs(board,education_level,display_order) where is_active;
create index if not exists learning_subjects_program_idx on public.learning_subjects(program_id,display_order) where is_active;
create index if not exists learning_chapters_subject_idx on public.learning_chapters(subject_id,display_order) where is_active;
create index if not exists learning_resources_chapter_idx on public.learning_resources(chapter_id,resource_type,display_order) where is_published and verification_status='verified';
create index if not exists learning_questions_chapter_idx on public.learning_questions(chapter_id,display_order) where is_published and verification_status='verified';
create or replace function public.learning_library_is_admin() returns boolean language sql stable set search_path=public as $$
 select exists(select 1 from public.profiles p where p.id=(select auth.uid()) and p.is_active=true and (p.is_founder=true or p.role::text='platform_admin'));
$$;
revoke all on function public.learning_library_is_admin() from public;
grant execute on function public.learning_library_is_admin() to authenticated;
create or replace function public.learning_library_touch_updated_at() returns trigger language plpgsql set search_path=public as $$ begin new.updated_at=now(); return new; end; $$;
do $$ declare t text; begin
 foreach t in array array['learning_programs','learning_subjects','learning_chapters','learning_resources','learning_questions'] loop
  execute format('alter table public.%I enable row level security',t);
  execute format('drop trigger if exists %I on public.%I',t||'_touch_updated_at',t);
  execute format('create trigger %I before update on public.%I for each row execute function public.learning_library_touch_updated_at()',t||'_touch_updated_at',t);
 end loop;
end $$;
drop policy if exists "Published learning programs are readable" on public.learning_programs;
create policy "Published learning programs are readable" on public.learning_programs for select to anon,authenticated using(is_active or public.learning_library_is_admin());
drop policy if exists "Learning admins manage programs" on public.learning_programs;
create policy "Learning admins manage programs" on public.learning_programs for all to authenticated using(public.learning_library_is_admin()) with check(public.learning_library_is_admin());
drop policy if exists "Active learning subjects are readable" on public.learning_subjects;
create policy "Active learning subjects are readable" on public.learning_subjects for select to anon,authenticated using((is_active and exists(select 1 from public.learning_programs p where p.id=program_id and p.is_active)) or public.learning_library_is_admin());
drop policy if exists "Learning admins manage subjects" on public.learning_subjects;
create policy "Learning admins manage subjects" on public.learning_subjects for all to authenticated using(public.learning_library_is_admin()) with check(public.learning_library_is_admin());
drop policy if exists "Active learning chapters are readable" on public.learning_chapters;
create policy "Active learning chapters are readable" on public.learning_chapters for select to anon,authenticated using((is_active and exists(select 1 from public.learning_subjects s join public.learning_programs p on p.id=s.program_id where s.id=subject_id and s.is_active and p.is_active)) or public.learning_library_is_admin());
drop policy if exists "Learning admins manage chapters" on public.learning_chapters;
create policy "Learning admins manage chapters" on public.learning_chapters for all to authenticated using(public.learning_library_is_admin()) with check(public.learning_library_is_admin());
drop policy if exists "Verified learning resources are readable" on public.learning_resources;
create policy "Verified learning resources are readable" on public.learning_resources for select to anon,authenticated using((is_published and verification_status='verified' and exists(select 1 from public.learning_chapters c join public.learning_subjects s on s.id=c.subject_id join public.learning_programs p on p.id=s.program_id where c.id=chapter_id and c.is_active and s.is_active and p.is_active)) or public.learning_library_is_admin());
drop policy if exists "Learning admins manage resources" on public.learning_resources;
create policy "Learning admins manage resources" on public.learning_resources for all to authenticated using(public.learning_library_is_admin()) with check(public.learning_library_is_admin());
drop policy if exists "Verified learning questions are readable" on public.learning_questions;
create policy "Verified learning questions are readable" on public.learning_questions for select to anon,authenticated using((is_published and verification_status='verified' and exists(select 1 from public.learning_chapters c join public.learning_subjects s on s.id=c.subject_id join public.learning_programs p on p.id=s.program_id where c.id=chapter_id and c.is_active and s.is_active and p.is_active)) or public.learning_library_is_admin());
drop policy if exists "Learning admins manage questions" on public.learning_questions;
create policy "Learning admins manage questions" on public.learning_questions for all to authenticated using(public.learning_library_is_admin()) with check(public.learning_library_is_admin());
grant select on public.learning_programs,public.learning_subjects,public.learning_chapters,public.learning_resources,public.learning_questions to anon,authenticated;
grant insert,update,delete on public.learning_programs,public.learning_subjects,public.learning_chapters,public.learning_resources,public.learning_questions to authenticated;
insert into public.learning_programs(program_key,board,education_level,class_label,course_name,display_order) select 'TS-SCERT-CLASS-'||n,'Telangana State Board','school','Class '||n,'Class '||n,n from generate_series(6,10) n on conflict(program_key) do nothing;
insert into public.learning_programs(program_key,board,education_level,class_label,course_name,display_order) select 'AP-SCERT-CLASS-'||n,'Andhra Pradesh State Board','school','Class '||n,'Class '||n,n from generate_series(6,10) n on conflict(program_key) do nothing;
insert into public.learning_programs(program_key,board,education_level,class_label,stream,course_code,course_name,display_order)
select b.prefix||'-INTER-'||y||'-'||st,b.board,'intermediate',case when y=1 then '1st Year' else '2nd Year' end,st,st,st||' · '||case when y=1 then '1st Year' else '2nd Year' end,y*10+row_number() over(partition by b.prefix,y order by st)
from (values('TS','Telangana State Board'),('AP','Andhra Pradesh State Board')) b(prefix,board) cross join generate_series(1,2) y cross join (values('MPC'),('BiPC'),('CEC'),('MEC'),('HEC')) streams(st) on conflict(program_key) do nothing;
insert into public.learning_programs(program_key,board,education_level,class_label,course_code,course_name,display_order)
select b.prefix||'-DEGREE-'||c.code,b.board,'degree','Degree',c.code,c.name,row_number() over(partition by b.prefix order by c.code)
from (values('TU','Telangana Universities'),('APU','Andhra Pradesh Universities')) b(prefix,board) cross join (values('BA','B.A.'),('BCOM','B.Com.'),('BSC','B.Sc.'),('BBA','BBA'),('BCA','BCA')) c(code,name) on conflict(program_key) do nothing;
