# Gascomp Monitoring Hub — Feature Implementation Specification
Updated: 21 October 2026

## Product hierarchy
Campaign is the top-level commercial initiative. A campaign can contain multiple programs. A program may optionally belong to a campaign; a standalone initiative has campaign_id = NULL and must remain visible in Program & Timeline without appearing in Campaign Tracker. Tasks must always belong to exactly one program. Program task lists, Kanban, and Timeline are filtered by the selected program_id; do not show a global unfiltered board by default.

## Program creation
Allow either (a) manual program creation or (b) uploading a program file. Supported initial upload types should be PDF, DOCX, XLSX, and MD/TXT. Extract text/tables, then produce a proposed plan, not an automatically approved plan. User must review the extracted objective, deliverables, dates, departments, PICs, dependencies, acceptance criteria, risks, KPI/target references, and source citations/page or sheet references. If information is missing, mark [NEEDS CONFIRMATION]; never invent targets, budget, stock, deadlines, or owners. Keep original source file and images attached to the program.

## Task breakdown and rule checks
Generate task proposals from approved program requirements. Every task has program_id, title, department, PIC, start/due dates, dependency, deliverable, acceptance criteria, estimated workload, priority, and source/rule reference. Validate:
- task dates fall within the program dates unless explicitly approved;
- dependencies exist and do not form a cycle;
- required deliverables and milestones are covered;
- PIC/department is populated;
- tasks are ordered and feasible relative to dependencies and estimated workload;
- KPI, budget, stock and targets remain unapproved until a designated approver confirms them;
- status/progress cannot be marked complete without evidence or acceptance criteria being met.
AI output is a proposal. A human owner approves the generated plan and any exceptions.

## Shared Kanban and Timeline
Kanban columns: Backlog, Ready, In Progress, Blocked, Review/Approval, Done. Timeline is generated from the same task records and milestone records, not manually duplicated. Changing task dates/status updates both views. Filters always include selected program and department; display the program title and campaign association above the board to prevent mixing work from different programs. Drag/drop and task updates write the same task ID and log changes.

## Program visuals
Each program supports one cover image and multiple supporting images/assets. Show thumbnail and image gallery in Program cards and program detail. Validate file size/type and store files in Supabase Storage (private bucket with signed URLs recommended) rather than large inline database values. Record asset metadata and source.

## Dashboard and leaderboard
Dashboard shows unfinished tasks, overdue/blockers, next deadlines, program readiness, and closing forecast. Leaderboards should not equate raw task count with performance. Display separate dimensions:
- completion rate (completed / due tasks);
- on-time completion rate;
- accepted deliverables;
- progress weighted by task complexity/estimated hours;
- blocked/overdue workload;
- initiative count (program proposals started and approved);
- capacity estimate (assigned estimated hours vs declared available hours).
Rank only where denominator and data coverage are sufficient; show sample size and last update. Do not label people low-performing based on missing data. Provide division and PIC views, plus a load/capacity indicator. Manager can set weights and minimum sample size.

## Campaign Tracker
Campaign is optional on each program. A program with a campaign_id appears under that campaign; a standalone program does not. Campaign page includes campaign name, brand/project, type, platform, period, status, budget and approved targets, banner/assets carousel, linked programs, creator/deliverable rows if applicable, GMV/orders/commission only when valid data sources exist. Do not show fabricated performance values; missing metrics should be “Belum tersedia”. Campaign dates and program dates should be checked for conflicts.

## AI Copilot activation
Use a server-side API route and a provider API key stored only in Vercel environment variables (e.g. OPENAI_API_KEY); never put a key in NEXT_PUBLIC variables or browser code. AI Copilot should support:
1. extract/structure uploaded program documents;
2. draft task breakdown and timeline;
3. check rules, missing information, dependencies, and schedule conflicts;
4. summarize task status, risks and closing readiness from database facts;
5. explain suggestions with links to source passages and database records.
Require user approval before creating/updating program or task records. Add rate limits, input size limits, file type checks, audit logs, and a clear label that AI suggestions require human review. AI cannot independently approve budget/targets, change stock, or mark work complete. AI is not active until the server route is implemented and provider key is configured in Vercel.

## Security and rollout gates
Current public form + shared admin key is not adequate for sensitive company-wide use. Before broad rollout, add identity and role permissions for admin approvals, file access controls, audit trail, anti-spam, backup/retention policy, and secret rotation. Use a staged rollout: migration in staging, validate schema, deploy app, test with dummy data, then production.
