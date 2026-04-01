# Task Manager - Flutter App

A functional and visually polished Task Management app built with Flutter.

## Track
**Track B: Mobile Specialist** - Local database using SQLite (sqflite)

## Stretch Goal
None chosen. Focused on polishing core features.

## Setup Instructions
1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Clone the repository:
   git clone https://github.com/Prateek022/task-manager-flutter.git
3. Navigate to project folder:
   cd task-manager-flutter
4. Install dependencies:
   flutter pub get
5. Connect an Android device with USB debugging enabled
6. Run the app:
   flutter run

## Tech Stack
- Flutter & Dart
- SQLite (sqflite) for local database
- SharedPreferences for draft saving
- UUID for unique task IDs

## AI Usage Report

### Most Helpful Prompts
1. "Build a Flutter SQLite database helper class with a Task model that has title, description, due date, status and blockedBy fields"
2. "Build a home screen in Flutter showing a list of tasks with search bar and filter chips by status"
3. "Build a task form screen in Flutter with date picker, status dropdown, blocked by dropdown and a 2 second simulated loading state on save"

### AI Hallucination Example
Claude initially gave incorrect Flutter PATH setup instructions for Windows, suggesting `C:\flutter\bin` as the path. However the actual extracted folder was nested at `C:\flutter\flutter\bin`. The fix was manually checking the folder structure using `ls /c/flutter` in Git Bash and correcting the PATH accordingly.

Claude also initially generated an empty `database_helper.dart` file which caused all Task type errors across the project. This was caught by running `cat lib/database_helper.dart` and fixed by re-pasting the correct code.
