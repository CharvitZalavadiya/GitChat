# Feature Templates

## Contents
- Folder structure
- auth types template
- users types template
- posts types template
- notifications types template
- uploads types template
- common types template
- index exports template
- express request extension template

## Folder Structure

```text
src/types/
  auth/types.ts
  users/types.ts
  posts/types.ts
  notifications/types.ts
  uploads/types.ts
  common/types.ts
  index.ts
  express.d.ts
```

## auth template (src/types/auth/types.ts)

```ts
import type { Request } from 'express';

// Enums
export enum TokenType {
  ACCESS = 'ACCESS',
  REFRESH = 'REFRESH'
}

export enum AuthProvider {
  LOCAL = 'LOCAL',
  GOOGLE = 'GOOGLE',
  GITHUB = 'GITHUB'
}

// Core Interfaces
export interface AuthUser {
  id: string;
  email: string;
  role: string;
  provider: AuthProvider;
}

// DTO Interfaces
export interface RegisterDto {
  email: string;
  password: string;
  name: string;
}

export interface LoginDto {
  email: string;
  password: string;
}

// Response Interfaces
export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface JwtPayload {
  sub: string;
  email: string;
  role: string;
  iat: number;
  exp: number;
}

export interface AuthResponse {
  user: AuthUser;
  tokens: AuthTokens;
}

// Utility Types
export type AuthenticatedRequest = Request & { user: AuthUser };
```

## users template (src/types/users/types.ts)

```ts
// Enums
export enum UserRole {
  ADMIN = 'ADMIN',
  USER = 'USER',
  MODERATOR = 'MODERATOR'
}

export enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  BANNED = 'BANNED'
}

// Core Interfaces
export interface User {
  id: string;
  email: string;
  name: string;
  role: UserRole;
  status: UserStatus;
  createdAt: string;
  updatedAt: string;
}

export interface UserProfile extends User {
  bio?: string;
  avatar?: string;
  lastLoginAt?: string;
}

// DTO Interfaces
export interface CreateUserDto {
  email: string;
  password: string;
  name: string;
  role?: UserRole;
}

export type UpdateUserDto = Partial<Pick<UserProfile, 'name' | 'bio' | 'avatar'>>;

// Response Interfaces
export type UserResponse = Omit<User, 'password'>;

export interface PaginatedUsers {
  data: UserResponse[];
  total: number;
  page: number;
  limit: number;
}

// Utility Types
export type UserIdentifier = Pick<User, 'id' | 'email'>;
```

## posts template (src/types/posts/types.ts)

```ts
// Enums
export enum PostStatus {
  DRAFT = 'DRAFT',
  PUBLISHED = 'PUBLISHED',
  ARCHIVED = 'ARCHIVED'
}

// Core Interfaces
export interface PostAuthor {
  id: string;
  name: string;
}

export interface Post {
  id: string;
  title: string;
  content: string;
  status: PostStatus;
  authorId: string;
  author?: PostAuthor;
  createdAt: string;
  updatedAt: string;
}

// DTO Interfaces
export interface CreatePostDto {
  title: string;
  content: string;
}

export interface UpdatePostDto {
  title?: string;
  content?: string;
  status?: PostStatus;
}

export interface PostsQueryDto {
  page?: number;
  limit?: number;
  q?: string;
  status?: PostStatus;
  authorId?: string;
}

// Response Interfaces
export interface PostsResponse {
  data: Post[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// Utility Types
export type PostPreview = Pick<Post, 'id' | 'title' | 'status' | 'createdAt'>;
```

## notifications template (src/types/notifications/types.ts)

```ts
// Enums
export enum NotificationType {
  SYSTEM = 'SYSTEM',
  COMMENT = 'COMMENT',
  MENTION = 'MENTION'
}

export enum NotificationStatus {
  UNREAD = 'UNREAD',
  READ = 'READ'
}

// Core Interfaces
export interface Notification {
  id: string;
  userId: string;
  type: NotificationType;
  status: NotificationStatus;
  message: string;
  createdAt: string;
}

// DTO Interfaces
export interface CreateNotificationDto {
  userId: string;
  type: NotificationType;
  message: string;
}

// Response Interfaces
export interface NotificationsResponse {
  data: Notification[];
  unreadCount: number;
}
```

## uploads template (src/types/uploads/types.ts)

```ts
// Enums
export enum UploadMimeType {
  IMAGE_JPEG = 'image/jpeg',
  IMAGE_PNG = 'image/png',
  IMAGE_WEBP = 'image/webp'
}

// Core Interfaces
export interface UploadedFile {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: UploadMimeType;
  size: number;
  filename: string;
  path: string;
}

// DTO Interfaces
export interface UploadAvatarDto {
  userId: string;
}

// Response Interfaces
export interface UploadResponse {
  url: string;
  filename: string;
}
```

## common template (src/types/common/types.ts)

```ts
// Core Interfaces
export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  errors?: string[];
}

export interface ApiErrorResponse {
  success: false;
  message: string;
  data: null;
  errors: Array<{ field?: string; message: string }>;
}

export interface PaginationQuery {
  page: number;
  limit: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// Utility Types
export type ID = string;
export type Nullable<T> = T | null;
export type Optional<T> = T | undefined;
export type DeepPartial<T> = { [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K] };
```

## Prisma mapping pattern

Use entity interfaces to mirror persisted model fields and map to public response types:

```ts
// Persisted shape
export interface UserEntity {
  id: string;
  email: string;
  name: string;
  passwordHash: string;
  createdAt: string;
  updatedAt: string;
}

// API-safe response shape
export type UserResponse = Omit<UserEntity, 'passwordHash'>;
```

## DTO transformation pattern

```ts
export type CreateUserDto = Pick<User, 'email' | 'name'> & { password: string };
export type UpdateUserDto = Partial<Pick<UserProfile, 'name' | 'bio' | 'avatar'>>;
export type PublicPost = Omit<Post, 'authorId'> & { author: PostAuthor };
```

## index exports template (src/types/index.ts)

```ts
export * from './auth/types';
export * from './users/types';
export * from './posts/types';
export * from './notifications/types';
export * from './uploads/types';
export * from './common/types';
```

## express request extension template (src/types/express.d.ts)

```ts
import type { AuthUser } from './auth/types';

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
      requestId?: string;
    }
  }
}

export {};
```
