# CareerFlow Project Tracking

## Version History

### [v0.1.0] - 2026-03-07
#### Added
- Initial project structure using Clean Architecture.
- Core dependencies (Riverpod, PDF, Dio, etc.).
- Dark theme and Material 3 support.
- Git repository initialization and branch setup (`main`, `dev`).
- Documentation: `README.md`, `CareerFlow.md`, `.gitignore`.

---

## Development Roadmap & Suggestions

### Priority 1: Core Infrastructure
1. **GitHub API Client**: Implement the autonomous data fetching logic.
2. **Local Storage/DB**: Decide and integrate persistence (Supabase/Firebase).

### Priority 2: CV Modules
1. **Static Data Forms**: Personal info, Education, Experience.
2. **Dynamic Project Engine**: Repository analysis and tech stack detection.

### Priority 3: PDF Motor
1. **ATS Compatible Layout**: Text-node based PDF generation.
2. **Dynamic QR Code**: Live link embedding.

### Suggestions for Improvement:
- **Offline First**: Use a local database (like Isar) to cache data before syncing with cloud.
- **AI Token Management**: Ensure secure handling of Gemini/OpenAI keys.
- **Design System**: Use defined color tokens for tech-badges to maintain consistency.
