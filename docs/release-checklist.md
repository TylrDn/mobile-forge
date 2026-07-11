# Release Checklist

## Pre-Release

- [ ] All feature branches merged to `develop`
- [ ] Version bumped in `app.json` and `package.json`
- [ ] Changelog updated
- [ ] All tests passing (`bun test`)
- [ ] No lint errors (`biome check .`)
- [ ] OTA update tested on staging channel

## Build

- [ ] EAS build triggered for both platforms
  ```bash
  eas build --platform all --profile production
  ```
- [ ] Build artifacts downloaded and smoke-tested on real devices
- [ ] iOS: TestFlight distribution confirmed
- [ ] Android: Internal track confirmed

## Submit

- [ ] App Store review notes prepared
- [ ] Screenshots/metadata up to date
  ```bash
  eas submit --platform all
  ```

## Post-Release

- [ ] Tag release on `main`: `git tag v1.x.x`
- [ ] Merge `release/*` back into `develop`
- [ ] Announce in team channel
- [ ] Monitor crash rates for 24h
