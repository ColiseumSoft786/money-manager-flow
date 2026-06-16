# Flow — Project Functionalities Reference

> **App name:** Flow (`mn.flow.flow`)  
> **Package:** `flow` · **Version:** 0.19.2+329  
> **Type:** Free, open-source personal finance / expense tracker  
> **Philosophy:** Offline-first, privacy-focused, no analytics or trackers  

This document describes what the **money-manager-flow** codebase does, based on the full project structure (`lib/`, platform targets, services, routes, and data layer).

---

## Table of contents

1. [Overview](#overview)
2. [Core financial features](#core-financial-features)
3. [Main app screens & navigation](#main-app-screens--navigation)
4. [Data models & storage](#data-models--storage)
5. [Backup, import & export](#backup-import--export)
6. [Analytics & reports](#analytics--reports)
7. [Preferences & customization](#preferences--customization)
8. [Security & privacy](#security--privacy)
9. [Integrations](#integrations)
10. [Platform-specific features](#platform-specific-features)
11. [Automation & deep links](#automation--deep-links)
12. [Technical architecture](#technical-architecture)
13. [Supported platforms & languages](#supported-platforms--languages)
14. [Features in schema but not yet in UI](#features-in-schema-but-not-yet-in-ui)

---

## Overview

Flow helps users track income, expenses, and transfers across multiple accounts and currencies. All ledger data lives **on the device** in an **ObjectBox** database. Optional network use is limited to exchange rates, Eny receipt AI, GitHub contributors, and **iCloud backup uploads** (Apple platforms)—not live cloud sync of transactions.

**Startup sequence** (`lib/main.dart`):

1. Open ObjectBox database  
2. Load local preferences (SharedPreferences)  
3. Run account sort-order migration  
4. Initialize notifications and sync transaction reminders  
5. Load exchange rates and currency registry  
6. Load user preferences from DB  
7. Start sync service (auto-backup / iCloud)  
8. Start recurring-transaction engine  
9. On iOS: resolve Siri/widget pending transactions  
10. Show app with routing, providers, theme, locale, and optional biometric blur lock  

---

## Core financial features

| Feature | Description |
|--------|-------------|
| **Transactions** | Create, edit, and delete income, expense, and transfer entries with title, description, amount, date, and currency (via account). |
| **Accounts** | Unlimited accounts: debit, savings, credit line, loan; optional credit limit, custom icon/theme, manual sort order. |
| **Categories** | Organize transactions by income/expense categories with icons and colors. |
| **Tags** | Optional labels on transactions; can link tags to phone contacts. |
| **Transfers** | Move money between accounts; preferences for how transfers appear in totals and flow charts. |
| **Multi-currency** | Per-account currency; fiat and crypto via currency registry; totals converted using cached exchange rates. |
| **Pending transactions** | Future-dated or unconfirmed entries; separate list and notification handling. |
| **Trash bin** | Soft-deleted transactions with configurable retention before permanent removal. |
| **Recurring transactions** | Templates with recurrence rules; service auto-generates upcoming instances. |
| **Attachments** | Receipts and files (camera, gallery, clipboard, desktop drag-and-drop) stored on disk and linked in DB. |
| **Geo tagging** | Optional GPS coordinates and map picker (OpenStreetMap) on transactions. |
| **Rich notes** | Markdown notes via Quill editor on transaction entry. |
| **Search & filters** | Filter by amount, date range, category, account, tags, attachments, pending state, etc. |
| **Filter presets** | Save and reuse transaction filter combinations (`TransactionFilterPreset`). |
| **Batch import** | Import multiple transactions from JSON URI (`flow-mn://` with `json` query). |
| **Account frecency** | Accounts can be sorted by how often they are used. |

---

## Main app screens & navigation

Routing uses **go_router** (`lib/routes.dart`). Paths below are the main user-facing flows.

### Home shell (`/`)

Four tabs:

| Tab | Purpose |
|-----|---------|
| **Home** | Balance summary, recent activity, configurable visuals, quick insights for selected time range. |
| **Accounts** | List and manage accounts; navigate to account details. |
| **Stats** | Charts, trends, forecasts, category/account breakdowns. |
| **Profile** | User profile, settings entry, support links. |

**FAB pie menu:** Quick actions to add expense, income, transfer, open Eny scan (when connected), etc. Button order is configurable.

### Setup & onboarding

| Route | Screen | Function |
|-------|--------|----------|
| `/setup` | SetupPage | Welcome slides (privacy, FOSS, features). |
| `/setup/choose` | SetupOnboardingPage | New install vs import / iCloud restore. |
| `/setup/currency` | SetupCurrencyPage | Choose primary display currency. |
| `/setup/accounts` | SetupAccountsPage | Create initial accounts from presets. |
| `/setup/categories` | SetupCategoriesPage | Pick default categories. |
| `/setup/profile` | SetupProfilePage | Set display name. |
| `/setup/profile/photo` | SetupProfilePhotoPage | Crop profile photo. |

Redirects to setup when the app has no completed first-run state.

### Transactions

| Route | Function |
|-------|----------|
| `/transaction/new` | Create transaction (fullscreen); supports URI query params; Eny type redirects to integration. |
| `/transaction/:id` | Edit existing transaction. |
| `/transaction/batch-import` | Review and import multiple transactions from JSON. |
| `/transactions` | Full transaction list with filters. |
| `/transactions/pending` | Pending / future transactions. |
| `/transactions/deleted` | Trash bin view. |

### Accounts & categories

| Route | Function |
|-------|----------|
| `/accounts` | Reorder and open accounts. |
| `/account/new` | Create account (optional template). |
| `/account/:id` | Balances, transactions, pending groups for one account. |
| `/account/:id/edit` | Edit account fields. |
| `/account/:id/transactions` | Filtered transaction list for account. |
| `/categories` | Manage categories. |
| `/category/new` | New category. |
| `/category/:id` | Category stats and related transactions. |
| `/category/:id/edit` | Edit category. |

### Tags

| Route | Function |
|-------|----------|
| `/transactionTags` | List tags. |
| `/transactionTags/new` | Create tag (optional contact link). |
| `/transactionTags/:id` | View/edit tag. |

### Statistics

| Route | Function |
|-------|----------|
| `/stats/category` | Spending/income breakdown by category (charts). |
| `/stats/account` | Breakdown by account. |

### Preferences (`/preferences` and children)

| Sub-route | Function |
|-----------|----------|
| Root | Language, primary currency, haptics, lock, privacy, file cleanup, notification permission, links to sub-pages. |
| `pendingTransactions` | How pending txs behave and confirm. |
| `numpad` | Phone-style vs calculator numpad for amounts. |
| `trashBin` | Retention period and trash behavior. |
| `transfer` | Transfer display and accounting options. |
| `reminders` | Daily reminder notification time. |
| `transactionButtonOrder` | Pie menu button order (synced to widgets on iOS). |
| `transactionGeo` | Enable geo tagging and map preview. |
| `transactionEntryFlow` | Which fields appear when adding a transaction. |
| `theme` | Color themes; iOS alternate app icons per theme. |
| `changeVisuals` | Growth/trend indicators on home. |
| `moneyFormatting` | ICU currency patterns and symbol display. |
| `sync` | Auto-backup interval, iCloud toggle, retention count. |
| `transactionListItemAppearance` | Density and fields on list tiles. |
| `integrations/eny` | Eny API key, connection, scan options. |

### Import & export

| Route | Function |s
|-------|----------|
| `/import` | Choose backup or CSV; desktop drag-and-drop. |
| `/import/wizard/v1` | Restore Flow backup format v1. |
| `/import/wizard/v2` | Restore Flow backup format v2. |
| `/import/wizard/csv` | Generic CSV import wizard. |
| `/import/wizard/external/ivy` | Import Ivy Wallet CSV export. |
| `/exportOptions` | Select accounts, date range, format. |
| `/export/:type` | Export as ZIP, JSON, CSV, or PDF. |
| `/export/history` | History of exports and backups (`BackupEntry`). |

### Integrations & community

| Route | Function |
|-------|----------|
| `/integrations/eny` | Camera receipt scan → Eny API → draft transaction. |
| `/integrate/eny?apiKey=…` | Deep link to connect Eny account. |
| `/profile`, `/profile/:id` | User profile management. |
| `/support` | Donate, links, app support. |
| `/community/contributors` | List GitHub contributors. |

### Utilities & debug

| Route | Function |
|-------|----------|
| `/utils/cropsquare` | Square image crop (profiles, icons). |
| `/utils/editmd` | Standalone markdown editor. |
| `/_debug/*` | Theme preview, scheduled notifications, iCloud debug, logs (development). |

---

## Data models & storage

### ObjectBox entities (`lib/entity/`)

| Entity | Role |
|--------|------|
| `Transaction` | Core ledger row: amount, currency, dates, pending/deleted flags, title, description, location vector, subtype, relations. |
| `Account` | Wallet/account metadata and type. |
| `Category` | Income/expense grouping. |
| `TransactionTag` | Labels; optional contact association. |
| `FileAttachment` | Linked files/receipts. |
| `RecurringTransaction` | Recurrence template. |
| `Profile` | User identity for display. |
| `UserPreferences` | DB-backed app settings. |
| `TransactionFilterPreset` | Saved filters. |
| `BackupEntry` | Export/backup history metadata. |
| `Budget` | Schema only (not used in UI yet). |
| `Goal` | Savings goal linked to account (schema only). |

### Transaction extensions (`lib/entity/transaction/extensions/`)

- **Transfer** — paired account movements  
- **Recurring** — link to recurring template  
- **Geo** — location metadata  
- **EnyReceipt** — provenance from Eny scan  

### Other persistence

| Store | Contents |
|-------|----------|
| **ObjectBox** | All relational app data under app support directory. |
| **SharedPreferences** | Device prefs: locale, exchange-rate cache, biometric flags, Eny API key, privacy session, etc. |
| **Filesystem** | `images/`, `files/`, rotating `logs/flow.log` |

### Data access layer

- **`lib/objectbox/actions.dart`** — Queries, aggregations, balances, upserts, trash, frecency, filters (no separate repository package).  
- **Providers** (`lib/providers/`) — `AccountsProviderScope`, `CategoriesProviderScope`, `TransactionTagsProviderScope` expose live lists to the widget tree.

**Note:** SQLite is **not** used.

---

## Backup, import & export

| Capability | Details |
|------------|---------|
| **Export ZIP/JSON** | Full recoverable backup of app data. |
| **Export CSV** | Spreadsheet-friendly transaction export. |
| **Export PDF** | Statement-style report (`lib/sync/export/`). |
| **Import Flow v1/v2** | Restore from previous Flow backups. |
| **Import CSV** | Wizard maps columns to accounts/categories. |
| **Import Ivy Wallet** | External CSV format support. |
| **Auto-backup** | Scheduled ZIP creation (`SyncService`). |
| **iCloud sync** | Upload/purge backups on iOS/macOS (`ICloudSyncer`, container `iCloud.mn.flow.flow`). |
| **Export history** | Track past backups in `BackupEntry`. |

There is **no** real-time multi-device sync of the live ledger—only backup files.

---

## Analytics & reports

| Feature | Location / type |
|---------|-----------------|
| Home summaries | Income vs expense for selected interval on Home tab. |
| Interval flow report | Cash flow over a date range (`IntervalFlowReport`). |
| Trends report | Spending/income trends over time. |
| Range forecast | Projected range based on history (`RangeForecastReport`). |
| Category/account charts | Pie charts, top categories, daily expense chart (`fl_chart`). |
| Drill-down stats | `/stats/category`, `/stats/account`. |
| Change visuals | Optional growth indicators on home cards. |

---

## Preferences & customization

- **11 locales** in `assets/l10n/`: English, German, Spanish, French, Italian, Russian, Ukrainian, Czech, Turkish, Arabic, Persian, Mongolian.  
- **Multiple color themes** (Flow palettes, Catppuccin, monochrome, etc.) in `lib/theme/`.  
- **iOS dynamic app icons** per theme (`flutter_dynamic_icon_plus`).  
- **Configurable numpad** (phone vs calculator layout).  
- **Transaction entry flow** — show/hide fields when adding txs.  
- **List tile appearance** — control density and visible fields.  
- **Money formatting** — ICU patterns, symbol placement.  
- **Haptic feedback** toggle.  
- **Pie menu button order** — including Eny when connected.  

---

## Security & privacy

| Feature | Description |
|---------|-------------|
| **Offline-first** | Core app works without network. |
| **No analytics** | Project stance: no trackers in app. |
| **Privacy mode** | Hide sensitive amounts; shake device toggles session privacy (`shake` package). |
| **Biometric lock** | Blur/lock UI on resume (`local_auth`). |
| **Local-only ledger** | Transactions are not uploaded to a Flow cloud account. |
| **User-controlled backups** | User chooses when/where exports and iCloud copies go. |

---

## Integrations

### Eny (AI receipt parser)

- Connect API key in preferences or via `flow-mn:///integrate/eny`.  
- Scan receipt with camera → HTTP API → pre-filled transaction.  
- Service: `EnyService` (`lib/services/integrations/`).  
- Transaction extension stores Eny receipt metadata.  

### Siri & home screen widgets (iOS / Android)

- **iOS:** WidgetKit extension, App Intents (`RecordTransactionIntent`), pending queue resolved by `SiriPendingService`.  
- **Android:** Glance widgets (`TwoEntry`, `TwoEntryLast`, `FourEntry`) launch `flow-mn://` URIs for quick transaction types.  
- **`home_widget`:** Syncs quick-action button order to iOS widgets.  

### Other

- **GitHub API** — Contributors page.  
- **In-app review** — Optional store review prompt.  
- **External toasts** — Cross-app toast messages (`ExternalToastsService`).  

---

## Platform-specific features

### Android (`android/`, package `mn.flow.flow`)

- Glance home screen widgets with deep links to new transactions.  
- Intent filter for `flow-mn://` scheme.  
- Local notifications (planned transactions, daily reminders).  
- Permissions: internet, location, contacts, biometrics, exact alarms.  
- FileProvider for sharing exports.  

### iOS (`ios/`)

- **Flow Widgets** app extension.  
- Siri shortcuts / App Intents for recording transactions.  
- Many **alternate app icons** in Info.plist.  
- **iCloud** entitlements for backup.  
- App group `NJH37247C9.flow` for widget/shared storage.  

### Desktop (macOS, Windows, Linux)

- `window_manager` for window sizing/behavior.  
- `desktop_drop` on import screen.  
- macOS app group for ObjectBox path.  

### Web

- Flutter web target present; desktop/mobile feature parity may vary.  

---

## Automation & deep links

**URI scheme:** `flow-mn://`

- Single transaction: query params on `/transaction/new` (title, amount, type, etc.).  
- Multiple transactions: JSON string in `json` query param → batch import page.  
- JSON schema: `schemas/programmable-object.json`.  

Examples from README:

```text
flow-mn:///transaction/new?title=Coffee&amount=4.50
```

Widgets and external apps can open these URIs to pre-fill new transactions.

---

## Technical architecture

```
lib/
├── main.dart              # App entry, initialization
├── routes.dart            # go_router configuration
├── routes/                # All pages (home, setup, prefs, export, …)
├── widgets/               # Reusable UI components
├── services/              # Business logic singletons
├── entity/                # ObjectBox models
├── objectbox/             # DB helpers, actions.dart
├── sync/                  # Import/export pipelines
├── reports/               # Report calculators & views
├── providers/             # InheritedWidget data scopes
├── prefs/                 # SharedPreferences wrappers
├── theme/                 # Themes and color registries
├── data/                  # DTOs, filters, programmable URI objects
├── l10n/                  # Localization helpers
└── utils/                 # Shared utilities
```

### Key services (`lib/services/`)

| Service | Responsibility |
|---------|----------------|
| `TransactionsService` | CRUD, trash, listeners, notification sync |
| `AccountsService` | Account lifecycle |
| `CategoriesService` | Categories |
| `TransactionTagService` | Tags |
| `RecurringTransactionsService` | Generate recurring instances |
| `ExchangeRatesService` | Fetch and cache FX rates |
| `CurrencyRegistryService` | Currency metadata |
| `SyncService` | Scheduled backups |
| `ICloudSyncer` | iCloud upload/purge |
| `NotificationsService` | Local notifications |
| `ActionableNotificationsService` | In-app banners (backup, rates, review) |
| `LocalAuthService` | Biometric lock |
| `UserPreferencesService` | DB settings + widget button order |
| `EnyService` | Receipt AI API |
| `SiriPendingService` | iOS widget/Siri import queue |
| `FileAttachmentService` | Attachment files |
| `CameraService` | Receipt capture |
| `ConnectivityService` | Online/offline state |
| `NavigationService` | Deep link handling |
| `GithubService` | Contributors API |

### Major dependencies → features (`pubspec.yaml`)

| Package | Enables |
|---------|---------|
| `objectbox` | Local NoSQL database |
| `go_router` | Navigation & deep links |
| `flutter_local_notifications` | Reminders & tx alerts |
| `local_auth` | Biometric lock |
| `geolocator` + `flutter_map` | Geo tagging |
| `camera` + `image_picker` | Receipt photos |
| `archive` + `csv` + `pdf` | Backup formats |
| `icloud_storage` | iCloud backups |
| `home_widget` | Widget data bridge |
| `app_links` | `flow-mn://` handling |
| `recurrence` | Recurring rules |
| `fl_chart` | Statistics charts |
| `flutter_quill` | Rich notes |
| `flutter_contacts` | Tag ↔ contact |
| `pie_menu` | Radial FAB menu |
| `window_manager` | Desktop windows |
| `desktop_drop` | Drag-drop import |

---

## Supported platforms & languages

| Platform | Status (per README) |
|----------|---------------------|
| Android | Primary; Play Store beta |
| iOS | Primary; App Store beta |
| macOS | Buildable |
| Linux | Buildable |
| Windows | Buildable; less tested |
| Web | Target present |

| Language (locale file) | Code |
|------------------------|------|
| English | `en` |
| German | `de_DE` |
| Spanish | `es_ES` |
| French | `fr_FR` |
| Italian | `it_IT` |
| Russian | `ru_RU` |
| Ukrainian | `uk_UA` |
| Czech | `cs_CZ` |
| Turkish | `tr_TR` |
| Arabic | `ar` |
| Persian | `fa_IR` |
| Mongolian | `mn_MN` |

---

## Features in schema but not yet in UI

These exist in ObjectBox models or stubs but are **not** fully productized:

| Item | Status |
|------|--------|
| **Budget** | Entity defined; no budget UI or `BudgetService` logic. |
| **Goal** | Savings goal entity; no dedicated screens. |

---

## Quick feature checklist (50+ capabilities)

- [x] Income / expense / transfer transactions  
- [x] Multiple accounts & account types (debit, savings, credit, loan)  
- [x] Categories and tags  
- [x] Multi-currency with exchange rates  
- [x] Pending & recurring transactions  
- [x] Trash bin with retention settings  
- [x] File attachments & camera capture  
- [x] Geo tagging & maps  
- [x] Markdown notes  
- [x] Search, filters, saved presets  
- [x] Home / Accounts / Stats / Profile tabs  
- [x] Stats charts and forecast reports  
- [x] ZIP / JSON / CSV / PDF export  
- [x] Flow v1/v2 / CSV / Ivy Wallet import  
- [x] Scheduled auto-backup & iCloud  
- [x] Onboarding & setup wizard  
- [x] Themes & iOS alternate icons  
- [x] 12 languages  
- [x] Biometric lock & privacy mode  
- [x] Local notifications & reminders  
- [x] Eny receipt AI integration  
- [x] Siri & home screen widgets  
- [x] URI automation (`flow-mn://`)  
- [x] Desktop window & drag-drop import  
- [x] GitHub contributors & support page  
- [ ] Budgets (schema only)  
- [ ] Goals (schema only)  

---

## Related documentation

- [README.md](./README.md) — Install, Eny, URI automation examples  
- [schemas/programmable-object.json](./schemas/programmable-object.json) — URI automation JSON schema  
- Upstream: [github.com/flow-mn/flow](https://github.com/flow-mn/flow)  

---

*Generated from codebase analysis. Update this file when major features or routes change.*
