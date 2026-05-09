# Contributing to Grow~

Welcome! We follow a professional **Senior Developer Workflow** to maintain production stability.

## 1. Branching Strategy
- **`main`**: The stable production-ready branch. **Never push directly to main.**
- **`feature/*`**: For new features (e.g., `feature/admin-panel`).
- **`fix/*`**: For bug fixes (e.g., `fix/auth-leak`).

## 2. Development Process
1. **Sync**: Ensure your local `main` is up to date: `git pull origin main`.
2. **Branch**: Create your feature branch: `git checkout -b feature/xyz`.
3. **Commit**: Use descriptive, conventional commits: `feat: add inventory stock tracking`.
4. **Push**: Push your branch to GitHub: `git push -u origin feature/xyz`.

## 3. Pull Requests (PRs)
- All changes must go through a PR.
- **CI/CD Checks**: Every PR must pass the automated CI pipeline:
  - `Static Analysis` (Linting)
  - `Unit Tests` (Smoke tests)
  - `Build Check` (APK build verification)
- **Green Tick**: Do not merge until you see the green checkmark from GitHub Actions.

## 4. Merging
- Use **Squash and Merge** on GitHub to keep the commit history clean.
- Delete your feature branch after a successful merge.

## 5. Coding Standards
- Follow the official [Flutter Style Guide](https://docs.flutter.dev/cookbook/style).
- Ensure all new features are documented in the `README.md` if necessary.
- Add unit tests for critical business logic.

---
*Thank you for helping us Grow~ the IdeaLab ecosystem!*
