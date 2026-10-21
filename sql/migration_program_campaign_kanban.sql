-- Gascomp Monitoring Hub: Program, Campaign, Kanban and leaderboard migration
-- Run only after the base sql/schema.sql. Back up before production changes.
create extension if not exists pgcrypto;

create table if not exists public.campaigns (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  brand text not null default 'Gascomp',
  platform text not null default '',
  campaign_type text not null default 'Marketing',
  start_date date,
  end_date date,
  status text not null default 'Draft' check (status in ('Draft','Planned','Active','Paused','Completed','Cancelled')),
  budget numeric not null default 0 check (budget >= 0),
  target_gmv numeric not null default 0 check (target_gmv >= 0),
  target_orders integer not null default 0 check (target_orders >= 0),
  banner_urls text[] not null default '{}',
  notes text not null default '',
  created_by text not null default 'system',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.programs add column if not exists campaign_id uuid references public.campaigns(id) on delete set null;
alter table public.programs add column if not exists description text not null default '';
alter table public.programs add column if not exists objective text not null default '';
alter table public.programs add column if not exists start_date date;
alter table public.programs add column if not exists end_date date;
alter table public.programs add column if not exists image_urls text[] not null default '{}';
alter table public.programs add column if not exists timeline_rules jsonb not null default '[]'::jsonb;
alter table public.programs add column if not exists initiative_type text not null default 'Inisiatif Divisi';
alter table public.programs add column if not exists created_at timestamptz not null default now();
alter table public.programs add column if not exists updated_at timestamptz not null default now();

alter table public.tasks add column if not exists parent_task_id uuid references public.tasks(id) on delete set null;
alter table public.tasks add column if not exists board_column text not null default 'Backlog';
alter table public.tasks add column if not exists sort_order integer not null default 0;
alter table public.tasks add column if not exists acceptance_criteria text not null default '';
alter table public.tasks add column if not exists task_type text not null default 'Execution';
alter table public.tasks add column if not exists estimated_hours numeric check (estimated_hours is null or estimated_hours >= 0);
alter table public.tasks add column if not exists actual_hours numeric check (actual_hours is null or actual_hours >= 0);
alter table public.tasks add column if not exists initiative_source text not null default 'Manual';
alter table public.tasks add column if not exists image_urls text[] not null default '{}';

create table if not exists public.program_milestones (
  id uuid primary key default gen_random_uuid(),
  program_id uuid not null references public.programs(id) on delete cascade,
  title text not null,
  description text not null default '',
  sequence integer not null default 0,
  start_date date,
  due_date date,
  required boolean not null default true,
  owner_department text not null default '',
  completion_criteria text not null default '',
  status text not null default 'Not Started' check (status in ('Not Started','In Progress','Blocked','Done','Skipped')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(program_id, sequence)
);

create table if not exists public.program_reviews (
  id uuid primary key default gen_random_uuid(),
  program_id uuid not null references public.programs(id) on delete cascade,
  review_type text not null default 'AI_RULE_CHECK',
  result text not null default 'Needs Review' check (result in ('Pass','Needs Review','Fail')),
  findings jsonb not null default '[]'::jsonb,
  recommendations jsonb not null default '[]'::jsonb,
  reviewed_by text not null default 'system',
  created_at timestamptz not null default now()
);

create index if not exists idx_programs_campaign on public.programs(campaign_id);
create index if not exists idx_tasks_program_due on public.tasks(program_id,due_date);
create index if not exists idx_tasks_board on public.tasks(program_id,board_column,sort_order);
create index if not exists idx_tasks_owner_status on public.tasks(owner_name,status);
create index if not exists idx_campaigns_status_dates on public.campaigns(status,start_date,end_date);
create index if not exists idx_milestones_program_sequence on public.program_milestones(program_id,sequence);

alter table public.campaigns enable row level security;
alter table public.program_milestones enable row level security;
alter table public.program_reviews enable row level security;
revoke all on public.campaigns, public.program_milestones, public.program_reviews from anon, authenticated;
grant usage on schema public to anon, authenticated;

-- Existing API uses server-only Supabase service role; never expose its key in browser code.
