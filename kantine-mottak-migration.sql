-- Kantine bestilling: café registers receipt of goods (varemottak)
-- Run once in the Supabase SQL editor BEFORE deploying the new kantine.html / kafeoversikt.html.

-- Received quantity per order line. Key = same key as the old checklist ("pid" or "pid_idx").
-- Value: {qty, price, date, by, note, no_invoice}
--   price      = unit price snapshot at receipt (invoice no longer changes if products.price changes)
--   no_invoice = true → quantity above what was ordered is not invoiced
alter table orders add column if not exists received jsonb default '{}'::jsonb;

-- Products received that were not on the order (over-delivery of other items, substitutions).
-- [{pid, qty, price, date, by, note, no_invoice}]
alter table orders add column if not exists extra_items jsonb default '[]'::jsonb;

-- Set by "Fullfør mottak" together with status = 'delivered'. Decides the invoice month.
alter table orders add column if not exists received_at timestamptz;
alter table orders add column if not exists received_by text;

-- Set when the canteen prints the order. Cleared when the café edits the order again.
alter table orders add column if not exists canteen_printed_at timestamptz;

-- Link auto-produced production rows to the import receipt, so "Angre import" can remove them.
alter table production_log add column if not exists purchase_receipt_id bigint;

-- Monthly invoice print tracking (replaces per-device localStorage)
create table if not exists canteen_invoices (
  month text primary key,          -- 'YYYY-MM'
  printed_at timestamptz not null default now(),
  total numeric not null default 0,
  order_ids jsonb default '[]'::jsonb
);
alter table canteen_invoices enable row level security;
drop policy if exists "Public access" on canteen_invoices;
create policy "Public access" on canteen_invoices for all using (true) with check (true);
