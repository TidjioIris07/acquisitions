# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Development Commands

Run the following commands from the project root:

- **Start Development Server**: `npm run dev` (runs the server in watch mode using `node --watch src/index.js`)
- **Linting**:
  - Run ESLint: `npm run lint`
  - Automatically fix lint errors: `npm run lint:fix`
- **Formatting**:
  - Format code with Prettier: `npm run format`
  - Check formatting: `npm run format:check`
- **Database Migrations & Tools**:
  - Generate migrations from schema changes: `npm run db:generate`
  - Apply migrations to the database: `npm run db:migrate`
  - Launch Drizzle Studio (database explorer): `npm run db:studio`
- **Testing**:
  - Note: There are currently no tests or test runners configured in `package.json`, although ESLint is configured to support Jest/Mocha globals for a `tests/**/*.js` pattern.

## Code Architecture

The project is built on Node.js using native ES Modules (`"type": "module"`). It uses Express.js as the web framework and Drizzle ORM to interface with a Neon serverless PostgreSQL database.

### Path Aliases / Import Mapping

Subpath imports are mapped using the `"imports"` field in `package.json`. Always use these aliases when importing modules instead of relative paths:

- `#config/*` -> `./src/config/*`
- `#controllers/*` -> `./src/controllers/*`
- `#middleware/*` -> `./src/middleware/*`
- `#models/*` -> `./src/models/*`
- `#routes/*` -> `./src/routes/*`
- `#services/*` -> `./src/services/*`
- `#utils/*` -> `./src/utils/*`
- `#validations/*` -> `./src/validations/*`

### Architectural Layers

- **Routing Layer (`src/routes/`)**: Receives incoming requests and mounts the appropriate controller handlers (e.g., `auth.route.js`).
- **Validation Layer (`src/validations/`)**: Defines structural payload schemas using Zod (e.g., `auth.validation.js`).
- **Controller Layer (`src/controllers/`)**: Handles request validation, extracts parameters, coordinates with services, manages response cookies, and structures responses (e.g., `auth.controller.js`).
- **Service Layer (`src/services/`)**: Enforces core business logic, orchestrates database interactions via Drizzle, and manages password hashing (e.g., `auth.service.js`).
- **Database Models (`src/models/`)**: Defines Drizzle database schemas and relationships (e.g., `user.model.js`).
- **Database Client (`src/config/database.js`)**: Exports the configured Drizzle ORM client using Neon serverless connection.
- **Logger Config (`src/config/logger.js`)**: Exports a customized Winston logger writing JSON-formatted logs to `logs/error.log` and `logs/combined.log` (with colorized terminal output in non-production environments).
- **Utility Layer (`src/utils/`)**: Provides standard helpers for:
  - Cookie management (`cookies.js`)
  - Zod error formatting (`format.js`)
  - JWT creation and verification (`jwt.js`)
