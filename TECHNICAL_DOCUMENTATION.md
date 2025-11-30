# JobMatchNow iOS - Technical Documentation

**Last Updated:** November 30, 2025  
**Version:** 1.0  
**Platform:** iOS 16.0+  
**Framework:** SwiftUI + UIKit Lifecycle

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [App Lifecycle](#app-lifecycle)
3. [Authentication System](#authentication-system)
4. [Navigation Structure](#navigation-structure)
5. [Feature Modules](#feature-modules)
6. [API Integration](#api-integration)
7. [Design System](#design-system)
8. [Status Bar Management](#status-bar-management)
9. [Data Models](#data-models)
10. [State Management](#state-management)
11. [Recent Changes](#recent-changes)

---

## Architecture Overview

### Design Pattern: MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────────────────────┐
│                     App Entry Point                      │
│                                                          │
│  AppDelegate → SceneDelegate → RootHostingController    │
│                                          ↓               │
│                                      RootView            │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                  Navigation Structure                    │
│                                                          │
│  SplashView → OnboardingCarousel → AuthView             │
│                                          ↓               │
│                                    MainTabView           │
│                                    /         \           │
│                         SearchTab         DashboardTab   │
└─────────────────────────────────────────────────────────┘
```

### Tech Stack

- **UI Framework:** SwiftUI 4.0+
- **Lifecycle:** UIKit AppDelegate/SceneDelegate (for custom UIHostingController)
- **Authentication:** Supabase Auth SDK
- **Networking:** URLSession + async/await
- **State Management:** @StateObject, @ObservableObject, Singleton pattern
- **Navigation:** NavigationStack (iOS 16+)
- **Package Dependencies:** None (native implementation only)

---

## App Lifecycle

### Entry Point: UIKit-based

**Why UIKit lifecycle?**  
We use a custom `UIHostingController` to control the status bar style dynamically based on screen background colors.

#### Files:
- `Core/AppDelegate.swift` - Application lifecycle delegate
- `Core/SceneDelegate.swift` - Window scene management
- `Core/StatusBarStyleManager.swift` - Custom hosting controller with status bar control

### Flow:

```swift
AppDelegate.application(_:configurationForConnecting:)
  ↓
SceneDelegate.scene(_:willConnectTo:)
  ↓
RootHostingController(rootView: RootView()
    .environmentObject(AppState.shared)
    .environmentObject(StatusBarStyleManager.shared))
```

### RootView Logic

```swift
RootView:
  1. Check AppState.authState
     - If .unauthenticated → Show SplashView
     - If .authenticated → Show MainTabView
  
  2. SplashView checks for existing Supabase session
     - Valid session → Navigate to MainTabView
     - No session → Show OnboardingCarouselView → AuthView
```

---

## Authentication System

### Provider: Supabase Auth

**Endpoints:**
- Sign Up: `POST {supabaseURL}/auth/v1/signup`
- Sign In: `POST {supabaseURL}/auth/v1/token?grant_type=password`
- LinkedIn OAuth: `{supabaseURL}/auth/v1/authorize?provider=linkedin_oidc`

### AuthManager (`Auth/AuthManager.swift`)

```swift
final class AuthManager: ObservableObject {
    // Published state
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    // Methods
    func signUpWithEmail(email: String, password: String) async
    func signInWithEmail(email: String, password: String) async
    func signInWithLinkedIn() async
    func signOut()
    func checkExistingSession() -> Bool
}
```

### Token Storage

**Location:** `UserDefaults`

```swift
Key: "supabase_access_token"  → String (JWT access token)
Key: "supabase_refresh_token" → String (JWT refresh token)
```

**Token Usage:**
- All `/api/me/*` endpoints require: `Authorization: Bearer <access_token>`
- Public endpoints (`/api/public/*`, `/api/resume`, `/api/jobs/explanation`) do not require authentication

### Session Flow

```
User Opens App
  ↓
SplashView.onAppear
  ↓
AuthManager.checkExistingSession()
  ↓
Read UserDefaults["supabase_access_token"]
  ↓
  Token exists & valid?
    YES → AppState.authState = .authenticated → MainTabView
    NO  → AppState.authState = .unauthenticated → OnboardingCarousel → AuthView
```

---

## Navigation Structure

### Global Tab Navigation (`Core/MainTabView.swift`)

```swift
TabView(selection: $appState.selectedTab) {
    // Search Tab
    NavigationStack {
        SearchUploadView()
    }
    .tabItem { Label("Search", systemImage: "magnifyingglass") }
    .tag(AppTab.search)
    
    // Dashboard Tab
    NavigationStack {
        DashboardView()
    }
    .tabItem { Label("Dashboard", systemImage: "chart.bar") }
    .tag(AppTab.dashboard)
}
```

### Navigation Patterns

#### 1. **Search Flow** (Search Tab)
```
SearchUploadView
  ↓ (upload resume)
SearchAnalyzingView (polling session status)
  ↓ (status == "completed")
SearchResultsView (show jobs)
  ↓ (tap job card)
SafariView (open job URL)
```

#### 2. **Dashboard Flow** (Dashboard Tab)
```
DashboardView
  ↓ (tap recent session card)
SearchResultsView (historical results)
  ↓ (tap job card)
SafariView (open job URL)
```

#### 3. **Settings** (Accessible from both tabs)
```
SearchUploadView or DashboardView
  ↓ (tap gear icon)
.sheet → SettingsView
  ↓ (tap Sign Out)
AuthView
```

---

## Feature Modules

### 1. Search Module (`Search/`)

#### SearchUploadView
- **Purpose:** Resume upload entry point
- **Features:**
  - File picker for PDF resumes
  - "Use sample resume" shortcut button
  - "Last Search" card (tappable, navigates to previous results)
- **State:** `@StateObject` for upload progress

#### SearchAnalyzingView
- **Purpose:** Display resume analysis progress
- **Features:**
  - Step-by-step progress indicators (Extract, Identify, Search)
  - Polling `GET /api/public/session?token={viewToken}` every 3 seconds
  - Auto-navigate to results when `status == "completed"`

#### SearchResultsView
- **Purpose:** Display job matches
- **ViewModel:** `ResultsViewModel`
- **Features:**
  - Location scope toggle: Local | National
  - Search bar for filtering by keyword
  - Job cards with company, title, location
  - Tap card to open job URL in Safari
  - Pull-to-refresh

#### ResultsViewModel (`Search/ResultsViewModel.swift`)
```swift
@MainActor
final class ResultsViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var locationScope: LocationScope = .national
    
    func refreshJobs() async
    func retry()
}
```

**Location Scope Logic:**
- Default: `.national` (matches initial API behavior)
- When toggled: Triggers `APIService.getJobs(viewToken:scope:)`
- API parameter: `?scope=local` or `?scope=national`

---

### 2. Dashboard Module (`Dashboard/`)

#### DashboardView
- **Purpose:** Show search history and metrics
- **ViewModel:** `DashboardViewModel`
- **Features:**
  - Summary card: Total Searches, Jobs Found, Avg per Search
  - Recent sessions list: Tappable cards showing title, date, stats
  - Empty state when no searches exist
  - Pull-to-refresh

#### DashboardViewModel (`Dashboard/DashboardViewModel.swift`)
```swift
@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var viewState: DashboardViewState = .loading
    @Published var summary: DashboardSummary?
    
    func loadDashboard() async
    func loadSessionResults(_ session: DashboardSessionSummary)
}
```

**View States:**
- `.loading` - Initial fetch
- `.loaded` - Data displayed
- `.empty` - No search history
- `.error(String)` - Auth failure or network error

#### DashboardModels (`Dashboard/DashboardModels.swift`)

**DashboardSummary:**
```swift
struct DashboardSummary: Decodable {
    let totalSearches: Int
    let totalJobsFound: Int
    let avgJobsPerSearch: Double
    let recentSessions: [DashboardSessionSummary]
}
```

**DashboardSessionSummary:**
```swift
struct DashboardSessionSummary: Identifiable, Decodable {
    let id: String              // from "search_session_id"
    let title: String?          // from "title_or_inferred_role"
    let createdAt: Date
    let totalJobs: Int
    let localCount: Int         // from "local_count"
    let nationalCount: Int      // from "national_count"
    let remoteCount: Int        // from "remote_count"
    let status: String?
    let viewToken: String?
}
```

---

### 3. Onboarding Module (`Onboarding/`)

#### SplashView
- **Purpose:** App launch screen, checks for existing session
- **Design:** Dark gradient background (midnight → deepComplement)
- **Logo:** JobMatchNow icon in primaryBrand color

#### OnboardingCarouselView
- **Purpose:** Feature introduction carousel (3 pages)
- **Pages:**
  1. "Match Your Resume" - AI-powered matching
  2. "Find Perfect Roles" - Job discovery
  3. "Track Your Progress" - Dashboard overview
- **CTA:** "Get Started" button navigates to AuthView

---

### 4. Settings Module (`Settings/`)

#### SettingsView
- **Purpose:** App settings and account management
- **Features:**
  - Sign Out button (calls `AuthManager.signOut()`)
  - App version info
  - Dismiss with "Done" button

---

## API Integration

### APIService (`Network/APIService.swift`)

**Base URL:** `https://www.jobmatchnow.ai`

#### Endpoints

| Method | Endpoint | Auth Required | Purpose |
|--------|----------|---------------|---------|
| `POST` | `/api/resume` | No | Upload resume, get view_token |
| `GET` | `/api/public/session?token=<viewToken>` | No | Poll analysis status |
| `GET` | `/api/public/jobs?token=<viewToken>&scope=<local\|national>` | No | Fetch job matches |
| `GET` | `/api/me/dashboard` | **Yes** | Get user dashboard summary |
| `POST` | `/api/jobs/explanation` | No | Get AI explanation for job match |

#### Authentication Implementation

**For `/api/me/dashboard` only:**

```swift
func getDashboard() async throws -> DashboardSummary {
    // 1. Read token from UserDefaults
    guard let accessToken = UserDefaults.standard.string(forKey: "supabase_access_token"),
          !accessToken.isEmpty else {
        throw APIError.unauthorized
    }
    
    // 2. Add Authorization header
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    // 3. Handle 401/403 as unauthorized
    if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
        throw APIError.unauthorized
    }
    
    // 4. Decode DashboardSummary
    return try JSONDecoder().decode(DashboardSummary.self, from: data)
}
```

**Error Handling in DashboardViewModel:**

```swift
do {
    let summary = try await apiService.getDashboard()
    viewState = .loaded
} catch let error as APIError {
    switch error {
    case .unauthorized:
        viewState = .error("Please sign in to view your dashboard.")
    case .httpError(404, _):
        viewState = .empty
    default:
        viewState = .error(error.localizedDescription)
    }
}
```

---

## Design System

### Color Palette (`Core/ThemeColors.swift`)

**Brand Colors:**
```swift
ThemeColors.primaryBrand       // #FF7538 - Atomic Tangerine (CTAs)
ThemeColors.primaryComplement  // #38A1FF - Vibrant Sky Blue (secondary actions)
ThemeColors.softComplement     // #A1D6FF - Soft Ice Blue (subtle highlights)
ThemeColors.deepComplement     // #005D8A - Deep Cyan (dark mode cards)
ThemeColors.midnight           // #0D3A6A - Midnight Navy (headings, dark text)
```

**Utility Colors:**
```swift
ThemeColors.warmAccent         // #FFB140 - Warm Honey (warnings, accents)
ThemeColors.errorRed           // #E74C3C - Bright Red (destructive actions)
ThemeColors.surfaceLight       // #F9F9F9 - Light Gray (light mode background)
ThemeColors.surfaceWhite       // #FFFFFF - Pure White (cards)
ThemeColors.borderSubtle       // #E5E7EB - Light Gray-Blue (dividers)
ThemeColors.textOnLight        // #0D3A6A - Midnight Navy (dark text on light)
ThemeColors.textOnDark         // #F9F9F9 - Light Gray (light text on dark)
```

**Usage Guide:** See `Docs/ColorPalette.md` for detailed 60-30-10 hierarchy rules.

### Typography

**System Font:** San Francisco (default iOS system font)

**Hierarchy:**
- **Large Title:** `.largeTitle` - Navigation titles
- **Title:** `.title` - Section headers
- **Title 2:** `.title2` - Card titles
- **Headline:** `.headline` - Emphasized text
- **Body:** `.body` - Primary content
- **Callout:** `.callout` - Secondary content
- **Caption:** `.caption` - Meta information

---

## Status Bar Management

### Problem Solved
Status bar icons (time, Wi-Fi, battery) were invisible on light backgrounds because SwiftUI couldn't dynamically update `preferredStatusBarStyle`.

### Solution: Custom UIHostingController

#### StatusBarStyleManager (`Core/StatusBarStyleManager.swift`)

```swift
final class StatusBarStyleManager: ObservableObject {
    static let shared = StatusBarStyleManager()
    
    @Published var statusBarStyle: UIStatusBarStyle = .default
}

// View extensions
extension View {
    func statusBarDarkContent() -> some View {
        self.onAppear {
            StatusBarStyleManager.shared.statusBarStyle = .darkContent
        }
    }
    
    func statusBarLightContent() -> some View {
        self.onAppear {
            StatusBarStyleManager.shared.statusBarStyle = .lightContent
        }
    }
}
```

#### RootHostingController (in same file)

```swift
final class RootHostingController<Content: View>: UIHostingController<Content> {
    private let manager = StatusBarStyleManager.shared
    private var cancellable: AnyCancellable?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        manager.statusBarStyle
    }
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
        
        cancellable = manager.$statusBarStyle.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
}
```

#### Integration in SceneDelegate

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = RootHostingController(
        rootView: RootView()
            .environmentObject(AppState.shared)
            .environmentObject(StatusBarStyleManager.shared)
    )
    window.makeKeyAndVisible()
    self.window = window
}
```

#### Info.plist Configuration

```xml
<key>UIViewControllerBasedStatusBarAppearance</key>
<true/>
```

### Usage in Views

```swift
// Light background screens
var body: some View {
    ZStack { ... }
        .statusBarDarkContent()  // Dark icons on light background
}

// Dark background screens
var body: some View {
    ZStack { ... }
        .statusBarLightContent()  // Light icons on dark background
}
```

**Applied to:**
- ✅ SearchUploadView (light) → `.statusBarDarkContent()`
- ✅ SearchResultsView (light) → `.statusBarDarkContent()`
- ✅ DashboardView (light) → `.statusBarDarkContent()`
- ✅ SplashView (dark) → `.statusBarLightContent()`
- ✅ AuthView (dark) → `.statusBarLightContent()`
- ✅ SearchAnalyzingView (dark) → `.statusBarLightContent()`

---

## Data Models

### Job (`Network/APIService.swift`)

```swift
struct Job: Decodable, Identifiable {
    let id: String
    let job_id: String
    let title: String
    let company_name: String
    let location: String
    let posted_at: String?
    let job_url: String?
    let source_query: String?
    let category: String?
    let isRemote: Bool
}
```

### SearchSession (`Models/SearchSession.swift`)

```swift
struct SearchSession: Identifiable, Codable {
    let id: String
    let viewToken: String
    let createdAt: Date
    let status: String
    var jobCount: Int
}
```

### LocationScope (`Network/APIService.swift`)

```swift
enum LocationScope: String, CaseIterable {
    case local = "local"
    case national = "national"
    
    var displayName: String {
        switch self {
        case .local: return "Local"
        case .national: return "National"
        }
    }
}
```

---

## State Management

### AppState (Singleton)

**Location:** `Core/AppState.swift`

```swift
final class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var authState: AuthState = .unauthenticated
    @Published var selectedTab: AppTab = .search
    @Published var currentViewToken: String?
    @Published var lastSearchSession: SearchSession?
    
    enum AuthState {
        case authenticated
        case unauthenticated
    }
    
    enum AppTab: Int {
        case search = 0
        case dashboard = 1
    }
}
```

**Injection:**
```swift
RootView()
    .environmentObject(AppState.shared)
```

**Access in Views:**
```swift
@EnvironmentObject var appState: AppState
```

---

## Recent Changes

### November 30, 2025

#### 1. **Dashboard Authentication Fix** (Commit: `e665d36`)
- **Problem:** `GET /api/me/dashboard` returned 401 Unauthorized
- **Solution:**
  - Added `APIError.unauthorized` case
  - Modified `APIService.getDashboard()` to:
    - Read `supabase_access_token` from UserDefaults
    - Add `Authorization: Bearer <token>` header
    - Handle 401/403 responses as unauthorized errors
  - Updated `DashboardViewModel.loadDashboard()` to show "Please sign in" error for unauthorized state

#### 2. **Dashboard Model Update** (Commit: `a75e7fd`)
- **Problem:** Dashboard decoding failed with `keyNotFound("id")`
- **Backend JSON Changed:**
  - `"search_session_id"` replaces `"id"`
  - `"title_or_inferred_role"` replaces `"title"`
  - `"local_count"`, `"national_count"`, `"remote_count"` replace `"direct_count"`, `"adjacent_count"`
  - Added `"status"` field
- **Solution:**
  - Updated `DashboardSessionSummary` CodingKeys
  - Updated `DashboardView` to show: Total | Local | National | Remote
  - Updated sample data

#### 3. **Location Scope Fix** (Earlier)
- **Problem:** UI showed "Local" but API fetched all/national jobs on first load
- **Solution:**
  - Changed `ResultsViewModel.locationScope` default to `.national`
  - Added debug logging for scope consistency
  - Ensured toggle triggers correct API call with `?scope=<value>`

#### 4. **Last Search Card Functionality** (Earlier)
- **Problem:** "Last Search" card on Upload screen was not tappable
- **Solution:**
  - Made entire card a tappable Button
  - Added `loadLastSearchResults()` method to fetch jobs via `APIService`
  - Added navigation to `SearchResultsView` with historical results
  - Added loading indicator while fetching

#### 5. **Status Bar Visibility** (Earlier)
- **Problem:** Status bar icons invisible on light backgrounds
- **Solution:**
  - Implemented custom `RootHostingController` with Combine observation
  - Created `StatusBarStyleManager.shared` singleton
  - Added `.statusBarDarkContent()` / `.statusBarLightContent()` view modifiers
  - Migrated from SwiftUI App lifecycle to UIKit AppDelegate/SceneDelegate

#### 6. **2025 Color System Compliance** (Earlier)
- Removed all non-palette violets/purples
- Updated gear icons to use `ThemeColors.midnight` (light mode) and `ThemeColors.primaryComplement` (dark mode)
- Replaced "Adjacent" category color with `ThemeColors.deepComplement`
- Updated empty states, save banners, and analyzing screen to use approved colors

#### 7. **Theme → ThemeColors Migration** (Earlier)
- Deprecated all `Theme.*` color aliases
- Migrated all views to use `ThemeColors.*` directly
- Added `@available(*, deprecated, ...)` attributes to `Theme.swift`
- Updated button styles, cards, and text to use design tokens

---

## Configuration Files

### Info.plist (`/Info.plist`)

**Key settings:**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>jobmatchnow</string>
        </array>
    </dict>
</array>

<key>UIViewControllerBasedStatusBarAppearance</key>
<true/>

<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
```

---

## Testing & Debugging

### Debug Logging

**APIService logs:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[APIService] 🔍 GET JOBS REQUEST
  URL: https://www.jobmatchnow.ai/api/public/jobs?token=...&scope=local
  Scope: local
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[APIService] 📥 Response - Status code: 200
[APIService] ✅ Successfully decoded 45 jobs (scope: local)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Dashboard logs:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[APIService] 📊 GET DASHBOARD REQUEST
  URL: https://www.jobmatchnow.ai/api/me/dashboard
  Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[APIService] ✅ Dashboard decoded - 5 searches, 243 jobs, 3 sessions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Common Issues & Solutions

#### Issue: "Please sign in to view your dashboard"
- **Cause:** No Supabase access token in UserDefaults
- **Fix:** Sign in via AuthView to obtain new token

#### Issue: Dashboard decoding error
- **Cause:** Backend JSON structure doesn't match Swift model
- **Fix:** Check `DashboardSessionSummary` CodingKeys match backend field names

#### Issue: Status bar icons not visible
- **Cause:** View not using `.statusBarDarkContent()` or `.statusBarLightContent()`
- **Fix:** Add appropriate modifier based on background color

#### Issue: Location scope not syncing
- **Cause:** Default scope doesn't match initial API call
- **Fix:** Ensure `ResultsViewModel.locationScope` defaults to `.national`

---

## Build Requirements

- **Xcode:** 15.0+
- **iOS Deployment Target:** 16.0+
- **Swift Version:** 5.9+
- **Dependencies:** None (native implementation)

### Build Configuration

```bash
# Clean build
cd /Users/jamessheppard/Developer/jobmatchnow-ios
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean -project JobMatchNow.xcodeproj -scheme JobMatchNow

# Build for simulator
xcodebuild -project JobMatchNow.xcodeproj \
           -scheme JobMatchNow \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

## File Structure

```
JobMatchNow/
├── Core/
│   ├── AppDelegate.swift                 # UIKit app lifecycle
│   ├── SceneDelegate.swift               # Window scene management
│   ├── RootView.swift                    # Auth state routing
│   ├── MainTabView.swift                 # Tab navigation
│   ├── AppState.swift                    # Global state singleton
│   ├── Theme.swift                       # (Deprecated) Legacy colors
│   ├── ThemeColors.swift                 # Design token color palette
│   ├── StatusBarStyleManager.swift       # Custom UIHostingController
│   └── SafariView.swift                  # SFSafariViewController wrapper
├── Auth/
│   ├── AuthManager.swift                 # Supabase auth logic
│   └── AuthView.swift                    # Sign in/up UI
├── Onboarding/
│   ├── SplashView.swift                  # Launch screen
│   └── OnboardingCarouselView.swift      # Feature intro
├── Search/
│   ├── SearchUploadView.swift            # Resume upload
│   ├── SearchAnalyzingView.swift         # Analysis progress
│   ├── SearchResultsView.swift           # Job matches
│   ├── ResultsViewModel.swift            # Results state management
│   └── ExplanationManager.swift          # (Future) AI explanations
├── Dashboard/
│   ├── DashboardView.swift               # Search history UI
│   ├── DashboardViewModel.swift          # Dashboard state
│   └── DashboardModels.swift             # Summary & session models
├── Settings/
│   └── SettingsView.swift                # App settings
├── Network/
│   └── APIService.swift                  # API client
├── Models/
│   ├── SearchSession.swift               # Session data
│   └── JobExplanation.swift              # (Future) Explanation models
└── Resources/
    └── SampleResume.pdf                  # Sample resume for testing
```

---

## Future Enhancements

### Planned Features
1. **AI Job Explanations** - "Why this matches you" expandable cards
2. **Job Bookmarking** - Save jobs for later review
3. **Advanced Filters** - Salary range, experience level, company size
4. **Push Notifications** - New matches for saved searches
5. **Profile Management** - Edit resume, preferences in-app
6. **Dark Mode** - Full dark mode support (currently mixed light/dark)

### Technical Debt
- Migrate fully from `Theme.swift` to `ThemeColors.swift` (deprecation warnings remain)
- Add unit tests for ViewModels and APIService
- Implement error analytics (e.g., Sentry, Firebase Crashlytics)
- Add retry logic with exponential backoff for API failures
- Implement token refresh flow for expired Supabase sessions

---

## Contact & Support

**Repository:** https://github.com/sheepsheeperton/jobmatchnow-ios  
**Backend API:** https://www.jobmatchnow.ai  
**Supabase Project:** [Your Supabase URL]

---

*This documentation reflects the state of the codebase as of November 30, 2025. For the latest changes, see git commit history.*

