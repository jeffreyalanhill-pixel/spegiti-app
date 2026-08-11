-- Spegiti shop schema — generated from the master project by dump-schema.mjs
-- source: bncsiyumhikicrixuzqg · generated: 2026-08-11T03:38:37.282Z

-- extensions
create extension if not exists pgcrypto;
create extension if not exists "pg_cron";

-- tables
create table if not exists "activity_log" (
  "id" uuid default gen_random_uuid() not null,
  "message" text not null,
  "icon" text,
  "entity_type" text,
  "entity_id" uuid,
  "created_at" timestamp with time zone default now() not null
);
create table if not exists "app_config" (
  "key" text not null,
  "value" jsonb,
  "updated_at" timestamp with time zone default now()
);
create table if not exists "appointments" (
  "id" uuid default gen_random_uuid() not null,
  "customer_id" uuid,
  "project_id" uuid,
  "type" text default 'consult'::text not null,
  "title" text,
  "appt_date" date not null,
  "appt_time" text,
  "duration" text,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null,
  "assigned_to" uuid
);
create table if not exists "approval_requests" (
  "id" uuid default gen_random_uuid() not null,
  "token" text not null,
  "project_id" uuid not null,
  "customer_id" uuid not null,
  "drawing_ids" uuid[] default '{}'::uuid[] not null,
  "status" text default 'sent'::text not null,
  "customer_comment" text,
  "sent_by" uuid,
  "sent_at" timestamp with time zone default now() not null,
  "responded_at" timestamp with time zone,
  "expires_at" timestamp with time zone,
  "markups" jsonb default '[]'::jsonb,
  "order_id" uuid
);
create table if not exists "attachments" (
  "id" uuid default gen_random_uuid() not null,
  "entity_type" text not null,
  "entity_id" text not null,
  "name" text,
  "drive_file_id" text,
  "drive_link" text,
  "created_by" uuid,
  "created_at" timestamp with time zone default now()
);
create table if not exists "automation_log" (
  "id" uuid default gen_random_uuid() not null,
  "kind" text not null,
  "entity_id" uuid not null,
  "sent_to" text,
  "detail" text,
  "created_at" timestamp with time zone default now()
);
create table if not exists "board_bookings" (
  "id" uuid default gen_random_uuid() not null,
  "station_id" uuid not null,
  "project_id" uuid,
  "start_date" date not null,
  "end_date" date not null,
  "note" text,
  "created_at" timestamp with time zone default now()
);
create table if not exists "customers" (
  "id" uuid default gen_random_uuid() not null,
  "code" text,
  "name" text not null,
  "contact" text,
  "phone" text,
  "email" text,
  "address" text,
  "source" text,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null,
  "auth_user_id" uuid,
  "designer_id" uuid,
  "note_text" text,
  "customer_type" text default 'residential'::text
);
create table if not exists "drawing_revisions" (
  "id" uuid default gen_random_uuid() not null,
  "drawing_id" uuid not null,
  "rev" text not null,
  "note" text,
  "author" uuid,
  "file_path" text,
  "file_name" text,
  "file_size" bigint,
  "drive_file_id" text,
  "drive_link" text,
  "approval_outcome" text default 'pending'::text not null,
  "created_at" timestamp with time zone default now() not null
);
create table if not exists "drawings" (
  "id" uuid default gen_random_uuid() not null,
  "code" text,
  "name" text not null,
  "type" text,
  "project_id" uuid,
  "current_rev" text default 'R0'::text not null,
  "approval_status" text default 'pending'::text not null,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null,
  "file_path" text,
  "file_name" text,
  "file_type" text,
  "drive_file_id" text,
  "drive_link" text
);
create table if not exists "employees" (
  "id" uuid default gen_random_uuid() not null,
  "name" text not null,
  "role" text,
  "phone" text,
  "email" text,
  "skills" text[] default '{}'::text[] not null,
  "status" text default 'active'::text not null,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null,
  "auth_user_id" uuid,
  "perm_role" text default 'viewer'::text not null,
  "work_days" integer[] default '{1,2,3,4,5}'::integer[],
  "pay_rate" numeric
);
create table if not exists "google_tokens" (
  "user_id" uuid not null,
  "refresh_token" text,
  "access_token" text,
  "token_expiry" timestamp with time zone,
  "calendar_id" text default 'primary'::text,
  "sync_token" text,
  "updated_at" timestamp with time zone default now()
);
create table if not exists "install_assignments" (
  "install_id" uuid not null,
  "employee_id" uuid not null,
  "role" text default 'installer'::text
);
create table if not exists "installs" (
  "id" uuid default gen_random_uuid() not null,
  "project_id" uuid not null,
  "crew" text,
  "start_date" date not null,
  "end_date" date not null,
  "type" text,
  "ready" boolean default false not null,
  "site_access" boolean default false not null,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null
);
create table if not exists "invoices" (
  "id" uuid default gen_random_uuid() not null,
  "project_id" uuid not null,
  "amount" numeric(12,2) not null,
  "kind" text default 'progress'::text not null,
  "status" text default 'sent'::text not null,
  "issued_on" date default CURRENT_DATE not null,
  "due_on" date,
  "sent_at" timestamp with time zone,
  "paid_at" timestamp with time zone,
  "note" text,
  "created_by" uuid,
  "created_at" timestamp with time zone default now(),
  "qb_id" text
);
create table if not exists "leads" (
  "id" uuid default gen_random_uuid() not null,
  "name" text not null,
  "contact" text,
  "source" text,
  "type" text,
  "status" text default 'new'::text not null,
  "value" numeric(12,2),
  "assigned" uuid,
  "phone" text,
  "email" text,
  "last_contact" date,
  "next_follow_up" date,
  "notes" text,
  "customer_id" uuid,
  "converted_project_id" uuid,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null
);
create table if not exists "messages" (
  "id" uuid default gen_random_uuid() not null,
  "project_id" uuid,
  "sender_type" text not null,
  "sender_employee_id" uuid,
  "sender_customer_id" uuid,
  "sender_name" text,
  "body" text not null,
  "read_by_staff" boolean default false not null,
  "read_by_customer" boolean default false not null,
  "created_at" timestamp with time zone default now() not null,
  "customer_id" uuid
);
create table if not exists "notes" (
  "id" uuid default gen_random_uuid() not null,
  "entity_type" text not null,
  "entity_id" uuid not null,
  "author" uuid,
  "body" text not null,
  "created_at" timestamp with time zone default now() not null
);
create table if not exists "order_items" (
  "id" uuid default gen_random_uuid() not null,
  "order_id" uuid not null,
  "description" text not null,
  "room" text,
  "qty" numeric default 1 not null,
  "unit_price" numeric default 0 not null,
  "sort_order" integer default 0
);
create table if not exists "orders" (
  "id" uuid default gen_random_uuid() not null,
  "project_id" uuid not null,
  "code" text,
  "version" integer default 1 not null,
  "status" text default 'draft'::text not null,
  "note" text,
  "created_by" uuid,
  "created_at" timestamp with time zone default now(),
  "updated_at" timestamp with time zone default now()
);
create table if not exists "payments" (
  "id" uuid default gen_random_uuid() not null,
  "project_id" uuid not null,
  "amount" numeric(12,2) not null,
  "kind" text default 'deposit'::text not null,
  "method" text default 'check'::text,
  "paid_on" date default CURRENT_DATE not null,
  "note" text,
  "created_by" uuid,
  "created_at" timestamp with time zone default now(),
  "qb_id" text
);
create table if not exists "po_items" (
  "id" uuid default gen_random_uuid() not null,
  "po_id" uuid not null,
  "description" text not null,
  "quantity" numeric(12,2),
  "received" boolean default false not null,
  "sort_order" integer default 0 not null,
  "created_at" timestamp with time zone default now() not null
);
create table if not exists "projects" (
  "id" uuid default gen_random_uuid() not null,
  "code" text not null,
  "customer_id" uuid not null,
  "contact" text,
  "type" text,
  "stage" text default 'Lead'::text not null,
  "assigned_pm" uuid,
  "installer" uuid,
  "value" numeric(12,2),
  "due_date" date,
  "install_date" date,
  "priority" text default 'normal'::text not null,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null,
  "designer_id" uuid,
  "stage_since" timestamp with time zone default now(),
  "note" text
);
create table if not exists "proposals" (
  "id" uuid default gen_random_uuid() not null,
  "customer_id" uuid not null,
  "project_id" uuid,
  "item" text,
  "value" numeric(12,2),
  "contact" text,
  "sent_date" date,
  "status" text default 'pending'::text not null,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null,
  "note" text
);
create table if not exists "punch_items" (
  "id" uuid default gen_random_uuid() not null,
  "project_id" uuid not null,
  "text" text not null,
  "done" boolean default false not null,
  "who" uuid,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null
);
create table if not exists "purchase_orders" (
  "id" uuid default gen_random_uuid() not null,
  "code" text not null,
  "vendor" text not null,
  "project_id" uuid,
  "value" numeric(12,2),
  "status" text default 'pending'::text not null,
  "eta" date,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null,
  "notes" text
);
create table if not exists "qb_tokens" (
  "id" integer default 1 not null,
  "realm_id" text,
  "refresh_token" text,
  "access_token" text,
  "token_expiry" timestamp with time zone,
  "connected_by" uuid,
  "updated_at" timestamp with time zone default now()
);
create table if not exists "stations" (
  "id" uuid default gen_random_uuid() not null,
  "name" text not null,
  "status" text default 'idle'::text not null,
  "operator" uuid,
  "task" text,
  "project_id" uuid,
  "pct" integer default 0 not null,
  "icon" text,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null
);
create table if not exists "time_entries" (
  "id" uuid default gen_random_uuid() not null,
  "employee_id" uuid not null,
  "project_id" uuid,
  "clock_in" timestamp with time zone,
  "clock_out" timestamp with time zone,
  "hours" numeric(6,2),
  "entry_date" date default CURRENT_DATE not null,
  "active" boolean default false not null,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null
);
create table if not exists "time_off" (
  "id" uuid default gen_random_uuid() not null,
  "employee_id" uuid not null,
  "start_date" date not null,
  "end_date" date not null,
  "type" text default 'pto'::text not null,
  "note" text,
  "status" text default 'approved'::text not null,
  "created_at" timestamp with time zone default now()
);
create table if not exists "work_orders" (
  "id" uuid default gen_random_uuid() not null,
  "code" text not null,
  "project_id" uuid,
  "customer_id" uuid,
  "task" text not null,
  "assigned" uuid,
  "priority" text default 'medium'::text not null,
  "due_date" date,
  "status" text default 'open'::text not null,
  "notes" text,
  "created_at" timestamp with time zone default now() not null,
  "updated_at" timestamp with time zone default now() not null
);

-- constraints
alter table activity_log add constraint "activity_log_pkey" PRIMARY KEY (id);
alter table app_config add constraint "app_config_pkey" PRIMARY KEY (key);
alter table appointments add constraint "appointments_pkey" PRIMARY KEY (id);
alter table approval_requests add constraint "approval_requests_pkey" PRIMARY KEY (id);
alter table attachments add constraint "attachments_pkey" PRIMARY KEY (id);
alter table automation_log add constraint "automation_log_pkey" PRIMARY KEY (id);
alter table board_bookings add constraint "board_bookings_pkey" PRIMARY KEY (id);
alter table customers add constraint "customers_pkey" PRIMARY KEY (id);
alter table drawing_revisions add constraint "drawing_revisions_pkey" PRIMARY KEY (id);
alter table drawings add constraint "drawings_pkey" PRIMARY KEY (id);
alter table employees add constraint "employees_pkey" PRIMARY KEY (id);
alter table google_tokens add constraint "google_tokens_pkey" PRIMARY KEY (user_id);
alter table install_assignments add constraint "install_assignments_pkey" PRIMARY KEY (install_id, employee_id);
alter table installs add constraint "installs_pkey" PRIMARY KEY (id);
alter table invoices add constraint "invoices_pkey" PRIMARY KEY (id);
alter table leads add constraint "leads_pkey" PRIMARY KEY (id);
alter table messages add constraint "messages_pkey" PRIMARY KEY (id);
alter table notes add constraint "notes_pkey" PRIMARY KEY (id);
alter table order_items add constraint "order_items_pkey" PRIMARY KEY (id);
alter table orders add constraint "orders_pkey" PRIMARY KEY (id);
alter table payments add constraint "payments_pkey" PRIMARY KEY (id);
alter table po_items add constraint "po_items_pkey" PRIMARY KEY (id);
alter table projects add constraint "projects_pkey" PRIMARY KEY (id);
alter table proposals add constraint "proposals_pkey" PRIMARY KEY (id);
alter table punch_items add constraint "punch_items_pkey" PRIMARY KEY (id);
alter table purchase_orders add constraint "purchase_orders_pkey" PRIMARY KEY (id);
alter table qb_tokens add constraint "qb_tokens_pkey" PRIMARY KEY (id);
alter table stations add constraint "stations_pkey" PRIMARY KEY (id);
alter table time_entries add constraint "time_entries_pkey" PRIMARY KEY (id);
alter table time_off add constraint "time_off_pkey" PRIMARY KEY (id);
alter table work_orders add constraint "work_orders_pkey" PRIMARY KEY (id);
alter table approval_requests add constraint "approval_requests_token_key" UNIQUE (token);
alter table customers add constraint "customers_code_key" UNIQUE (code);
alter table drawings add constraint "drawings_code_key" UNIQUE (code);
alter table projects add constraint "projects_code_key" UNIQUE (code);
alter table purchase_orders add constraint "purchase_orders_code_key" UNIQUE (code);
alter table work_orders add constraint "work_orders_code_key" UNIQUE (code);
alter table appointments add constraint "appointments_type_check" CHECK ((type = ANY (ARRAY['consult'::text, 'site_measure'::text, 'qc'::text, 'deadline'::text])));
alter table approval_requests add constraint "approval_requests_status_check" CHECK ((status = ANY (ARRAY['sent'::text, 'approved'::text, 'changes_requested'::text, 'rejected'::text])));
alter table customers add constraint "customers_customer_type_check" CHECK ((customer_type = ANY (ARRAY['residential'::text, 'commercial'::text])));
alter table drawing_revisions add constraint "drawing_revisions_approval_outcome_check" CHECK ((approval_outcome = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'superseded'::text])));
alter table drawings add constraint "drawings_approval_status_check" CHECK ((approval_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])));
alter table employees add constraint "employees_perm_role_check" CHECK ((perm_role = ANY (ARRAY['owner'::text, 'manager'::text, 'installer'::text, 'viewer'::text, 'designer'::text])));
alter table employees add constraint "employees_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'inactive'::text])));
alter table invoices add constraint "invoices_amount_check" CHECK ((amount > (0)::numeric));
alter table invoices add constraint "invoices_kind_check" CHECK ((kind = ANY (ARRAY['deposit'::text, 'progress'::text, 'final'::text, 'other'::text])));
alter table invoices add constraint "invoices_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'sent'::text, 'paid'::text, 'void'::text])));
alter table leads add constraint "leads_status_check" CHECK ((status = ANY (ARRAY['new'::text, 'needs_response'::text, 'contacted'::text, 'qualified'::text, 'lost'::text])));
alter table messages add constraint "messages_sender_type_check" CHECK ((sender_type = ANY (ARRAY['staff'::text, 'customer'::text])));
alter table notes add constraint "notes_entity_type_check" CHECK ((entity_type = ANY (ARRAY['customer'::text, 'project'::text, 'work_order'::text, 'purchase_order'::text, 'drawing'::text, 'lead'::text])));
alter table orders add constraint "orders_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'sent'::text, 'approved'::text, 'superseded'::text, 'declined'::text])));
alter table payments add constraint "payments_amount_check" CHECK ((amount > (0)::numeric));
alter table payments add constraint "payments_kind_check" CHECK ((kind = ANY (ARRAY['deposit'::text, 'progress'::text, 'final'::text, 'other'::text])));
alter table projects add constraint "projects_priority_check" CHECK ((priority = ANY (ARRAY['urgent'::text, 'high'::text, 'normal'::text, 'low'::text])));
alter table projects add constraint "projects_stage_check" CHECK (((stage IS NOT NULL) AND ((length(TRIM(BOTH FROM stage)) >= 1) AND (length(TRIM(BOTH FROM stage)) <= 40))));
alter table proposals add constraint "proposals_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'declined'::text])));
alter table purchase_orders add constraint "purchase_orders_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'ordered'::text, 'partial'::text, 'received'::text])));
alter table qb_tokens add constraint "qb_tokens_id_check" CHECK ((id = 1));
alter table stations add constraint "stations_pct_check" CHECK (((pct >= 0) AND (pct <= 100)));
alter table stations add constraint "stations_status_check" CHECK ((status = ANY (ARRAY['running'::text, 'waiting'::text, 'idle'::text])));
alter table time_off add constraint "time_off_status_check" CHECK ((status = ANY (ARRAY['requested'::text, 'approved'::text, 'denied'::text])));
alter table time_off add constraint "time_off_type_check" CHECK ((type = ANY (ARRAY['pto'::text, 'sick'::text, 'holiday'::text, 'other'::text])));
alter table work_orders add constraint "work_orders_priority_check" CHECK ((priority = ANY (ARRAY['high'::text, 'medium'::text, 'low'::text])));
alter table work_orders add constraint "work_orders_status_check" CHECK ((status = ANY (ARRAY['open'::text, 'in_progress'::text, 'on_hold'::text, 'done'::text])));
alter table appointments add constraint "appointments_assigned_to_fkey" FOREIGN KEY (assigned_to) REFERENCES employees(id) ON DELETE SET NULL;
alter table appointments add constraint "appointments_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL;
alter table appointments add constraint "appointments_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL;
alter table approval_requests add constraint "approval_requests_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE;
alter table approval_requests add constraint "approval_requests_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL;
alter table approval_requests add constraint "approval_requests_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
alter table approval_requests add constraint "approval_requests_sent_by_fkey" FOREIGN KEY (sent_by) REFERENCES employees(id) ON DELETE SET NULL;
alter table board_bookings add constraint "board_bookings_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL;
alter table board_bookings add constraint "board_bookings_station_id_fkey" FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE;
alter table customers add constraint "customers_auth_user_id_fkey" FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;
alter table customers add constraint "customers_designer_id_fkey" FOREIGN KEY (designer_id) REFERENCES employees(id) ON DELETE SET NULL;
alter table drawing_revisions add constraint "drawing_revisions_author_fkey" FOREIGN KEY (author) REFERENCES employees(id) ON DELETE SET NULL;
alter table drawing_revisions add constraint "drawing_revisions_drawing_id_fkey" FOREIGN KEY (drawing_id) REFERENCES drawings(id) ON DELETE CASCADE;
alter table drawings add constraint "drawings_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
alter table employees add constraint "employees_auth_user_id_fkey" FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE SET NULL;
alter table google_tokens add constraint "google_tokens_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
alter table install_assignments add constraint "install_assignments_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;
alter table install_assignments add constraint "install_assignments_install_id_fkey" FOREIGN KEY (install_id) REFERENCES installs(id) ON DELETE CASCADE;
alter table installs add constraint "installs_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
alter table invoices add constraint "invoices_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
alter table leads add constraint "leads_assigned_fkey" FOREIGN KEY (assigned) REFERENCES employees(id) ON DELETE SET NULL;
alter table leads add constraint "leads_converted_project_id_fkey" FOREIGN KEY (converted_project_id) REFERENCES projects(id) ON DELETE SET NULL;
alter table leads add constraint "leads_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL;
alter table messages add constraint "messages_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE;
alter table messages add constraint "messages_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
alter table messages add constraint "messages_sender_customer_id_fkey" FOREIGN KEY (sender_customer_id) REFERENCES customers(id) ON DELETE SET NULL;
alter table messages add constraint "messages_sender_employee_id_fkey" FOREIGN KEY (sender_employee_id) REFERENCES employees(id) ON DELETE SET NULL;
alter table notes add constraint "notes_author_fkey" FOREIGN KEY (author) REFERENCES employees(id) ON DELETE SET NULL;
alter table order_items add constraint "order_items_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;
alter table orders add constraint "orders_created_by_fkey" FOREIGN KEY (created_by) REFERENCES employees(id);
alter table orders add constraint "orders_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
alter table payments add constraint "payments_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
alter table po_items add constraint "po_items_po_id_fkey" FOREIGN KEY (po_id) REFERENCES purchase_orders(id) ON DELETE CASCADE;
alter table projects add constraint "projects_assigned_pm_fkey" FOREIGN KEY (assigned_pm) REFERENCES employees(id) ON DELETE SET NULL;
alter table projects add constraint "projects_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT;
alter table projects add constraint "projects_designer_id_fkey" FOREIGN KEY (designer_id) REFERENCES employees(id) ON DELETE SET NULL;
alter table projects add constraint "projects_installer_fkey" FOREIGN KEY (installer) REFERENCES employees(id) ON DELETE SET NULL;
alter table proposals add constraint "proposals_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE;
alter table proposals add constraint "proposals_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL;
alter table punch_items add constraint "punch_items_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;
alter table punch_items add constraint "punch_items_who_fkey" FOREIGN KEY (who) REFERENCES employees(id) ON DELETE SET NULL;
alter table purchase_orders add constraint "purchase_orders_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL;
alter table stations add constraint "stations_operator_fkey" FOREIGN KEY (operator) REFERENCES employees(id) ON DELETE SET NULL;
alter table stations add constraint "stations_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL;
alter table time_entries add constraint "time_entries_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;
alter table time_entries add constraint "time_entries_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL;
alter table time_off add constraint "time_off_employee_id_fkey" FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE;
alter table work_orders add constraint "work_orders_assigned_fkey" FOREIGN KEY (assigned) REFERENCES employees(id) ON DELETE SET NULL;
alter table work_orders add constraint "work_orders_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL;
alter table work_orders add constraint "work_orders_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

-- indexes
CREATE INDEX IF NOT EXISTS idx_activity_created ON public.activity_log USING btree (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_approval_project ON public.approval_requests USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_approval_token ON public.approval_requests USING btree (token);
CREATE INDEX IF NOT EXISTS idx_appt_date ON public.appointments USING btree (appt_date);
CREATE INDEX IF NOT EXISTS idx_appt_project ON public.appointments USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_attachments_entity ON public.attachments USING btree (entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_automation_log_lookup ON public.automation_log USING btree (kind, entity_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_board_bookings_dates ON public.board_bookings USING btree (start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_board_bookings_station ON public.board_bookings USING btree (station_id);
CREATE INDEX IF NOT EXISTS idx_customers_designer ON public.customers USING btree (designer_id);
CREATE INDEX IF NOT EXISTS idx_drawings_project ON public.drawings USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_drawrev_drawing ON public.drawing_revisions USING btree (drawing_id);
CREATE INDEX IF NOT EXISTS idx_installs_dates ON public.installs USING btree (start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_installs_project ON public.installs USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_invoices_project ON public.invoices USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_leads_status ON public.leads USING btree (status);
CREATE INDEX IF NOT EXISTS idx_messages_customer ON public.messages USING btree (customer_id);
CREATE INDEX IF NOT EXISTS idx_messages_project ON public.messages USING btree (project_id, created_at);
CREATE INDEX IF NOT EXISTS idx_notes_entity ON public.notes USING btree (entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_payments_project ON public.payments USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_po_items_po ON public.po_items USING btree (po_id);
CREATE INDEX IF NOT EXISTS idx_po_project ON public.purchase_orders USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_po_status ON public.purchase_orders USING btree (status);
CREATE INDEX IF NOT EXISTS idx_projects_customer ON public.projects USING btree (customer_id);
CREATE INDEX IF NOT EXISTS idx_projects_designer ON public.projects USING btree (designer_id);
CREATE INDEX IF NOT EXISTS idx_projects_due ON public.projects USING btree (due_date);
CREATE INDEX IF NOT EXISTS idx_projects_pm ON public.projects USING btree (assigned_pm);
CREATE INDEX IF NOT EXISTS idx_projects_stage ON public.projects USING btree (stage);
CREATE INDEX IF NOT EXISTS idx_proposals_customer ON public.proposals USING btree (customer_id);
CREATE INDEX IF NOT EXISTS idx_proposals_project ON public.proposals USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_proposals_status ON public.proposals USING btree (status);
CREATE INDEX IF NOT EXISTS idx_punch_project ON public.punch_items USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_time_active ON public.time_entries USING btree (active);
CREATE INDEX IF NOT EXISTS idx_time_employee ON public.time_entries USING btree (employee_id);
CREATE INDEX IF NOT EXISTS idx_time_off_emp ON public.time_off USING btree (employee_id);
CREATE INDEX IF NOT EXISTS idx_wo_assigned ON public.work_orders USING btree (assigned);
CREATE INDEX IF NOT EXISTS idx_wo_customer ON public.work_orders USING btree (customer_id);
CREATE INDEX IF NOT EXISTS idx_wo_project ON public.work_orders USING btree (project_id);
CREATE INDEX IF NOT EXISTS idx_wo_status ON public.work_orders USING btree (status);
CREATE UNIQUE INDEX IF NOT EXISTS uq_customers_auth_user ON public.customers USING btree (auth_user_id) WHERE (auth_user_id IS NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS uq_employees_auth_user ON public.employees USING btree (auth_user_id) WHERE (auth_user_id IS NOT NULL);

-- functions
CREATE OR REPLACE FUNCTION public.has_role(VARIADIC roles text[])
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select coalesce(staff_role() = any(roles), false);
$function$
;
CREATE OR REPLACE FUNCTION public.is_staff()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (select 1 from employees where auth_user_id = auth.uid());
$function$
;
CREATE OR REPLACE FUNCTION public.my_customer_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select id from customers where auth_user_id = auth.uid() limit 1;
$function$
;
CREATE OR REPLACE FUNCTION public.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$
;
CREATE OR REPLACE FUNCTION public.staff_role()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select perm_role from employees where auth_user_id = auth.uid() limit 1;
$function$
;

do $$ begin
  begin grant execute on all functions in schema public to authenticated, anon; exception when others then null; end;
end $$;

-- triggers
CREATE TRIGGER trg_appointments_updated BEFORE UPDATE ON public.appointments FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_customers_updated BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_drawings_updated BEFORE UPDATE ON public.drawings FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_employees_updated BEFORE UPDATE ON public.employees FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_installs_updated BEFORE UPDATE ON public.installs FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_leads_updated BEFORE UPDATE ON public.leads FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_projects_updated BEFORE UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_proposals_updated BEFORE UPDATE ON public.proposals FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_punch_items_updated BEFORE UPDATE ON public.punch_items FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_purchase_orders_updated BEFORE UPDATE ON public.purchase_orders FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_stations_updated BEFORE UPDATE ON public.stations FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_time_entries_updated BEFORE UPDATE ON public.time_entries FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_work_orders_updated BEFORE UPDATE ON public.work_orders FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- row level security
alter table "activity_log" enable row level security;
alter table "app_config" enable row level security;
alter table "appointments" enable row level security;
alter table "approval_requests" enable row level security;
alter table "attachments" enable row level security;
alter table "automation_log" enable row level security;
alter table "board_bookings" enable row level security;
alter table "customers" enable row level security;
alter table "drawing_revisions" enable row level security;
alter table "drawings" enable row level security;
alter table "employees" enable row level security;
alter table "google_tokens" enable row level security;
alter table "install_assignments" enable row level security;
alter table "installs" enable row level security;
alter table "invoices" enable row level security;
alter table "leads" enable row level security;
alter table "messages" enable row level security;
alter table "notes" enable row level security;
alter table "order_items" enable row level security;
alter table "orders" enable row level security;
alter table "payments" enable row level security;
alter table "po_items" enable row level security;
alter table "projects" enable row level security;
alter table "proposals" enable row level security;
alter table "punch_items" enable row level security;
alter table "purchase_orders" enable row level security;
alter table "qb_tokens" enable row level security;
alter table "stations" enable row level security;
alter table "time_entries" enable row level security;
alter table "time_off" enable row level security;
alter table "work_orders" enable row level security;

-- policies
create policy "authenticated full access" on "activity_log" for all to authenticated using (is_staff()) with check (is_staff());
create policy "config_stages_read" on "app_config" for select to authenticated using ((key = 'pipeline_stages'::text));
create policy "mgr write app_config" on "app_config" for all to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text])) with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff read app_config" on "app_config" for select to authenticated using (is_staff());
create policy "authenticated full access" on "appointments" for all to authenticated using (is_staff()) with check (is_staff());
create policy "customer reads own appointments" on "appointments" for select to authenticated using ((customer_id = my_customer_id()));
create policy "owner_del_appointments" on "appointments" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_appointments" on "appointments" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_appointments" on "appointments" for select to authenticated using (is_staff());
create policy "staff_upd_appointments" on "appointments" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "customer reads own approvals" on "approval_requests" for select to authenticated using ((project_id IN ( SELECT projects.id
   FROM projects
  WHERE (projects.customer_id = my_customer_id()))));
create policy "owner_del_approval_requests" on "approval_requests" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_approval_requests" on "approval_requests" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_approval_requests" on "approval_requests" for select to authenticated using (is_staff());
create policy "staff_upd_approval_requests" on "approval_requests" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff read attachments" on "attachments" for select to authenticated using (is_staff());
create policy "staff write attachments" on "attachments" for all to authenticated using (is_staff()) with check (is_staff());
create policy "staff_ins_attachments" on "attachments" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_upd_attachments" on "attachments" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff read automation_log" on "automation_log" for select to authenticated using (is_staff());
create policy "mgr write board_bookings" on "board_bookings" for all to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text])) with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff read board_bookings" on "board_bookings" for select to authenticated using (is_staff());
create policy "authenticated full access" on "customers" for all to authenticated using (is_staff()) with check (is_staff());
create policy "customer reads self" on "customers" for select to authenticated using ((auth_user_id = auth.uid()));
create policy "owner_del_customers" on "customers" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_customers" on "customers" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_customers" on "customers" for select to authenticated using (is_staff());
create policy "staff_upd_customers" on "customers" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "authenticated full access" on "drawing_revisions" for all to authenticated using (is_staff()) with check (is_staff());
create policy "staff_ins_drawing_revisions" on "drawing_revisions" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_upd_drawing_revisions" on "drawing_revisions" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "authenticated full access" on "drawings" for all to authenticated using (is_staff()) with check (is_staff());
create policy "customer reads own drawings" on "drawings" for select to authenticated using ((project_id IN ( SELECT projects.id
   FROM projects
  WHERE (projects.customer_id = my_customer_id()))));
create policy "owner_del_drawings" on "drawings" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_drawings" on "drawings" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_drawings" on "drawings" for select to authenticated using (is_staff());
create policy "staff_upd_drawings" on "drawings" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "authenticated full access" on "employees" for all to authenticated using (is_staff()) with check (is_staff());
create policy "owner_del_employees" on "employees" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_employees" on "employees" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff_read_employees" on "employees" for select to authenticated using (is_staff());
create policy "staff_upd_employees" on "employees" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "mgr write install_assignments" on "install_assignments" for all to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text])) with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff read install_assignments" on "install_assignments" for select to authenticated using (is_staff());
create policy "authenticated full access" on "installs" for all to authenticated using (is_staff()) with check (is_staff());
create policy "customer reads own installs" on "installs" for select to authenticated using ((project_id IN ( SELECT projects.id
   FROM projects
  WHERE (projects.customer_id = my_customer_id()))));
create policy "owner_del_installs" on "installs" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_installs" on "installs" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff_read_installs" on "installs" for select to authenticated using (is_staff());
create policy "staff_upd_installs" on "installs" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "customer reads own invoices" on "invoices" for select to authenticated using ((project_id IN ( SELECT projects.id
   FROM projects
  WHERE (projects.customer_id = my_customer_id()))));
create policy "staff read invoices" on "invoices" for select to authenticated using (is_staff());
create policy "staff write invoices" on "invoices" for all to authenticated using (is_staff()) with check (is_staff());
create policy "authenticated full access" on "leads" for all to authenticated using (is_staff()) with check (is_staff());
create policy "owner_del_leads" on "leads" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_leads" on "leads" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_leads" on "leads" for select to authenticated using (is_staff());
create policy "staff_upd_leads" on "leads" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "customer reads own messages" on "messages" for select to authenticated using (((customer_id = my_customer_id()) OR (project_id IN ( SELECT projects.id
   FROM projects
  WHERE (projects.customer_id = my_customer_id())))));
create policy "customer sends own messages" on "messages" for insert to authenticated with check (((sender_type = 'customer'::text) AND (sender_customer_id = my_customer_id()) AND ((customer_id = my_customer_id()) OR (project_id IN ( SELECT projects.id
   FROM projects
  WHERE (projects.customer_id = my_customer_id()))))));
create policy "customer updates own messages" on "messages" for update to authenticated using (((customer_id = my_customer_id()) OR (project_id IN ( SELECT projects.id
   FROM projects
  WHERE (projects.customer_id = my_customer_id())))));
create policy "staff all messages" on "messages" for all to authenticated using (is_staff()) with check (is_staff());
create policy "staff_ins_messages" on "messages" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_upd_messages" on "messages" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "authenticated full access" on "notes" for all to authenticated using (is_staff()) with check (is_staff());
create policy "staff_ins_notes" on "notes" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_upd_notes" on "notes" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_del_order_items" on "order_items" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_ins_order_items" on "order_items" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_order_items" on "order_items" for select to authenticated using (is_staff());
create policy "staff_upd_order_items" on "order_items" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_del_orders" on "orders" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_orders" on "orders" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_orders" on "orders" for select to authenticated using (is_staff());
create policy "staff_upd_orders" on "orders" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "customer reads own payments" on "payments" for select to authenticated using ((project_id IN ( SELECT projects.id
   FROM projects
  WHERE (projects.customer_id = my_customer_id()))));
create policy "staff read payments" on "payments" for select to authenticated using (is_staff());
create policy "staff write payments" on "payments" for all to authenticated using (is_staff()) with check (is_staff());
create policy "authenticated full access" on "po_items" for all to authenticated using (is_staff()) with check (is_staff());
create policy "owner_del_po_items" on "po_items" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_po_items" on "po_items" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff_read_po_items" on "po_items" for select to authenticated using (is_staff());
create policy "staff_upd_po_items" on "po_items" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "authenticated full access" on "projects" for all to authenticated using (is_staff()) with check (is_staff());
create policy "customer reads own projects" on "projects" for select to authenticated using ((customer_id = my_customer_id()));
create policy "owner_del_projects" on "projects" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_projects" on "projects" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_projects" on "projects" for select to authenticated using (is_staff());
create policy "staff_upd_projects" on "projects" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "authenticated full access" on "proposals" for all to authenticated using (is_staff()) with check (is_staff());
create policy "owner_del_proposals" on "proposals" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_proposals" on "proposals" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_proposals" on "proposals" for select to authenticated using (is_staff());
create policy "staff_upd_proposals" on "proposals" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "authenticated full access" on "punch_items" for all to authenticated using (is_staff()) with check (is_staff());
create policy "owner_del_punch_items" on "punch_items" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_punch_items" on "punch_items" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "staff_read_punch_items" on "punch_items" for select to authenticated using (is_staff());
create policy "staff_upd_punch_items" on "punch_items" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'designer'::text]));
create policy "authenticated full access" on "purchase_orders" for all to authenticated using (is_staff()) with check (is_staff());
create policy "owner_del_purchase_orders" on "purchase_orders" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_purchase_orders" on "purchase_orders" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff_read_purchase_orders" on "purchase_orders" for select to authenticated using (is_staff());
create policy "staff_upd_purchase_orders" on "purchase_orders" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "authenticated full access" on "stations" for all to authenticated using (is_staff()) with check (is_staff());
create policy "owner_del_stations" on "stations" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_stations" on "stations" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff_read_stations" on "stations" for select to authenticated using (is_staff());
create policy "staff_upd_stations" on "stations" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "authenticated full access" on "time_entries" for all to authenticated using (is_staff()) with check (is_staff());
create policy "owner_del_time_entries" on "time_entries" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_time_entries" on "time_entries" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff_read_time_entries" on "time_entries" for select to authenticated using (is_staff());
create policy "staff_upd_time_entries" on "time_entries" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "delete time_off" on "time_off" for delete to authenticated using ((has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]) OR (employee_id IN ( SELECT employees.id
   FROM employees
  WHERE (employees.auth_user_id = auth.uid())))));
create policy "insert time_off" on "time_off" for insert to authenticated with check ((has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]) OR (employee_id IN ( SELECT employees.id
   FROM employees
  WHERE (employees.auth_user_id = auth.uid())))));
create policy "mgr update time_off" on "time_off" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff read time_off" on "time_off" for select to authenticated using (is_staff());
create policy "authenticated full access" on "work_orders" for all to authenticated using (is_staff()) with check (is_staff());
create policy "owner_del_work_orders" on "work_orders" for delete to authenticated using (has_role(VARIADIC ARRAY['owner'::text]));
create policy "staff_ins_work_orders" on "work_orders" for insert to authenticated with check (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text]));
create policy "staff_read_work_orders" on "work_orders" for select to authenticated using (is_staff());
create policy "staff_upd_work_orders" on "work_orders" for update to authenticated using (has_role(VARIADIC ARRAY['owner'::text, 'manager'::text, 'installer'::text]));

-- storage
insert into storage.buckets (id, name, public) values ('drawing-files','drawing-files', false) on conflict (id) do nothing;
