create table if not exists public.notes (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.categories(id) on delete set null,
  title text not null,
  content text not null,
  pinned boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists notes_user_updated_idx
on public.notes (user_id, updated_at desc);

create trigger notes_updated_at
before update on public.notes
for each row
execute procedure public.handle_updated_at();

alter table public.notes enable row level security;

create policy "notes_select_own"
on public.notes for select
using (auth.uid() = user_id);

create policy "notes_insert_own"
on public.notes for insert
with check (auth.uid() = user_id);

create policy "notes_update_own"
on public.notes for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "notes_delete_own"
on public.notes for delete
using (auth.uid() = user_id);
