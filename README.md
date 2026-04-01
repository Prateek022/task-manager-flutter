# Task Manager - Flutter App

A functional and visually polished Task Management app built with Flutter.

## Track
**Track B: Mobile Specialist** - Local database using SQLite (sqflite)

## Features
- Create, Read, Update, Delete tasks
- Task fields: Title, Description, Due Date, Status, Blocked By
- Blocked tasks appear greyed out with a lock icon
- Draft saving when navigating away from task creation
- Search tasks by title
- Filter tasks by status (All, To-Do, In Progress, Done)
- 2-second simulated loading state on save with disabled button

## Setup Instructions
1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Clone the repository:
   git clone https://github.com/Prateek022/task-manager-flutter.git
3. Navigate to project folder:
   cd task-manager-flutter
4. Install dependencies:
   flutter pub get
5. Run the app:
   flutter run

## Tech Stack
- Flutter & Dart
- SQLite (sqflite) for local database
- SharedPreferences for draft saving
- UUID for unique task IDs

## AI Usage
- Used Claude (Anthropic) to generate the initial code structure, database helper, and UI components
- Claude helped debug PATH issues during Flutter installation
- All code was reviewed and tested manually on a Nothing Phone 2a
