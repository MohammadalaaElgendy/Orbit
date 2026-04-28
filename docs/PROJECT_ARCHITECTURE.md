# Orbit Project Architecture

## Stack

* Flutter (latest stable)
* Provider (state management)
* MVVM architecture
* Feature-based structure
* Repository pattern
* Dependency Injection using Provider only (NO GetIt)
* Drift for local database
* Supabase for backend
* PowerSync for synchronization

## Platforms

Supported:

* Android
* iOS
* Windows
* macOS
* Linux

Not supported:

* Web

## Architecture Rules

UI Layer:

* Widgets only
* No business logic
* No direct database access
* No direct API access

ViewModel Layer:

* State management
* UI logic
* Uses ChangeNotifier

Repository Layer:

* Single source of truth
* Handles local and remote operations

Data Layer:

* Drift local storage
* Supabase remote storage
* PowerSync synchronization

Rule:
UI always reads from local database only.

Sync flow:
UI → ViewModel → Repository → Drift → PowerSync → Supabase

## Folder Structure

lib/
core/
features/
shared/

Feature structure:
data/
domain/
presentation/

## Dependency Injection

Use Provider and MultiProvider only.

Do NOT use:

* GetIt
* Riverpod
* Bloc

## Theme System

* Light theme
* Dark theme
* Centralized theme management

## UI Rules

* Rounded corners everywhere
* Soft glassmorphism only for:

  * headers
  * dialogs
  * main cards

Avoid glass in lists.

## Code Rules

* Clean code
* Reusable widgets
* Modular features
* Strong typing
* Null safety
* Scalable structure
