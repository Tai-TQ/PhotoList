# PhotoList

A modern iOS photo gallery application built with Swift using Clean Architecture principles. The app displays a list of photos fetched from the Picsum API with efficient image loading and caching.

## Features

- Photo gallery with infinite scrolling
- Search functionality (by ID or Author)
- Pull-to-refresh support
- Efficient image loading and caching
- Smooth scrolling with optimized performance

## Architecture Overview

The project follows Clean Architecture principles with three main layers:

### 1. Domain Layer (`Packages/Domain/`)
Contains business logic and entities:
- **Entities**: `Photo`, `PagingInfo`, `CommonError`
- **Use Cases**: `GetPhotosUseCase`, `ImageUseCase`  
- **Repositories**: Abstract protocols for data access

### 2. Data Layer (`Packages/Data/`)
Handles data sources and external APIs:
- **DTOs**: Data transfer objects for API responses
- **Repositories**: Concrete implementations
- **Services**: API service with Picsum Photos API integration
- **Cache**: Efficient disk-based image caching system

### 3. Presentation Layer (`ListPhoto/`)
UI and presentation logic:
- **MVVM**: ViewModels with Combine publishers
- **Views**: UIKit-based view controllers
- **Navigation**: Coordinator pattern for routing
- **DI**: Dependency injection assemblers

## Project Structure

```
ListPhoto/
├── ListPhoto.xcodeproj/          # Xcode project files
├── ListPhoto/                    # Main app target
│   ├── DI/                      # Dependency injection
│   ├── Extensions/              # UIKit extensions
│   ├── Presentation/            # Views, ViewModels, Controllers
│   │   ├── Splash/             # Splash screen module
│   │   ├── ListPhoto/          # Photo list module
│   │   └── Common/             # Shared UI components
│   └── Supports/               # Utilities and helpers
├── ListPhotoTests/              # Unit tests
├── Packages/                    # Swift Package Manager modules
│   ├── Domain/                 # Business logic layer
│   └── Data/                   # Data access layer
├── Mintfile                    # Development tools
└── README.md                   # Project documentation
```

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Swift 6.1+

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Tai-TQ/PhotoList.git
   cd ListPhoto
   ```

2. **Open in Xcode**
   ```bash
   open ListPhoto.xcodeproj
   ```

3. **Build and run**
   - Select your target device or simulator
   - Press `Cmd+R` to build and run

### Test Coverage
- **ViewModel Tests**: Business logic and data transformation
- **Mock Objects**: For dependencies and external services

## Code Quality

The project maintains high code quality through:

- **SwiftLint**: Linting rules for consistency
- **SwiftFormat**: Automatic code formatting
- **Clean Architecture**: Separation of concerns
- **SOLID Principles**: Maintainable and testable code
- **Unit Testing**: Comprehensive test coverage

---

*Built with ❤️ using Swift and Clean Architecture*
