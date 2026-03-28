# Conventions

## Naming and File Rules

- Use feature-based folders under src/features.
- Use file naming pattern feature.layer.ts.
- Keep global middleware in src/middlewares.
- Keep shared utilities in src/utils.
- Keep environment access centralized in src/config/env.ts.

## Layer Responsibility Rules

- routes: endpoint declaration and middleware attachment only.
- controllers: req/res mapping only.
- services: business logic only.
- models: data access only.
- middlewares: reusable cross-cutting logic.

Reject generated output that mixes these responsibilities.

## Standard API Response

Every endpoint returns:

```json
{
  "success": true,
  "message": "Human-readable message",
  "data": {},
  "errors": []
}
```

Failures return:

```json
{
  "success": false,
  "message": "Error message",
  "data": null,
  "errors": [
    {
      "path": "field",
      "message": "validation detail"
    }
  ]
}
```

## Error Handling Rules

- Throw ApiError from services/middlewares for controlled failures.
- Wrap controllers with asyncHandler.
- Handle all uncaught errors in error.middleware.ts.
- Log errors with logger (pino or winston), not console.log.

## Validation Rules

- Validate every write endpoint and any filtered read endpoint.
- Use zod schemas grouped by feature in feature validation files.
- Apply validate middleware before controller handler.

## Auth and Tokens

- Use Bearer access token verification middleware.
- Attach resolved user context to req.user.
- Keep access/refresh token generation and refresh flow in auth service.
- Protect sensitive routes with requireAuth.

## Environment Rules

- Validate env with zod in config/env.ts.
- Import env object from config/env.ts everywhere.
- Never read process.env directly in features/services/controllers.

## TypeScript Rules

- Use strict mode.
- Use explicit interfaces for DTOs and service contracts.
- Extend Express Request type in src/types/express.d.ts.
- For protected routes guarded by requireAuth, it is acceptable to assert req.user is defined.

## Logging Rules

- Use pino or winston.
- Add request logging middleware in app.ts.
- Add structured context for errors in error middleware.

## Rate Limiting Rules

- Apply global limiter in app.ts.
- Apply stricter limiter on auth and upload routes.
- Route order should be strictRateLimiter -> auth (if needed) -> validate -> controller.

## Generation Decision Rules

When user asks setup:
- Generate package.json, tsconfig.json, .env.example, prisma/schema.prisma, base src files, and common middlewares.
- Generate route registry and sample health endpoint.

When user asks add feature:
- Generate full feature file set and route registration.

When user asks add endpoint:
- Update route + controller + service (+ model when needed) together.

When user asks add middleware:
- Generate middleware file and integrate into app/router.

## Quality Checklist

- No placeholder comments for critical logic.
- No layer leaks (for example Prisma calls in controller).
- No direct process.env outside env module.
- No console.log in production code paths.
- Route index updated for all new feature routers.
- Service methods include brief JSDoc comments.
