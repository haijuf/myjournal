create type public.habit_type as enum ('ongoing', 'mission-specific');
create type public.tracking_type as enum ('Completion', 'Duration', 'Quantity');
create type public.frequency_period as enum ('Daily', 'Weekly');

create table if not exists public.habits (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.categories(id) on delete set null,
  title text not null,
  description text,
  habit_type public.habit_type not null default 'ongoing',
  tracking_type public.tracking_type not null default 'Completion',
  target_value numeric,
  target_unit text,
  target_frequency integer not null default 1,
  frequency_period public.frequency_period not null default 'Weekly',
  selected_weekdays integer[],
  start_date date not null,
  end_date date,
  status text not null default 'Active',
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint habits_target_positive check (target_frequency > 0)
);

create index if not exists habits_user_active_idx
on public.habits (user_id, status, habit_type, start_date);

create trigger habits_updated_at
before update on public.habits
for each row
execute procedure public.handle_updated_at();

alter table public.habits enable row level security;

create policy "habits_select_own"
on public.habits for select
using (auth.uid() = user_id);

create policy "habits_insert_own"
on public.habits for insert
with check (auth.uid() = user_id);

create policy "habits_update_own"
on public.habits for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "habits_delete_own"
on public.habits for delete
using (auth.uid() = user_id);
