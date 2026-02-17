#!/bin/bash
# Database setup script - creates tables via Python using DATABASE_URL (e.g. Supabase Session Pooler)
# No local PostgreSQL required. Set DATABASE_URL in .env before running.

set -e
cd "$(dirname "$0")"

if [ ! -f .env ]; then
    echo "No .env file found. Copy .env.example to .env and set DATABASE_URL (and other keys)."
    exit 1
fi

echo "Creating tables using DATABASE_URL from .env..."
python3 -c "
from dotenv import load_dotenv
load_dotenv()
from database import create_tables
create_tables()
print('Tables created successfully.')
"

echo "Database setup complete!"

