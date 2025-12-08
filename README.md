# GHFollowers

Small UIKit app to explore GitHub users and their followers.

## Features

- Search GitHub users with a debounce + suggestion list.
- View follower lists with diffable data source, paging, and empty states.
- Inspect a user profile (bio, location, blog) plus repo/gist/follower counts.
- Quick actions: open GitHub profile in Safari or fetch that user's followers.
- Favorite users locally with persistence and avatar caching.
- Fully programmatic UI using SnapKit, async/await networking, and system SF Symbols.

## Tech Stack

- Swift, UIKit, SnapKit for layout.
- Async/Await networking via a lightweight `NetworkService` + `NetworkManager`.
- Image caching (`ImageCacheManager`), persistence (`PersistenceManager`), and reusable UI components (buttons, labels, cells).
- Diffable data source for the follower collection view.

## Getting Started

1. Install Xcode (16+ recommended).
2. Open `GHFollowers.xcodeproj` (or the workspace if you use one).
3. Select a simulator or device running iOS 17+ and press Run.
4. No API keys needed—the app calls the public GitHub REST API.

## How to Use

- Search tab: enter a GitHub username, pick a suggestion, or tap **Get Followers**.
- Followers list: scroll to load more, tap a user to open their profile.
- User info: view stats and tap actions to open the GitHub profile or fetch followers.
- Favorites tab: see and manage your saved users.

## Project Structure (high level)

- `ViewControllers/`: Search, Follower list, User info, Favorites, Alerts.
- `CustomViews/`: Reusable UI (buttons, labels, cells, item info views, loading/empty views).
- `Models/`: `User`, `Follower`, search response models.
- `Ultilities/`: Networking, caching, persistence, UI helpers, SF Symbols.

## Notes

- Network calls rely on GitHub's rate limits; heavy use may be throttled.
- Layouts are programmatic—no Storyboards except the launch screen.
