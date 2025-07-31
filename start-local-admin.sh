#!/bin/bash

echo "🍩 Starting Donut Shop with Local Admin Interface"

# Check if Docker and Docker Compose are available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed or not in PATH"
    exit 1
fi

# Use docker compose if available, otherwise fall back to docker-compose
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo "📦 Starting database and PgAdmin services..."
$COMPOSE_CMD up postgres pgadmin -d

echo "⏳ Waiting for database to be ready..."
while ! $COMPOSE_CMD exec -T postgres pg_isready -U postgres -d donut_shop &> /dev/null; do
    sleep 2
    echo "   Still waiting for database..."
done

echo "🌐 Starting API server..."
cd donut-admin-vue

# Check if npm dependencies are installed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing npm dependencies..."
    npm install
fi

# Start API server in background
echo "🚀 Starting API server on port 3001..."
npm run server &
API_PID=$!

# Wait a moment for the API to start
sleep 3

# Start Vue dev server
echo "🎨 Starting Vue development server on port 5173..."
npm run dev &
VUE_PID=$!

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Shutting down services..."
    kill $API_PID 2>/dev/null
    kill $VUE_PID 2>/dev/null
    cd ..
    $COMPOSE_CMD down
    echo "✅ All services stopped"
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM

echo ""
echo "✅ All services are running!"
echo ""
echo "🌍 Access points:"
echo "   📊 Admin Dashboard: http://localhost:5173"
echo "   🔧 API Server: http://localhost:3001"
echo "   🗄️  Database: localhost:5433"
echo "   🔧 PgAdmin: http://localhost:8080"
echo ""
echo "🔑 Database credentials:"
echo "   Admin user: admin_donut_db"
echo "   Password: donut_admin_2025"
echo ""
echo "🔑 PgAdmin credentials:"
echo "   Email: admin@donutshop.com"
echo "   Password: pgadmin_donut_2025"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for user interruption
wait