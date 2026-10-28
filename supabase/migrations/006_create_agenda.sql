create table if not exists public.agenda_events (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid references public.categories(id) on delete set null,
  mission_id uuid references public.weekly_missions(id) on delete set null,
  habit_id uuid references public.habits(id) on delete set null,
  title text not null,
  description text,
  event_date date not null,
  event_time text,
  status text not null default 'Planned',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists agenda_user_date_idx
on public.agenda_events (user_id, event_date, status);

create trigger agenda_updated_at
before update on public.agenda_events
for each row
execute procedure public.handle_updated_at();

alter table public.agenda_events enable row level security;

create policy "agenda_select_own"
on public.agenda_events for select
using (auth.uid() = user_id);

create policy "agenda_insert_own"
on public.agenda_events for insert
with check (auth.uid() = user_id);

create policy "agenda_update_own"
on public.agenda_events for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "agenda_delete_own"
on public.agenda_events for delete
using (auth.uid() = user_id);
