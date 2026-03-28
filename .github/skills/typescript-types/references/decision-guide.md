# Decision Guide

## Contents
- Fast decision flow
- Interface rules
- Type alias rules
- Enum rules
- Edge cases
- Anti-patterns

## Fast Decision Flow

1. Is it an object shape (entity, DTO, response, config)?
- Yes: use interface.
- No: continue.

2. Is it a union/intersection/primitive alias/tuple/conditional/mapped type?
- Yes: use type alias.
- No: continue.

3. Is it a fixed reusable value set used across files/features?
- Yes: use string enum or const enum.
- No: use union type for small local literal sets.

## Interface Rules

Use interface for:
- Domain objects and entities
- Request/response object contracts
- DTO bodies and parameter objects
- Contracts expected to be extended later

Example:

```ts
export interface UserProfile {
  id: string;
  email: string;
  name: string;
  createdAt: string;
}

export interface UpdateUserProfileDto {
  name?: string;
  avatar?: string;
}
```

## Type Alias Rules

Use type for:
- Primitive aliases
- Unions
- Intersections
- Tuples
- Utility/conditional/mapped patterns

Examples:

```ts
export type UserId = string;
export type SortOrder = 'asc' | 'desc';
export type AdminUser = UserProfile & { permissions: string[] };
export type Coordinates = [number, number];
export type IsString<T> = T extends string ? true : false;
```

## Enum Rules

Use enum when values are stable and reused broadly.

Use string enums only:

```ts
export enum UserRole {
  ADMIN = 'ADMIN',
  USER = 'USER',
  MODERATOR = 'MODERATOR'
}
```

Use const enum where compile-time inlining is acceptable:

```ts
export const enum Permission {
  READ = 'READ',
  WRITE = 'WRITE'
}
```

Use union type instead of enum for tiny local sets:

```ts
export type Direction = 'left' | 'right' | 'up' | 'down';
```

Never use numeric enums.

## Edge Cases

Generic interfaces:

```ts
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  errors?: string[];
}
```

Mapped/conditional utility types:

```ts
export type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};

export type NonNull<T> = T extends null | undefined ? never : T;
```

Constrained generic patterns:

```ts
export interface EntityWithId {
  id: string;
}

export type EntityMap<T extends EntityWithId> = Record<T['id'], T>;

export interface Repository<T extends EntityWithId> {
  findById(id: string): Promise<T | null>;
  save(entity: T): Promise<T>;
}
```

Error response shape recommendation:

```ts
export interface ApiErrorResponse {
  success: false;
  message: string;
  data: null;
  errors: Array<{ field?: string; message: string }>;
}
```

Declaration merging risk:
- Interface can merge by name across declarations.
- Use type when you need closed, non-merge behavior.

## Anti-Patterns

Avoid:

```ts
// Wrong for standard object entity shape
export type User = {
  id: string;
  email: string;
};
```

Prefer:

```ts
export interface User {
  id: string;
  email: string;
}
```

Avoid numeric enum:

```ts
// Wrong
export enum Role {
  Admin,
  User
}
```

Prefer string enum:

```ts
export enum Role {
  ADMIN = 'ADMIN',
  USER = 'USER'
}
```
