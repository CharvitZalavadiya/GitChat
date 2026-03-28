# Prisma Schema Examples

## Contents
- Datasource and generator setup
- Data types and field attributes
- Enums
- One-to-many (User -> Post)
- One-to-one (User -> Profile)
- Many-to-many (Post <-> Tag)
- Optional vs required fields
- Indexes and unique constraints

## Base Datasource and Generator

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}
```

## Rich Model Example

```prisma
enum Role {
  USER
  ADMIN
}

enum PostStatus {
  DRAFT
  PUBLISHED
  ARCHIVED
}

model User {
  id          String    @id @default(cuid())
  email       String    @unique
  username    String    @unique
  role        Role      @default(USER)
  isActive    Boolean   @default(true)
  age         Int?
  rating      Float?
  metadata    Json?
  avatarBytes Bytes?
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  deletedAt   DateTime?

  profile     Profile?
  posts       Post[]

  @@index([createdAt])
  @@index([role, isActive])
}

model Profile {
  id        String   @id @default(cuid())
  bio       String?
  website   String?
  userId    String   @unique
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
}

model Post {
  id          String     @id @default(cuid())
  title       String
  content     String?
  status      PostStatus @default(DRAFT)
  published   Boolean    @default(false)
  views       Int        @default(0)
  authorId    String
  author      User       @relation(fields: [authorId], references: [id], onDelete: Cascade)
  tags        Tag[]
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt

  @@index([authorId])
  @@index([status, createdAt])
  @@unique([authorId, title])
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]
}
```

## Relationship Notes

- One-to-many: `User.posts` with relation scalar `Post.authorId`.
- One-to-one: `Profile.userId` is `@unique` and references `User.id`.
- Many-to-many: implicit relation via `Post.tags` and `Tag.posts`.
- Optional fields use `?` (for example `content String?`, `deletedAt DateTime?`).

## Provider Variants

PostgreSQL:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

MySQL:

```prisma
datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}
```

SQLite:

```prisma
datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}
```
