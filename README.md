# Journal Jufri

Personal productivity workspace built with Vue 3, TypeScript, Vite, Pinia, and Lucide.

## Current phase

The first implementation phase is intentionally local-first: missions, habits, agenda, journal, and notes are fully editable and persisted in browser storage. This makes the product usable while the Supabase schema, authentication, and RLS are connected in the database phase. No fake remote sync is presented as completed.

## Run locally

```bash
npm install
npm run dev
```

Quality checks:

```bash
npm run build
npm test
```

## Planned database phase

The Supabase connection will use `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` from `.env.local`. The browser must only receive the anon key; service-role credentials must never be exposed in frontend code. The service layer in `src/services/` is the integration boundary for replacing local persistence with Supabase queries and RLS-protected tables.

## Deployment

`vercel.json` contains the SPA fallback required for direct Vue Router-style routes. Configure the two Vite environment variables in Vercel after the Supabase migration and auth flow are ready.
