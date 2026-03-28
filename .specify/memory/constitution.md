# GitChat Constitution

## Core Principles

### I. Feature-First Modular Architecture (NON-NEGOTIABLE)
All backend features must follow feature-based modular structure and strict layering.
- Routes: endpoint registration and middleware wiring only
- Controllers: request/response orchestration only
- Services: business logic only
- Models: data access only
- Shared concerns stay in dedicated middleware/config/utils modules

Business logic in controllers is prohibited.

### II. Strong Type Safety and Type Organization (NON-NEGOTIABLE)
Type safety is a mandatory design constraint.
- Feature types must live in `src/types/<feature>/types.ts`
- Shared types must live in `src/types/common/types.ts`
- Object shapes must prefer interface over type aliases
- Enums must be string enum or const enum only; numeric enums are prohibited
- `any` is disallowed unless explicitly justified in review

### III. Standardized Error and Response Contracts (NON-NEGOTIABLE)
All API behavior must be predictable and uniform.
- Async controllers must use `asyncHandler`
- Controlled failures should use `ApiError`
- Global error middleware must be the final error boundary
- API responses must follow a single shape:
	- Success/Error envelope: `{ success, message, data, errors }`

### IV. Security and Configuration Discipline (NON-NEGOTIABLE)
Security-sensitive rules are mandatory.
- No hardcoded secrets
- Authentication uses JWT with access + refresh tokens
- Auth middleware is required for protected routes and must attach `req.user`
- `console.log` is prohibited in production code
- Circular dependencies are prohibited
- Environment values are sourced from root `.env` and must be handled consistently through configuration conventions in code

### V. Skill-Driven, Industry-Standard Delivery
Implementation quality must align with practical industry standards and modular scalability goals.
- Reuse established project skills and conventions wherever applicable
- Prefer simple, modular, scalable backend design over over-engineered solutions
- Use common extras (`jobs/`, `events/`, `queues/`, `lib/`, `scripts/`, `docs/`) when needed by feature scope

## Architecture, Stack, and Project Structure

### Project Identity
- Project: GitChat
- Purpose: An AI chat platform with git-inspired branches where each branch has different context

### Technology and Deployment
- Frontend: Next.js + TypeScript
- Backend: Express.js + TypeScript
- Database: Supabase PostgreSQL
- ORM: Prisma
- Frontend deployment: Vercel
- Backend deployment: AWS EC2 or Render (final host pending)

### Monorepo Structure

```text
apps/
	client/                  # Next.js frontend
	server/                  # Express.js backend
shared/                    # Shared TypeScript code/contracts
```

### Backend Source Structure

```text
src/
	features/
		<feature>/
			<feature>.routes.ts
			<feature>.controller.ts
			<feature>.service.ts
			<feature>.model.ts
	types/
		<feature>/
			types.ts
		common/
			types.ts
	middlewares/
	config/
	utils/
	routes/
	app.ts
	server.ts
```

### Test Placement
- Frontend tests: `apps/client/tests`
- Backend tests: `apps/server/tests`
- Tests are currently not enforced as a hard gate in the constitution at this stage

### Database Workflow
- Prisma client pattern is required
- Schema changes use `prisma migrate dev`

## Development Workflow and SpecKit Process

### Branching and Review
- Workflow: feature branch -> PR -> review -> merge to main
- All PRs must be reviewed before merge

### Commit and Code Quality
- Conventional commits are strongly preferred
- Industry best practices should drive implementation and review

### SpecKit Workflow (Required)
- Specs live under `.specify/`
- Standard flow:
	1. spec
	2. approve
	3. implement
	4. test
	5. review
	6. merge
- Use SpecKit CLI primarily
- Each approved spec should map to one feature folder or one clearly scoped change set
- Feature names in specs should align with feature folder names whenever possible

### Validation, Logging, and Tooling Status
- Validation/logging standards are intentionally lightweight right now
- Logging framework is not yet mandated
- Production rule still applies: no `console.log` in production code
- CI, strict TDD, and required test matrix are intentionally deferred for now

## Governance

This constitution is the source of truth for architecture and coding behavior in GitChat.

- Authority: Only the project owner may amend this constitution
- Amendment requirements:
	- rationale for change
	- impacted files/modules list
	- migration notes (if behavior or structure changes)
	- version bump
- Review standard: PR review must verify compliance with non-negotiable rules before merge

**Version**: 1.0.0 | **Ratified**: 2026-03-28 | **Last Amended**: 2026-03-28

## Quick Reference

| Area | Rule |
|---|---|
| Architecture | Feature-based structure with strict route/controller/service/model separation |
| Controllers | No business logic |
| Types | `src/types/<feature>/types.ts` + `src/types/common/types.ts` |
| Type style | Prefer interface for object shapes |
| Enums | String/const enums only, no numeric enums |
| Async flow | Use `asyncHandler` in async controllers |
| API contract | Always return `{ success, message, data, errors }` envelope |
| Security | No hardcoded secrets; JWT access+refresh pattern; protected routes require auth middleware |
| Production logging | No `console.log` |
| Dependencies | No circular dependencies |
| Repo model | Monorepo with `apps/client`, `apps/server`, `shared` |
| SpecKit | `.specify/` + spec -> approve -> implement -> test -> review -> merge |
