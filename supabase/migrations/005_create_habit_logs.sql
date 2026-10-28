create table if not exists public.habit_logs (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  habit_id uuid not null references public.habits(id) on delete cascade,
  occurrence_date date not null,
  status text not null default 'Completed',
  actual_duration numeric,
  actual_quantity numeric,
  actual_unit text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint habit_logs_unique_day unique (habit_id, occurrence_date)
);

create index if not exists habit_logs_user_date_idx
on public.habit_logs (user_id, occurrence_date);

create trigger habit_logs_updated_at
before update on public.habit_logs
for each row
execute procedure public.handle_updated_at();

alter table public.habit_logs enable row level security;

create policy "habit_logs_select_own"
on public.habit_logs for select
using (auth.uid() = user_id);

create policy "habit_logs_insert_own"
on public.habit_logs for insert
with check (
  auth.uid() = user_id and exists (
    select 1 from public.habits h where h.id = habit_id and h.user_id = auth.uid()
  )
);

create policy "habit_logs_update_own"
on public.habit_logs for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "habit_logs_delete_own"
on public.habit_logs for delete
using (auth.uid() = user_id);
