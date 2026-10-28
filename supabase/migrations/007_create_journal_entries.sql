create table if not exists public.journal_entries (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.categories(id) on delete set null,
  title text not null,
  content text not null,
  journal_date date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists journal_user_date_idx
on public.journal_entries (user_id, journal_date desc);

create trigger journal_updated_at
before update on public.journal_entries
for each row
execute procedure public.handle_updated_at();

alter table public.journal_entries enable row level security;

create policy "journal_select_own"
on public.journal_entries for select
using (auth.uid() = user_id);

create policy "journal_insert_own"
on public.journal_entries for insert
with check (auth.uid() = user_id);

create policy "journal_update_own"
on public.journal_entries for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "journal_delete_own"
on public.journal_entries for delete
using (auth.uid() = user_id);
