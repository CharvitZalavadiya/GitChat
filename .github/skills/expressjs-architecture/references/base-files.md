# Base Files Boilerplate

## Contents
- package.json
- tsconfig.json
- .env.example
- prisma/schema.prisma
- src/app.ts
- src/server.ts
- src/config/env.ts
- src/config/db.ts
- src/config/logger.ts
- src/utils/ApiError.ts
- src/utils/ApiResponse.ts
- src/utils/asyncHandler.ts
- src/middlewares/error.middleware.ts
- src/middlewares/auth.middleware.ts
- src/middlewares/validate.middleware.ts
- src/middlewares/rateLimiter.middleware.ts
- src/routes/index.ts
- src/types/express.d.ts

## package.json

```json
{
  "name": "express-api",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc -p tsconfig.json",
    "start": "node dist/server.js",
    "lint": "eslint .",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev",
    "prisma:deploy": "prisma migrate deploy"
  },
  "dependencies": {
    "@prisma/client": "latest",
    "cors": "latest",
    "express": "latest",
    "express-rate-limit": "latest",
    "helmet": "latest",
    "jsonwebtoken": "latest",
    "morgan": "latest",
    "pino": "latest",
    "pino-pretty": "latest",
    "zod": "latest"
  },
  "devDependencies": {
    "@types/cors": "latest",
    "@types/express": "latest",
    "@types/jsonwebtoken": "latest",
    "@types/morgan": "latest",
    "@types/node": "latest",
    "eslint": "latest",
    "prisma": "latest",
    "tsx": "latest",
    "typescript": "latest"
  }
}
```

## tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "outDir": "dist",
    "rootDir": "src",
    "types": ["node"]
  },
  "include": ["src", "prisma/seed.ts"],
  "exclude": ["dist", "node_modules"]
}
```

## .env.example

```env
NODE_ENV=development
PORT=4000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/appdb?schema=public
JWT_ACCESS_SECRET=replace_with_a_long_secret
JWT_REFRESH_SECRET=replace_with_a_long_secret
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
CORS_ORIGIN=http://localhost:3000
```

## prisma/schema.prisma

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id           String   @id @default(cuid())
  email        String   @unique
  passwordHash String
  refreshToken String?
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  posts Post[]
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  authorId  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  author User @relation(fields: [authorId], references: [id], onDelete: Cascade)

  @@index([authorId])
}
```

## src/config/env.ts

```ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(4000),
  DATABASE_URL: z.string().min(1),
  JWT_ACCESS_SECRET: z.string().min(16),
  JWT_REFRESH_SECRET: z.string().min(16),
  JWT_ACCESS_EXPIRES_IN: z.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: z.string().default('7d'),
  CORS_ORIGIN: z.string().default('*')
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  const issues = parsed.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`);
  throw new Error(`Invalid environment variables:\n${issues.join('\n')}`);
}

export const env = parsed.data;
```

## src/config/logger.ts

```ts
import pino from 'pino';
import { env } from './env';

export const logger = pino({
  level: env.NODE_ENV === 'production' ? 'info' : 'debug',
  transport:
    env.NODE_ENV === 'production'
      ? undefined
      : {
          target: 'pino-pretty',
          options: { colorize: true, translateTime: 'SYS:standard' }
        }
});
```

## src/config/db.ts

```ts
import { PrismaClient } from '@prisma/client';
import { env } from './env';
import { logger } from './logger';

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: ['warn', 'error']
  });

if (env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

export async function connectDb(): Promise<void> {
  await prisma.$connect();
  logger.info('Database connected');
}

export async function disconnectDb(): Promise<void> {
  await prisma.$disconnect();
  logger.info('Database disconnected');
}
```

## src/utils/ApiError.ts

```ts
export class ApiError extends Error {
  public readonly statusCode: number;
  public readonly errors: unknown[];

  constructor(statusCode: number, message: string, errors: unknown[] = []) {
    super(message);
    this.name = 'ApiError';
    this.statusCode = statusCode;
    this.errors = errors;
    Error.captureStackTrace(this, this.constructor);
  }
}
```

## src/utils/ApiResponse.ts

```ts
export interface ApiResponseShape<T> {
  success: boolean;
  message: string;
  data: T | null;
  errors: unknown[];
}

export class ApiResponse<T> {
  static success<T>(message: string, data: T): ApiResponseShape<T> {
    return {
      success: true,
      message,
      data,
      errors: []
    };
  }

  static error(message: string, errors: unknown[] = []): ApiResponseShape<null> {
    return {
      success: false,
      message,
      data: null,
      errors
    };
  }
}
```

## src/utils/asyncHandler.ts

```ts
import type { NextFunction, Request, Response } from 'express';

/**
 * Wrap async route handlers and forward rejections to global error middleware.
 */
export const asyncHandler =
  (
    fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>
  ) =>
  (req: Request, res: Response, next: NextFunction): void => {
    void fn(req, res, next).catch(next);
  };
```

## src/middlewares/validate.middleware.ts

```ts
import type { RequestHandler } from 'express';
import type { AnyZodObject } from 'zod';
import { ApiError } from '../utils/ApiError';

export const validate = (schema: AnyZodObject): RequestHandler => {
  return async (req, _res, next) => {
    const result = await schema.safeParseAsync({
      body: req.body,
      query: req.query,
      params: req.params
    });

    if (!result.success) {
      const errors = result.error.issues.map((issue) => ({
        path: issue.path.join('.'),
        message: issue.message
      }));
      return next(new ApiError(400, 'Validation failed', errors));
    }

    req.body = result.data.body;
    req.query = result.data.query;
    req.params = result.data.params;
    return next();
  };
};
```

## src/middlewares/rateLimiter.middleware.ts

```ts
import rateLimit from 'express-rate-limit';

export const globalRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests, please try again later.',
    data: null,
    errors: []
  }
});

export const strictRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false
});
```

## src/middlewares/auth.middleware.ts

```ts
import jwt from 'jsonwebtoken';
import type { RequestHandler } from 'express';
import { env } from '../config/env';
import { ApiError } from '../utils/ApiError';

interface JwtPayload {
  sub: string;
  email?: string;
  role?: string;
}

export const requireAuth: RequestHandler = (req, _res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return next(new ApiError(401, 'Missing or invalid authorization header'));
  }

  const token = authHeader.slice(7);

  try {
    const payload = jwt.verify(token, env.JWT_ACCESS_SECRET) as JwtPayload;
    req.user = {
      id: payload.sub,
      email: payload.email ?? '',
      role: payload.role ?? 'user'
    };
    return next();
  } catch {
    return next(new ApiError(401, 'Invalid or expired token'));
  }
};
```

## src/middlewares/error.middleware.ts

```ts
import type { ErrorRequestHandler } from 'express';
import { logger } from '../config/logger';
import { ApiError } from '../utils/ApiError';
import { ApiResponse } from '../utils/ApiResponse';

export const errorMiddleware: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof ApiError) {
    logger.warn({ err, statusCode: err.statusCode }, err.message);
    return res.status(err.statusCode).json(ApiResponse.error(err.message, err.errors));
  }

  logger.error({ err }, 'Unhandled server error');
  return res.status(500).json(ApiResponse.error('Internal server error'));
};
```

## src/routes/index.ts

```ts
import { Router } from 'express';
import { authRouter } from '../features/auth/auth.routes';
import { usersRouter } from '../features/users/users.routes';

export const apiRouter = Router();

apiRouter.use('/auth', authRouter);
apiRouter.use('/users', usersRouter);
```

## src/app.ts

```ts
import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import { env } from './config/env';
import { logger } from './config/logger';
import { errorMiddleware } from './middlewares/error.middleware';
import { globalRateLimiter } from './middlewares/rateLimiter.middleware';
import { apiRouter } from './routes';

export const app = express();

app.use(helmet());
app.use(cors({ origin: env.CORS_ORIGIN }));
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(globalRateLimiter);
app.use(
  morgan('combined', {
    stream: {
      write: (message) => logger.info(message.trim())
    }
  })
);

app.get('/health', (_req, res) => {
  return res.status(200).json({
    success: true,
    message: 'Server healthy',
    data: { uptime: process.uptime() },
    errors: []
  });
});

app.use('/api/v1', apiRouter);
app.use(errorMiddleware);
```

## Route-level strict limiter example (auth)

```ts
import { Router } from 'express';
import { strictRateLimiter } from '../../middlewares/rateLimiter.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { loginSchema } from './auth.middleware';
import { login } from './auth.controller';

export const authRouter = Router();

authRouter.post('/login', strictRateLimiter, validate(loginSchema), login);
```

## src/server.ts

```ts
import http from 'node:http';
import { app } from './app';
import { connectDb, disconnectDb } from './config/db';
import { env } from './config/env';
import { logger } from './config/logger';

const server = http.createServer(app);

async function bootstrap(): Promise<void> {
  await connectDb();

  server.listen(env.PORT, () => {
    logger.info(`Server listening on port ${env.PORT}`);
  });
}

async function shutdown(signal: string): Promise<void> {
  logger.info(`Received ${signal}, shutting down...`);

  server.close(async () => {
    await disconnectDb();
    logger.info('Shutdown complete');
    process.exit(0);
  });

  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10000).unref();
}

process.on('SIGINT', () => {
  void shutdown('SIGINT');
});

process.on('SIGTERM', () => {
  void shutdown('SIGTERM');
});

void bootstrap().catch((error) => {
  logger.error({ error }, 'Failed to bootstrap server');
  process.exit(1);
});
```

## src/types/express.d.ts

```ts
declare namespace Express {
  export interface UserContext {
    id: string;
    email: string;
    role: string;
  }

  export interface Request {
    user?: UserContext;
  }
}
```
