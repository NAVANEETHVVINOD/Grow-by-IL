# Professional Engineering Workflow: Grow~ RC2+

To maintain production stability, we are adopting a **Senior-Grade Workflow**. No more pushing directly to `main`.

## 1. Branching Strategy
- **`main`**: The "Holy" branch. Always stable. Always buildable.
- **`feature/*`**: For new work (e.g., `feature/admin-inventory`).
- **`fix/*`**: For urgent bug fixes (e.g., `fix/auth-crash`).

## 2. The Development Loop
1. **Create a branch**: `git checkout -b feature/my-new-feature`
2. **Commit often**: `git commit -m "feat: added inventory list"`
3. **Push to GitHub**: `git push -u origin feature/my-new-feature`

## 3. The Pull Request (PR)
- Open a PR on GitHub from your feature branch to `main`.
- **CI/CD Automation**: GitHub Actions will automatically run:
  - `flutter analyze` (No lint errors)
  - `flutter test` (All tests pass)
  - `flutter build apk` (Ensures infrastructure hasn't broken)
- **Review**: (Self-review or peer review) Check the diff for schema drift or dead UI.

## 4. Merging
- Only merge if the **"Green Checkmark"** (CI passes) is present.
- Use **"Squash and Merge"** to keep the `main` history clean.

## 5. Branch Protection (Manual Step)
*Senior Developer Recommendation*: Go to GitHub Settings -> Branches -> Add Rule for `main`:
- [x] Require a pull request before merging.
- [x] Require status checks to pass before merging (select `build`).
- [x] Do not allow bypassing the above settings.

---
*By following this, we guarantee that RC1 stability is never accidentally broken by RC2 development.*
