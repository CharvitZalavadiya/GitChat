---
name: typescript-types
description: "Use to generate and organize production-ready TypeScript types, interfaces, enums, DTOs, and shared utility types using strict feature-based type folders and centralized exports. Trigger when users ask to add/create/define types, interfaces, enums, DTOs, payload types, request/response types, or ask whether to use type vs interface vs enum in Node.js/Express/Prisma/Supabase/Next.js TypeScript projects."
---

# Typescript Types

## Goal
Generate complete TypeScript type code and file updates, not concept-only guidance.

## Required Folder Convention

Always follow this structure:

```text
src/
	types/
		auth/
			types.ts
		users/
			types.ts
		posts/
			types.ts
		common/
			types.ts
		index.ts
```

Rules:
- One feature per folder under `src/types/<feature>`.
- One `types.ts` file per feature folder.
- Do not mix multiple features in one types file.
- Shared definitions go only in `src/types/common/types.ts`.
- Re-export all feature/common types from `src/types/index.ts`.

## Generation Workflow

When asked to add or create types for a feature:
1. Create or update `src/types/<feature>/types.ts`.
2. Organize definitions in section order:
	 - Enums
	 - Core interfaces
	 - DTO interfaces
	 - Response interfaces
	 - Utility types
3. Update `src/types/index.ts` exports.
4. If request touches shared contracts, update `src/types/common/types.ts`.
5. If request extends `req.user`, update `src/types/express.d.ts` (not feature file).

## Interface vs Type Rules

Use interface for object shapes by default:
- Entities
- DTO objects
- API response object shapes
- Class contracts
- Objects likely to be extended

Use type for:
- Unions
- Intersections
- Primitive aliases
- Tuples
- Conditional and mapped utility types
- Closed definitions that should not be declaration-merged

Do not replace object interfaces with type aliases when interface is sufficient.

## Enum Rules

Use string enum or const enum only:
- Feature-specific enums in feature `types.ts`.
- Shared enums in `src/types/common/types.ts`.

Prefer union type over enum only for tiny, local-only literal sets.

Never generate numeric enums.

## Naming Rules

- Interface names: PascalCase
- Type aliases: PascalCase
- Enum names: PascalCase
- Enum members: SCREAMING_SNAKE_CASE
- Folders: lowercase singular
- File names: lowercase, use `types.ts`

## Integration Rules

- Controllers consume DTO interfaces for request typing.
- Services return typed entities/response interfaces.
- Middlewares use enums for role/status checks.
- Prisma model contracts should map 1:1 with entity interfaces.
- Derive public response types from entities using `Omit`/`Pick` (for example strip `passwordHash`).
- Express request extension belongs in `src/types/express.d.ts` only.

Use standardized API success/error shapes in common types for cross-feature consistency.

## Required Outputs Per Task

If user asks for feature types, generate:
- `src/types/<feature>/types.ts` with complete definitions.
- `src/types/index.ts` export update.

If user asks for shared types, generate:
- `src/types/common/types.ts` updates.
- `src/types/index.ts` export update.

If user asks interface/type/enum design question:
- Provide decision with examples.
- If project files are present, also generate concrete type code in correct files.

## References To Load

Read these references when generating:
- `references/decision-guide.md`
- `references/feature-templates.md`
- `references/utility-types.md`

## Output Style For This Skill

When triggered:
- Prefer file creation/edits with complete imports/exports.
- Produce ready-to-use interfaces/types/enums with no placeholders.
- Keep exports clean and centralized via `src/types/index.ts`.
