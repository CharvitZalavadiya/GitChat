---
name: prisma-orm
description: "Use for Prisma ORM setup, schema modeling, migrations, and type-safe database queries in Node.js/TypeScript projects. Trigger on requests about Prisma Client methods, relations, transactions, connecting Prisma to PostgreSQL/Supabase/MySQL/SQLite, replacing raw SQL with Prisma, migration workflows, or any question phrased as 'How do I do X in Prisma?'."
---

# Prisma ORM

## Goal
Provide practical, production-safe Prisma workflows for schema design, migrations, and type-safe querying across PostgreSQL (including Supabase), MySQL, and SQLite.

## Quick Start Workflow

1. Install Prisma dependencies.
2. Initialize Prisma project files.
3. Configure `DATABASE_URL` (and `DIRECT_URL` for Supabase/PostgreSQL where needed).
4. Model schema in `prisma/schema.prisma`.
5. Run migrations and generate Prisma Client.
6. Implement query logic with Prisma Client.

## Installation and Setup

Install:

```bash
npm install prisma --save-dev
npm install @prisma/client
```

Initialize:

```bash
npx prisma init
```

Expected structure:
- `prisma/schema.prisma`
- `prisma/migrations/`
- `.env`

Example `.env`:

```env
DATABASE_URL="postgresql://user:password@host:5432/dbname?schema=public"
DIRECT_URL="postgresql://user:password@host:5432/dbname?schema=public"
```

Use `DIRECT_URL` primarily for migrations/introspection when your main `DATABASE_URL` goes through a pooler (for example pgBouncer on Supabase).

## Schema Definition

Use `prisma/schema.prisma` to define datasource, generator, models, relations, enums, indexes, and constraints.

Field types commonly used:
- `String`, `Int`, `Boolean`, `DateTime`, `Float`, `Json`, `Bytes`

Common field/model attributes:
- `@id`, `@default`, `@unique`, `@relation`, `@updatedAt`
- `@@index`, `@@unique`

Modeling guidance:
- Use optional marker `?` for nullable/optional fields.
- Use relation scalar fields (for example `authorId`) plus relation fields (`author User @relation(...)`).
- Add indexes on frequently filtered/sorted columns.

For complete model/enum/relation examples, read:
- `references/schema-examples.md`

## Migrations

Development migration:

```bash
npx prisma migrate dev --name init
```

Generate client after schema changes when needed:

```bash
npx prisma generate
```

Production migration apply:

```bash
npx prisma migrate deploy
```

Reset local development database:

```bash
npx prisma migrate reset
```

View migration history/status:

```bash
npx prisma migrate status
```

When to use `db push` vs `migrate`:
- `npx prisma migrate dev`: creates migration files, applies them, and keeps auditable history for teams/environments.
- `npx prisma db push`: syncs schema directly to database without creating migration history.
- Prefer `migrate dev` and `migrate deploy` for production workflows.
- Use `db push` for fast prototyping, local spikes, and disposable databases.
- With Supabase poolers, keep `DIRECT_URL` available so schema engine operations avoid pooler limitations.

## Prisma Client Setup

Use a singleton Prisma client in Node.js/Next.js to avoid exhausting database connections during hot reload and serverless bursts.

```ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
	globalForPrisma.prisma ??
	new PrismaClient({
		log: ['warn', 'error']
	});

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

Recommended placement in Next.js projects:
- Keep singleton at `lib/prisma.ts`.
- Import it in route handlers, server actions, and backend-only modules.
- Do not instantiate PrismaClient inside each request handler.

## CRUD Operations

Core read/write methods to use:
- `create`
- `findUnique`
- `findFirst`
- `findMany`
- `update`
- `updateMany`
- `delete`
- `deleteMany`
- `upsert`

Query features to apply:
- Filtering: `where`, `AND`, `OR`, `NOT`, `contains`, `startsWith`, `in`, `gte`, `lte`
- Sorting: `orderBy`
- Pagination: `skip`, `take`, `cursor`
- Field projection: `select`
- Relations: `include`

For detailed CRUD, filtering, pagination, relation queries, and upsert examples, read:
- `references/queries.md`

## Advanced Queries

Support these patterns:
- Nested writes (create/update related records in one call)
- Transactions with `prisma.$transaction([])` or interactive transaction callback
- Raw SQL with `prisma.$queryRaw` and `prisma.$executeRaw`
- Aggregations: `_count`, `_sum`, `_avg`, `_min`, `_max`
- Grouping with `groupBy`

Safety rules:
- Prefer Prisma query builder first.
- Use raw SQL only for unsupported/complex cases.
- Use tagged template forms of raw queries and avoid unsafe string concatenation.

## Prisma with Supabase PostgreSQL

Supabase connection pattern:
- `DATABASE_URL`: use pooled URL (pgBouncer) for Prisma Client runtime traffic.
- `DIRECT_URL`: use direct connection URL for schema engine operations (migrations, introspection).

Supabase gotchas:
- Enable SSL in connection strings.
- Keep connection limits in mind, especially with serverless concurrency.
- Keep a singleton PrismaClient and avoid creating new clients per request.
- Do not put service role keys into Prisma URLs; use Postgres connection strings only.
- Prisma queries do not automatically carry Supabase JWT context for `auth.uid()` checks; RLS policies relying on request auth context usually need Supabase client APIs instead of Prisma.

Connection troubleshooting checklist:
- Error: too many connections -> verify singleton usage and prefer pooled `DATABASE_URL`.
- Migration/introspection issues through pooler -> ensure `DIRECT_URL` points to direct connection.
- TLS failures -> verify SSL params in connection string and runtime network policies.

## Prisma Studio

Use Prisma Studio as a local visual browser/editor:

```bash
npx prisma studio
```

Use Studio mainly for local inspection, manual verification, and seed-data spot checks.

## Seeding

Create `prisma/seed.ts` for baseline data and test fixtures.

Example `prisma/seed.ts`:

```ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
	const user = await prisma.user.upsert({
		where: { email: 'admin@example.com' },
		update: {},
		create: {
			email: 'admin@example.com',
			username: 'admin'
		}
	});

	await prisma.post.create({
		data: {
			title: 'Seeded post',
			content: 'Created by seed script',
			authorId: user.id
		}
	});
}

main()
	.catch((e) => {
		console.error(e);
		process.exit(1);
	})
	.finally(async () => {
		await prisma.$disconnect();
	});
```

Run:

```bash
npx prisma db seed
```

## Best Practices

- Keep PrismaClient singleton in backend runtime code.
- Catch and handle `PrismaClientKnownRequestError` and `PrismaClientValidationError`.
- Implement soft deletes with fields like `deletedAt DateTime?` and filter active records by default.
- Seed predictable baseline data via `prisma/seed.ts`.
- Use TypeScript with generated Prisma types for end-to-end type safety.
- Commit migration files to source control.
- Never hardcode credentials; load from `.env`.

## Response Style for This Skill

When using this skill:
- Ask for database provider and runtime context if missing (Next.js API routes, server actions, Express, workers).
- Prefer Prisma-first examples, then include raw SQL alternatives only when useful.
- Include migration command plus rollback/reset caution on schema-change questions.
- Explicitly explain `migrate dev` vs `db push` mechanics when users compare them.
- Include Supabase `DATABASE_URL` and `DIRECT_URL` guidance for Supabase/PostgreSQL requests.
- Include TypeScript-safe examples unless user requests JavaScript only.
