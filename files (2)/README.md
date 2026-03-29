# Flodo — Your Task OS 🚀

> A premium, visually striking task management app built for the Flodo AI take-home assessment.

---

## Screenshots & Design Philosophy

Flodo uses a **dark cyberpunk-premium** aesthetic — deep navy base, electric purple & cyan accents, frosted glass cards, and smooth micro-animations. The goal: look like a product you'd pay for, not a tutorial app.

---

## Track & Stretch Goal

- **Track A — The Full-Stack Builder**
  - Frontend: Flutter & Dart (Riverpod state management)
  - Backend: Python FastAPI
  - Database: SQLite (via SQLAlchemy)

- **Stretch Goal 3 — Persistent Drag-and-Drop**
  - Tasks can be reordered by drag & drop on the main list
  - Custom `sort_order` field is saved to the database and persists on restart

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x, Dart |
| State Management | flutter_riverpod 2.x |
| Backend | Python FastAPI |
| Database | SQLite (SQLAlchemy ORM) |
| HTTP | Dio |
| Animations | flutter_animate |
| Fonts | Google Fonts (Syne + DM Sans + DM Mono) |
| Drafts | shared_preferences |

---

## Project Structure

```
flodo/
├── backend/
│   ├── main.py          # FastAPI app, all routes
│   ├── models.py        # SQLAlchemy Task model
│   ├── schemas.py       # Pydantic request/response schemas
│   ├── database.py      # SQLite engine + session
│   └── requirements.txt
│
└── flutter_app/
    └── lib/
        ├── main.dart
        ├── theme/
        │   └── app_theme.dart      # Full design system
        ├── models/
        │   └── task.dart           # Task data model
        ├── services/
        │   ├── api_service.dart    # Dio HTTP client
        │   └── draft_service.dart  # SharedPreferences draft persistence
        ├── providers/
        │   └── tasks_provider.dart # Riverpod AsyncNotifier
        ├── screens/
        │   ├── home_screen.dart    # Main list with D&D + search + filter
        │   └── task_form_screen.dart # Create/Edit with draft support
        └── widgets/
            └── task_card.dart      # Animated task card with blocked state
```

---

## Setup Instructions

### Prerequisites

- Python 3.10+
- Flutter 3.10+ (with Dart SDK)
- Android emulator / iOS simulator / physical device

---

### 1. Backend Setup

```bash
cd flodo/backend

# Create virtual environment
python -m venv venv
source venv/bin/activate        # Mac/Linux
# venv\Scripts\activate         # Windows

# Install dependencies
pip install -r requirements.txt

# Start the server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be running at `http://localhost:8000`.  
Visit `http://localhost:8000/docs` for the interactive Swagger UI.

---

### 2. Flutter App Setup

```bash
cd flodo/flutter_app

# Install dependencies
flutter pub get

# Run on Android emulator (default - uses 10.0.2.2)
flutter run

# Run on iOS simulator or web — update the base URL first:
# In lib/services/api_service.dart, change:
#   static const String _baseUrl = 'http://10.0.2.2:8000';
# To:
#   static const String _baseUrl = 'http://localhost:8000';
```

> **Note for physical Android device:** Replace `10.0.2.2` with your computer's local IP address (e.g., `192.168.1.x`). Make sure both devices are on the same network.

---

## Core Features

| Feature | Details |
|---|---|
| Task CRUD | Create, Read, Update, Delete with confirmation dialogs |
| 4-Field Model | Title, Description, Due Date, Status |
| Blocked By | Visual greyed-out card + lock icon when blocker isn't Done |
| Search | Debounced 300ms text search by title |
| Filter | Status filter chips (All / To-Do / In Progress / Done) |
| Drafts | Form state auto-saved via SharedPreferences; restored on reopen |
| 2s Simulated Delay | Loading spinner + disabled Save button during create/update |
| Drag & Drop Reorder | ReorderableListView with persistent sort_order saved to DB |
| Overdue Indicators | Red date + "OVERDUE" badge for past-due incomplete tasks |
| Stats Pill | Live "X / Y done" counter in the header |
| Error State | Friendly offline error with retry button |

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/tasks` | List all tasks (supports `?search=` and `?status=` params) |
| GET | `/tasks/{id}` | Get single task |
| POST | `/tasks` | Create task (2s delay) |
| PUT | `/tasks/{id}` | Update task (2s delay) |
| DELETE | `/tasks/{id}` | Delete task (unblocks dependents) |
| PATCH | `/tasks/reorder/bulk` | Bulk update sort_order for drag & drop |

---

## AI Usage Report

This project was built with significant assistance from Claude (Anthropic).

### Most Helpful Prompts

1. **"Build a FastAPI backend for a task management app with SQLite, supporting CRUD, a blocked_by relationship, and a sort_order field for drag-and-drop reordering. Include a 2-second simulated async delay on creates and updates."**
   — Generated clean, production-structured FastAPI code with proper async/await patterns and SQLAlchemy relationships.

2. **"Design a Flutter dark theme design system with a cyberpunk-premium aesthetic using Syne + DM Sans + DM Mono fonts, neon purple/cyan/green accents, and glassmorphism-style cards."**
   — Produced a cohesive, reusable `FlodoTheme` class that made the entire app visually consistent.

3. **"Implement Riverpod AsyncNotifier for task state with optimistic drag-and-drop reordering."**
   — Helped structure the state layer cleanly with proper `AsyncValue` guards and optimistic updates.

### AI Hallucination Example

When I asked for the `phosphor_flutter` icon usage, Claude referenced method signatures that were slightly off for the version in pubspec. The icons were declared with a style parameter that didn't exist in the pinned version. **Fix:** Switched to Material icons (`Icons.*`) which are always consistent, and used `phosphor_flutter` only where verified.

---

## Technical Decisions I'm Proud Of

**Riverpod AsyncNotifier with optimistic drag-and-drop:**  
When a user drags a task, the UI updates *instantly* (optimistic update to local state), then the reorder API call goes out in the background. This makes the drag feel snappy and native — no loading spinner needed for an operation the user just performed manually. If the API call fails, the next fetch will re-sync the true order from the server.

---

## Author

**Paryul Jain**  
Full-Stack Developer | Flutter + FastAPI  
📱 +91 7489673591  
🔗 [linkedin.com/in/paryul-jain-05533426b](https://www.linkedin.com/in/paryul-jain-05533426b/)
