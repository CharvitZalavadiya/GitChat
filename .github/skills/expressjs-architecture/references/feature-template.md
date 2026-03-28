# Feature Template

## Goal
Generate all files for a feature in one pass with strict layer separation and route registration.

## Required Files per Feature

Given feature name example posts:
- src/features/posts/posts.routes.ts
- src/features/posts/posts.controller.ts
- src/features/posts/posts.service.ts
- src/features/posts/posts.model.ts
- src/features/posts/posts.validation.ts (or posts.middleware.ts if it exports middleware functions)

Always update:
- src/routes/index.ts

## Generation Checklist

1. Define DTO interfaces and zod schemas.
2. Define model methods for DB access.
3. Define service methods with business logic and JSDoc.
4. Define controller methods with asyncHandler and ApiResponse.
5. Define routes with validation middleware and auth middleware where required.
6. Register feature router in src/routes/index.ts.

## Boilerplate: Model

```ts
import { prisma } from '../../config/db';

export interface PostRecord {
  id: string;
  title: string;
  content: string | null;
  authorId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreatePostModelInput {
  title: string;
  content?: string;
  authorId: string;
}

export const postsModel = {
  create: async (input: CreatePostModelInput): Promise<PostRecord> => {
    return prisma.post.create({
      data: {
        title: input.title,
        content: input.content ?? null,
        authorId: input.authorId
      }
    }) as Promise<PostRecord>;
  },

  findById: async (id: string): Promise<PostRecord | null> => {
    return prisma.post.findUnique({ where: { id } }) as Promise<PostRecord | null>;
  },

  findMany: async (skip: number, take: number): Promise<PostRecord[]> => {
    return prisma.post.findMany({
      skip,
      take,
      orderBy: { createdAt: 'desc' }
    }) as Promise<PostRecord[]>;
  },

  updateById: async (id: string, data: Partial<CreatePostModelInput>): Promise<PostRecord> => {
    return prisma.post.update({ where: { id }, data }) as Promise<PostRecord>;
  },

  deleteById: async (id: string): Promise<void> => {
    await prisma.post.delete({ where: { id } });
  }
};
```

## Boilerplate: Service

```ts
import { ApiError } from '../../utils/ApiError';
import { postsModel, type CreatePostModelInput, type PostRecord } from './posts.model';

export interface CreatePostInput {
  title: string;
  content?: string;
  authorId: string;
}

export class PostsService {
  /** Create a new post for an author. */
  static async createPost(input: CreatePostInput): Promise<PostRecord> {
    return postsModel.create(input as CreatePostModelInput);
  }

  /** Get a post by its identifier. */
  static async getPostById(id: string): Promise<PostRecord> {
    const post = await postsModel.findById(id);
    if (!post) {
      throw new ApiError(404, 'Post not found');
    }
    return post;
  }

  /** List posts with pagination. */
  static async listPosts(page: number, limit: number): Promise<PostRecord[]> {
    const skip = (page - 1) * limit;
    return postsModel.findMany(skip, limit);
  }

  /** Update a post if it exists. */
  static async updatePost(id: string, input: Partial<CreatePostInput>): Promise<PostRecord> {
    await this.getPostById(id);
    return postsModel.updateById(id, input);
  }

  /** Delete a post if it exists. */
  static async deletePost(id: string): Promise<void> {
    await this.getPostById(id);
    await postsModel.deleteById(id);
  }
}
```

## Boilerplate: Controller

```ts
import type { Request, Response } from 'express';
import { ApiResponse } from '../../utils/ApiResponse';
import { asyncHandler } from '../../utils/asyncHandler';
import { PostsService } from './posts.service';

export const createPost = asyncHandler(async (req: Request, res: Response) => {
  const post = await PostsService.createPost({
    title: req.body.title,
    content: req.body.content,
    authorId: req.user!.id
  });

  return res.status(201).json(ApiResponse.success('Post created', post));
});

export const getPost = asyncHandler(async (req: Request, res: Response) => {
  const post = await PostsService.getPostById(req.params.postId);
  return res.status(200).json(ApiResponse.success('Post fetched', post));
});

export const listPosts = asyncHandler(async (req: Request, res: Response) => {
  const page = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 10);
  const posts = await PostsService.listPosts(page, limit);

  return res.status(200).json(
    ApiResponse.success('Posts fetched', {
      items: posts,
      page,
      limit
    })
  );
});

export const updatePost = asyncHandler(async (req: Request, res: Response) => {
  const post = await PostsService.updatePost(req.params.postId, req.body);
  return res.status(200).json(ApiResponse.success('Post updated', post));
});

export const deletePost = asyncHandler(async (req: Request, res: Response) => {
  await PostsService.deletePost(req.params.postId);
  return res.status(200).json(ApiResponse.success('Post deleted', { id: req.params.postId }));
});
```

## Boilerplate: Routes

```ts
import { Router } from 'express';
import { requireAuth } from '../../middlewares/auth.middleware';
import { strictRateLimiter } from '../../middlewares/rateLimiter.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { createPostSchema, updatePostSchema, listPostsSchema, postIdParamSchema } from './posts.validation';
import { createPost, getPost, listPosts, updatePost, deletePost } from './posts.controller';

export const postsRouter = Router();

postsRouter.get('/', validate(listPostsSchema), listPosts);
postsRouter.get('/:postId', validate(postIdParamSchema), getPost);
postsRouter.post('/', strictRateLimiter, requireAuth, validate(createPostSchema), createPost);
postsRouter.patch('/:postId', requireAuth, validate(updatePostSchema), updatePost);
postsRouter.delete('/:postId', requireAuth, validate(postIdParamSchema), deletePost);
```

## Boilerplate: Feature Validation (zod schemas)

```ts
import { z } from 'zod';

export const createPostSchema = z.object({
  body: z.object({
    title: z.string().trim().min(1).max(150),
    content: z.string().trim().max(5000).optional()
  }),
  params: z.object({}),
  query: z.object({})
});

export const updatePostSchema = z.object({
  body: z.object({
    title: z.string().trim().min(1).max(150).optional(),
    content: z.string().trim().max(5000).optional()
  }),
  params: z.object({
    postId: z.string().cuid2().or(z.string().uuid())
  }),
  query: z.object({})
});

export const listPostsSchema = z.object({
  body: z.object({}),
  params: z.object({}),
  query: z.object({
    page: z.coerce.number().int().min(1).optional(),
    limit: z.coerce.number().int().min(1).max(100).optional(),
    q: z.string().optional()
  })
});

export const postIdParamSchema = z.object({
  body: z.object({}),
  params: z.object({
    postId: z.string().cuid2().or(z.string().uuid())
  }),
  query: z.object({})
});
```

## Route Registry Update Pattern

```ts
import { postsRouter } from '../features/posts/posts.routes';

apiRouter.use('/posts', postsRouter);
```

## Auth Feature Template (register, login, refresh)

auth.model.ts:

```ts
import { prisma } from '../../config/db';

export const authModel = {
  findUserByEmail: (email: string) => prisma.user.findUnique({ where: { email } }),
  createUser: (email: string, passwordHash: string) =>
    prisma.user.create({ data: { email, passwordHash } }),
  updateRefreshToken: (userId: string, refreshToken: string | null) =>
    prisma.user.update({ where: { id: userId }, data: { refreshToken } })
};
```

auth.service.ts:

```ts
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { env } from '../../config/env';
import { ApiError } from '../../utils/ApiError';
import { authModel } from './auth.model';

export class AuthService {
  /** Register a new account and return signed tokens. */
  static async register(email: string, password: string): Promise<{ accessToken: string; refreshToken: string }> {
    const existing = await authModel.findUserByEmail(email);
    if (existing) throw new ApiError(409, 'Email already in use');

    const passwordHash = await bcrypt.hash(password, 12);
    const user = await authModel.createUser(email, passwordHash);
    return this.issueTokens(user.id, user.email);
  }

  /** Authenticate credentials and return signed tokens. */
  static async login(email: string, password: string): Promise<{ accessToken: string; refreshToken: string }> {
    const user = await authModel.findUserByEmail(email);
    if (!user) throw new ApiError(401, 'Invalid credentials');

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) throw new ApiError(401, 'Invalid credentials');

    return this.issueTokens(user.id, user.email);
  }

  /** Rotate refresh token and issue a new token pair. */
  static async refresh(refreshToken: string): Promise<{ accessToken: string; refreshToken: string }> {
    const payload = jwt.verify(refreshToken, env.JWT_REFRESH_SECRET) as { sub: string; email: string };
    const user = await authModel.findUserByEmail(payload.email);

    if (!user || user.refreshToken !== refreshToken) {
      throw new ApiError(401, 'Invalid refresh token');
    }

    return this.issueTokens(user.id, user.email);
  }

  private static async issueTokens(userId: string, email: string): Promise<{ accessToken: string; refreshToken: string }> {
    const accessToken = jwt.sign({ sub: userId, email }, env.JWT_ACCESS_SECRET, {
      expiresIn: env.JWT_ACCESS_EXPIRES_IN
    });

    const refreshToken = jwt.sign({ sub: userId, email }, env.JWT_REFRESH_SECRET, {
      expiresIn: env.JWT_REFRESH_EXPIRES_IN
    });

    await authModel.updateRefreshToken(userId, refreshToken);
    return { accessToken, refreshToken };
  }
}
```

auth.controller.ts:

```ts
import type { Request, Response } from 'express';
import { ApiResponse } from '../../utils/ApiResponse';
import { asyncHandler } from '../../utils/asyncHandler';
import { AuthService } from './auth.service';

export const register = asyncHandler(async (req: Request, res: Response) => {
  const tokens = await AuthService.register(req.body.email, req.body.password);
  return res.status(201).json(ApiResponse.success('Registered successfully', tokens));
});

export const login = asyncHandler(async (req: Request, res: Response) => {
  const tokens = await AuthService.login(req.body.email, req.body.password);
  return res.status(200).json(ApiResponse.success('Logged in successfully', tokens));
});

export const refresh = asyncHandler(async (req: Request, res: Response) => {
  const tokens = await AuthService.refresh(req.body.refreshToken);
  return res.status(200).json(ApiResponse.success('Token refreshed', tokens));
});
```

auth.routes.ts:

```ts
import { Router } from 'express';
import { strictRateLimiter } from '../../middlewares/rateLimiter.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { loginSchema, refreshSchema, registerSchema } from './auth.validation';
import { login, refresh, register } from './auth.controller';

export const authRouter = Router();

authRouter.post('/register', strictRateLimiter, validate(registerSchema), register);
authRouter.post('/login', strictRateLimiter, validate(loginSchema), login);
authRouter.post('/refresh', strictRateLimiter, validate(refreshSchema), refresh);
```

auth.validation.ts:

```ts
import { z } from 'zod';

const email = z.string().trim().email();
const password = z.string().min(8).max(128);

export const registerSchema = z.object({
  body: z.object({ email, password }),
  params: z.object({}),
  query: z.object({})
});

export const loginSchema = z.object({
  body: z.object({ email, password }),
  params: z.object({}),
  query: z.object({})
});

export const refreshSchema = z.object({
  body: z.object({ refreshToken: z.string().min(16) }),
  params: z.object({}),
  query: z.object({})
});
```

## Nested Feature Pattern (comments under posts, full)

Required files:
- src/features/comments/comments.routes.ts
- src/features/comments/comments.controller.ts
- src/features/comments/comments.service.ts
- src/features/comments/comments.model.ts
- src/features/comments/comments.validation.ts

```ts
// src/features/comments/comments.routes.ts
import { Router } from 'express';
import { requireAuth } from '../../middlewares/auth.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { createComment, listCommentsByPost } from './comments.controller';
import { createCommentSchema, postCommentsSchema } from './comments.validation';

export const commentsRouter = Router({ mergeParams: true });

commentsRouter.get('/', validate(postCommentsSchema), listCommentsByPost);
commentsRouter.post('/', requireAuth, validate(createCommentSchema), createComment);

// src/features/posts/posts.routes.ts
import { commentsRouter } from '../comments/comments.routes';

postsRouter.use('/:postId/comments', commentsRouter);
```

## Uploads Pattern (multer in users feature)

users.routes.ts:

```ts
import { Router } from 'express';
import multer from 'multer';
import { requireAuth } from '../../middlewares/auth.middleware';
import { strictRateLimiter } from '../../middlewares/rateLimiter.middleware';
import { uploadAvatar } from './users.controller';

const upload = multer({
  storage: multer.diskStorage({
    destination: 'uploads/avatars',
    filename: (_req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`)
  }),
  limits: { fileSize: 3 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/webp'];
    cb(null, allowed.includes(file.mimetype));
  }
});

export const usersRouter = Router();

usersRouter.post('/me/avatar', strictRateLimiter, requireAuth, upload.single('avatar'), uploadAvatar);
```

users.service.ts:

```ts
/** Persist avatar path for a user. */
static async setAvatar(userId: string, avatarPath: string): Promise<UserRecord> {
  return usersModel.updateAvatar(userId, avatarPath);
}
```

users.controller.ts:

```ts
export const uploadAvatar = asyncHandler(async (req: Request, res: Response) => {
  if (!req.file) {
    throw new ApiError(400, 'Avatar file is required');
  }

  const user = await UsersService.setAvatar(req.user!.id, req.file.path);
  return res.status(200).json(ApiResponse.success('Avatar uploaded', user));
});
```
