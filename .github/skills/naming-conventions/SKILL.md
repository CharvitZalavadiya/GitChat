---
name: naming-conventions
description: "Use when creating, renaming, or reviewing files, folders, variables, functions, or components to enforce project naming conventions for Next.js, Express.js, and general code. Trigger phrases: naming conventions, file naming, function naming, enforce naming, naming rules."
---

# Naming Conventions Skill

## Purpose
Ensure all code, files, and folders follow consistent, clear, and framework-appropriate naming conventions across the project.

## File & Folder Naming

- **Next.js**:
  - Base files (e.g., `page.tsx`, `layout.tsx`, `error.tsx`, `loading.tsx`) must follow official Next.js conventions.
  - Components: `camelCase` (e.g., ` userProfile.tsx`, `loginForm.tsx`).
  - API routes: `camelCase` (e.g., `getUser.ts`).
  - Folders: `camelCase` or `PascalCase` (no kebab-case).

- **Express.js**:
  - Use dot notation for file roles:
    - Controllers: `auth.controller.js`, `user.controller.js`
    - Middleware: `auth.middleware.js`, `logger.middleware.js`
    - Models: `user.model.js`, `session.model.js`
    - Route files: `user.routes.js`, `auth.routes.js`
  - Folders: `camelCase` (no kebab-case).

- **Shared/General**:
  - Utility files: `camelCase` (e.g., `formatDate.ts`, `parseUser.ts`).
  - Config files: `camelCase` (e.g., `tailwindConfig.js`).

## Variable & Function Naming
- All function and variable names: `camelCase` (e.g., `getUserData`, `userProfile`).
- Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_USERS`, `API_URL`).
- Classes/Components: `PascalCase` (e.g., `UserProfile`, `AuthService`).

## Other Naming Rules
- No spaces, kebab-case, or special characters in any file, folder, or variable name.
- Avoid abbreviations unless they are widely recognized (e.g., `auth`, `req`, `res`).
- Use descriptive, intention-revealing names.
- For test files, use `.test` or `.spec` suffix (e.g., `userProfile.test.ts`).
- For environment files, use `.env` and `UPPER_SNAKE_CASE` for keys.

## Enforcement Checklist
- All new/renamed files and folders follow the above conventions.
- All new/renamed variables, functions, and classes follow the above conventions.
- No legacy or off-pattern names are introduced in new code.
