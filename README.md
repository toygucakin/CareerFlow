# CareerFlow

**CareerFlow** is a hybrid CV Maker application designed specifically for software developers. It combines manually entered professional data with autonomous project tracking via GitHub and WakaTime APIs to create a "living portfolio".

## Key Features
- **Hybrid Data Entry**: Static personal/experience data + Autonomous project updates.
- **Tech Stack Analysis**: Automatic language and framework detection from repositories.
- **AI Summarization**: README files summarized into punchy project descriptions.
- **ATS-Friendly PDF**: 100% text-based PDF export with selectable text.
- **Dynamic QR Codes**: Link your PDF to your live, updated portfolio.

## Technical Stack
- **Framework**: Flutter (Multi-platform)
- **State Management**: Riverpod (Clean Architecture)
- **PDF Engine**: `pdf` & `printing` packages
- **APIs**: GitHub, WakaTime, Gemini (AI)

## Development
This project follows a branching strategy where `dev` is the active development branch and `main` contains stable releases.
