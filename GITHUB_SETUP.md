# GitHub Repository Setup Guide

This guide will help you set up your Voice Mailer project on GitHub.

## Prerequisites

- Git installed on your computer
- GitHub account
- Flutter project ready (which you already have)

## Step 1: Initialize Git Repository

If you haven't already initialized Git in your project:

   ```bash
   cd VoiceMailer
   git init
   ```

## Step 2: Add Files to Git

```bash
# Add all files
git add .

# Make initial commit
git commit -m "Initial commit: Voice Mailer Flutter app"
```

## Step 3: Create GitHub Repository

1. Go to [GitHub](https://github.com)
2. Click the "+" icon in the top right
3. Select "New repository"
4. Fill in:
   - Repository name: `VoiceMailer`
   - Description: `A Flutter application for recording voice messages and sending them via email with speech-to-text transcription`
   - Make it Public or Private (your choice)
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
5. Click "Create repository"

## Step 4: Connect Local Repository to GitHub

```bash
# Add the remote origin (replace YOUR_USERNAME with your GitHub username)
   git remote add origin https://github.com/YOUR_USERNAME/VoiceMailer.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 5: Set Up Branch Protection (Optional but Recommended)

1. Go to your repository on GitHub
2. Click "Settings" tab
3. Click "Branches" in the left sidebar
4. Click "Add rule"
5. Set branch name pattern to `main`
6. Enable:
   - Require a pull request before merging
   - Require status checks to pass before merging
   - Require branches to be up to date before merging

## Step 6: Set Up GitHub Actions

The GitHub Actions workflow is already configured in `.github/workflows/flutter.yml`. It will automatically:
- Run tests on every push and pull request
- Build the app for different platforms
- Provide feedback on code quality

## Step 7: Configure Environment Variables (for CI/CD)

If you want to use GitHub Actions with your Azure API keys:

1. Go to repository Settings → Secrets and variables → Actions
2. Add new repository secrets:
   - `AZURE_API_KEY`: Your Azure Speech Services API key
   - `AZURE_REGION`: Your Azure region

## Step 8: Create Your First Issue

1. Go to the "Issues" tab in your repository
2. Click "New issue"
3. Use one of the templates we created
4. Create a simple issue like "Add app screenshots to README"

## Step 9: Create Your First Pull Request

1. Create a new branch: `git checkout -b feature/update-readme`
2. Make a small change (e.g., add your name to README)
3. Commit and push: 
   ```bash
   git add .
   git commit -m "feat: add maintainer information to README"
   git push origin feature/update-readme
   ```
4. Go to GitHub and create a Pull Request
5. Use the PR template we created

## Step 10: Set Up Project Wiki (Optional)

1. Go to your repository
2. Click "Wiki" tab
3. Create pages for:
   - Installation Guide
   - API Documentation
   - Troubleshooting

## Step 11: Enable GitHub Pages (Optional)

1. Go to Settings → Pages
2. Source: Deploy from a branch
3. Branch: `gh-pages` (create this branch if it doesn't exist)
4. Save

## Step 12: Add Topics and Description

1. Go to your repository
2. Click the gear icon next to "About"
3. Add topics: `flutter`, `dart`, `voice-recording`, `speech-to-text`, `email`
4. Update description if needed

## Step 13: Create Releases

When you're ready to release:

1. Go to "Releases" in your repository
2. Click "Create a new release"
3. Tag version: `v1.0.0`
4. Release title: `Voice Mailer v1.0.0`
5. Description: Copy from CHANGELOG.md
6. Upload build artifacts (APK, etc.)

## Next Steps

- Add screenshots to your README
- Write more detailed documentation
- Set up automated testing
- Create a project roadmap
- Engage with the community

## Troubleshooting

### If you get permission errors:
```bash
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

### If you need to change remote URL:
```bash
   git remote set-url origin https://github.com/YOUR_USERNAME/VoiceMailer.git
```

### If you need to force push (be careful):
```bash
git push -f origin main
```

---

**Remember**: Never commit sensitive information like API keys to your repository!
