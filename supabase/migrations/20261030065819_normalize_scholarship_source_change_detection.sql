create or replace function private.refresh_scholarship_source_monitor()
returns jsonb language plpgsql
set search_path = pg_catalog, public, private, extensions
as $$
declare src record; resp record; normalized_body text; body_hash text; checked integer:=0; changed integer:=0; failed integer:=0;
begin
  for src in select official_url,max(source_label) as source_label from public.scholarship_opportunities where status='published' group by official_url loop
    begin
      select * into resp from extensions.http_get(src.official_url); checked:=checked+1;
      if resp.status between 200 and 299 then
        normalized_body:=coalesce(resp.content,'');
        normalized_body:=regexp_replace(normalized_body,'<script[^>]*>[\\s\\S]*?</script>','','gi');
        normalized_body:=regexp_replace(normalized_body,'<style[^>]*>[\\s\\S]*?</style>','','gi');
        normalized_body:=regexp_replace(normalized_body,'<!--[\\s\\S]*?-->','','g');
        normalized_body:=regexp_replace(normalized_body,'[[:space:]]+',' ','g');
        body_hash:=encode(digest(convert_to(normalized_body,'UTF8'),'sha256'),'hex');
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
update private.scholarship_source_monitor set change_detected=false,change_detected_at=null;