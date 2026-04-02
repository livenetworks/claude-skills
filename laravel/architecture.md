# Laravel Architecture Reference

> Extracted from the architecture skill — Laravel-specific structure, workflow, and operational concerns.

---

## 1. Project Structure

### Laravel Project Layout

```
app/
├── Console/              ← Artisan commands
├── DTOs/                 ← Data Transfer Objects (Message, FileUploadData)
├── Events/               ← Domain events (ItemCreated, ItemUpdated)
├── Exceptions/           ← Custom exceptions (DomainException, InvalidStateException)
├── Http/
│   ├── Controllers/      ← Thin controllers extending LNController
│   ├── Middleware/        ← Custom middleware
│   └── Requests/         ← Form Request validation classes
├── Listeners/            ← Event listeners (side effects only)
├── Models/               ← Eloquent models (LNWriteModel, LNReadModel, Model)
├── Policies/             ← Authorization policies
├── Providers/            ← Service providers (view composers registered here)
├── Services/             ← Business logic (injected into controllers)
│   ├── ItemService.php
│   ├── FileUploadService.php
│   └── Contexts/         ← FileContextInterface implementations
├── Traits/               ← Shared traits (HasRoles, etc.)
└── View/
    └── Composers/        ← View composers

config/                   ← App configuration
database/
├── migrations/           ← Ordered by date + sequence
└── seeders/              ← Reference data seeders (if needed)

resources/
├── views/
│   ├── layouts/          ← _ln.blade.php, _app.blade.php, _ajax.blade.php
│   ├── components/       ← Blade components (<x-ln.modal>, <x-ln.toast>)
│   ├── {feature}/        ← Feature views (items/, users/, reports/)
│   │   ├── index.blade.php
│   │   ├── show.blade.php
│   │   ├── _form.blade.php        ← Partial (always has a ViewComposer)
│   │   └── _panel-{name}.blade.php ← Panel partial
│   └── auth/             ← Login, register, etc.
├── css/                  ← or scss/ — project styles
├── js/                   ← Project JS (coordinators)
└── lang/                 ← Translation files

routes/
├── web.php               ← Web routes (Blade SSR projects)
└── api.php               ← API routes (if needed)

public/                   ← Web root
storage/                  ← Logs, uploads, cache
tests/                    ← Test files
```

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Controller | PascalCase, plural, `Controller` suffix | `ItemsController` |
| Model (write) | PascalCase, singular | `Item` |
| Model (read) | `V` prefix, PascalCase | `VItems` |
| Service | PascalCase, singular, `Service` suffix | `ItemService` |
| Form Request | `Store`/`Update` prefix, `Request` suffix | `StoreItemRequest` |
| Policy | PascalCase, singular, `Policy` suffix | `ItemPolicy` |
| Event | PascalCase, past tense | `ItemCreated` |
| Listener | PascalCase, descriptive | `SendItemNotification` |
| Composer | PascalCase, `Composer` suffix | `ItemFormComposer` |
| DTO | PascalCase, descriptive | `Message`, `FileUploadData` |
| Exception | PascalCase, `Exception` suffix | `InvalidStateException` |
| Middleware | PascalCase, descriptive | `CheckPermission` |
| Migration | `snake_case` with date prefix | `2025_01_15_000001_create_items_table` |
| View | `kebab-case` or `snake_case` | `items/index.blade.php` |
| Route name | `dot.notation` | `items.index`, `items.store` |
| Config key | `snake_case` | `app.timezone` |

### Feature Organization

New features follow a consistent pattern:

```
New feature "Reports":
1. Model:       app/Models/Report.php + app/Models/VReports.php
2. Migration:   database/migrations/..._create_reports_table.php
3. View:        database/migrations/..._create_v_reports_view.php
4. Service:     app/Services/ReportService.php
5. Controller:  app/Http/Controllers/ReportsController.php
6. Request:     app/Http/Requests/StoreReportRequest.php
7. Views:       resources/views/reports/index.blade.php, show.blade.php, _form.blade.php
8. Composer:    app/View/Composers/ReportFormComposer.php
9. Event:       app/Events/ReportCreated.php (if side effects needed)
10. Route:      routes/web.php (add to auth group)
```

### Rules

- **Feature = vertical slice** — all pieces of a feature live in their standard locations, named consistently
- **No feature folders** — don't create `app/Features/Reports/` with controller+model+service inside; use Laravel's standard structure
- **Flat is better than nested** — `app/Services/ReportService.php` not `app/Services/Reports/ReportService.php` (unless there are 3+ service files for one feature)
- **Don't create structure you don't need yet** — no empty folders, no placeholder files

---

## 2. Git Workflow — GitHub Flow

### Branching Strategy

```
main (production-ready)
 ├── feature/add-reports
 ├── feature/user-export
 ├── fix/email-validation
 └── chore/update-dependencies
```

**`main`** = always deployable, always stable.
**Feature branches** = short-lived, branched from main, merged back via PR.

### Branch Naming

```
{type}/{short-description}

feature/add-reports
feature/user-profile-page
fix/email-duplicate-check
fix/upload-size-limit
chore/update-laravel-11
chore/cleanup-unused-routes
refactor/extract-file-service
docs/api-endpoints
```

Types: `feature/`, `fix/`, `chore/`, `refactor/`, `docs/`

### Commit Messages — Conventional Commits

```
{type}: {short description}

feat: add report generation service
fix: prevent duplicate email on member creation
chore: update composer dependencies
refactor: extract file upload into pipeline
docs: document API authentication flow
style: fix SCSS indentation in _card.scss
test: add member creation test
```

| Type | When |
|------|------|
| `feat` | New feature or functionality |
| `fix` | Bug fix |
| `chore` | Dependencies, config, build — no production code change |
| `refactor` | Code restructure without behavior change |
| `docs` | Documentation only |
| `style` | Formatting, whitespace — no logic change |
| `test` | Adding or fixing tests |

### Commit Rules

- **One logical change per commit** — don't mix a feature with a refactor
- **Present tense, imperative** — "add report service" not "added report service"
- **Short first line** (under 72 chars), optional body for context
- **No WIP commits on main** — squash or rebase before merge
- **Reference issue/ticket** in body if applicable: `Closes #42`

### Tags — Semantic Versioning

```
v1.0.0    Major release
v1.1.0    New features (backward compatible)
v1.1.1    Bug fixes
```

Tag on main after significant releases. Not every merge needs a tag.

---

## 3. Security Principles

### Authentication

Auth strategy depends on the project — Sanctum for token-based, session for traditional Blade, or both. The principles are constant:

- **Never store plaintext passwords** — always `Hash::make()`
- **Never expose auth tokens in URLs** — tokens in headers or cookies only
- **Session/token expiry** — always set reasonable TTLs
- **Rate limit login attempts** — Laravel's `ThrottleRequests` middleware
- **Logout = invalidate** — destroy session/revoke token, don't just redirect

### Authorization

- **Never trust client-side** — always validate permissions server-side
- **Least privilege** — users get minimum required access, escalate explicitly
- **Authorization in policies/controllers** — never in routes, never in Blade only
- **`@can` in Blade is UI convenience** — it hides buttons but the controller MUST also check

### Data Protection

```php
// Sensitive data in .env, never in code
DB_PASSWORD=...
MAIL_PASSWORD=...
API_SECRET=...

// Never log sensitive data
Log::info('User login', ['user_id' => $user->id]);  // RIGHT
Log::info('User login', ['password' => $request->password]); // NEVER

// Encrypt sensitive DB fields when needed
protected $casts = [
    'api_key' => 'encrypted',
    'ssn' => 'encrypted',
];
```

### Input & Output

- **Validate all input** — Form Requests or inline validation, never trust raw input
- **Escape all output** — Blade `{{ }}` auto-escapes; use `{!! !!}` only for trusted HTML
- **SQL injection** — Eloquent and query builder are safe; raw queries use parameter binding
- **CSRF** — enabled by default in Laravel for web routes; API routes use token auth instead
- **CORS** — configure explicitly in `config/cors.php`; never `allow_all_origins` in production

### File Uploads

- **Validate MIME type AND extension** — don't trust client-reported type
- **Limit file size** — enforce in validation AND server config (php.ini, nginx)
- **Store outside web root** — use Laravel's `storage/` disk, serve via controller with auth check
- **Generate unique filenames** — never use original filename for storage (path traversal risk)

### Secrets Management

- **`.env` for secrets** — never commit secrets to Git
- **`.env.example` as template** — document required vars without values
- **Different secrets per environment** — dev/staging/prod have separate credentials
- **Rotate compromised secrets immediately** — and audit access logs

---

## 4. Server-Side Caching

### Principles

- **Cache driver is project-specific** — don't hardcode a driver; use Laravel's cache abstraction
- **File cache is fine for simple projects** — no need for Redis unless you have a reason
- **Cache at the data layer, not the view layer** — cache query results in models/services, not rendered HTML
- **Short TTLs** — prefer 1-hour cache that's always fresh over 24-hour cache that's stale
- **Invalidate on write** — when data changes, clear the relevant cache

### Cache::remember Pattern

```php
// In Model — cached lookup
public static function allCached(): Collection
{
    return Cache::remember('categories.all', 3600, fn() => static::all());
}

// Invalidate on change
protected static function booted(): void
{
    static::saved(fn() => Cache::forget('categories.all'));
    static::deleted(fn() => Cache::forget('categories.all'));
}
```

### What to Cache

| Cache | TTL | Invalidation |
|-------|-----|-------------|
| Reference/lookup data (categories, roles, statuses) | 1-4 hours | On save/delete via model hooks |
| User permissions/roles | 1 hour | On role assignment change |
| Expensive aggregations (counts, stats) | 15-30 min | Time-based or on relevant write |
| External API responses | Depends on API | Time-based |
| Config/settings | Until changed | On settings update |

### What NOT to Cache

- User-specific data that changes frequently (current session, real-time status)
- Data that must be real-time accurate (financial transactions, inventory counts)
- Anything that's already fast without cache (simple PK lookup)

### Cache Key Naming

```php
// Pattern: {entity}.{scope}.{identifier}
'categories.all'
'roles.all'
'user.42.permissions'
'stats.monthly.2025-01'
'settings.app'
```

### Rules

- **Always use `Cache::remember()`** — never manual get/set pairs
- **Always invalidate on write** — stale cache is worse than no cache
- **Key naming is consistent** — `{entity}.{scope}` pattern
- **Don't cache in controllers** — cache in models or services
- **Don't micro-optimize** — cache when you have a measured performance problem, not preventively

---

## 5. Environment Management

### Three Environments

| Environment | Purpose | Data |
|-------------|---------|------|
| **Local/Dev** | Development on developer machine | Seeded test data or DB copy |
| **Staging** | Pre-production testing | Anonymized copy of production |
| **Production** | Live | Real data |

### .env Discipline

```
.env              ← Local config (gitignored)
.env.example      ← Template with all keys, no values
.env.staging      ← Staging overrides (gitignored or in deploy tool)
.env.production   ← Production overrides (gitignored, managed by deploy)
```

### Rules

- **Never commit `.env`** — only `.env.example`
- **APP_DEBUG=false in production** — always
- **APP_ENV matches environment** — `local`, `staging`, `production`
- **Different DB credentials per environment** — never share credentials across environments
- **Log level** — `debug` in local, `error` or `warning` in production

---

## 6. Dependency Management

### Composer Principles

- **Lock file committed** — `composer.lock` is always in Git (reproducible builds)
- **Minimal dependencies** — don't add a package for something you can write in 20 lines
- **Review before adding** — check maintenance status, last update, Laravel version compatibility
- **Pin major versions** — `"laravel/framework": "^11.0"` not `"*"`
- **Dev dependencies separate** — testing tools, debug bars go in `require-dev`

### npm Principles (for ln-acme / frontend assets)

- **Lock file committed** — `package-lock.json` in Git
- **Minimal packages** — ln-acme is zero-dependency by design; don't add jQuery, Bootstrap, etc.
- **Build tools only in devDependencies** — Vite, PostCSS, etc.

---

## 7. Anti-Patterns — NEVER Do These

### Structure
- Feature folders (`app/Features/Reports/`) — use Laravel's standard layout
- Empty placeholder directories
- Deeply nested namespaces for simple features
- Business logic in controllers, models, or Blade templates — use Services
- Multiple responsibilities in one Service (keep them focused)

### Git
- Long-lived feature branches (merge frequently)
- WIP commits on main
- Mixing multiple concerns in one commit
- Force-pushing to main/shared branches
- Committing `.env`, secrets, or credentials

### Security
- Plaintext passwords or tokens in code/config/logs
- `APP_DEBUG=true` in production
- `allow_all_origins` CORS in production
- Trusting client-side authorization only
- Storing uploads in public web root without auth
- Using `{!! !!}` for user-provided content

### Caching
- Caching without invalidation strategy
- Manual get/set instead of `Cache::remember()`
- Caching in controllers (cache in models/services)
- Long TTLs on frequently-changing data
- Caching data that must be real-time accurate

### Dependencies
- Adding packages for trivial functionality
- Unpinned dependency versions (`"*"`)
- Missing lock files in Git
- Dev dependencies in production require
