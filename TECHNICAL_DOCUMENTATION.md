# JobMatchNow iOS App - Complete Technical Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [App Lifecycle & Entry Point](#app-lifecycle--entry-point)
3. [Authentication System](#authentication-system)
4. [State Management](#state-management)
5. [Navigation Flow](#navigation-flow)
6. [Backend API Integration](#backend-api-integration)
7. [Core Features](#core-features)
8. [Data Models](#data-models)
9. [UI Design System](#ui-design-system)
10. [File Structure](#file-structure)

---

## Architecture Overview

### Technology Stack
- **Framework**: SwiftUI (iOS 17+)
- **Language**: Swift 5.9+
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **Backend**: Supabase (PostgreSQL + REST API)
- **Authentication**: Supabase Auth (OAuth + Email/Password)
- **State Management**: Combine framework with `@Published` properties
- **Concurrency**: Swift Concurrency (async/await)

### Core Architectural Principles

1. **Single Source of Truth**: `AppState.shared` manages global app state
2. **Reactive UI**: SwiftUI views observe `@Published` properties via `@StateObject`
3. **Separation of Concerns**: 
   - Views handle presentation
   - ViewModels handle business logic
   - Services handle API communication
4. **Dependency Injection**: ViewModels receive dependencies (e.g., APIService)
5. **Type Safety**: Strong typing with enums for states and filters

---

## App Lifecycle & Entry Point

### UIKit-Based Lifecycle (for Status Bar Control)

**Files:**
- `Core/AppDelegate.swift`
- `Core/SceneDelegate.swift`
- `Core/StatusBarStyleManager.swift`

The app uses UIKit's `AppDelegate` and `SceneDelegate` instead of SwiftUI's `@main App` to enable custom status bar control.

#### AppDelegate.swift
```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                    configurationForConnecting connectingSceneSession: UISceneSession) 
        -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default", sessionRole: .windowApplication)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
```

**Purpose**: Configures the app to use `SceneDelegate` for window management.

#### SceneDelegate.swift
```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let rootView = RootView()
            .environmentObject(AppState.shared)
            .environmentObject(StatusBarStyleManager.shared)
        
        window.rootViewController = RootHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()
    }
}
```

**Purpose**: 
- Creates the root window
- Injects `RootHostingController` (custom UIHostingController)
- Provides `AppState` and `StatusBarStyleManager` as environment objects

#### StatusBarStyleManager.swift
```swift
final class StatusBarStyleManager: ObservableObject {
    static let shared = StatusBarStyleManager()
    @Published var statusBarStyle: UIStatusBarStyle = .default
}

final class RootHostingController<Content: View>: UIHostingController<Content> {
    private var cancellable: AnyCancellable?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        StatusBarStyleManager.shared.statusBarStyle
    }
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
        cancellable = StatusBarStyleManager.shared.$statusBarStyle.sink { [weak self] _ in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
```

**Purpose**: 
- Manages status bar appearance (light/dark icons)
- Updates when views change background color
- Ensures status bar icons are always visible

#### View Modifiers for Status Bar
```swift
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

**Usage in Views**:
- Light background screens (Search, Results, Dashboard): `.statusBarDarkContent()`
- Dark background screens (Splash, Auth, Analyzing): `.statusBarLightContent()`

---

## Authentication System

### Supabase Configuration

**Backend**: `https://nxbhfoqaoaeiguoldnng.supabase.co`
**File**: `Auth/AuthManager.swift`

### AuthManager (Singleton)

```swift
final class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoading = false
    @Published var error: AuthError?
    
    private let supabaseURL = "https://nxbhfoqaoaeiguoldnng.supabase.co"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    private let redirectURL = "jobmatchnow://auth/callback"
}
```

### Authentication Methods

#### 1. Email Sign-Up

**Endpoint**: `POST /auth/v1/signup`

**Flow**:
```
User enters email + password
    ↓
AuthManager.signUpWithEmail(email, password)
    ↓
POST to Supabase /auth/v1/signup
    ↓
If success (200/201):
    - Check if email confirmation required
    - If tokens returned → sign in immediately
    - If confirmation required → show message
    ↓
Store access_token, refresh_token, user_id, user_email in UserDefaults
    ↓
Update AppState.signIn(user: UserInfo)
    ↓
Navigate to MainTabView
```

**Error Handling**:
- "This email is already registered" → Suggest sign in
- Password validation → "Password must be at least 6 characters"
- Generic errors → "Sign up failed. Please try again."

#### 2. Email Sign-In

**Endpoint**: `POST /auth/v1/token?grant_type=password`

**Flow**:
```
User enters email + password
    ↓
AuthManager.signInWithEmail(email, password)
    ↓
POST to Supabase /auth/v1/token
    ↓
If success (200):
    - Extract access_token, refresh_token from response
    - Store tokens in UserDefaults
    - Fetch user info
    ↓
Update AppState.signIn(user: UserInfo)
    ↓
Navigate to MainTabView
```

#### 3. LinkedIn OAuth

**Endpoint**: `GET /auth/v1/authorize?provider=linkedin_oidc`

**Flow**:
```
User taps "Continue with LinkedIn"
    ↓
AuthManager.signInWithLinkedIn()
    ↓
Open ASWebAuthenticationSession with Supabase OAuth URL
    ↓
User authenticates on LinkedIn's website
    ↓
Redirect to jobmatchnow://auth/callback#access_token=...&refresh_token=...
    ↓
Parse callback URL fragment
    ↓
Extract tokens, store in UserDefaults
    ↓
Fetch user info from /auth/v1/user
    ↓
Update AppState.signIn(user: UserInfo)
    ↓
Navigate to MainTabView
```

**ASWebAuthenticationSession**:
- Presents system web view for OAuth
- Secure authentication (credentials never exposed to app)
- Supports credential autofill

#### 4. Session Management

**Check Existing Session** (on app launch):
```swift
func checkExistingSession() async -> Bool {
    // 1. Check UserDefaults for stored tokens
    guard let accessToken = UserDefaults.standard.string(forKey: accessTokenKey) else {
        return false
    }
    
    // 2. Verify token with Supabase
    let isValid = try await verifyToken(accessToken)
    if isValid {
        // Restore session
        return true
    }
    
    // 3. Try to refresh with refresh_token
    if let refreshToken = UserDefaults.standard.string(forKey: refreshTokenKey) {
        let refreshed = try await refreshSession(refreshToken)
        if refreshed {
            return true
        }
    }
    
    // 4. Session invalid, clear and sign out
    clearSession()
    return false
}
```

**Token Verification**:
```
GET /auth/v1/user
Headers: Authorization: Bearer {access_token}
If 200 → token valid
If 401 → token expired
```

**Token Refresh**:
```
POST /auth/v1/token?grant_type=refresh_token
Body: { "refresh_token": "..." }
Response: New access_token and refresh_token
```

#### 5. Sign Out

**Flow**:
```
User taps "Log Out"
    ↓
AuthManager.signOut()
    ↓
Call POST /auth/v1/logout with access_token
    ↓
Clear UserDefaults (all tokens)
    ↓
AppState.signOut()
    ↓
Navigate to AuthView
```

### Session Storage

**UserDefaults Keys**:
- `supabase_access_token`: JWT for API authentication
- `supabase_refresh_token`: Token to get new access_token
- `supabase_user_id`: Supabase user UUID
- `supabase_user_email`: User's email address

---

## State Management

### AppState (Global Singleton)

**File**: `Core/AppState.swift`

```swift
final class AppState: ObservableObject {
    static let shared = AppState()
    
    // Authentication
    @Published var authState: AuthState = .loading
    @Published var currentUser: UserInfo?
    
    // Navigation
    @Published var selectedTab: Tab = .search
    
    // Onboarding
    @Published var hasCompletedOnboarding: Bool
    
    // Search persistence
    @Published var lastSearch: LastSearchInfo?
}
```

#### AuthState Enum
```swift
enum AuthState: Equatable {
    case loading    // Checking existing session
    case unauthenticated  // No valid session
    case authenticated    // Valid session exists
}
```

#### LastSearchInfo Struct
```swift
struct LastSearchInfo: Codable {
    let viewToken: String
    let date: Date
    let totalMatches: Int
    let directMatches: Int
    let adjacentMatches: Int
    let label: String?  // Inferred job title from resume
}
```

**Persistence**: Saved to UserDefaults as JSON

**Purpose**: Enables "Last Search" quick access card on upload screen

#### Methods

**signIn(user: UserInfo)**
- Sets `authState = .authenticated`
- Stores `currentUser`
- Triggers navigation to MainTabView

**signOut()**
- Sets `authState = .unauthenticated`
- Clears `currentUser`
- Clears `lastSearch`
- Triggers navigation to AuthView

**saveLastSearch(_ info: LastSearchInfo)**
- Stores in `@Published var lastSearch`
- Persists to UserDefaults
- Enables quick re-access from upload screen

**switchToTab(_ tab: Tab)**
- Programmatic tab switching
- Used from menu actions (e.g., "Open Dashboard" from results)

---

## Navigation Flow

### Root Navigation Structure

```
RootView (決定 authentication state)
├─ case .loading
│  └─ SplashView
│     └─ Checks existing session
│        └─ If valid → .authenticated
│        └─ If invalid → .unauthenticated
│
├─ case .unauthenticated
│  ├─ If !hasCompletedOnboarding
│  │  └─ OnboardingCarouselView (3 pages)
│  │     └─ Taps "Get Started" → completeOnboarding()
│  │        └─ Shows AuthView
│  └─ Else
│     └─ AuthView (Email + LinkedIn auth)
│        └─ Success → .authenticated
│
└─ case .authenticated
   └─ MainTabView
      ├─ Tab 0: Search Stack
      │  └─ SearchUploadView
      │     ├─ Upload resume → SearchAnalyzingView
      │     │  └─ Poll session → SearchResultsView
      │     └─ Tap "Last Search" → SearchResultsView (historical)
      │
      └─ Tab 1: Dashboard Stack
         └─ DashboardView
            └─ Tap session card → SearchResultsView (historical)
```

### Navigation Stacks

Each tab has its own `NavigationStack`:

```swift
struct MainTabView: View {
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack {
                SearchUploadView()
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tag(AppState.Tab.search)
            
            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("Dashboard", systemImage: "rectangle.stack") }
            .tag(AppState.Tab.dashboard)
        }
    }
}
```

**Benefits**:
- Each tab maintains its own navigation history
- Switching tabs preserves navigation state
- Deep linking possible within each stack

---

## Backend API Integration

### APIService (Singleton)

**File**: `Network/APIService.swift`
**Base URL**: `https://www.jobmatchnow.ai`

```swift
class APIService {
    static let shared = APIService()
    private let baseURL = "https://www.jobmatchnow.ai"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
    }
}
```

### API Endpoints

#### 1. Upload Resume

**Method**: `POST /api/resume`
**Content-Type**: `multipart/form-data`

```swift
func uploadResume(fileURL: URL) async throws -> String {
    // 1. Read file data from disk
    let fileData = try Data(contentsOf: fileURL)
    
    // 2. Detect MIME type (PDF, DOCX, DOC, etc.)
    let mimeType = getMimeType(for: fileURL)
    
    // 3. Build multipart form data
    let boundary = "Boundary-\(UUID().uuidString)"
    var body = Data()
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n")
    body.append("Content-Type: \(mimeType)\r\n\r\n")
    body.append(fileData)
    body.append("\r\n--\(boundary)--\r\n")
    
    // 4. Send POST request
    var request = URLRequest(url: URL(string: "\(baseURL)/api/resume")!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpBody = body
    
    // 5. Parse response
    let (data, response) = try await session.data(for: request)
    let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
    
    // 6. Return view_token
    return uploadResponse.view_token
}
```

**Response**:
```json
{
  "user_search_id": "uuid",
  "view_token": "token_abc123",
  "search_session_id": "uuid"
}
```

**view_token**: Used for all subsequent API calls to retrieve jobs and session status

#### 2. Get Session Status (Polling)

**Method**: `GET /api/public/session?token={view_token}`

```swift
func getSessionStatus(viewToken: String) async throws -> SessionStatus {
    let url = URL(string: "\(baseURL)/api/public/session?token=\(viewToken)")!
    let (data, _) = try await session.data(from: url)
    return try JSONDecoder().decode(SessionStatus.self, from: data)
}
```

**Response**:
```json
{
  "status": "processing" | "completed" | "failed",
  "created_at": "2024-01-15T10:30:00Z",
  "error_message": null
}
```

**Polling Logic**:
```swift
// In SearchAnalyzingView
func pollSessionStatus() async {
    while true {
        let status = try await APIService.shared.getSessionStatus(viewToken: viewToken)
        
        switch status.status {
        case "completed":
            await loadJobs()
            return
        case "failed":
            showError = true
            return
        default:
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
    }
}
```

#### 3. Get Jobs

**Method**: `GET /api/public/jobs?token={view_token}&scope={local|national}`

```swift
func getJobs(viewToken: String, scope: LocationScope? = nil) async throws -> [Job] {
    var urlComponents = URLComponents(string: "\(baseURL)/api/public/jobs")!
    var queryItems = [URLQueryItem(name: "token", value: viewToken)]
    
    if let scope = scope {
        queryItems.append(URLQueryItem(name: "scope", value: scope.rawValue))
    }
    
    urlComponents.queryItems = queryItems
    
    let (data, _) = try await session.data(from: urlComponents.url!)
    return try JSONDecoder().decode([Job].self, from: data)
}
```

**Response**:
```json
[
  {
    "id": "uuid",
    "job_id": "job_123",
    "title": "iOS Developer",
    "company_name": "Tech Corp",
    "location": "San Francisco, CA",
    "posted_at": "2 days ago",
    "job_url": "https://...",
    "source_query": "iOS developer",
    "category": "direct",
    "is_remote": true
  }
]
```

**Parameters**:
- `token`: view_token from upload
- `scope`: (optional) `local` or `national` for location filtering

#### 4. Get Job Explanation (AI-Generated)

**Method**: `POST /api/jobs/explanation`
**Content-Type**: `application/json`

```swift
func getJobExplanation(jobId: String, viewToken: String) async throws -> JobExplanation {
    var request = URLRequest(url: URL(string: "\(baseURL)/api/jobs/explanation")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = ExplanationRequest(jobId: jobId, viewToken: viewToken)
    request.httpBody = try JSONEncoder().encode(body)
    
    let (data, _) = try await session.data(for: request)
    return try JSONDecoder().decode(JobExplanation.self, from: data)
}
```

**Request**:
```json
{
  "job_id": "job_123",
  "view_token": "token_abc123"
}
```

**Response**:
```json
{
  "explanation_summary": "This role aligns strongly with your background...",
  "bullets": [
    "5+ years iOS experience matches your 7 years in Swift/SwiftUI",
    "Team leadership requirement aligns with your management experience"
  ]
}
```

#### 5. Get Dashboard Summary

**Method**: `GET /api/me/dashboard`
**Authentication**: Required (user-specific data)

```swift
func getDashboard() async throws -> DashboardSummary {
    let url = URL(string: "\(baseURL)/api/me/dashboard")!
    let (data, _) = try await session.data(from: url)
    return try JSONDecoder().decode(DashboardSummary.self, from: data)
}
```

**Response**:
```json
{
  "total_searches": 12,
  "total_jobs_found": 487,
  "avg_jobs_per_search": 40.6,
  "recent_sessions": [
    {
      "id": "session_1",
      "title": "Chief Financial Officer",
      "created_at": "2024-01-15T10:30:00Z",
      "total_jobs": 95,
      "direct_count": 62,
      "adjacent_count": 33,
      "view_token": "token_abc123"
    }
  ]
}
```

---

## Core Features

### 1. Resume Upload & Job Matching

**Flow**:
```
SearchUploadView
    ↓
User selects PDF/DOCX file via UIDocumentPickerViewController
    ↓
POST /api/resume (multipart/form-data)
    ↓
Receive view_token
    ↓
Navigate to SearchAnalyzingView
    ↓
Poll GET /api/public/session every 2s
    ↓
When status = "completed":
    GET /api/public/jobs?token={view_token}
    ↓
Navigate to SearchResultsView with jobs
```

**Sample Resume Feature**:
```swift
// SearchUploadView
Button("Use sample resume") {
    let sampleURL = Bundle.main.url(forResource: "SampleResume", withExtension: "pdf")
    uploadResume(fileURL: sampleURL!)
}
```

**Purpose**: Demo mode for testing without user's resume

### 2. Location Scope Filtering

**UI Component**: `LocationScopeToggle`
**File**: `Search/SearchResultsView.swift`

```swift
enum LocationScope: String {
    case local = "local"
    case national = "national"
}

struct LocationScopeToggle: View {
    @Binding var selectedScope: LocationScope
    let isLoading: Bool
    
    var body: some View {
        HStack {
            Button("📍 Local") { selectedScope = .local }
            Button("🌍 National") { selectedScope = .national }
        }
    }
}
```

**Integration with ResultsViewModel**:
```swift
@MainActor
class ResultsViewModel: ObservableObject {
    @Published var locationScope: LocationScope = .local {
        didSet {
            if oldValue != locationScope {
                Task { await refreshJobs() }
            }
        }
    }
    
    func refreshJobs() async {
        isRefreshing = true
        let newJobs = try await apiService.getJobs(viewToken: viewToken, scope: locationScope)
        jobs = newJobs
        isRefreshing = false
    }
}
```

**Flow**:
```
User taps "National" toggle
    ↓
locationScope.didSet triggered
    ↓
refreshJobs() called
    ↓
Loading overlay shown
    ↓
GET /api/public/jobs?token=xxx&scope=national
    ↓
New jobs returned
    ↓
viewModel.jobs updated
    ↓
SwiftUI re-renders list
```

### 3. Job Filtering (All/Remote)

**UI Component**: Segmented Picker
**File**: `Search/SearchResultsView.swift`

```swift
enum JobFilter: String, CaseIterable {
    case all = "All"
    case remote = "Remote"
}

Picker("Filter", selection: $selectedFilter) {
    Text("All (\(viewModel.jobs.count))").tag(JobFilter.all)
    Text("Remote (\(remoteCount))").tag(JobFilter.remote)
}
.pickerStyle(SegmentedPickerStyle())
```

**Filtering Logic**:
```swift
var filteredJobs: [Job] {
    var result = viewModel.jobs
    
    // Apply remote filter
    switch selectedFilter {
    case .all:
        break
    case .remote:
        result = result.filter { $0.isRemote }
    }
    
    // Apply search text filter
    if !searchText.isEmpty {
        result = result.filter { job in
            job.title.localizedCaseInsensitiveContains(searchText) ||
            job.company_name.localizedCaseInsensitiveContains(searchText) ||
            job.location.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    return result
}
```

**Filter Hierarchy**:
1. **Location Scope** (Local/National) → API fetch
2. **Remote Filter** (All/Remote) → Local filtering
3. **Search Text** → Further local filtering

### 4. AI Job Explanations

**Manager**: `ExplanationManager`
**File**: `Search/ExplanationManager.swift`

```swift
@MainActor
class ExplanationManager: ObservableObject {
    @Published private(set) var explanationStates: [String: ExplanationState] = [:]
    @Published var expandedJobIds: Set<String> = []
    
    func toggleExpanded(_ jobId: String) {
        if expandedJobIds.contains(jobId) {
            expandedJobIds.remove(jobId)
        } else {
            expandedJobIds.insert(jobId)
            // Auto-load explanation on first expand
            if case .idle = state(for: jobId) {
                loadExplanation(for: jobId)
            }
        }
    }
    
    func loadExplanation(for jobId: String) {
        explanationStates[jobId] = .loading
        
        Task {
            let explanation = try await apiService.getJobExplanation(
                jobId: jobId,
                viewToken: viewToken
            )
            explanationStates[jobId] = .loaded(explanation)
        }
    }
}
```

**State Management**:
```swift
enum ExplanationState: Equatable {
    case idle        // Not loaded yet
    case loading     // API request in progress
    case loaded(JobExplanation)  // Success
    case error(String)           // Failed
}
```

**UI Integration**:
```swift
struct JobCardView: View {
    let job: Job
    let explanationState: ExplanationState
    let isExpanded: Bool
    
    var body: some View {
        VStack {
            // Job details
            
            // "Why this matches you" row
            Button("Why this matches you") {
                onToggleExpand()
            }
            
            // Expanded explanation section
            if isExpanded {
                switch explanationState {
                case .loading:
                    ProgressView("Analyzing...")
                case .loaded(let explanation):
                    Text(explanation.explanationSummary)
                    ForEach(explanation.bullets) { bullet in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(bullet)
                        }
                    }
                case .error(let message):
                    Text(message)
                    Button("Try Again") { onRetryExplanation() }
                default:
                    EmptyView()
                }
            }
        }
    }
}
```

**Caching**:
- Once loaded, explanation stays in `explanationStates` dictionary
- Collapsing/re-expanding doesn't re-fetch
- Survives scroll (LazyVStack cell reuse)

### 5. Dashboard Metrics & History

**ViewModel**: `DashboardViewModel`
**File**: `Dashboard/DashboardViewModel.swift`

```swift
@MainActor
class DashboardViewModel: ObservableObject {
    @Published private(set) var summary: DashboardSummary?
    @Published private(set) var viewState: DashboardViewState = .loading
    
    func loadDashboard() async {
        viewState = .loading
        
        let summary = try await apiService.getDashboard()
        self.summary = summary
        
        if summary.totalSearches == 0 {
            viewState = .empty
        } else {
            viewState = .loaded
        }
    }
}
```

**View States**:
```swift
enum DashboardViewState {
    case loading   // Fetching data
    case loaded    // Data displayed
    case empty     // No search history yet
    case error(String)  // Fetch failed
}
```

**UI Layout**:
```
┌─────────────────────────────────────┐
│          Dashboard                  │
├─────────────────────────────────────┤
│  Summary Strip Card:                │
│  ┌──────────┬──────────┬──────────┐ │
│  │ 🔍 12    │ 💼 487   │ 📊 40.6  │ │
│  │ Searches │ Jobs    │ Avg/Search│ │
│  └──────────┴──────────┴──────────┘ │
│                                     │
│  Recent Searches:                   │
│  ┌─────────────────────────────────┐ │
│  │ Chief Financial Officer      >  │ │
│  │ Jan 15, 2024 at 10:30 AM        │ │
│  │ ───────────────────────────     │ │
│  │  95 Total │ 62 Direct │ 33 Adj  │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Navigation to Historical Results**:
```swift
func loadSessionResults(_ session: DashboardSessionSummary) {
    isLoadingSession = true
    
    Task {
        let jobs = try await apiService.getJobs(viewToken: session.viewToken)
        
        loadedJobs = jobs
        selectedViewToken = session.viewToken
        navigateToResults = true
    }
}
```

### 6. Last Search Quick Access

**Storage**: `AppState.lastSearch`
**Persistence**: UserDefaults (JSON encoded)

**Save on Upload Success**:
```swift
// After getting jobs from API
let lastSearchInfo = AppState.LastSearchInfo(
    viewToken: viewToken,
    date: Date(),
    totalMatches: jobs.count,
    directMatches: jobs.filter { $0.category == "direct" }.count,
    adjacentMatches: jobs.filter { $0.category == "adjacent" }.count,
    label: inferredJobTitle
)
AppState.shared.saveLastSearch(lastSearchInfo)
```

**Display on Upload Screen**:
```swift
if let lastSearch = appState.lastSearch {
    LastSearchCard(lastSearch: lastSearch) {
        // Load jobs and navigate
        loadLastSearchResults(lastSearch)
    }
}
```

**Load Historical Results**:
```swift
func loadLastSearchResults(_ lastSearch: AppState.LastSearchInfo) {
    isLoadingLastSearch = true
    
    Task {
        let jobs = try await APIService.shared.getJobs(viewToken: lastSearch.viewToken)
        
        lastSearchJobs = jobs
        navigateToLastSearch = true
    }
}
```

---

## Data Models

### Job
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
    
    enum CodingKeys: String, CodingKey {
        case id, job_id, title, company_name, location
        case posted_at, job_url, source_query, category
        case isRemote = "is_remote"
    }
}
```

### JobExplanation
```swift
struct JobExplanation: Decodable {
    let explanationSummary: String
    let bullets: [String]
    
    enum CodingKeys: String, CodingKey {
        case explanationSummary = "explanation_summary"
        case bullets
    }
}
```

### DashboardSummary
```swift
struct DashboardSummary: Decodable {
    let totalSearches: Int
    let totalJobsFound: Int
    let avgJobsPerSearch: Double
    let recentSessions: [DashboardSessionSummary]
    
    enum CodingKeys: String, CodingKey {
        case totalSearches = "total_searches"
        case totalJobsFound = "total_jobs_found"
        case avgJobsPerSearch = "avg_jobs_per_search"
        case recentSessions = "recent_sessions"
    }
}
```

### DashboardSessionSummary
```swift
struct DashboardSessionSummary: Identifiable, Decodable {
    let id: String
    let title: String?
    let createdAt: Date
    let totalJobs: Int
    let directCount: Int
    let adjacentCount: Int
    let viewToken: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case createdAt = "created_at"
        case totalJobs = "total_jobs"
        case directCount = "direct_count"
        case adjacentCount = "adjacent_count"
        case viewToken = "view_token"
    }
}
```

### SearchSession
```swift
struct SearchSession: Identifiable, Codable {
    let id: String
    let viewToken: String
    let createdAt: Date
    let label: String?
    let totalMatches: Int
    let directMatches: Int
    let adjacentMatches: Int
    let status: String?
    
    var displayLabel: String {
        label ?? "Search #\(id.prefix(8))"
    }
}
```

---

## UI Design System

### ThemeColors (Design Tokens)

**File**: `Core/ThemeColors.swift`

```swift
enum ThemeColors {
    // Brand / CTA
    static let primaryBrand = Color(hex: "FF7538")  // Atomic Tangerine
    
    // Complementary Blues
    static let primaryComplement = Color(hex: "38A1FF")  // Sky Blue
    static let softComplement = Color(hex: "A1D6FF")     // Ice Blue
    static let deepComplement = Color(hex: "005D8A")     // Deep Cyan
    static let midnight = Color(hex: "0D3A6A")           // Midnight Navy
    
    // Warm Accent
    static let warmAccent = Color(hex: "FFB140")  // Honey
    
    // Neutrals
    static let surfaceLight = Color(hex: "F9F9F9")  // Light Gray
    static let surfaceWhite = Color(hex: "FFFFFF")  // Pure White
    static let borderSubtle = Color(hex: "E5E7EB")  // Gray-Blue
    
    // Utility
    static let errorRed = Color(hex: "E74C3C")     // Bright Red
    static let textOnLight = Color(hex: "0D3A6A")  // Midnight Navy
    static let textOnDark = Color(hex: "F9F9F9")   // Light Gray
}
```

### Color Usage Guidelines

**Primary Actions (Upload, Get Matches, Sign In)**:
- Background: `ThemeColors.primaryBrand` (Orange)
- Text: `ThemeColors.textOnDark` (White)

**Secondary Actions (View Details, filters)**:
- Background: `ThemeColors.primaryComplement` (Blue)
- Text: `ThemeColors.textOnDark`

**Success States (Completed steps)**:
- Icon/Text: `ThemeColors.primaryComplement`

**Warning States (Non-critical alerts)**:
- Background: `ThemeColors.warmAccent.opacity(0.1)`
- Text: `ThemeColors.warmAccent`

**Error States (Failed operations)**:
- Background: `ThemeColors.errorRed.opacity(0.1)`
- Text: `ThemeColors.errorRed`

**Remote Badge**:
- Background: `ThemeColors.primaryComplement.opacity(0.15)`
- Text: `ThemeColors.primaryComplement`

### Typography

**Theme.swift** (deprecated, use ThemeColors directly):
```swift
struct Theme {
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
}
```

**SwiftUI Font Scale**:
- `.largeTitle`: Main headers (e.g., "Your Job Matches")
- `.title`: Section headers
- `.title2`: Secondary headers
- `.headline`: Card titles, important labels
- `.subheadline`: Meta info, descriptions
- `.body`: Regular text
- `.caption`: Timestamps, hints

---

## File Structure

```
JobMatchNow/
├── Assets.xcassets/
│   ├── AppIcon.appiconset/
│   │   ├── Contents.json
│   │   └── AppIcon.png (1024x1024)
│   └── AccentColor.colorset/
│
├── Auth/
│   ├── AuthManager.swift          # Supabase authentication
│   └── AuthView.swift             # Email/LinkedIn sign-in UI
│
├── Core/
│   ├── AppDelegate.swift          # UIKit app entry point
│   ├── SceneDelegate.swift        # Window setup with RootHostingController
│   ├── StatusBarStyleManager.swift # Status bar style control
│   ├── AppState.swift             # Global state management
│   ├── RootView.swift             # Root navigation router
│   ├── MainTabView.swift          # Bottom tab bar (Search/Dashboard)
│   ├── SafariView.swift           # In-app web view
│   ├── Theme.swift                # (deprecated) Legacy theme
│   └── ThemeColors.swift          # Design token color system
│
├── Dashboard/
│   ├── DashboardModels.swift      # DashboardSummary, SessionSummary
│   ├── DashboardViewModel.swift   # MVVM business logic
│   └── DashboardView.swift        # Metrics & history UI
│
├── Models/
│   ├── JobExplanation.swift       # AI explanation models
│   └── SearchSession.swift        # Historical search model
│
├── Network/
│   └── APIService.swift           # All API endpoints
│
├── Onboarding/
│   ├── SplashView.swift           # Launch screen with session check
│   └── OnboardingCarouselView.swift # 3-page intro carousel
│
├── Search/
│   ├── SearchUploadView.swift         # Resume upload screen
│   ├── SearchAnalyzingView.swift      # Session polling screen
│   ├── SearchResultsView.swift        # Job cards list
│   ├── ResultsViewModel.swift         # Results state management
│   └── ExplanationManager.swift       # Per-job explanation state
│
├── Settings/
│   └── SettingsView.swift         # App settings & account info
│
├── Resources/
│   └── SampleResume.pdf           # Demo resume file
│
└── Info.plist                     # App configuration
```

---

## Key Architectural Patterns

### 1. MVVM Pattern

**Model**: Data structures (`Job`, `DashboardSummary`, etc.)
**View**: SwiftUI views (pure presentation)
**ViewModel**: Business logic (`ResultsViewModel`, `DashboardViewModel`)

**Example**:
```
DashboardView (View)
    ↓ observes
DashboardViewModel (ViewModel)
    ↓ calls
APIService (Service)
    ↓ fetches
DashboardSummary (Model)
```

### 2. Dependency Injection

ViewModels receive dependencies in initializer:
```swift
class ResultsViewModel: ObservableObject {
    private let apiService: APIService
    
    init(jobs: [Job], viewToken: String, apiService: APIService = .shared) {
        self.apiService = apiService
    }
}
```

**Benefits**:
- Testable (can inject mock APIService)
- Explicit dependencies
- Flexible architecture

### 3. Reactive State Management

All state changes propagate via `@Published` properties:
```swift
@Published var jobs: [Job] = []

// Change triggers SwiftUI re-render
jobs = newJobs
```

### 4. Async/Await for Concurrency

All network calls use Swift Concurrency:
```swift
func loadDashboard() async {
    let summary = try await apiService.getDashboard()
    self.summary = summary
}
```

**Called from SwiftUI**:
```swift
.onAppear {
    Task {
        await viewModel.loadDashboard()
    }
}
```

### 5. Error Handling

Errors propagate up and are handled at UI level:
```swift
do {
    let jobs = try await apiService.getJobs(viewToken: token)
} catch let error as APIError {
    self.errorMessage = error.localizedDescription
    self.viewState = .error
}
```

---

## Performance Optimizations

### 1. LazyVStack for Long Lists
```swift
ScrollView {
    LazyVStack(spacing: 16) {
        ForEach(jobs) { job in
            JobCardView(job: job)
        }
    }
}
```
**Benefit**: Cards rendered on-demand as user scrolls

### 2. Explanation Caching
```swift
var explanationStates: [String: ExplanationState] = [:]
```
**Benefit**: Once loaded, explanations persist during scroll

### 3. Debounced Search
```swift
@State private var searchText = ""

var filteredJobs: [Job] {
    if searchText.isEmpty { return jobs }
    return jobs.filter { /* filter logic */ }
}
```
**Benefit**: Filtering happens on UI thread, very fast for 100s of jobs

### 4. Session Caching
```swift
// Store session in AppState for quick re-access
AppState.shared.saveLastSearch(lastSearchInfo)
```
**Benefit**: User can return to last search without re-uploading

---

## Security Considerations

### 1. Token Storage
- Access tokens stored in UserDefaults (encrypted by iOS)
- Refresh tokens used to get new access tokens
- Tokens cleared on sign out

### 2. OAuth Flow
- Uses `ASWebAuthenticationSession` (system web view)
- User credentials never exposed to app
- Secure redirect via custom URL scheme

### 3. HTTPS Only
- All API calls use HTTPS
- Certificate pinning not implemented (relies on system trust)

### 4. No Sensitive Data in Logs
- Production builds should disable debug prints
- Tokens truncated in logs: `token.prefix(8)...`

---

## Testing Strategy

### Unit Tests (Recommended)
- Test ViewModels with mock APIService
- Test data model parsing (Decodable conformance)
- Test filter logic (filteredJobs computed property)

### UI Tests (Recommended)
- Test authentication flow
- Test resume upload flow
- Test job filtering
- Test explanation expansion

### Manual Testing Checklist
- [ ] Sign up with new email
- [ ] Sign in with existing email
- [ ] Sign in with LinkedIn
- [ ] Upload PDF resume
- [ ] Upload DOCX resume
- [ ] Use sample resume
- [ ] View job explanations
- [ ] Filter by remote
- [ ] Switch location scope
- [ ] Access last search
- [ ] View dashboard metrics
- [ ] Navigate to historical results
- [ ] Sign out

---

## Future Enhancements

### Potential Features
1. **Job Bookmarking**: Save favorite jobs
2. **Push Notifications**: New jobs matching profile
3. **Resume Versions**: Upload multiple resumes
4. **Job Application Tracking**: Track applied jobs
5. **Salary Insights**: Compensation data
6. **Company Reviews**: Glassdoor integration
7. **Interview Prep**: AI-generated interview questions
8. **Network Referrals**: LinkedIn connections at companies
9. **Job Alerts**: Email notifications for new matches
10. **Analytics Dashboard**: Application success rate

### Technical Debt
1. Add comprehensive unit tests
2. Implement proper error recovery (retry with exponential backoff)
3. Add analytics tracking (e.g., Mixpanel)
4. Implement crash reporting (e.g., Sentry)
5. Add accessibility labels (VoiceOver support)
6. Implement dark mode (currently light mode only)
7. Add localization for internationalization
8. Optimize image loading for job logos
9. Implement pagination for large result sets
10. Add offline mode with local caching

---

## Deployment

### App Store Configuration

**Bundle Identifier**: `com.jobmatchnow.ios`
**Minimum iOS Version**: 17.0
**Supported Devices**: iPhone only
**Orientation**: Portrait only

### Build Configuration

**Debug**:
- Detailed logging enabled
- Shorter timeouts for faster testing

**Release**:
- Logging disabled
- Production API endpoints
- Code optimization enabled

### URL Scheme

**Scheme**: `jobmatchnow://`
**Purpose**: OAuth callback handling

**Configured in Info.plist**:
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
```

---

## Troubleshooting Guide

### Common Issues

#### 1. "No input catalogs contained AppIcon"
**Cause**: AppIcon in wrong folder type
**Fix**: Ensure `AppIcon.appiconset/` exists (not `.imageset`)

#### 2. Status bar icons not visible
**Cause**: Status bar style not set
**Fix**: Use `.statusBarDarkContent()` or `.statusBarLightContent()` view modifiers

#### 3. OAuth callback not working
**Cause**: URL scheme not registered
**Fix**: Check `Info.plist` for `CFBundleURLSchemes`

#### 4. Session expired errors
**Cause**: Access token expired, refresh token failed
**Fix**: Clear app data and sign in again

#### 5. Resume upload fails
**Cause**: File too large or unsupported format
**Fix**: Check MIME type detection, file size limits

---

## Conclusion

This documentation provides a comprehensive overview of the JobMatchNow iOS app architecture, features, and implementation details. The app follows modern iOS development best practices with SwiftUI, MVVM architecture, and reactive state management.

**Key Strengths**:
- Clean separation of concerns (MVVM)
- Reactive UI with Combine
- Comprehensive error handling
- Secure authentication with Supabase
- Performant list rendering
- Intuitive user experience

**For Developers**:
- Follow existing patterns when adding features
- Use `ThemeColors` for all color values
- Create ViewModels for complex screens
- Write unit tests for business logic
- Document public APIs with code comments

**For Product**:
- All features map to backend API endpoints
- User flows are optimized for conversion
- Error states provide clear guidance
- Performance is optimized for large datasets

