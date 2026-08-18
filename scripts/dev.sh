#!/bin/bash

echo "🚀 Starting Acquisition App in Development Mode"
echo "================================================"

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "❌ Error: .env.development file not found!"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker Desktop and try again."
    exit 1
fi

# Create .neon_local directory
mkdir -p .neon_local

# Add .neon_local to .gitignore
if ! grep -q ".neon_local/" .gitignore 2>/dev/null; then
    echo ".neon_local/" >> .gitignore
    echo "✅ Added .neon_local/ to .gitignore"
fi

echo ""
echo "📦 Starting Neon Local..."
echo "   - Neon Local will create an ephemeral database branch"
echo ""

docker compose -f docker-compose.dev.yml up -d neon-local

if [ $? -ne 0 ]; then
    echo "❌ Failed to start Neon Local!"
    exit 1
fi

echo "⏳ Waiting for Neon Local to become healthy..."

until docker compose -f docker-compose.dev.yml exec -T neon-local pg_isready -U postgres -h 127.0.0.1 -p 5432 >/dev/null 2>&1
do
    sleep 2
done

echo "✅ Neon Local is ready!"

echo ""
echo "📜 Applying latest schema with Drizzle..."
npm run db:migrate

if [ $? -ne 0 ]; then
    echo "❌ Database migration failed!"
    exit 1
fi

echo "✅ Database migration completed!"

echo ""
echo "🚀 Starting development application..."
echo ""

docker compose -f docker-compose.dev.yml up --build app

echo ""
echo "🎉 Development environment started!"
echo "   Application: http://localhost:3000"
echo "   Database: postgres://neon:npg@localhost:5432/neondb"