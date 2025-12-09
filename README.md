# GHFollowers

A UIKit app to explore GitHub users and their followers, built with **Clean Architecture**, **MVVM**, **Coordinator Pattern**, and **Dependency Injection**.

## Features

- 🔍 **Search GitHub users** with debounce and real-time suggestions
- 👥 **View follower lists** with diffable data source, pagination, and empty states
- 📊 **User profiles** with detailed information (bio, location, repos, gists, followers)
- ⚡ **Quick actions**: open GitHub profile in Safari or fetch user's followers
- ⭐ **Favorites**: save and manage favorite users locally with persistence
- 🖼️ **Image caching** for optimized performance
- 🎨 **Fully programmatic UI** using SnapKit, async/await networking, and SF Symbols

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

### 🏗️ Architecture Layers

1. **Domain Layer** (Business Logic)

   - `Entities/`: Core business models (`User`, `Follower`)
   - `Repositories/`: Repository protocols (abstractions)
   - `Usecases/`: Business use cases (GetFollowers, SearchUsers, etc.)

2. **Data Layer** (Data Sources)

   - `Repositories/`: Repository implementations
   - `Network/`: Network service, endpoints, error handling
   - `Local/`: Persistence manager, image cache

3. **Presentation Layer** (UI)

   - `ViewControllers/`: UI controllers (thin, only UI logic)
   - `ViewModels/`: Business logic and state management (MVVM)
   - `CustomViews/`: Reusable UI components
   - `Extensions/`: UI helper extensions

4. **Application Layer** (App Setup)
   - `Coordinators/`: Navigation flow management (Coordinator Pattern)
   - `DIContainer.swift`: Dependency Injection container

### 🎯 Design Patterns

- **MVVM (Model-View-ViewModel)**: ViewModels handle business logic, ViewControllers only manage UI
- **Coordinator Pattern**: Coordinators manage navigation flow, decoupling ViewControllers
- **Dependency Injection**: All dependencies injected through initializers via DIContainer
- **Repository Pattern**: Abstracts data sources, making code testable and maintainable
- **Use Cases**: Encapsulate business logic in single-purpose classes

## Tech Stack

- **Language**: Swift
- **UI Framework**: UIKit (programmatic, no Storyboards)
- **Layout**: SnapKit for Auto Layout
- **Networking**:
  - Async/Await for modern concurrency
  - Custom `NetworkService` with protocol-based design
  - Endpoint-based API configuration
- **State Management**: Combine framework for reactive data binding
- **Architecture**: Clean Architecture + MVVM + Coordinator Pattern
- **Dependency Injection**: Custom DI Container
- **Data Persistence**: UserDefaults (via PersistenceManager)
- **Image Caching**: NSCache-based `ImageCacheManager`
- **UI Components**: Custom reusable components (buttons, labels, cells)

## Project Structure

```
GHFollowers/
├── Application/
│   ├── Coordinators/          # Navigation flow management
│   │   ├── Coordinator.swift
│   │   ├── AppCoordinator.swift
│   │   ├── SearchCoordinator.swift
│   │   ├── FavoritesCoordinator.swift
│   │   ├── FollowerListCoordinator.swift
│   │   └── UserInfoCoordinator.swift
│   ├── DIContainer.swift      # Dependency Injection container
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
├── Domain/                     # Business Logic Layer
│   ├── Entities/              # Core models
│   │   ├── User.swift
│   │   └── Follower.swift
│   ├── Repositories/          # Repository protocols
│   │   ├── FollowerRepositoryProtocol.swift
│   │   ├── UserRepositoryProtocol.swift
│   │   └── FavoriteRepositoryProtocol.swift
│   └── Usecases/             # Business use cases
│       ├── GetFollowersUseCase.swift
│       ├── SearchUsersUseCase.swift
│       ├── GetUserInfoUseCase.swift
│       ├── GetFavoritesUseCase.swift
│       ├── AddFavoriteUseCase.swift
│       └── RemoveFavoriteUseCase.swift
│
├── Data/                      # Data Layer
│   ├── Repositories/         # Repository implementations
│   │   ├── FollowerRepository.swift
│   │   ├── UserRepository.swift
│   │   └── FavoriteRepository.swift
│   ├── Network/              # Networking
│   │   ├── NetworkService.swift
│   │   ├── NetworkManager.swift
│   │   ├── NetworkError.swift
│   │   ├── EndPoint.swift
│   │   └── Request/
│   └── Local/                # Local storage
│       ├── PersistenceManager.swift
│       └── ImageCacheManager.swift
│
└── Presentation/             # UI Layer
    ├── ViewControllers/     # UI Controllers
    │   ├── SearchVC.swift
    │   ├── FollowerListVC.swift
    │   ├── UserInfoVC.swift
    │   └── FavoritesListVC.swift
    ├── ViewModels/           # Business logic & state
    │   ├── SearchViewModel.swift
    │   ├── FollowerListViewModel.swift
    │   ├── UserInfoViewModel.swift
    │   └── FavoritesListViewModel.swift
    ├── CustomViews/          # Reusable UI components
    │   ├── Buttons/
    │   ├── Cells/
    │   ├── Labels/
    │   └── Views/
    └── Extensions/            # UI helper extensions
```

## Getting Started

### Prerequisites

- Xcode 16+ (recommended)
- iOS 17.0+ deployment target
- Swift 5.9+

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd GHFollowers
   ```

2. Open the project:

   ```bash
   open GHFollowers.xcodeproj
   ```

3. Select a simulator or device (iOS 17+) and press `⌘R` to run

4. **No API keys needed** - the app uses the public GitHub REST API

## How to Use

### Search Tab

- Enter a GitHub username in the search field
- View real-time suggestions as you type (with debounce)
- Tap a suggestion or press "Get Followers" to view followers

### Followers List

- Scroll down to load more followers (pagination)
- Tap any follower to view their profile
- Use the search bar to filter followers
- Tap the "+" button to add user to favorites

### User Info

- View detailed user information (bio, location, stats)
- Tap "GitHub Profile" to open in Safari
- Tap "Get Followers" to view that user's followers

### Favorites Tab

- View all saved favorite users
- Tap a favorite to view their followers
- Swipe to delete favorites

## Key Concepts

### Dependency Injection

All dependencies are injected through initializers, managed by `DIContainer`:

```swift
// Example: ViewModel receives UseCase via DI
let viewModel = SearchViewModel(
    searchUsersUseCase: dependencyContainer.searchUsersUseCase
)
```

### Coordinator Pattern

Coordinators handle navigation, keeping ViewControllers decoupled:

```swift
// Coordinator manages navigation flow
coordinator?.showFollowerList(for: username)
```

### MVVM Pattern

ViewModels contain business logic, ViewControllers only handle UI:

```swift
// ViewModel manages state
@Published var suggestions: [GitHubUser] = []

// ViewController binds to ViewModel
viewModel.$suggestions
    .sink { [weak self] _ in
        self?.updateUI()
    }
```

### Repository Pattern

Repositories abstract data sources:

```swift
// Protocol defines interface
protocol FollowerRepositoryProtocol {
    func getFollowers(for username: String, page: Int) async throws -> [Follower]
}

// Implementation handles data fetching
final class FollowerRepository: FollowerRepositoryProtocol { ... }
```

## Testing

The architecture is designed for testability:

- **Protocols** allow easy mocking of dependencies
- **Dependency Injection** enables test doubles
- **Separation of concerns** makes unit testing straightforward

Example test structure:

- Mock repositories for data layer testing
- Mock use cases for domain layer testing
- Test ViewModels with injected mock dependencies

## Notes

- ⚠️ **Rate Limits**: Network calls rely on GitHub's rate limits; heavy use may be throttled
- 🎨 **No Storyboards**: All layouts are programmatic (except launch screen)
- 🔄 **Async/Await**: Modern Swift concurrency throughout
- 📱 **iOS 17+**: Requires iOS 17.0 or later

## Future Improvements

- [ ] Unit tests for ViewModels and Use Cases
- [ ] UI tests for critical user flows
- [ ] Error handling improvements
- [ ] Offline support with Core Data
- [ ] Dark mode optimizations

## License

This project is for educational purposes.

---

**Built with ❤️ using Clean Architecture, MVVM, and Coordinator Pattern**
