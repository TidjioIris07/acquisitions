# Acquisitions App - Dockerized Setup with Neon Database

This repository is configured with a fully containerized setup that supports distinct local development (using **Neon Local** with Docker) and production deployment (connecting to **Neon Cloud Database**).

---

## Environment & Architecture Overview

The application is containerized using a multi-stage `Dockerfile` with separate development and production targets:

1. **Development Target (`development`):**
   - Runs with `NODE_ENV=development`.
   - Uses `node --watch` for hot-reloading.
   - Spins up a local **Neon Local Proxy** service alongside the app.
   - Automatically supports ephemeral dev/test database instances.
   
2. **Production Target (`production`):**
   - Runs with `NODE_ENV=production`.
   - Stripped of development dependencies, optimized for minimal container footprint and security.
   - Directly connects to your secure **Neon Cloud Database** (no local proxy).

---

## 🚀 Local Development (with Neon Local)

Neon Local is the easiest way to run serverless-like Postgres setups locally, enabling ephemeral branches.

### 1. Configure Development Environment
Make sure you have a `.env.development` file in your root directory. A template is already provided:

```ini
PORT=3000
NODE_ENV=development
LOG_LEVEL=info

# Points to the local Neon proxy running in docker-compose
DATABASE_URL=postgres://postgres:postgres@neon-local:5432/acquisitions_dev?sslmode=disable

ARCJET_KEY=your_arcjet_key
```

### 2. Start the Development Containers
Run the development stack using the default `docker-compose.yml` (or `docker-compose.dev.yml`):

```bash
docker compose up --build
```

This command will:
1. Spin up the `neon-local` PostgreSQL proxy at `localhost:5432`.
2. Wait until the database health check passes.
3. Start the application in development watch-mode with your volume mounts active (allowing instant hot-reloading).

### 3. Run Database Migrations Locally
Once the containers are running, you can apply your Drizzle database migrations directly to your Neon Local instance:

```bash
# From your host machine:
npm run db:migrate
```

*Note: You can configure migrations to auto-apply on container startup by overriding the entrypoint if desired.*

---

## 🌐 Production Deployment (Neon Cloud)

In production, we connect directly to the Neon Serverless PostgreSQL Cloud instance. No proxy service is run in the production container network.

### 1. Configure Production Environment
The application uses the `.env.production` file to set up environment defaults:

```ini
PORT=3000
NODE_ENV=production
LOG_LEVEL=info

# Points directly to the serverless Neon Cloud Database
DATABASE_URL=postgresql://neondb_owner:npg_s3SrypBHiPJ6@ep-dark-mouse-a2qmrf5t-pooler.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require

ARCJET_KEY=your_production_arcjet_key
```

### 2. Run the Production Build
To test the production container locally, run:

```bash
docker compose -f docker-compose.prod.yml up --build
```

### 3. Dynamic Environment Injection
For secure deployments (e.g., AWS, GCP, Render, K8s), **do not commit production secrets to version control**. 

You can override the `DATABASE_URL` dynamically at runtime. Docker Compose automatically picks up host environment variables:

```bash
# Set your secure cloud URL on your production host
export DATABASE_URL="postgresql://user:password@endpoint.neon.tech/dbname?sslmode=require"

# Start the production stack
docker compose -f docker-compose.prod.yml up -d
```

---

## 🛠️ Summary of Docker & Environment Configuration Files

- `Dockerfile`: Multi-stage build containing `base`, `development`, and `production` steps.
- `.dockerignore`: Excludes local modules, logs, and sensitive `.env*` files from entering the Docker context.
- `.env.development`: Pre-configured connection string for Neon Local.
- `.env.production`: Configured to point directly to the remote serverless Neon Cloud Database.
- `docker-compose.yml` (and `docker-compose.dev.yml`): Configures the local app with the `neon-local` container.
- `docker-compose.prod.yml`: Configures the production app target with environment variable injection.
