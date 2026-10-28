create type public.mission_status as enum ('Draft', 'Active', 'Completed', 'Archived');

create table if not exists public.weekly_missions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.categories(id) on delete set null,
  title text not null,
  description text,
  start_date date not null,
  end_date date not null,
  status public.mission_status not null default 'Draft',
  completed_at timestamptz,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint missions_valid_range check (end_date >= start_date)
);

create index if not exists missions_user_date_idx
on public.weekly_missions (user_id, start_date, end_date);

create trigger missions_updated_at
before update on public.weekly_missions
for each row
execute procedure public.handle_updated_at();

alter table public.weekly_missions enable row level security;

create policy "missions_select_own"
on public.weekly_missions for select
using (auth.uid() = user_id);

create policy "missions_insert_own"
on public.weekly_missions for insert
with check (auth.uid() = user_id);

create policy "missions_update_own"
on public.weekly_missions for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "missions_delete_own"
on public.weekly_missions for delete
using (auth.uid() = user_id);
