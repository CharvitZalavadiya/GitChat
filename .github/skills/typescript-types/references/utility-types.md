# Utility Types

## Contents
- Built-in utility types
- When to use each
- Custom utility types
- Recommended common set

## Built-in Utility Types

### Partial

Use when every property should be optional.

```ts
type UpdateUserDto = Partial<{
  name: string;
  avatar: string;
  bio: string;
}>;
```

### Required

Use when all optional properties become required.

```ts
type RequiredProfile = Required<UserProfile>;
```

### Pick

Use to select a subset of properties.

```ts
type UserIdentity = Pick<User, 'id' | 'email'>;
```

### Omit

Use to remove properties.

```ts
type SafeUser = Omit<User, 'passwordHash' | 'refreshToken'>;
```

### Readonly

Use to enforce immutable properties.

```ts
type ReadonlyConfig = Readonly<{ region: string; retries: number }>;
```

### Record

Use for keyed maps.

```ts
type RolePermissions = Record<UserRole, string[]>;
```

### Extract

Use to keep overlapping union members.

```ts
type ActiveStates = Extract<UserStatus, UserStatus.ACTIVE | UserStatus.INACTIVE>;
```

### Exclude

Use to remove union members.

```ts
type NonBannedStatus = Exclude<UserStatus, UserStatus.BANNED>;
```

### ReturnType

Use to infer function return type.

```ts
type CreateTokenResult = ReturnType<typeof createTokenPair>;
```

### Parameters

Use to infer function parameters tuple.

```ts
type CreateUserParams = Parameters<typeof createUser>;
```

## Custom Utility Types

### Nullable

```ts
export type Nullable<T> = T | null;
```

### Optional

```ts
export type Optional<T> = T | undefined;
```

### DeepPartial

```ts
export type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K];
};
```

### ValueOf

```ts
export type ValueOf<T> = T[keyof T];
```

### Prettify

```ts
export type Prettify<T> = {
  [K in keyof T]: T[K];
} & {};
```

### NonEmptyArray

```ts
export type NonEmptyArray<T> = [T, ...T[]];
```

## Recommended Common Set

Use these in src/types/common/types.ts by default:

```ts
export type ID = string;
export type Nullable<T> = T | null;
export type Optional<T> = T | undefined;
export type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K];
};
export type ValueOf<T> = T[keyof T];
export type Prettify<T> = { [K in keyof T]: T[K] } & {};
```

## Usage Guidance

- Prefer built-in utility types before inventing custom helpers.
- Keep custom utilities in src/types/common/types.ts.
- Use expressive names and export all shared utilities through src/types/index.ts.
- Avoid overly clever generic types that reduce readability.
