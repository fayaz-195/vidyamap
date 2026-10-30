create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists http with schema extensions;
create table if not exists private.scholarship_source_monitor (
  official_url text primary key,
  source_label text not null,
  last_checked_at timestamptz,
  last_http_status integer,
  content_sha256 text,
  change_detected boolean not null default false,
  change_detected_at timestamptz,
  last_error text,
  updated_at timestamptz not null default now()
);
revoke all on table private.scholarship_source_monitor from public, anon, authenticated;
create or replace function private.refresh_scholarship_source_monitor()
returns jsonb language plpgsql
set search_path = pg_catalog, public, private, extensions
as $$
declare src record; resp record; body_hash text; checked integer := 0; changed integer := 0; failed integer := 0;
begin
  for src in select official_url,max(source_label) as source_label from public.scholarship_opportunities where status='published' group by official_url loop
    begin
      select * into resp from extensions.http_get(src.official_url);
      checked := checked + 1;
      if resp.status between 200 and 299 then
        body_hash := encode(digest(convert_to(coalesce(resp.content,''),'UTF8'),'sha256'),'hex');
        insert into private.scholarship_source_monitor(official_url,source_label,last_checked_at,last_http_status,content_sha256,last_error,updated_at)
        values(src.official_url,src.source_label,now(),resp.status,body_hash,null,now())
        on conflict(official_url) do update set source_label=excluded.source_label,last_checked_at=excluded.last_checked_at,last_http_status=excluded.last_http_status,
          change_detected=private.scholarship_source_monitor.change_detected or (private.scholarship_source_monitor.content_sha256 is not null and private.scholarship_source_monitor.content_sha256<>excluded.content_sha256),
          change_detected_at=case when private.scholarship_source_monitor.content_sha256 is not null and private.scholarship_source_monitor.content_sha256<>excluded.content_sha256 then now() else private.scholarship_source_monitor.change_detected_at end,
          content_sha256=excluded.content_sha256,last_error=null,updated_at=now();
        update public.scholarship_opportunities set source_checked_at=current_date where official_url=src.official_url and status='published';
        if exists(select 1 from private.scholarship_source_monitor where official_url=src.official_url and change_detected) then changed:=changed+1; end if;
      else
        failed:=failed+1;
        insert into private.scholarship_source_monitor(official_url,source_label,last_checked_at,last_http_status,last_error,updated_at)
        values(src.official_url,src.source_label,now(),resp.status,'Official source returned a non-success HTTP status.',now())
        on conflict(official_url) do update set source_label=excluded.source_label,last_checked_at=excluded.last_checked_at,last_http_status=excluded.last_http_status,last_error=excluded.last_error,updated_at=now();
      end if;
    exception when others then
      failed:=failed+1;
      insert into private.scholarship_source_monitor(official_url,source_label,last_checked_at,last_error,updated_at)
      values(src.official_url,src.source_label,now(),left(sqlerrm,500),now())
      on conflict(official_url) do update set source_label=excluded.source_label,last_checked_at=excluded.last_checked_at,last_error=excluded.last_error,updated_at=now();
    end;
  end loop;
  return jsonb_build_object('checked',checked,'changed_sources',changed,'failed',failed,'checked_at',now());
end; $$;
revoke all on function private.refresh_scholarship_source_monitor() from public,anon,authenticated;
grant execute on function private.refresh_scholarship_source_monitor() to postgres;
select cron.unschedule(jobid) from cron.job where jobname='vidyamap-scholarship-source-check';
select cron.schedule('vidyamap-scholarship-source-check','30 21 * * *',$$select private.refresh_scholarship_source_monitor();$$);