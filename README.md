# CyberSwahili

A Flutter application for reading Swahili blog content from Google Blogger with offline-first functionality.

## Features

- **Offline-First Architecture**: Cache blog posts locally using Isar database
- **Swahili Localization**: Full i18n support with Swahili as primary language
- **Modern UI**: Material 3 design with responsive layout
- **Content Categories**: Filter posts by labels/tags
- **HTML Rendering**: Native display of rich blog content
- **Pull-to-Refresh**: Manual content synchronization

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.11.5 or higher)
- Android Studio or VS Code
- Google Account with Blogger access

### 2. Google Blogger API Setup

#### Step 1: Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the Blogger API v3:
   - Go to "APIs & Services" > "Library"
   - Search for "Blogger API v3"
   - Click "Enable"

#### Step 2: Create API Key
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "API Key"
3. Copy the generated API key
4. (Optional) Restrict the API key:
   - Click on the API key
   - Under "Application restrictions", select "None"
   - Under "API restrictions", select "Restrict key" and check "Blogger API v3"

#### Step 3: Get Your Blog ID
1. Go to [Blogger](https://www.blogger.com/)
2. Open your blog
3. Go to Settings > Basic
4. Copy the "Blog ID" (usually a long number)

#### Step 4: Configure Environment Variables
1. Copy `.env.example` to `.env`
2. Update the `.env` file with your credentials:

```env
BLOGGER_API_KEY=your_actual_api_key_here
BLOG_ID=your_actual_blog_id_here
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Generate Code

```bash
# Generate localization files
flutter gen-l10n

# Generate Isar database schema
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

```bash
# For Android
flutter run -d android

# For iOS (macOS only)
flutter run -d ios

# For Web (note: limited Isar support)
flutter run -d chrome
```

## Project Structure

```
lib/
├── config/           # Configuration and environment setup
├── l10n/            # Localization files
├── models/          # Data models (BlogPost)
├── providers/       # Riverpod state management
├── repositories/    # Data access layer
├── services/        # External API services
├── ui/
│   ├── screens/     # Screen widgets
│   └── widgets/     # Reusable UI components
└── main.dart        # App entry point
```

## Architecture

### State Management
- **Riverpod**: Reactive state management with providers
- **StateNotifier**: Handles async operations and state transitions

### Data Layer
- **Repository Pattern**: Abstracts data sources (API + Local DB)
- **Offline-First**: Prioritizes cached data with background sync
- **Isar Database**: Fast NoSQL database for Flutter

### API Integration
- **Google Blogger API v3**: RESTful API for blog content
- **HTTP Client**: Dart's http package for network requests
- **Error Handling**: Graceful degradation for network failures

## Development

### Adding New Features
1. Create feature branch from `main`
2. Implement using TDD approach
3. Add tests for new functionality
4. Update documentation

### Code Generation
After modifying models or adding new localized strings:

```bash
flutter pub run build_runner build
flutter gen-l10n
```

### Testing
```bash
flutter test
```

## Security Notes

- API keys are stored in `.env` file (add to `.gitignore`)
- Never commit real API keys to version control
- Consider using secure storage for production apps
- Implement proper API key restrictions in Google Cloud Console

## Troubleshooting

### Common Issues

1. **"Blogger API not configured"**
   - Check that `.env` file exists and contains valid credentials
   - Ensure `.env` is not in `.gitignore`

2. **Build fails with Isar errors**
   - Run: `flutter pub run build_runner build --delete-conflicting-outputs`
   - Clean and rebuild: `flutter clean && flutter pub get`

3. **Network errors**
   - Verify API key has correct permissions
   - Check internet connection
   - Ensure blog is public or API key has proper access

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
