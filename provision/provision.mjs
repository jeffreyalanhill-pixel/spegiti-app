// Spegiti shop factory: one command turns a signup into a running shop.
//
//   node provision.mjs <slug> "<Shop Name>" <owner-email>
//   node provision.mjs --into <existing-ref> <slug> "<Shop Name>" <owner-email>
//
// Steps: create Supabase project (or reuse --into ref) → wait healthy →
// apply schema.sql → set function secrets → deploy edge functions →
// seed starter config + owner login → register <slug>.spegiti.com in the
// app's SHOPS map → git commit/push (Vercel auto-deploys).
import { readFileSync, writeFileSync, readdirSync, existsSync } from "fs";
import { execSync } from "child_process";
import { randomBytes } from "crypto";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const here = dirname(fileURLToPath(import.meta.url));
const CONFIG = JSON.parse(readFileSync(join(here, "config.json"), "utf8"));
const TOKEN = readFileSync(CONFIG.management_token_file, "utf8").trim();
const API = "https://api.supabase.com/v1";

const argv = process.argv.slice(2);
let intoRef = null;
if (argv[0] === "--into") { intoRef = argv[1]; argv.splice(0, 2); }
const [slug, shopName, ownerEmail] = argv;
if (!slug || !shopName || !ownerEmail || !/^[a-z0-9-]{2,30}$/.test(slug)) {
  console.error('usage: node provision.mjs [--into <ref>] <slug> "<Shop Name>" <owner-email>');
  process.exit(1);
}
const hostname = `${slug}.spegiti.com`;

async function api(path, opts = {}) {
  const r = await fetch(`${API}${path}`, {
    ...opts,
    headers: { Authorization: `Bearer ${TOKEN}`, ...(opts.body && !(opts.body instanceof FormData) ? { "Content-Type": "application/json" } : {}), ...(opts.headers || {}) },
  });
  const text = await r.text();
  if (!r.ok) throw new Error(`${opts.method || "GET"} ${path} → ${r.status}: ${text.slice(0, 400)}`);
  try { return JSON.parse(text); } catch { return text; }
}
const q = (ref, sql) => api(`/projects/${ref}/database/query`, { method: "POST", body: JSON.stringify({ query: sql }) });
const step = (m) => console.log(`\n■ ${m}`);

// ── 1. project ────────────────────────────────────────────────────
let ref = intoRef;
const dbPass = randomBytes(24).toString("base64url");
if (!ref) {
  step(`creating Supabase project spegiti-${slug}`);
  const proj = await api("/projects", {
    method: "POST",
    body: JSON.stringify({
      organization_id: CONFIG.organization_id,
      name: `spegiti-${slug}`,
      db_pass: dbPass,
      region: "us-east-1",
    }),
  });
  ref = proj.id;
  console.log(`  ref: ${ref}`);
} else {
  step(`reusing existing project ${ref}`);
}

step("waiting for project to be healthy");
for (let i = 0; i < 60; i++) {
  const p = await api(`/projects/${ref}`);
  if (p.status === "ACTIVE_HEALTHY") break;
  if (i === 59) throw new Error(`project never became healthy (last: ${p.status})`);
  await new Promise((r) => setTimeout(r, 10000));
  process.stdout.write(".");
}
console.log(" healthy");

// ── 2. schema ─────────────────────────────────────────────────────
step("applying schema.sql");
const schema = readFileSync(join(here, "schema.sql"), "utf8");
try {
  await q(ref, schema);
  console.log("  applied in one shot");
} catch (e) {
  console.log(`  one-shot failed (${e.message.slice(0, 120)}), applying section by section`);
  const sections = schema.split(/\n(?=-- [a-z])/);
  for (const s of sections) {
    try { await q(ref, s); } catch (e2) { console.error(`  SECTION FAILED (continuing): ${s.slice(0, 60)} → ${e2.message.slice(0, 200)}`); }
  }
}
const tcount = await q(ref, "select count(*)::int as n from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and c.relkind='r'");
console.log(`  tables in new project: ${tcount[0].n}`);

// ── 3. api keys ───────────────────────────────────────────────────
step("fetching API keys");
const keys = await api(`/projects/${ref}/api-keys`);
const anon = keys.find((k) => k.name === "anon")?.api_key;
const service = keys.find((k) => k.name === "service_role")?.api_key;
if (!anon || !service) throw new Error("could not read anon/service keys");

// ── 4. secrets + edge functions ───────────────────────────────────
step("setting function secrets");
const automationSecret = randomBytes(32).toString("hex");
const secrets = [
  { name: "AUTOMATION_SECRET", value: automationSecret },
  { name: "APP_URL", value: `https://${hostname}` },
];
if (CONFIG.resend_api_key) secrets.push({ name: "RESEND_API_KEY", value: CONFIG.resend_api_key });
await api(`/projects/${ref}/secrets`, { method: "POST", body: JSON.stringify(secrets) });
console.log(`  set: ${secrets.map((s) => s.name).join(", ")}${CONFIG.resend_api_key ? "" : "  (no RESEND_API_KEY in config — emails off until set)"}`);

step("deploying edge functions");
const fnDirs = readdirSync(CONFIG.functions_dir, { withFileTypes: true }).filter((d) => d.isDirectory());
for (const d of fnDirs) {
  const entry = join(CONFIG.functions_dir, d.name, "index.ts");
  if (!existsSync(entry)) continue;
  const code = readFileSync(entry, "utf8");
  const fd = new FormData();
  fd.append("metadata", new Blob([JSON.stringify({ name: d.name, entrypoint_path: "index.ts", verify_jwt: false })], { type: "application/json" }));
  fd.append("file", new Blob([code], { type: "text/typescript" }), "index.ts");
  await api(`/projects/${ref}/functions/deploy?slug=${d.name}`, { method: "POST", body: fd });
  process.stdout.write(`  ${d.name}`);
}
console.log("");

// ── 5. seed: starter config + owner ───────────────────────────────
step("seeding starter config");
const esc = (s) => String(s).replace(/'/g, "''");
await q(ref, `
  insert into app_config (key, value) values
    ('enabled_features', '[]'),
    ('notify_email', '${esc(ownerEmail)}')
  on conflict (key) do update set value = excluded.value;`);

step("creating owner login");
const ownerPass = randomBytes(12).toString("base64url");
const projUrl = `https://${ref}.supabase.co`;
const ur = await fetch(`${projUrl}/auth/v1/admin/users`, {
  method: "POST",
  headers: { apikey: service, Authorization: `Bearer ${service}`, "Content-Type": "application/json", "User-Agent": "spegiti-provision" },
  body: JSON.stringify({ email: ownerEmail, password: ownerPass, email_confirm: true }),
});
const user = await ur.json();
if (!ur.ok) throw new Error(`owner user create failed: ${JSON.stringify(user).slice(0, 300)}`);
await q(ref, `
  insert into employees (name, email, role, perm_role, status, auth_user_id)
  values ('${esc(shopName)} Owner', '${esc(ownerEmail)}', 'Owner', 'owner', 'active', '${user.id}');`);
console.log(`  owner: ${ownerEmail}`);

// ── 6. register hostname in the app ───────────────────────────────
step("registering shop in the app's SHOPS map");
const idx = readFileSync(CONFIG.app_index, "utf8");
const entry = `  "${hostname}": { url: "${projUrl}", anon: "${anon}", name: "${esc(shopName)}" },\n/*__SHOPS__*/`;
if (idx.includes(`"${hostname}"`)) console.log("  already registered");
else {
  writeFileSync(CONFIG.app_index, idx.replace("/*__SHOPS__*/", entry));
  execSync(`git add index.html && git commit -m "provision: ${slug} (${shopName})" && git push`, { cwd: dirname(CONFIG.app_index), stdio: "pipe" });
  console.log("  committed + pushed (Vercel auto-deploys)");
}

// ── done ──────────────────────────────────────────────────────────
console.log(`
════════════════════════════════════════════════════════════
  SHOP PROVISIONED: ${shopName}
  URL:        https://${hostname}
  Owner:      ${ownerEmail}
  Temp pass:  ${ownerPass}     (have them change it after first login)
  Supabase:   ${ref}
════════════════════════════════════════════════════════════
Remaining (once per shop):
  1. Vercel → spegiti-app → Settings → Domains → add ${hostname}
  2. Squarespace DNS → CNAME  ${slug} → cname.vercel-dns.com
     (or add ONE wildcard CNAME *.spegiti.com and skip this forever)
`);
