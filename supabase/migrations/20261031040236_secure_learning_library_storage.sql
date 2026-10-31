-- Keep learning uploads private until a verified, published resource points to the file.
update storage.buckets set public=false where id='learning-library-files';
drop policy if exists "Public can read published learning library files" on storage.objects;
drop policy if exists "Public can read verified published learning library files" on storage.objects;
create policy "Public can read verified published learning library files" on storage.objects
for select to anon,authenticated
using (
 bucket_id='learning-library-files'
 and exists (
  select 1 from public.learning_resources lr
  join public.learning_chapters c on c.id=lr.chapter_id
  join public.learning_subjects s on s.id=c.subject_id
  join public.learning_programs p on p.id=s.program_id
  where lr.file_path=storage.objects.name and lr.is_published=true
   and lr.verification_status='verified' and c.is_active=true
   and s.is_active=true and p.is_active=true
 )
);
drop policy if exists "Learning admins upload learning library files" on storage.objects;
create policy "Learning admins upload learning library files" on storage.objects
for insert to authenticated with check(bucket_id='learning-library-files' and public.learning_library_is_admin());
drop policy if exists "Learning admins update learning library files" on storage.objects;
create policy "Learning admins update learning library files" on storage.objects
for update to authenticated using(bucket_id='learning-library-files' and public.learning_library_is_admin())
with check(bucket_id='learning-library-files' and public.learning_library_is_admin());
drop policy if exists "Learning admins delete learning library files" on storage.objects;
create policy "Learning admins delete learning library files" on storage.objects
for delete to authenticated using(bucket_id='learning-library-files' and public.learning_library_is_admin());
