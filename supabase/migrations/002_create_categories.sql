create table if not exists public.categories (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  color text not null default '#d9ad6a',
  icon text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint categories_name_not_blank check (length(trim(name)) > 0)
);

create unique index if not exists categories_user_name_unique
on public.categories (user_id, lower(name));

create trigger categories_updated_at
before update on public.categories
for each row
execute procedure public.handle_updated_at();

alter table public.categories enable row level security;

create policy "categories_select_own"
on public.categories for select
using (auth.uid() = user_id);

create policy "categories_insert_own"
on public.categories for insert
with check (auth.uid() = user_id);

create policy "categories_update_own"
on public.categories for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "categories_delete_own"
on public.categories for delete
using (auth.uid() = user_id);
