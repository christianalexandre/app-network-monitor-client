# Homebrew Release Guide

## User Installation

```bash
brew tap christianalexandre/app-network-monitor-client
brew install --cask app-network-monitor
```

---

## Release Process

### 1. Build in Xcode

1. Open `AppNetworkMonitor.xcodeproj`
2. Update version in project settings if needed
3. **Product → Archive**
4. **Distribute App → Copy App** (save to Desktop)

### 2. Package and Generate Hash

```bash
cd ~/Desktop
zip -r AppNetworkMonitor-X.Y.Z.zip AppNetworkMonitor.app
shasum -a 256 AppNetworkMonitor-X.Y.Z.zip
```

### 3. Create GitHub Release

1. Go to [Releases](https://github.com/christianalexandre/homebrew-app-network-monitor-client/releases)
2. **Draft a new release**
3. Tag: `X.Y.Z` (e.g., `1.0.0`)
4. Upload `AppNetworkMonitor-X.Y.Z.zip`
5. Publish

### 4. Update Cask

Edit `Casks/app-network-monitor.rb`:

```ruby
version "X.Y.Z"
sha256 "paste_hash_here"
```

### 5. Commit and Push

```bash
git add Casks/app-network-monitor.rb
git commit -m "Release X.Y.Z"
git push origin main
```

### 6. Test Installation

```bash
brew update
brew upgrade --cask app-network-monitor
```
