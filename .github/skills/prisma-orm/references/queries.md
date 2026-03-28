# Prisma Query Examples

## Contents
- PrismaClient singleton usage
- CRUD
- Filtering and sorting
- Pagination
- Select and include
- Nested writes
- Transactions
- Raw SQL
- Aggregations and groupBy
- Error handling and soft delete pattern

## PrismaClient Singleton Import

```ts
import { prisma } from './prismaClient';
```

## CRUD

Create:

```ts
await prisma.post.create({
  data: {
    title: 'Hello Prisma',
    content: 'First post',
    authorId: userId
  }
});
```

findUnique:

```ts
await prisma.user.findUnique({
  where: { email: 'alice@example.com' }
});
```

findFirst:

```ts
await prisma.post.findFirst({
  where: { published: true },
  orderBy: { createdAt: 'desc' }
});
```

findMany:

```ts
await prisma.post.findMany({
  where: { published: true }
});
```

update:

```ts
await prisma.post.update({
  where: { id: postId },
  data: { title: 'Updated title' }
});
```

updateMany:

```ts
await prisma.post.updateMany({
  where: { authorId: userId, published: false },
  data: { status: 'ARCHIVED' }
});
```

delete:

```ts
await prisma.post.delete({
  where: { id: postId }
});
```

deleteMany:

```ts
await prisma.post.deleteMany({
  where: { authorId: userId, published: false }
});
```

upsert:

```ts
await prisma.user.upsert({
  where: { email: 'alice@example.com' },
  create: { email: 'alice@example.com', username: 'alice' },
  update: { username: 'alice-updated' }
});
```

## Filtering, Sorting, Pagination

```ts
await prisma.post.findMany({
  where: {
    AND: [
      { authorId: userId },
      {
        OR: [
          { title: { contains: search, mode: 'insensitive' } },
          { content: { startsWith: prefix, mode: 'insensitive' } }
        ]
      },
      { views: { gte: 10, lte: 1000 } },
      { status: { in: ['PUBLISHED', 'ARCHIVED'] } }
    ],
    NOT: { deletedAt: { not: null } }
  },
  orderBy: [{ createdAt: 'desc' }, { title: 'asc' }],
  skip: 0,
  take: 20
});
```

Cursor pagination:

```ts
await prisma.post.findMany({
  where: { authorId: userId },
  orderBy: { createdAt: 'desc' },
  cursor: lastPostId ? { id: lastPostId } : undefined,
  skip: lastPostId ? 1 : 0,
  take: 20
});
```

## Select and Include

```ts
await prisma.post.findMany({
  where: { authorId: userId },
  select: {
    id: true,
    title: true,
    createdAt: true
  }
});
```

```ts
await prisma.post.findMany({
  where: { authorId: userId },
  include: {
    author: {
      select: { id: true, email: true, username: true }
    },
    tags: true
  }
});
```

## Nested Writes

```ts
await prisma.user.create({
  data: {
    email: 'new@example.com',
    username: 'new-user',
    profile: {
      create: { bio: 'Developer' }
    },
    posts: {
      create: [
        { title: 'Post A', content: 'A' },
        { title: 'Post B', content: 'B' }
      ]
    }
  },
  include: {
    profile: true,
    posts: true
  }
});
```

## Transactions

Array form:

```ts
await prisma.$transaction([
  prisma.post.create({ data: { title: 'Tx post', authorId: userId } }),
  prisma.user.update({ where: { id: userId }, data: { isActive: true } })
]);
```

Interactive form:

```ts
await prisma.$transaction(async (tx) => {
  const post = await tx.post.create({
    data: { title: 'Interactive tx', authorId: userId }
  });

  await tx.auditLog.create({
    data: { actorId: userId, action: 'CREATE_POST', entityId: post.id }
  });
});
```

## Raw SQL

Safe tagged template:

```ts
const rows = await prisma.$queryRaw<{ id: string; title: string }[]>`
  SELECT id, title
  FROM "Post"
  WHERE "authorId" = ${userId}
  ORDER BY "createdAt" DESC
  LIMIT 20
`;
```

Execute statement:

```ts
const affected = await prisma.$executeRaw`
  UPDATE "Post"
  SET "views" = "views" + 1
  WHERE "id" = ${postId}
`;
```

## Aggregations and GroupBy

```ts
const stats = await prisma.post.aggregate({
  where: { authorId: userId },
  _count: { id: true },
  _sum: { views: true },
  _avg: { views: true },
  _min: { createdAt: true },
  _max: { createdAt: true }
});
```

```ts
const grouped = await prisma.post.groupBy({
  by: ['status'],
  where: { authorId: userId },
  _count: { _all: true },
  _avg: { views: true },
  orderBy: { status: 'asc' }
});
```

## Error Handling

```ts
import { Prisma } from '@prisma/client';

try {
  await prisma.user.create({
    data: { email: 'alice@example.com', username: 'alice' }
  });
} catch (error) {
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    if (error.code === 'P2002') {
      throw new Error('Unique constraint violation');
    }
  }

  if (error instanceof Prisma.PrismaClientValidationError) {
    throw new Error('Invalid Prisma query input');
  }

  throw error;
}
```

## Soft Deletes Pattern

Use `deletedAt DateTime?` and default queries that exclude deleted records:

```ts
await prisma.post.findMany({
  where: {
    authorId: userId,
    deletedAt: null
  }
});
```
