---
name: expressjs-architecture
description: "Use to scaffold and generate production-grade Express.js TypeScript server code with strict feature-based architecture, layered responsibilities, JWT auth, zod validation, standardized API responses, centralized error handling, and Prisma/Supabase-ready data access. Trigger when users ask to set up an Express project, add features/modules/routes/controllers/services/middlewares, generate REST API backend code, define Express folder structure or best practices, add auth/rate limiting/logging/uploads, or build Express with Prisma/Supabase/PostgreSQL."
---

# Expressjs Architecture

## Goal
Generate complete, ready-to-run Express.js TypeScript code and file scaffolding, not conceptual-only explanations.

## Required Architecture

Always use feature-based structure:

```text
src/
	features/
		auth/
			auth.routes.ts
			auth.controller.ts
			auth.service.ts
			auth.model.ts
			auth.middleware.ts
		users/
			users.routes.ts
			users.controller.ts
			users.service.ts
			users.model.ts
		posts/
		[feature]/
	middlewares/
		error.middleware.ts
		auth.middleware.ts
		validate.middleware.ts
		rateLimiter.middleware.ts
	config/
		db.ts
		env.ts
		logger.ts
	utils/
		ApiError.ts
		ApiResponse.ts
		asyncHandler.ts
	types/
		express.d.ts
	routes/
		index.ts
	app.ts
	server.ts
```

Never switch to type-based folders like controllers/services at root.

## Layer Responsibilities

Enforce strict separation:
- Routes: endpoints + middleware + controller wiring only.
- Controllers: request/response handling only, call service, return ApiResponse.
- Services: business rules and orchestration only, no req/res objects.
- Models: pure DB access (Prisma/raw SQL) only.
- Middlewares: reusable request interceptors and cross-cutting concerns.

Reject generated code that violates layer boundaries.

## Generation Rules

When user asks to set up project:
- Scaffold all base directories and files.
- Generate `package.json`, `tsconfig.json`, `.env.example`, `prisma/schema.prisma`, and `prisma/migrations/`.
- Generate working app/server/config/utils/middlewares/routes code.

When user asks to add feature:
- Generate complete feature files (routes, controller, service, model, optional feature middleware).
- Register the feature router in `src/routes/index.ts`.

When user asks to add endpoint:
- Update feature routes, controller, and service together.
- Add input validation schema and middleware for new endpoint.

When user asks to add middleware:
- Place it in `src/middlewares` for global/shared concerns.
- Place it in `src/features/<feature>` only if feature-specific.

Always:
- Generate complete code with imports/exports.
- Use naming `feature.layer.ts`.
- Add JSDoc comments to service methods.
- Avoid placeholder comments such as "TODO add logic".

## Enforced Conventions

- Error handling: `ApiError`, `asyncHandler`, global error middleware.
- Response shape: `{ success, message, data, errors }` via `ApiResponse`.
- Validation: zod schemas + `validate.middleware.ts`.
- Auth: JWT verification middleware; access + refresh token flow in auth service.
- Env: zod-validated config in `config/env.ts`; do not read `process.env` outside that module.
- TypeScript: strict mode, request augmentation in `types/express.d.ts`, explicit DTO interfaces.
- Logging: pino or winston; no console logging in production paths.
- Rate limiting: global and route-level use of `express-rate-limit`.

## Base File Boilerplate

Read `references/base-files.md` when generating or updating:
- `package.json`
- `tsconfig.json`
- `.env.example`
- `prisma/schema.prisma`
- `src/app.ts`
- `src/server.ts`
- `src/config/env.ts`
- `src/config/db.ts`
- `src/utils/ApiError.ts`
- `src/utils/ApiResponse.ts`
- `src/utils/asyncHandler.ts`
- `src/middlewares/error.middleware.ts`
- `src/middlewares/auth.middleware.ts`

## Feature Scaffolding Template

Read `references/feature-template.md` when generating features such as:
- auth
- users
- posts
- comments (nested under posts)
- notifications
- uploads (multer)

## Conventions Reference

Read `references/conventions.md` before generating code to verify naming, response format, error behavior, and import structure.

## Output Style for This Skill

When this skill is triggered:
- Prefer direct file creation/edits over abstract explanation.
- Return generated file set and route registration updates.
- If user gives partial request, infer missing boilerplate and generate it.
- Keep code production-ready and immediately runnable.
