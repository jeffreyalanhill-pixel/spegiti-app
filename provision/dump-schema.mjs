// Extracts the complete public-schema DDL from the master Supabase project
// into provision/schema.sql — the template every new shop is stamped from.
// Usage: node dump-schema.mjs   (token + source ref from config below)
import { readFileSync, writeFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const here = dirname(fileURLToPath(import.meta.url));
const CONFIG = JSON.parse(readFileSync(join(here, "config.json"), "utf8"));
const TOKEN = readFileSync(CONFIG.management_token_file, "utf8").trim();
const SRC = CONFIG.source_project_ref;
const API = "https://api.supabase.com/v1";

async function q(sql) {
  const r = await fetch(`${API}/projects/${SRC}/database/query`, {
    method: "POST",
    headers: { Authorization: `Bearer ${TOKEN}`, "Content-Type": "application/json" },
    body: JSON.stringify({ query: sql }),
  });
  if (!r.ok) throw new Error(`query failed ${r.status}: ${(await r.text()).slice(0, 300)}`);
  return r.json();
}

const out = [];
out.push("-- Spegiti shop schema — generated from the master project by dump-schema.mjs");
out.push(`-- source: ${SRC} · generated: ${new Date().toISOString()}`);
out.push("");

// extensions (beyond the defaults every Supabase project has)
const ext = await q(`select extname from pg_extension where extname not in ('plpgsql','pg_stat_statements','pgcrypto','pgjwt','uuid-ossp','supabase_vault','pg_graphql','pg_net') order by 1`);
out.push("-- extensions");
out.push(`create extension if not exists pgcrypto;`);
for (const e of ext) out.push(`create extension if not exists "${e.extname}";`);
out.push("");

// tables: columns + defaults + not null
const tables = await q(`select c.relname as t from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind='r' order by c.relname`);
const colsSql = `
  select c.relname as t, a.attname as col, format_type(a.atttypid, a.atttypmod) as typ,
         a.attnotnull as nn, pg_get_expr(d.adbin, d.adrelid) as def, a.attnum
  from pg_attribute a
  join pg_class c on c.oid = a.attrelid
  join pg_namespace n on n.oid = c.relnamespace
  left join pg_attrdef d on d.adrelid = a.attrelid and d.adnum = a.attnum
  where n.nspname='public' and c.relkind='r' and a.attnum > 0 and not a.attisdropped
  order by c.relname, a.attnum`;
const cols = await q(colsSql);
out.push("-- tables");
for (const { t } of tables) {
  const tc = cols.filter(x => x.t === t);
  const lines = tc.map(x =>
    `  "${x.col}" ${x.typ}${x.def ? ` default ${x.def}` : ""}${x.nn ? " not null" : ""}`);
  out.push(`create table if not exists "${t}" (\n${lines.join(",\n")}\n);`);
}
out.push("");

// constraints: PK/unique/check first, FKs after all tables exist
const cons = await q(`
  select conrelid::regclass::text as t, conname, contype, pg_get_constraintdef(oid) as def
  from pg_constraint
  where connamespace = 'public'::regnamespace and conrelid != 0
  order by case contype when 'p' then 0 when 'u' then 1 when 'c' then 2 else 3 end, conrelid::regclass::text, conname`);
out.push("-- constraints");
for (const c of cons) out.push(`alter table ${c.t} add constraint "${c.conname}" ${c.def};`);
out.push("");

// standalone indexes (non-constraint)
const idx = await q(`
  select indexdef from pg_indexes
  where schemaname='public' and indexname not in (select conname from pg_constraint where connamespace='public'::regnamespace)
  order by indexname`);
out.push("-- indexes");
for (const i of idx) out.push(`${i.indexdef.replace("CREATE INDEX", "CREATE INDEX IF NOT EXISTS").replace("CREATE UNIQUE INDEX", "CREATE UNIQUE INDEX IF NOT EXISTS")};`);
out.push("");

// functions
const fns = await q(`
  select pg_get_functiondef(p.oid) as def
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where n.nspname='public' and p.prokind='f'
  order by p.proname`);
out.push("-- functions");
for (const f of fns) out.push(`${f.def};`);
out.push("");

// grants for the helper functions (mirrors phase0 migration)
out.push(`do $$ begin
  begin grant execute on all functions in schema public to authenticated, anon; exception when others then null; end;
end $$;`);
out.push("");

// triggers
const trg = await q(`
  select pg_get_triggerdef(t.oid) as def
  from pg_trigger t join pg_class c on c.oid = t.tgrelid join pg_namespace n on n.oid = c.relnamespace
  where n.nspname='public' and not t.tgisinternal
  order by t.tgname`);
out.push("-- triggers");
for (const t of trg) out.push(`${t.def};`);
out.push("");

// row level security
const rls = await q(`
  select c.relname as t from pg_class c join pg_namespace n on n.oid=c.relnamespace
  where n.nspname='public' and c.relkind='r' and c.relrowsecurity
  order by 1`);
out.push("-- row level security");
for (const r of rls) out.push(`alter table "${r.t}" enable row level security;`);
out.push("");

// policies
const pol = await q(`
  select schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
  from pg_policies where schemaname='public'
  order by tablename, policyname`);
out.push("-- policies");
for (const p of pol) {
  const roles = (Array.isArray(p.roles) ? p.roles : String(p.roles).replace(/[{}]/g, "").split(",")).join(", ");
  let s = `create policy "${p.policyname}" on "${p.tablename}"`;
  if (String(p.permissive).toLowerCase().startsWith("restrict")) s += " as restrictive";
  s += ` for ${p.cmd.toLowerCase()} to ${roles}`;
  if (p.qual) s += ` using (${p.qual})`;
  if (p.with_check) s += ` with check (${p.with_check})`;
  out.push(s + ";");
}
out.push("");

// storage bucket for drawings (private; policies ride on storage.objects defaults + our app uses signed URLs)
out.push("-- storage");
out.push(`insert into storage.buckets (id, name, public) values ('drawing-files','drawing-files', false) on conflict (id) do nothing;`);
out.push("");

const sql = out.join("\n");
writeFileSync(join(here, "schema.sql"), sql);
console.log(`schema.sql written: ${sql.length} chars · ${tables.length} tables · ${cons.length} constraints · ${fns.length} functions · ${trg.length} triggers · ${pol.length} policies · rls on ${rls.length}`);
