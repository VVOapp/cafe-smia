-- Ukens quiz (under Lojalitet-fanen) — kjør dette i Supabase SQL-editoren én gang.
--
-- Én rad ("current") holder hele ukens quiz: sudoku, ordspill og løsningsord.
-- Admin redigerer og lagrer via appen; ansatte ser fasiten (read-only) samme sted,
-- slik at de kan sjekke svarlapper i disken uten å trenge admin-tilgang.

create table if not exists weekly_quiz (
  slug            text primary key default 'current',
  week_label      text,
  date_label      text,
  greeting        text,
  codeword        text,
  clues           jsonb not null default '[]'::jsonb,   -- [{ clue, answer }, ...] én per bokstav i løsningsordet
  draw_when       text,
  prize           text,
  sudoku_puzzle   jsonb,                                  -- 6x6 array med tall/null (blanke ruter)
  sudoku_solution jsonb,                                  -- 6x6 array med fasiten
  updated_at      timestamptz default now()
);

-- RLS: samme mønster som resten av databasen (anon-nøkkelen i appen trenger
-- lese- og skrivetilgang siden det ikke er noen server-backend).
alter table weekly_quiz enable row level security;
create policy "Public access" on weekly_quiz for all using (true) with check (true);
