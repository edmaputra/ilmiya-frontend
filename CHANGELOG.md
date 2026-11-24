# Changelog

## [Unreleased](https://github.com/edmaputra/ilmiya-frontend/compare/v0.9.0...HEAD)

### Features

* **iam,profile:** add account profile page and enforce tenant resource isolation ([8847d39](https://github.com/edmaputra/ilmiya-frontend/commit/8847d39))
  * Add self-service user profile page with account details, password updates, and session boundaries
  * Add superadmin account administration toolkit on profile screen for user governance
  * Integrate profile screen into shell navigation, persona menu, sidebar, and command palette
  * Fix cross-tenant resource leakage across users, groups, schools, and academic years
  * Display latest release tag version across UI (sidebar header, sidebar footer, profile security card, user menus)

## [0.9.0](https://github.com/edmaputra/ilmiya-frontend/compare/v0.8.0...v0.9.0) (2026-11-24)

### Features

* **iam:** add scope editing, reparenting, and scope-based boundary filtering ([#32](https://github.com/edmaputra/ilmiya-frontend/issues/32)) ([43c82f4](https://github.com/edmaputra/ilmiya-frontend/commit/43c82f4))
  * Add `PUT /api/v1/scopes/{id}` and `POST /api/v1/scopes/{id}/move` support
  * Implement `EditScopeDialog` with live path preview and eligible parent reparenting
  * Support depth computation and parentId inheritance in `ScopeTreeNode.fromJson`
  * Filter accessible schools in IAM console by actor scope boundaries
  * Add widget and unit tests for scope editing, reparenting, and boundary restrictions

## [0.8.0](https://github.com/edmaputra/ilmiya-frontend/compare/v0.7.0...v0.8.0) (2026-11-24)

### Features

* **tenant:** switch context switcher to tenant level and prioritize tenant display over school child ([#31](https://github.com/edmaputra/ilmiya-frontend/issues/31)) ([f2f04f0](https://github.com/edmaputra/ilmiya-frontend/commit/f2f04f0))
  * Streamline top navigation and tenant switcher dialog to operate at the tenant foundation level
  * Prioritize foundation names in header brand bar and sidebar context selectors

## [0.7.0](https://github.com/edmaputra/ilmiya-frontend/compare/v0.6.0...v0.7.0) (2026-11-24)

### Features

* **iam:** show human-readable scope label and path tooltip in users tab ([#30](https://github.com/edmaputra/ilmiya-frontend/issues/30)) ([5167b05](https://github.com/edmaputra/ilmiya-frontend/commit/5167b05))
  * Resolve raw scope IDs into human-readable formatted scope path labels and breadcrumbs
  * Add interactive tooltips displaying complete scope paths

### Bug Fixes

* **iam:** wrap scope badge text in flexible to prevent renderflex overflow ([5167b05](https://github.com/edmaputra/ilmiya-frontend/commit/5167b05))

## [0.6.0](https://github.com/edmaputra/ilmiya-frontend/compare/v0.5.1...v0.6.0) (2026-11-23)

### Features

* **iam:** improve scopes management, role boundaries, and target scope assignment ([#29](https://github.com/edmaputra/ilmiya-frontend/issues/29)) ([94e2526](https://github.com/edmaputra/ilmiya-frontend/commit/94e2526))
  * Enhance hierarchical scope visualization and administrative assignment
  * Enforce boundary constraints when assigning roles and scopes to users

### Bug Fixes

* **iam:** resolve mobile overflow and viewport height in iam scope tree ([94e2526](https://github.com/edmaputra/ilmiya-frontend/commit/94e2526))

## [0.5.1](https://github.com/edmaputra/ilmiya-frontend/compare/v0.5.0...v0.5.1) (2026-11-21)

### Bug Fixes

* **auth:** sanitize session and token expiry error details ([#28](https://github.com/edmaputra/ilmiya-frontend/issues/28)) ([995eb6d](https://github.com/edmaputra/ilmiya-frontend/commit/995eb6d))
  * Prevent raw exception traces from leaking into user-facing authentication toasts
  * Normalize session expired messages across token refresh and unauthorized states

## [0.5.0](https://github.com/edmaputra/ilmiya-frontend/compare/v0.4.0...v0.5.0) (2026-11-17)

### Features

* **iam:** support batch role assignment endpoint and improve macOS local networking ([#27](https://github.com/edmaputra/ilmiya-frontend/issues/27)) ([5d55f02](https://github.com/edmaputra/ilmiya-frontend/commit/5d55f02))
  * Integrate `POST /api/v1/users/{id}/roles/batch` in `AssignRoleDialog` and `IamService`
  * Add `AssignUserRoleRequest` and `AssignUserRolesBatchRequest` models in `iam.dart`
  * Redesign `AssignRoleDialog` with quick-select role chips, staged batch queue preview, and atomic batch submission
  * Implement `assignUserRolesBatch` in `MockStorageService` for offline/mock simulation
  * Add `HttpOverrides` to allow local development SSL certificates for localhost and `*.localhost` domains
  * Update macOS `Release.entitlements` with `network.server` entitlement for loopback connectivity
  * Configure `NSExceptionDomains` in macOS `Info.plist` for local development endpoints
  * Add comprehensive batch widget and service unit tests

### Bug Fixes

* **auth:** prevent 401 session expiration from platform tenant header ([5d55f02](https://github.com/edmaputra/ilmiya-frontend/commit/5d55f02))
  * Strip non-tenant keyword 'platform' from `X-Tenant-ID` headers in `ApiClient.request`
  * Guard `SchoolService` `getProfile`, `updateProfile`, and `configureSettings` to return empty without firing network calls during platform-level sessions
  * Avoid invoking school profile query in `AuthNotifier.refreshProfile` when `tenantId` is 'platform'
  * Support `PLATFORM_SUPERADMIN` and `ROLE_PLATFORM_SUPERADMIN` role identifiers across IAM models and permission checks
  * Add live mode tests for platform tenant header sanitization and school profile guard
* **navigation:** prevent `NavigationBar` destination assertion on compact viewport ([5d55f02](https://github.com/edmaputra/ilmiya-frontend/commit/5d55f02))
  * Avoid instantiating `NavigationBar` with fewer than 2 destinations when in platform superadmin session on compact viewports
  * Add widget test verifying clean build without assertion on compact viewport

## [0.4.0](https://github.com/edmaputra/ilmiya-frontend/compare/v0.3.0...v0.4.0) (2026-11-16)

### Features

* **iam,tenant:** support multi-role/group assignment, school-anchored scopes, and separated schools console ([#26](https://github.com/edmaputra/ilmiya-frontend/issues/26)) ([4a398f4](https://github.com/edmaputra/ilmiya-frontend/commit/4a398f4))
  * Redesign `AssignRoleDialog` into a two-tab console for multi-role and group management
  * Enforce school prerequisite and base path format (`<tenantId>/<school_id>/...`) for scope trees
  * Move Schools & Campuses to dedicated submenu under Institution & Control
  * Restrict session switching strictly to Tenants (Foundations)
  * Isolate superadmin platform session and provision tenant admin root scopes

## [0.3.0](https://github.com/edmaputra/ilmiya-frontend/compare/v0.2.2...v0.3.0) (2026-11-16)

### Features

* **tenant:** improve empty superadmin state, dynamic tenant switcher, and scope assignment ([#25](https://github.com/edmaputra/ilmiya-frontend/issues/25)) ([fe6d595](https://github.com/edmaputra/ilmiya-frontend/commit/fe6d595))
  * Handle empty tenant state for superadmin gracefully without fallback defaults:
    * Add `SchoolResponse.empty()` model factory
    * Return empty profile in `SchoolService` and `MockStorageService` when `tenantId` is empty
    * Keep `tenantId` empty in `AuthNotifier` when no tenants exist or `tenantId` is blank
    * Hide school profile title, badges, and switcher options under top bar header
  * Dynamically load registered schools in `AppShellTenantDialog` and `HeaderTenantSwitcherDialog` so newly created tenants are listed immediately
  * Rename IAM user action button to 'Assign Role & Scope' and support selecting scope node partitions
  * Remove legacy 'springfield' domain and test references across codebase and tests

## [0.2.2](https://github.com/edmaputra/ilmiya-frontend/compare/v0.2.1...v0.2.2) (2026-11-16)

### Bug Fixes

* **iam,tenant,navigation:** address user management, tenant school filtering, and session reset ([#24](https://github.com/edmaputra/ilmiya-frontend/issues/24)) ([92c8694](https://github.com/edmaputra/ilmiya-frontend/commit/92c8694))
  * Enable user profile editing and password reset with `EditUserDialog` in IAM Console
  * Display assigned roles chips for all users in IAM Users list
  * Hide Executive Dashboard, Courses & Grades, and Communications & Labs submenus while preserving underlying implementations
  * Filter Schools & Campuses by active tenant foundation selection and bypass tenant header when loading superadmin school directory
  * Completely purge session and teardown widget subtree on logout/login so next user starts from dashboard
  * Add and update comprehensive unit and widget tests

## [0.2.1](https://github.com/edmaputra/ilmiya-frontend/compare/v0.2.0...v0.2.1) (2026-11-16)

### Features

* **ci:** implement tag-only automated semantic release on merge to main ([#23](https://github.com/edmaputra/ilmiya-frontend/issues/23)) ([c653c53](https://github.com/edmaputra/ilmiya-frontend/commit/c653c53))
  * Implement tag-only automated semantic release on merge to main branch using `github-tag-action`

## [0.2.0](https://github.com/edmaputra/ilmiya-frontend/compare/ilmiya_app-v0.1.0...ilmiya_app-v0.2.0) (2026-11-15)


### Features

* **auth,iam:** enhance auth flow, redesign IAM console, and support profile-based API mode ([fee1b93](https://github.com/edmaputra/ilmiya-frontend/commit/fee1b93ba869f90f7b84761339a0984e4909463a))
* **auth,iam:** enhance auth flow, redesign IAM console, and support profile-based API mode ([4656be8](https://github.com/edmaputra/ilmiya-frontend/commit/4656be8b363c5e186d78bc20bba366745879e090))
* **auth:** add 401/403 session guard, login redirection, and live API authentication support ([b5ea6e3](https://github.com/edmaputra/ilmiya-frontend/commit/b5ea6e3b253a5a0a97eb13651431f8a810fe027f))
* **auth:** add 401/403 session guard, login redirection, and live REST API support ([29d3c8c](https://github.com/edmaputra/ilmiya-frontend/commit/29d3c8cc435f69b866cf334ad8d7e61e174b09ab))
* **auth:** add login theme toggle, searchable tenant switcher, and session persistence ([a030e1e](https://github.com/edmaputra/ilmiya-frontend/commit/a030e1e3e3426de02cf54ccd414cd98b9e8c9c6f))
* **auth:** login theme toggle, searchable tenant switcher, and session persistence ([c0028a3](https://github.com/edmaputra/ilmiya-frontend/commit/c0028a304292f01551113cc7a39b7d5467d5995f))
* **ci:** adopt agent CI workflow, formatting, and coverage gates ([828aaf9](https://github.com/edmaputra/ilmiya-frontend/commit/828aaf9858d12562644551c4b14eae79fe45f955))
* **ci:** adopt agent CI workflow, formatting, and coverage gates ([49ebf25](https://github.com/edmaputra/ilmiya-frontend/commit/49ebf25ccc149fbc6c2f7f2aa8d6bbc9cc3f1752))
* convert frontend to Flutter multiplatform with backend and ed-iam security integration ([1f30a02](https://github.com/edmaputra/ilmiya-frontend/commit/1f30a0204379531de6e10209af1c90778838abc9))
* **devops:** prepare web deployment containerization and runtime config for CI/CD ([d531076](https://github.com/edmaputra/ilmiya-frontend/commit/d53107625691c0521e506537f941344a13a282cf))
* **devops:** prepare web deployment containerization and runtime config for CI/CD ([d5ec3a5](https://github.com/edmaputra/ilmiya-frontend/commit/d5ec3a5688e34b62f115c9c1106cf293f865b8bc))
* Flutter multiplatform migration with Ilmiya backend and ed-iam security integration ([9981e90](https://github.com/edmaputra/ilmiya-frontend/commit/9981e906f594b32bfc2d3cedc8c68f05166dd280))
* implement UI and client services for Ilmiya backend and ed-iam management ([829ddbf](https://github.com/edmaputra/ilmiya-frontend/commit/829ddbf029ca17930963abb73de4a8df3edb19d6))
* initialize OpenSIS project structure ([2f9c073](https://github.com/edmaputra/ilmiya-frontend/commit/2f9c073b8f9a43aa4ff80f5624d291ffc69dbb70))
* integrate ed-iam authentication, session refresh, and RBAC permission guards ([b4a6ea4](https://github.com/edmaputra/ilmiya-frontend/commit/b4a6ea463776486bf5ff9c95a9521f29b2e3d9ed))
* Migrate Ilmiya to Flutter Multiplatform (iOS, Android, Web, Linux) ([7fad197](https://github.com/edmaputra/ilmiya-frontend/commit/7fad1974349f00ec89e5c15a3624b41f77d63663))
* migrate project to Flutter multiplatform (iOS, Android, Web, Linux) ([4551edb](https://github.com/edmaputra/ilmiya-frontend/commit/4551edba7089a3e6bdc5717b49f04dde4ae60149))
* **platform:** add iOS support and cleanup platform scaffolding ([500028f](https://github.com/edmaputra/ilmiya-frontend/commit/500028f37e3ad3bf165c695e28b91120c40743f8))
* **platform:** add macOS desktop support ([67f8b1a](https://github.com/edmaputra/ilmiya-frontend/commit/67f8b1aadb17675638f9f1e51d02c4f4f1b1251f))
* **school:** add dedicated superadmin tenant profile management console ([642474c](https://github.com/edmaputra/ilmiya-frontend/commit/642474c4a51e6f16dad01bc7bb7cf389c1028432))
* **school:** add dedicated superadmin tenant profile management console ([bb76174](https://github.com/edmaputra/ilmiya-frontend/commit/bb76174d343a85cf029c40b991000dfa501e0a14))
* **security:** retain session and display error message on 403 access denied ([7bfd7d8](https://github.com/edmaputra/ilmiya-frontend/commit/7bfd7d8dd12702a6774d2258066b46f2d31efe1a))
* **tenant:** implement tenant foundation and school hierarchy in frontend ([#19](https://github.com/edmaputra/ilmiya-frontend/issues/19)) ([cbe4989](https://github.com/edmaputra/ilmiya-frontend/commit/cbe49892e5d8eca4d9432838dc81dc755eb26637))
* **tenant:** separate foundation and school registration workflows ([#20](https://github.com/edmaputra/ilmiya-frontend/issues/20)) ([556a607](https://github.com/edmaputra/ilmiya-frontend/commit/556a607fe292333de47699ed59d1aa68bce9582b))
* **theme:** modernize UI themes with Kite styling and resolve mobile layout overflows ([d64bec2](https://github.com/edmaputra/ilmiya-frontend/commit/d64bec298789625b82e825ae38c36dda31058ac1))
* **theme:** modernize UI themes with Kite styling and resolve mobile layout overflows ([0d21366](https://github.com/edmaputra/ilmiya-frontend/commit/0d21366a5ad6f09c44da4e48fd1f2f4d51b119c6))
* **ui:** improve mobile responsiveness, tenant reactivity, and clean legacy files ([9c422ee](https://github.com/edmaputra/ilmiya-frontend/commit/9c422ee4fdb607aa98bbff9a11797dd87f413a9e))
* **ui:** improve mobile text scaling, add school icon, and enforce flutter standards ([cf7b50e](https://github.com/edmaputra/ilmiya-frontend/commit/cf7b50e18d2809d18eab5abfb320a59a1b2da8c5))
* **ui:** improve mobile text scaling, add school icon, and enforce flutter standards ([7d3955a](https://github.com/edmaputra/ilmiya-frontend/commit/7d3955a564ce86bb60c2648f7eba2fdac1751a61))
* **ui:** redesign dashboard using Kite admin framework and improve adaptability ([d12ea38](https://github.com/edmaputra/ilmiya-frontend/commit/d12ea381e5a1e1a8364838365d577ead4541db02))
* **ui:** Redesign dashboard using Kite admin framework and improve adaptability ([1e5311b](https://github.com/edmaputra/ilmiya-frontend/commit/1e5311b4d56e7be654039898e5a68ca66ed6c732))


### Bug Fixes

* **auth:** enable submitting login credentials via Enter key ([2a1981f](https://github.com/edmaputra/ilmiya-frontend/commit/2a1981f4b85cc5c819e8e3c3b04aeb81085e075f))
* **build:** update Dockerfile flutter image to stable and fix kite_ui SDK compatibility ([99597b4](https://github.com/edmaputra/ilmiya-frontend/commit/99597b4e3a816b0ba89ddea66b8fde63f520c10e))
* **build:** update Dockerfile flutter image to stable and fix kite_ui SDK compatibility ([50ae32b](https://github.com/edmaputra/ilmiya-frontend/commit/50ae32bd33d976bfed9d33e805c19f2bca7da561))
* **core:** make ApiClient reactive and fix Live REST API toggle ([4a0aab5](https://github.com/edmaputra/ilmiya-frontend/commit/4a0aab508bc2b9bc5925891f9bce85659bf3cff8))
* **kite_ui:** resolve deprecated_member_use analysis errors on Flutter 3.50+ ([3683352](https://github.com/edmaputra/ilmiya-frontend/commit/368335235398add7a259b07f59e7aa02cd38c9af))
* **macos:** enable network client entitlement and ATS for desktop ([e606fbc](https://github.com/edmaputra/ilmiya-frontend/commit/e606fbc52ce25712d608972f0d83d9ac078b6d8f))
* **school:** resolve layout overflows and improve responsiveness in tenant management ([79a1caf](https://github.com/edmaputra/ilmiya-frontend/commit/79a1caf747a070dc56f850cac3ab23cc62e3299c))
* **school:** resolve layout overflows and improve responsiveness in tenant management ([f214385](https://github.com/edmaputra/ilmiya-frontend/commit/f21438553df0f3069b5185e828558516c0eea90a))
* **theme:** optimize responsive layouts for mobile viewports and resolve static analysis ([f98b65f](https://github.com/edmaputra/ilmiya-frontend/commit/f98b65fc734f7fd2c0e785a68e29bae860f562db))
