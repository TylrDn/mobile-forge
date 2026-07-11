# Release Checklist

Copy this checklist into the release PR description. Check off each item before proceeding to the next phase.

---

## Pre-Release

### Version and Changelog

- [ ] Determine the release version following semver: `vMAJOR.MINOR.PATCH`
- [ ] Run the release script to bump `app.json` version, iOS build number, and Android version code:
  ```bash
  bash scripts/release.sh <version>   # e.g. bash scripts/release.sh 1.2.0
  ```
- [ ] Verify `app.json` reflects the correct `version`, `ios.buildNumber`, and `android.versionCode`
- [ ] Add a changelog entry documenting all user-visible changes since the last release
- [ ] Confirm no `TODO`, `FIXME`, or `console.log` statements remain in changed files

### Code Quality

- [ ] All feature branches targeting this release have been merged to `develop`
- [ ] `develop` CI is green (lint + typecheck + test all passing)
- [ ] No open issues labeled `release-blocker`
- [ ] Dependency audit clean: `bun audit` (or equivalent) shows no high/critical vulnerabilities

### Device Smoke Test

- [ ] Install the **preview** build on a physical iOS device and verify core flows:
  - [ ] App launches without crash
  - [ ] Authentication flow completes successfully
  - [ ] Primary user journey (app-specific) works end-to-end
  - [ ] Deep links resolve correctly
  - [ ] Push notifications received (if applicable)
- [ ] Repeat smoke test on a physical Android device
- [ ] Test on the minimum supported OS versions (iOS 16, Android 10)

---

## Build

### Trigger Production Build

- [ ] Create a `release/<version>` branch from `develop`
- [ ] Open a PR targeting `main` with title `release: v<version>`
- [ ] PR approved by at least 1 team member
- [ ] PR merged to `main` (merge commit — not squash)
- [ ] EAS production build triggered automatically by the merge to `main`
  - Alternatively, trigger manually:
    ```bash
    eas build --platform all --profile production --non-interactive
    ```
- [ ] Monitor build status at [expo.dev/builds](https://expo.dev/builds)

### Verify Build Artifacts

- [ ] iOS build status: **Finished** (not errored or cancelled)
- [ ] Android build status: **Finished**
- [ ] Download the iOS `.ipa` and verify it installs on a test device
- [ ] Download the Android `.aab` and verify it installs via `adb` or Firebase App Distribution

---

## iOS Release

### TestFlight

- [ ] EAS Submit uploaded the build to App Store Connect (or trigger manually: `eas submit --platform ios`)
- [ ] Build visible in App Store Connect → TestFlight → Builds
- [ ] Build passes Apple's automated checks (no missing privacy manifests, valid entitlements)
- [ ] Internal TestFlight group notified and tested
- [ ] External TestFlight group (beta users) notified if applicable

### App Store Submission

- [ ] Release notes (What's New) written for this version in all supported languages
- [ ] Screenshots and preview videos up to date for all required device sizes
- [ ] App Privacy section in App Store Connect reflects any new data collection
- [ ] Age rating confirmed accurate
- [ ] Submit for App Store review
- [ ] App Store review approved

---

## Android Release

### Internal Test Track

- [ ] EAS Submit uploaded the build to Google Play (or trigger manually: `eas submit --platform android`)
- [ ] Build visible in Google Play Console → Internal Testing
- [ ] Internal testers install and verify the build
- [ ] No crashes reported in Android Vitals within 24h of internal distribution

### Production Track

- [ ] Promote build from Internal Testing → Production in Google Play Console
- [ ] Rollout percentage: start at 10–20%, monitor for 24h, then ramp to 100%
- [ ] Google Play review approved (if triggered)

---

## Post-Release

### Git Housekeeping

- [ ] Tag the release commit on `main`:
  ```bash
  git tag v<version>
  git push origin v<version>
  ```
- [ ] Back-merge `main` into `develop` to sync the version bump:
  ```bash
  git checkout develop
  git merge --no-ff origin/main -m "chore: merge release/v<version> back to develop"
  git push origin develop
  ```
- [ ] Delete the `release/<version>` branch

### Communication

- [ ] Update the Notion release log with version number, date, build numbers, and link to changelog
- [ ] Announce release in the team Slack channel with a summary of changes
- [ ] Notify support team of any known issues or changes that affect user-facing behavior

### Monitoring

- [ ] Confirm Sentry (or crash reporting tool) is receiving events from the new version
- [ ] Monitor crash-free session rate for 24h after full rollout
- [ ] Monitor ANR rate (Android) for 24h
- [ ] Check app store ratings for any sudden drop post-release
- [ ] Confirm no spike in support tickets related to the new version
