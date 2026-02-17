# Agentic AI Workflow Chatbot

A Python FastAPI backend implementing an intelligent agentic AI workflow chatbot with hierarchical team structure. The system uses a Supervisor agent to coordinate four specialized workers for weather intelligence, document understanding, meeting scheduling, and database queries.

## 🏗️ Architecture

```
User Question
     ↓
Supervisor (AI Reasoning Agent)
     ↓
Decision: Weather/Document/DB/Meeting Tool
     ↓
Execute Action
     ↓
Generate Final Response
```

### Agent Structure

- **Supervisor (Root Agent)**: Coordinates all specialized agents and routes queries intelligently
- **Agent 1: Weather Intelligence Agent**: Fetches real-time and historical weather data
- **Agent 2: Document + Web Intelligence Agent**: Reads documents (PDF) and falls back to Google Search
- **Agent 3: Meeting Scheduling Agent**: Schedules meetings with weather and conflict checks
- **Agent 4: NL2SQL Agent**: Converts natural language to PostgreSQL queries

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Database: **Supabase Session Pooler** (recommended; no local PostgreSQL needed) or any PostgreSQL connection URL
- API Keys:
  - Google Gemini API Key (from [Google AI Studio](https://aistudio.google.com/))
  - OpenWeatherMap API Key (from [OpenWeatherMap](https://openweathermap.org/api))

### Installation

1. **Clone and navigate to the project:**
```bash
cd path-to-the-project-folder
```

2. **Create virtual environment:**
```bash
python3.11 -m venv venv311
source venv311/bin/activate
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Set up environment variables:**
```bash
cp .env.example .env
# Edit .env and add your API keys
```

Required `.env` file:
```bash
# Google Gemini API Key (required)
GEMINI_API_KEY=your_gemini_api_key_here

# OpenWeatherMap API Key (required for WeatherAgent)
OPENWEATHERMAP_API_KEY=your_openweathermap_api_key_here

# PostgreSQL via Supabase Session Pooler (no local PostgreSQL needed)
# Use the Session pooler URL from Supabase Dashboard → Settings → Database
# If password contains @ or #, URL-encode as %40 and %23
DATABASE_URL=postgresql://postgres.YOUR_PROJECT_REF:YOUR_PASSWORD@aws-1-ap-southeast-1.pooler.supabase.com:5432/postgres

# Server Port (optional)
PORT=8000
```

5. **Set up database (creates tables using DATABASE_URL; no local PostgreSQL required):**
```bash
chmod +x setup_db.sh
./setup_db.sh
```

6. **Place your resume PDF:**
```bash
# Ensure resume.pdf is in the data folder
mkdir -p data
cp your_resume.pdf data/resume.pdf
```

7. **Run the server:**
```bash
python main.py
```

Server will start at `http://localhost:8000`

## 📋 API Endpoints

### Health Check
```bash
curl http://localhost:8000/health
```

### Chat Endpoint
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Your question here",
    "session_id": "your_session_id"
  }'
```

## 🧪 Testing

### Test 1: Weather Query
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What is the weather in Chennai today?",
    "session_id": "test123"
  }'
```

**Expected:** Returns current weather data for Chennai

### Test 2: Document Query
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What is my experience with Python?",
    "session_id": "test123"
  }'
```

**Expected:** Returns information from resume.pdf

### Test 3: Google Search Fallback
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Who is the CEO of Google?",
    "session_id": "test123"
  }'
```

**Expected:** Returns answer from Google Search (Gemini grounding)

### Test 4: SQL Query
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Show all meetings scheduled tomorrow",
    "session_id": "test123"
  }'
```

**Expected:** Returns meeting list with tomorrow's date calculated automatically

### Test 5: Meeting Scheduling
```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Schedule a meeting tomorrow at 2 PM called Team Review in Chennai",
    "session_id": "test123"
  }'
```

**Expected:** Checks weather, conflicts, and schedules meeting if conditions are met

## 🗄️ Database Setup

**Recommended: Supabase Session Pooler** (no local PostgreSQL required)

1. Create a project at [Supabase](https://supabase.com).
2. In **Settings → Database**, copy the **Session pooler** connection string (URI).
3. Put it in `.env` as `DATABASE_URL`. If your password contains `@` or `#`, URL-encode them as `%40` and `%23`.
4. Run setup to create tables:
```bash
chmod +x setup_db.sh
./setup_db.sh
```

### Database Schema

The `meetings` table schema:

```sql
CREATE TABLE meetings (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    meeting_date DATE NOT NULL,
    meeting_time TIME,
    reasoning TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Database Connection Issues

- **Connection refused / Peer auth failed:** Use the Supabase Session Pooler URL in `.env` (no local PostgreSQL needed).
- **Authentication failed:** Check that `DATABASE_URL` uses the correct pooler password. Encode special characters in the password (`@` → `%40`, `#` → `%23`).
- **Tables don't exist:** Run `./setup_db.sh` after setting `DATABASE_URL` in `.env`.

## 🔧 Configuration

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GEMINI_API_KEY` | Yes | Google Gemini API key from AI Studio |
| `OPENWEATHERMAP_API_KEY` | Yes | OpenWeatherMap API key |
| `DATABASE_URL` | Yes | PostgreSQL connection string (e.g. Supabase Session Pooler URI) |
| `PORT` | No | Server port (default: 8000) |

### File Structure

```
ragul/
├── main.py              # FastAPI application
├── agents.py            # Agent definitions
├── tools.py             # Tool implementations
├── database.py          # Database models
├── requirements.txt     # Python dependencies
├── init_db.sql         # Database schema
├── setup_db.sh         # Database setup script
├── Dockerfile          # Docker configuration
├── .env.example        # Environment variables template
├── .gitignore          # Git ignore rules
├── data/               # Document storage (resume.pdf)
└── README.md           # This file
```

## 📚 Agent Capabilities

### Agent 1: Weather Intelligence
- Fetches current and historical weather data
- Supports natural language queries: "today", "tomorrow", "yesterday"
- Uses OpenWeatherMap API

### Agent 2: Document + Web Intelligence
- Reads PDF documents (resume.pdf in `/data` folder)
- Answers queries based on document content
- **Automatic Google Search fallback** when information is not in document
- Uses Gemini API for document understanding

### Agent 3: Meeting Scheduling
- Checks tomorrow's weather
- Evaluates weather conditions (good/bad logic)
- Checks database for conflicts
- Creates meetings with reasoning

### Agent 4: NL2SQL
- Converts natural language to PostgreSQL queries
- Automatically calculates dates (tomorrow, today, next week)
- Read-only SELECT queries (safety)
- Returns formatted results

## 🐳 Docker Deployment

Build and run with Docker:

```bash
docker build -t agentic-chatbot .
docker run -p 8000:8000 --env-file .env agentic-chatbot
```



## 📝 License

This project is open source and available for use.

## 🙏 Acknowledgments

- Google ADK for agent orchestration
- Google Gemini for LLM capabilities
- OpenWeatherMap for weather data
- FastAPI for the web framework
