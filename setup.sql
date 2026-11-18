-- Luke & Taylor HQ: run once in Supabase > SQL Editor

-- 1. one table holds everything (scores, dates, places, questions...)
create table if not exists public.kv (
  key text primary key,
  value jsonb,
  client text,
  updated_at timestamptz default now()
);
alter table public.kv enable row level security;

drop policy if exists "only luke and taylor" on public.kv;
create policy "only luke and taylor" on public.kv for all to authenticated
  using ((auth.jwt()->>'email') in ('luke@lukeandtaylor.net','taylor@lukeandtaylor.net'))
  with check ((auth.jwt()->>'email') in ('luke@lukeandtaylor.net','taylor@lukeandtaylor.net'));

-- live updates between the two phones
alter publication supabase_realtime add table public.kv;

-- 2. private photo storage (Secretgram)
insert into storage.buckets (id, name, public) values ('photos','photos',false)
  on conflict (id) do nothing;

drop policy if exists "only luke and taylor photos" on storage.objects;
create policy "only luke and taylor photos" on storage.objects for all to authenticated
  using (bucket_id = 'photos' and (auth.jwt()->>'email') in ('luke@lukeandtaylor.net','taylor@lukeandtaylor.net'))
  with check (bucket_id = 'photos' and (auth.jwt()->>'email') in ('luke@lukeandtaylor.net','taylor@lukeandtaylor.net'));
