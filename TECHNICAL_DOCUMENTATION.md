# JobMatchNow iOS - Technical Documentation

**Last Updated:** December 7, 2025  
**Version:** 2.0  
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
│                              /        |        \         │
│                     SearchTab   InsightsTab   DashboardTab│
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
    .tag(AppState.Tab.search)
    
    // Insights Tab
    NavigationStack {
        InsightsView()
    }
    .tabItem { Label("Insights", systemImage: "sparkles") }
    .tag(AppState.Tab.insights)
    
    // Dashboard Tab
    NavigationStack {
        DashboardView()
    }
    .tabItem { Label("Dashboard", systemImage: "rectangle.stack") }
    .tag(AppState.Tab.dashboard)
}
.tint(ThemeColors.primaryBrand)  // Brand purple for tab bar accents
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
  - **File picker** for PDF, Word, and image files (primary upload method)
  - **Camera scanner** using VNDocumentCameraViewController (iOS 13+)
    - Auto edge detection and perspective correction
    - Image processing: orientation normalization, compression, resize
    - Only shown on devices with camera support
  - "Use sample resume" shortcut button (debug builds only)
  - "Last Search" card (tappable, navigates to previous results)
- **State:** `@StateObject` for upload progress
- **Supporting Files:**
  - `DocumentScannerView.swift` - SwiftUI wrapper for VisionKit scanner
  - `ImageProcessor.swift` - Image normalization and JPEG compression

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
    @Published var selectedBucket: JobBucket = .all
    
    func refreshJobs() async
    func retry()
}
```

**Job Bucket Logic:**
- Default: `.all` (matches initial API behavior - no query params)
- 4-button control: **All | Remote | Local | National**
- Each bucket triggers `APIService.getJobs(viewToken:bucket:)` with appropriate query params

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
    let title: String?          // from "title_or_inferred_role" (deprecated)
    let createdAt: Date
    let totalJobs: Int
    let localCount: Int         // from "local_count"
    let nationalCount: Int      // from "national_count"
    let remoteCount: Int        // from "remote_count"
    let status: String?
    let viewToken: String?
    
    // NEW: Semantic labels from backend
    let currentRoleTitle: String?   // from "current_role_title" - User's current job from résumé
    let currentRoleCompany: String? // from "current_role_company" - User's current company
    let lastSearchTitle: String?    // from "last_search_title" - Search intent / inferred role
    
    // Computed properties for UI
    var displayTitle: String        // Returns currentRoleTitle ?? title ?? fallback
    var searchIntentTitle: String   // Returns lastSearchTitle ?? title ?? "Job Search"
    var dashboardSubtitle: String   // "Last search: {intent} • {count} matches • {time}"
}
```

---

### 3. Onboarding Module (`Onboarding/`)

#### SplashView
- **Purpose:** App launch screen, checks for existing session
- **Design:** Dark gradient background using `ThemeColors.introGradient`
- **Logo:** App icon (`AppLogo` from assets) with rounded corners

#### OnboardingCarouselView
- **Purpose:** Feature introduction carousel (3 pages), shown only once
- **Persistence:** `hasCompletedOnboarding` flag in UserDefaults via AppState
- **Pages:**
  1. "Personalized job matches, powered by your unique experience"
  2. "Not a job board — a smart matcher built around your résumé"
  3. "Get job recommendations in under 60 seconds"
- **CTA:** "Next" (pages 1-2), "Get started" (page 3)
- **Illustrations:** Programmatic SwiftUI scenes in `OnboardingScenes.swift`

#### OnboardingScenes.swift
- **Purpose:** Programmatic vector-style illustrations for onboarding cards
- **Contains:**
  - `OnboardingScenePersonalized` - Resume card with floating skill badges
  - `OnboardingSceneAIMatcher` - Document with scanning lens effect
  - `OnboardingSceneFastResults` - Stopwatch with speed lines
- **Design:** Flat, minimal, geometric style using ThemeColors palette

---

### 4. Consent Module (`Consent/`)

#### DataConsentView
- **Purpose:** Privacy consent gate before first resume upload
- **Shows:** Only once, when user first tries to upload a resume
- **Persistence:** `hasAcceptedDataConsent` flag in UserDefaults via AppState
- **Content:**
  - Explanation of AI processing (Claude)
  - Data storage and encryption info
  - Bulleted list of what data is collected
  - "I Agree and Continue" primary CTA
  - "Not now" secondary action
  - Links to Privacy Policy and Terms of Use

#### Integration
- `SearchUploadView` checks `appState.hasAcceptedDataConsent`
- If false, presents `DataConsentView` as fullScreenCover
- User cannot upload until consent is granted

---

### 5. Insights Module (`Insights/`)

#### InsightsView
- **Purpose:** Display AI-powered resume insights and role suggestions
- **ViewModel:** `InsightsViewModel`
- **Features:**
  - Resume Score card (0-100 with feedback)
  - Suggested Roles section with tappable chips
  - Role explanations with AI-generated summaries and bullets
  - Loading, error, and empty states

#### InsightsViewModel
```swift
@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var resumeScore: Int?
    @Published var resumeFeedback: String?
    @Published var suggestedRoles: [String] = []
    @Published var roleExplanations: [String: RoleSnippetResponse] = [:]
    @Published var expandedRole: String?
    
    func loadLatestSessionInsights() async
    func toggleRoleExplanation(_ role: String)
    func fetchRoleExplanation(role: String) async
}
```

---

### 7. Settings Module (`Settings/`)

#### SettingsView
- **Purpose:** App settings and account management
- **Features:**
  - **Data & AI Processing section:**
    - "How we use your résumé" → Opens `DataConsentInfoView` (read-only consent info)
  - **Account section:**
    - Sign Out button (calls `AuthManager.signOut()`)
  - **Debug section (development only):**
    - Reset Onboarding flag
    - Reset Data Consent flag
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
| `GET` | `/api/public/session?token=<viewToken>` | No | Poll analysis status (includes resume_score, realistic_target_roles) |
| `GET` | `/api/public/jobs?token=<viewToken>&scope=<local\|national>` | No | Fetch job matches |
| `GET` | `/api/me/dashboard` | **Yes** | Get user dashboard summary + recent_starred_jobs |
| `POST` | `/api/jobs/explanation` | No | Get AI explanation for job match |
| `POST` | `/api/jobs/interaction` | No | Track job interaction (view, star, apply) |
| `POST` | `/api/insights/role-snippet` | No | Get AI explanation for suggested role |

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

**System:** Triadic Palette — Purple (brand) + Green-Teal (actions) + Warm Sand (accents)

**Purple Family (Brand):**
```swift
ThemeColors.brandPurpleDark    // #3B3355 - Primary brand for headings, icons
ThemeColors.brandPurpleMid     // #5D5D81 - Secondary structure, inactive states
ThemeColors.primaryBrand       // Maps to brandPurpleDark (semantic alias)
```

**Green-Teal (Primary Actions):**
```swift
ThemeColors.accentGreen        // #52885E - ⭐ PRIMARY CTAs, buttons, key metrics
ThemeColors.accentGreenPressed // #3D6847 - Pressed button states
ThemeColors.primaryAccent      // Maps to accentGreen (semantic alias)
```

**Warm Sand (Secondary Accents):**
```swift
ThemeColors.accentSand         // #F5EEE4 - Soft backgrounds, subtle chips
ThemeColors.accentSandDark     // #E8DFD2 - Borders on sand surfaces
ThemeColors.secondaryAccent    // Maps to accentSand (semantic alias)
```

**Neutrals:**
```swift
ThemeColors.surfaceLight       // #F9FAFB - Light mode page background
ThemeColors.surfaceWhite       // #FFFFFF - Card backgrounds (light mode)
ThemeColors.surfaceDark        // #0A0A0F - Dark mode page background
ThemeColors.cardLight          // #FFFFFF - Cards (light mode)
ThemeColors.cardDark           // #1A1B26 - Cards (dark mode)
ThemeColors.borderSubtle       // #E5E7EB - Dividers, card borders
ThemeColors.softGrey           // #6B7280 - Secondary text
ThemeColors.paperWhite         // #FEFCFD - Text on dark backgrounds
```

**Text Colors:**
```swift
ThemeColors.textOnLight        // brandPurpleDark - Primary text on light
ThemeColors.textOnDark         // paperWhite - Primary text on dark
ThemeColors.textSecondaryLight // softGrey - Secondary text (light mode)
ThemeColors.textSecondaryDark  // #A0A0B0 - Secondary text (dark mode)
```

**Gradients:**
```swift
ThemeColors.introGradient      // For splash/intro screens
ThemeColors.loadingGradient    // For analyzing/loading screens
ThemeColors.brandGradient      // For marketing/hero sections
```

**Usage Guide:** See `Docs/ColorPalette.md` for detailed 60-30-10 hierarchy rules and component mapping.

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

### JobBucket (`Network/APIService.swift`)

```swift
enum JobBucket: String, CaseIterable {
    case all = "all"           // No query params (all jobs)
    case remote = "remote"     // &remote=true
    case local = "local"       // &scope=local&remote=false
    case national = "national" // &scope=national&remote=false
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .remote: return "Remote"
        case .local: return "Local"
        case .national: return "National"
        }
    }
    
    /// Returns appropriate query parameters for this bucket
    func queryParameters(viewToken: String) -> [String: String]
}
```

**Bucket → API Query Mapping:**
| Bucket   | API Call |
|----------|----------|
| All      | `?token=X` (no filters) |
| Remote   | `?token=X&remote=true` |
| Local    | `?token=X&scope=local&remote=false` |
| National | `?token=X&scope=national&remote=false` |

---

## State Management

### AppState (Singleton)

**Location:** `Core/AppState.swift`

```swift
final class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var authState: AuthState = .loading
    @Published var selectedTab: Tab = .search
    @Published var hasCompletedOnboarding: Bool      // Persisted in UserDefaults
    @Published var hasAcceptedDataConsent: Bool      // Persisted in UserDefaults
    @Published var currentUser: UserInfo?
    @Published var lastSearch: LastSearchInfo?       // Synced from Dashboard
    
    enum AuthState: Equatable {
        case loading
        case authenticated
        case unauthenticated
    }
    
    enum Tab: Int {
        case search = 0
        case insights = 1
        case dashboard = 2
    }
    
    // Methods
    func completeOnboarding()     // Sets flag + persists
    func resetOnboarding()        // Clears flag (debug)
    func acceptDataConsent()      // Sets flag + persists
    func resetDataConsent()       // Clears flag (debug)
    func signIn(user: UserInfo)
    func signOut()
    func saveLastSearch(_ info: LastSearchInfo)
    func switchToTab(_ tab: Tab)
    
    // Last search info with semantic labels
    struct LastSearchInfo: Codable, Equatable {
        let viewToken: String
        let date: Date
        let totalMatches: Int
        let directMatches: Int
        let adjacentMatches: Int
        let label: String?               // Deprecated fallback
        let currentRoleTitle: String?    // User's current job from résumé
        let lastSearchTitle: String?     // Search intent / target role
    }
}
```

**Last Search Sync:** When `DashboardViewModel.loadDashboard()` succeeds, it automatically calls `updateLastSearchInAppState()` to populate `AppState.shared.lastSearch` from the most recent dashboard session. This ensures the Search tab's "Last Search" card shows the same data as the Dashboard.

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

### December 7, 2025

#### 1. **Insights Tab & Module** (Latest)
- **Change:** Added dedicated Insights tab as third navigation item
- **Purpose:** Move resume score and suggested roles off results page for cleaner UX
- **Features:**
  - Resume Score card with 0-100 score and full feedback
  - Suggested Roles section with tappable chips
  - Role explanations fetch structured JSON (summary + bullets) from API
  - Loading, error, and empty states
- **New Files:**
  - `Insights/InsightsView.swift` - UI for insights display
  - `Insights/InsightsViewModel.swift` - Data loading and role explanation fetching
- **API Integration:** Uses existing `/api/public/session` for score/roles, new `/api/insights/role-snippet` for explanations

#### 2. **Data Consent Gate**
- **Change:** Added privacy consent screen before first resume upload
- **Purpose:** Comply with privacy best practices for AI data processing
- **Flow:** User must accept consent before uploading resume (one-time gate)
- **Persistence:** `hasAcceptedDataConsent` flag in UserDefaults via AppState
- **New Files:**
  - `Consent/DataConsentView.swift` - Full consent UI + read-only info variant
- **Integration:** SearchUploadView checks flag, presents fullScreenCover if needed

#### 3. **Onboarding Carousel Enhancement**
- **Change:** Added programmatic SwiftUI illustrations for onboarding
- **Purpose:** Beautiful onboarding without requiring external image assets
- **New Files:**
  - `Onboarding/OnboardingScenes.swift` - Three animated scenes:
    - `OnboardingScenePersonalized` - Resume card with floating badges
    - `OnboardingSceneAIMatcher` - Document with scanning lens
    - `OnboardingSceneFastResults` - Stopwatch with speed lines
- **Design:** Flat, minimal, geometric style using ThemeColors triadic palette

#### 4. **Job Bookmarks (Saved Jobs)**
- **Change:** Added ability to save/star jobs from results
- **UI:** Bookmark icon on job cards (outlined/filled toggle)
- **API:** New `APIService.trackJobInteraction(jobId:viewToken:interactionType:)` 
- **Dashboard:** "Saved Jobs" section displays `recent_starred_jobs` from API
- **Files Changed:**
  - `SearchResultsView.swift` - Bookmark icon on cards
  - `ResultsViewModel.swift` - `toggleBookmark(for:)` method
  - `DashboardModels.swift` - `DashboardSavedJob` struct
  - `DashboardView.swift` - Saved Jobs section

#### 5. **Job Quality Badges**
- **Change:** Client-side quality labels on job cards
- **Badges:**
  - "High Match" - when `category == "direct"`
  - "Fresh" - when `posted_at` ≤ 48 hours
  - "Remote-Friendly" - when `isRemote == true`
- **Files Changed:** `SearchResultsView.swift` - `JobQualityBadge` components

#### 6. **Pipeline Error Handling**
- **Change:** Improved error handling in analyzing flow
- **Features:**
  - Timeout detection during session polling
  - "Processing Failed" alert with Retry / Upload Different File options
  - Graceful handling of "failed" status from backend
- **Files Changed:** `SearchAnalyzingView.swift`

#### 7. **Triadic Color System**
- **Change:** Migrated from Palette A to triadic system
- **Colors:**
  - Purple (brand) - typography, icons, brand identity
  - Green-teal (actions) - primary CTAs, buttons, key metrics
  - Warm sand (accents) - soft highlights, subtle badges
- **Files Changed:** 
  - `ThemeColors.swift` - Complete rewrite
  - `Docs/ColorPalette.md` - Updated documentation

#### 8. **Search/Dashboard Title Consistency**
- **Change:** Last Search card now shows same title as Dashboard
- **Display:** Primary shows `currentRoleTitle`, subtitle shows `lastSearchTitle`
- **Files Changed:** `SearchUploadView.swift` - `LastSearchCard` component

#### 9. **UI Polish**
- **Splash screen:** Replaced briefcase icon with AppLogo asset
- **Loading screen:** Updated copy to "This may take 1 to 2 minutes"
- **Dashboard:** Fixed black bars on empty state (full-bleed background)

---

### December 1, 2025

#### 1. **Camera Scanning for Resume Upload**
- **Change:** Added camera scanning capability using VisionKit's document scanner
- **Purpose:** Allow users to photograph their résumé directly with iPhone camera
- **Features:**
  - Uses `VNDocumentCameraViewController` for optimal OCR results
  - Auto edge detection and perspective correction
  - Image processing pipeline: orientation fix, resize, JPEG compression
  - Camera button hidden on simulator and unsupported devices
  - Falls back to existing file picker (unchanged)
- **New Files:**
  - `Search/DocumentScannerView.swift` - SwiftUI wrapper for VisionKit scanner
  - `Search/ImageProcessor.swift` - Image normalization and compression utility
- **Modified Files:**
  - `Info.plist` - Added `NSCameraUsageDescription` permission
  - `Search/SearchUploadView.swift` - Added "Scan with Camera" button + fullScreenCover
- **Data Flow:**
  ```
  Camera → VNDocumentCameraViewController → UIImage
    → ImageProcessor (normalize, resize, compress)
    → temp JPEG file → uploadFile() (existing)
    → Backend OCR (already supports JPEG)
  ```
- **Note:** No backend changes required - OCR already processes image files

#### 3. **Semantic Labels for Search Sessions**
- **Change:** Added `currentRoleTitle`, `currentRoleCompany`, `lastSearchTitle` to dashboard and search models
- **Purpose:** Show meaningful labels instead of generic "Search" or "Recent search"
- **Dashboard Card Now Shows:**
  - **Primary:** User's current role from résumé (e.g., "Co-owner / CFO")
  - **Subtitle:** "Last search: Accounting Specialist • 79 matches • 2h ago"
- **Search Upload Card Now Shows:**
  - **Primary:** Search intent (e.g., "Accounting Specialist")
  - **Secondary:** "Based on your role: Co-owner / CFO"
- **Files Changed:**
  - `DashboardModels.swift` - Added new fields + computed properties
  - `AppState.swift` - Updated `LastSearchInfo` struct
  - `DashboardViewModel.swift` - Added `updateLastSearchInAppState()` sync
  - `DashboardView.swift` - Updated `RecentSessionCard` subtitle
  - `SearchUploadView.swift` - Updated `LastSearchCard` display logic

#### 4. **Automatic Token Refresh**
- **Change:** Dashboard now automatically refreshes expired Supabase tokens
- **Problem:** After ~1 hour, tokens expire and dashboard shows "Session expired"
- **Solution:**
  - Added `AuthManager.refreshTokenIfNeeded() async -> Bool`
  - `DashboardViewModel.loadDashboard()` catches `.unauthorized` and tries refresh
  - If refresh succeeds → retries dashboard load automatically
  - If refresh fails → shows "Session expired. Please sign in again."
- **Files Changed:**
  - `AuthManager.swift` - Added public refresh method
  - `DashboardViewModel.swift` - Added retry logic for 401 errors

### November 30, 2025

#### 1. **Job Bucket Filter Refactor**
- **Change:** Replaced dual-control filtering with single 4-button bucket control
- **Old:** Local/National scope toggle + All/Remote filter (2 separate controls)
- **New:** All | Remote | Local | National (single mutually-exclusive control)
- **API Mapping:**
  - All: `?token=X` (no filters)
  - Remote: `?token=X&remote=true`
  - Local: `?token=X&scope=local&remote=false`
  - National: `?token=X&scope=national&remote=false`
- **Files Changed:**
  - `APIService.swift` - Added `JobBucket` enum, updated `getJobs(viewToken:bucket:)`
  - `ResultsViewModel.swift` - Replaced `locationScope` with `selectedBucket`
  - `SearchResultsView.swift` - Replaced `LocationScopeToggle` and `JobFilter` with `JobBucketPicker`

#### 2. **Dashboard Authentication Fix**
- **Problem:** `GET /api/me/dashboard` returned 401 Unauthorized
- **Solution:**
  - Added `APIError.unauthorized` case
  - Modified `APIService.getDashboard()` to add Authorization header
  - Updated `DashboardViewModel.loadDashboard()` to show "Please sign in" error for unauthorized state

#### 3. **Dashboard Model Update**
- **Problem:** Dashboard decoding failed with `keyNotFound("id")`
- **Solution:**
  - Updated `DashboardSessionSummary` CodingKeys to match new backend JSON
  - Updated `DashboardView` to show: Total | Local | National | Remote

#### 4. **Last Search Card Functionality**
- **Problem:** "Last Search" card on Upload screen was not tappable
- **Solution:**
  - Made entire card a tappable Button
  - Added navigation to historical results

#### 5. **Status Bar Visibility**
- **Problem:** Status bar icons invisible on light backgrounds
- **Solution:**
  - Implemented custom `RootHostingController` with Combine observation
  - Created `StatusBarStyleManager.shared` singleton
  - Migrated from SwiftUI App lifecycle to UIKit AppDelegate/SceneDelegate

#### 6. **2025 Color System & Theme Migration**
- Migrated all views from `Theme.*` to `ThemeColors.*`
- Removed non-palette violets/purples
- Updated gear icons, empty states, and cards to use approved colors

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

<key>NSCameraUsageDescription</key>
<string>JobMatchNow uses your camera to photograph your résumé for AI-powered job matching.</string>

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
├── Assets.xcassets/
│   ├── AccentColor.colorset/
│   ├── AppIcon.appiconset/
│   ├── AppLogo.imageset/                 # App logo for splash screen
│   ├── onboarding_personalized.imageset/ # Onboarding illustration slot
│   ├── onboarding_ai_matcher.imageset/   # Onboarding illustration slot
│   └── onboarding_fast_results.imageset/ # Onboarding illustration slot
├── Core/
│   ├── AppDelegate.swift                 # UIKit app lifecycle
│   ├── SceneDelegate.swift               # Window scene management
│   ├── RootView.swift                    # Auth state routing
│   ├── MainTabView.swift                 # 3-tab navigation (Search, Insights, Dashboard)
│   ├── AppState.swift                    # Global state singleton
│   ├── Theme.swift                       # (Deprecated) Legacy colors
│   ├── ThemeColors.swift                 # Triadic color palette
│   ├── StatusBarStyleManager.swift       # Custom UIHostingController
│   └── SafariView.swift                  # SFSafariViewController wrapper
├── Auth/
│   ├── AuthManager.swift                 # Supabase auth logic
│   └── AuthView.swift                    # Sign in/up UI
├── Consent/
│   └── DataConsentView.swift             # Data consent gate + info view
├── Onboarding/
│   ├── SplashView.swift                  # Launch screen
│   ├── OnboardingCarouselView.swift      # 3-page feature intro
│   └── OnboardingScenes.swift            # Programmatic SwiftUI illustrations
├── Search/
│   ├── SearchUploadView.swift            # Resume upload (file picker + camera)
│   ├── DocumentScannerView.swift         # VisionKit camera scanner wrapper
│   ├── ImageProcessor.swift              # Image normalization & compression
│   ├── SearchAnalyzingView.swift         # Analysis progress with error handling
│   ├── SearchResultsView.swift           # Job matches with badges & bookmarks
│   ├── ResultsViewModel.swift            # Results state + bookmark toggle
│   └── ExplanationManager.swift          # AI match explanations
├── Insights/
│   ├── InsightsView.swift                # Resume score & suggested roles UI
│   └── InsightsViewModel.swift           # Insights data & role explanations
├── Dashboard/
│   ├── DashboardView.swift               # Search history + saved jobs UI
│   ├── DashboardViewModel.swift          # Dashboard state + starred jobs
│   └── DashboardModels.swift             # Summary, session, saved job models
├── Settings/
│   └── SettingsView.swift                # App settings + data consent info
├── Network/
│   └── APIService.swift                  # API client + job interactions
├── Models/
│   ├── SearchSession.swift               # Session data
│   └── JobExplanation.swift              # Explanation models
└── Resources/
    └── SampleResume.pdf                  # Sample resume for testing
```

---

## Future Enhancements

### Planned Features
1. ✅ ~~AI Job Explanations~~ - "Why this matches you" expandable cards (Completed Dec 2025)
2. ✅ ~~Job Bookmarking~~ - Save jobs for later review (Completed Dec 2025)
3. **Advanced Filters** - Salary range, experience level, company size
4. **Push Notifications** - New matches for saved searches
5. **Profile Management** - Edit resume, preferences in-app
6. **Dark Mode** - Full dark mode support (currently mixed light/dark)
7. ✅ ~~Resume Insights~~ - Score and suggested roles (Completed Dec 2025)

### Technical Debt
- ✅ ~~Migrate fully from `Theme.swift` to `ThemeColors.swift`~~ (Completed Dec 2025 - triadic system)
- Add unit tests for ViewModels and APIService
- Implement error analytics (e.g., Sentry, Firebase Crashlytics)
- ✅ ~~Add retry logic for API failures~~ (Completed Dec 2025 - pipeline error handling)
- ✅ ~~Implement token refresh flow for expired Supabase sessions~~ (Completed Dec 1, 2025)

---

## Contact & Support

**Repository:** https://github.com/sheepsheeperton/jobmatchnow-ios  
**Backend API:** https://www.jobmatchnow.ai  
**Supabase Project:** [Your Supabase URL]

---

*This documentation reflects the state of the codebase as of December 7, 2025. For the latest changes, see git commit history.*

