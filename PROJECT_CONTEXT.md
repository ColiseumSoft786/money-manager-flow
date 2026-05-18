# Flow — project context (navigation map)

This file is a **maintained index** of the **money-manager-flow** / **Flow** codebase so humans and AI assistants can find things quickly. It is **not** a copy of the repository: the real source of truth is the files in git (especially `lib/` and `assets/`). Regenerate or extend this document when major structure changes.

- **App name (Dart package):** `flow`  
- **Description:** Personal finance app (see `pubspec.yaml`).  
- **SDK:** Dart `>=3.10.0 <4.0.0`  
- **Local DB:** ObjectBox (`lib/objectbox.dart`, `lib/objectbox/`, generated `objectbox.g.dart`).

---

## What this repo contains (high level)

| Area | Role |
|------|------|
| `lib/` | All Flutter/Dart application logic (~457+ `.dart` files including generated `*.g.dart`). |
| `assets/` | Fonts (Poppins), `l10n/*.json`, images, animations (`lottie`), etc. |
| `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` | Platform runners, native glue, store/widget configs. |
| `test/` | Unit/widget tests and fixtures (e.g. CSV samples). |
| Generated / build | `*.g.dart` (json_serializable, ObjectBox), `.dart_tool/`, `build/` — **do not hand-edit** generated files; run codegen (see below). |

---

## Entry points and global wiring

| File | Purpose |
|------|---------|
| `lib/main.dart` | `main()`: bindings, logging, `ObjectBox.initialize()`, `LocalPreferences.initialize()`, notifications, sync, deep links, `runApp` with themes and localization. |
| `lib/routes.dart` | Single **`GoRouter`** definition: `/`, transactions, accounts, import/export, setup sub-routes, preferences, debug routes, `globalNavigatorKey`. |
| `lib/constants.dart` | Debug flags and shared constants (e.g. `flowDebugMode`). |
| `lib/logging.dart` | App logging setup. |
| `lib/graceful_migrations.dart` | Data/schema migrations on startup. |

---

## `lib/` layout (folders)

Use these as the primary mental model when searching the tree:

| Folder | Contents |
|--------|----------|
| **`routes/`** | Screen-level widgets and flows (`home_page.dart`, `transactions_page.dart`, `transaction_page.dart`, `setup/*`, `preferences/*`, `import_wizard/*`, `export/*`, `debug/*`, …). |
| **`widgets/`** | Reusable UI: `general/` (buttons, surfaces, icons), `home/`, `sheets/`, `setup/`, import wizard pieces, reports, etc. |
| **`entity/`** | ObjectBox `@Entity` models and related types: `account`, `transaction`, `category`, `profile`, `budget`, `goal`, `recurring_transaction`, `transaction_tag`, `transaction_filter_preset`, `file_attachment`, `backup_entry`, `user_preferences`, … + generated `*.g.dart`. |
| **`objectbox/`** | Store helpers, `actions.dart`, generated `objectbox.g.dart`. |
| **`data/`** | Non-entity domain structures: filters, money, icons, charts, setup defaults (`data/setup/default_accounts.dart`, `default_categories.dart`), import/export models, … |
| **`services/`** | Singleton-style services: `transactions`, `accounts`, `sync`, `notifications`, `exchange_rates`, `user_preferences`, `local_auth`, `navigation`, `currency_registry`, `recurring_transactions`, … plus subfolders (e.g. `services/integrations/`). |
| **`providers/`** | `ChangeNotifier` / app state: `accounts_provider`, `categories_provider`, `transaction_tags_provider`, … |
| **`prefs/`** | Typed preference helpers layered on `LocalPreferences`. |
| **`theme/`** | `theme.dart` (exports `helpers.dart`), `flow_color_scheme.dart`, color theme registry (`color_themes/`, including `flow/`), text theme, pie menu theme. |
| **`l10n/`** | `FlowLocalizations`, `extensions.dart` (`.t(context)`), `supported_languages.dart`, enum localization helpers. |
| **`sync/`** | Backup/import/export pipelines (`import_v1`, `import_v2`, `export_v1`, `export_v2`, CSV/PDF, model versions). |
| **`reports/`** | Reporting logic and views (trends, forecasts, category/group reports). |
| **`utils/`** | Cross-cutting helpers: time/range, JSON converters, extensions, file pickers, Quill, platform bits. |

Other top-level `lib/` files worth knowing: `routes.dart`, `objectbox.dart`, `flow_localizations` wiring in `main.dart`, `widgets/flow_themes.dart`.

---

## Routes reference (`lib/routes.dart`)

All navigation uses **`GoRouter`** with `globalNavigatorKey`. The table below describes **what each route is for**; implementation lives in the referenced page under `lib/routes/`.

### Core & transactions

| Path | What it does |
|------|----------------|
| `/` | **Home** — main shell: tabs for home content, stats, profile; primary entry after launch. |
| `/transaction/new` | **New transaction** — fullscreen `TransactionPage.create`. Reads optional query params via `TransactionProgrammableObject.fromUri` (prefill type, amount, accounts, etc.). **Redirects:** `?type=eny` → `/integrations/eny`; non-empty `?json=` → `/transaction/batch-import` with encoded JSON. |
| `/transaction/batch-import` | **Batch import / multi-entry** — `TransactionBatchImportPage`; params from `TransactionMultiProgrammableObject.fromUri` (e.g. pasted JSON). |
| `/transaction/:id` | **Edit transaction** — fullscreen `TransactionPage.edit` for existing ObjectBox id. |
| `/transactions` | **All transactions** — filtered list of non-deleted transactions (`TransactionsPage.all`). |
| `/transactions/pending` | **Pending transactions** — scheduled / not-yet-posted items (`TransactionsPage.pending`). |
| `/transactions/deleted` | **Trash** — deleted transactions view (`TransactionsPage.deleted`). |

### Integrations (Eny)

| Path | What it does |
|------|----------------|
| `/integrations/eny` | **Eny integration hub** — connect or manage the Eny receipt/expense integration (`EnyPage`). |
| `/integrate/eny` | **Deep-link Eny connect** — `IntegrateEnyPage` with `apiKey` (required) and optional `email`. **Redirect:** missing/empty `apiKey` → `/not-found`. |

### Accounts

| Path | What it does |
|------|----------------|
| `/accounts` | **Accounts list** — all accounts, balances, navigation to detail/new (`AccountsPage`). |
| `/account/new` | **Create account** — `AccountEditPage.create()`; optional GoRouter **`extra`** `Account` seeds the form (setup preset pencil → same route). Redesigned: hero icon plate, **CURRENT BALANCE** label + amount, **ACCOUNT NAME** field, rounded rows for Currency/Type/Theme color, exclude-from-balance toggle row. |
| `/account/:id` | **Account detail** — `AccountPage` for one account; optional query `range=` (`TimeRange`) for default stats range. |
| `/account/:id/edit` | **Edit account** — fullscreen `AccountEditPage` for that id (same redesigned layout as `/account/new`). |
| `/account/:id/transactions` | **Transactions for one account** — `TransactionsPage.account`; optional `title=` query for app bar. |

### Categories

| Path | What it does |
|------|----------------|
| `/categories` | **Categories list** — manage expense/income categories (`CategoriesPage`). |
| `/category/new` | **Create category** — `CategoryEditPage.create`. |
| `/category/:id` | **Category detail** — `CategoryPage`; optional `range=` for default time range. |
| `/category/:id/edit` | **Edit category** — fullscreen `CategoryEditPage`. |

### Transaction tags

| Path | What it does |
|------|----------------|
| `/transactionTags` | **Tags list** — manage labels applied to transactions (`TransactionTagsPage`). |
| `/transactionTags/new` | **Create tag** — `TransactionTagPage.create`. |
| `/transactionTags/:id` | **View/edit tag** — `TransactionTagPage` for one tag. |

### Preferences (nested under `/preferences`)

| Path | What it does |
|------|----------------|
| `/preferences` | **Preferences hub** — grouped settings entry (`PreferencesPage`). |
| `/preferences/pendingTransactions` | Rules for **pending / scheduled** transaction behavior. |
| `/preferences/numpad` | **Numpad / calculator** layout and input preferences. |
| `/preferences/trashBin` | **Trash** retention and related options. |
| `/preferences/transfer` | **Transfer** flow defaults (e.g. which accounts surface first). |
| `/preferences/reminders` | **Reminders** — notification-related preferences. |
| `/preferences/transactionButtonOrder` | **Transaction form button order** — customize action buttons on entry screen. |
| `/preferences/transactionGeo` | **Geo / location** on transactions (capture, privacy). |
| `/preferences/transactionEntryFlow` | **Entry flow** — how new transactions are guided (steps, defaults). |
| `/preferences/theme` | **Theme** — light/dark, color scheme selection. |
| `/preferences/changeVisuals` | **Change / cash** visuals — coins/notes display preferences (`ChangeVisualsPreferencesPage`). |
| `/preferences/moneyFormatting` | **Money display** — ICU patterns, decimals, grouping. |
| `/preferences/sync` | **Backup & sync** — iCloud/local backup, restore hooks (`SyncPreferencesPage`). |
| `/preferences/transactionListItemAppearance` | **List tiles** — density, fields shown on transaction rows. |
| `/preferences/integrations/eny` | **Eny-specific** settings inside preferences. |

### Profile

| Path | What it does |
|------|----------------|
| `/profile` | **Profile** — user identity, picture, app-level profile settings (`ProfilePage`). |
| `/profile/:id` | **Profile by id** — same page variant when multiple profile records exist (multi-profile). |

### Utilities (modal / shared)

| Path | What it does |
|------|----------------|
| `/utils/cropsquare` | **Square cropper** for images (e.g. avatar). Requires `GoRouterState.extra` as `CropSquareImagePageProps`; throws `ErrorPage` if wrong type. |
| `/utils/editmd` | **Markdown editor** — `EditMarkdownPage`; optional `extra` = `EditMarkdownPageProps` (`initialValue`, `maxLength`). |

### Export & import

| Path | What it does |
|------|----------------|
| `/exportOptions` | **Export options** — choose what to include before running export (`ExportOptionsPage`). |
| `/import` | **Import entry** — pick backup/CSV path; `?setupMode=true` runs flow in first-run setup context (`ImportPage`). |
| `/import/wizard/v1` | **Restore Flow backup v1** — wizard over an `ImportV1` instance passed in **`extra`**; `setupMode` query supported. Wrong/missing extra → error page. |
| `/import/wizard/v2` | **Restore Flow backup v2** — same pattern with `ImportV2` in **`extra`**. |
| `/import/wizard/csv` | **Generic CSV import** — wizard with `ImportCSV` in **`extra`**. |
| `/import/wizard/external/ivy` | **Ivy Wallet CSV** — dedicated importer wizard; **`extra`** = `IvyWalletCsvImporter`. |
| `/export/history` | **Past exports / backups** — list and manage export history (`ExportHistoryPage`). |
| `/export/:type` | **Run export** — `type` maps to `ExportMode` (e.g. zip). If `type=pdf` and **`extra` is null**, opens **`ExportPdfPage`**; otherwise **`ExportPage`** with optional `extra` options object. |

### First-run setup (`/setup/*`)

| Path | What it does |
|------|----------------|
| `/setup` | **Setup shell** — container for onboarding steps (`SetupPage`). |
| `/setup/choose` | **Onboarding slides** — welcome, privacy, FOSS story, etc. (`SetupOnboardingPage`). |
| `/setup/currency` | **Primary currency** — pick base currency for the ledger (`SetupCurrencyPage`). |
| `/setup/accounts` | **Starter accounts** — section header, then **existing + preset** `AccountPresetCard` rows, then **`AddAccountCard`** (“Add new account”) at the **bottom** of the list. Bottom bar: **Continue** (not Next) — fixed design **342×68** (width clamped to screen minus padding), **24px** corners, fill/shadow tokens `kFlowSetupAccountsContinueButtonFill` / `kFlowSetupAccountsContinueButtonShadows` (`flow_color_scheme.dart`), label **`setup.continue`**, centered row layout. |
| `/setup/categories` | **Starter categories** — preset categories and toggles; `?standalone=true` for out-of-setup use; `selectAll` query (default preselect all unless `false`). |
| `/setup/profile` | **Profile basics** — name and profile fields during setup (`SetupProfilePage`). |
| `/setup/profile/photo` | **Profile photo** — crop/set picture; **`extra`** = `String` image path (`SetupProfilePhotoPage`). |

### Stats & community

| Path | What it does |
|------|----------------|
| `/stats/category` | **Stats by category** — `StatsByGroupPage` with `byCategory: true`; optional `range=` query. |
| `/stats/account` | **Stats by account** — same with `byCategory: false`; optional `range=`. |
| `/community/contributors` | **Contributors** — credits / open-source contributors (`ContributorsPage`). |

### Support & debug

| Path | What it does |
|------|----------------|
| `/support` | **Support** — help, links, contact (`SupportPage`). |
| `/_debug/theme` | **Debug: theme** — internal theme inspection (`DebugThemePage`). |
| `/_debug/scheduledNotifications` | **Debug: scheduled notifications** — inspect scheduled notification state. |
| `/_debug/iCloud` | **Debug: iCloud** — sync/iCloud diagnostics. |
| `/_debug/logs` | **Debug: log files** — list logs (`DebugLogsPage`). |
| `/_debug/logs/view` | **Debug: log viewer** — **`extra`** must be `String` file path (`DebugLogPage`). |

### Router error state

| Behavior | What it does |
|----------|----------------|
| `errorBuilder` | Any unmatched or broken navigation shows **`ErrorPage`** with the error string (user-facing failure). |

**Note:** `routes.dart` currently registers **`/import` twice** (same `ImportPage` builder). Behavior is identical; consider deduplicating in code later.

---

## Localization

- **Files:** `assets/l10n/*.json` — locales include `en`, `ar`, `cs_CZ`, `de_DE`, `es_ES`, `fa_IR`, `fr_FR`, `it_IT`, `mn_MN`, `ru_RU`, `tr_TR`, `uk_UA`.  
- **Loader:** `lib/l10n/flow_localizations.dart` loads `assets/l10n/${locale.code}.json`.  
- **Usage:** string keys via `.t(context)` from `lib/l10n/extensions.dart` (e.g. `"setup.next".t(context)`).  
- **Adding keys:** add to **all** locale JSON files to avoid missing translations.

---

## Code generation

From repo root (see `regenerate_code.sh`):

```bash
dart run build_runner build --delete-conflicting-outputs && dart format lib
```

Regenerates ObjectBox and `json_serializable` outputs (`*.g.dart`) where applicable.

---

## Entities (hand-authored Dart in `lib/entity/`)

Non-exhaustive list of core `@Entity` types (each may have `*.g.dart`):

- `Account`, `Transaction`, `Category`, `Profile`, `Budget`, `Goal`  
- `RecurringTransaction`, `TransactionTag`, `TransactionFilterPreset`  
- `FileAttachment`, `BackupEntry`, `UserPreferences`  

`Transaction` has a rich type/extension layout under `lib/entity/transaction/`.

---

## Services (`lib/services/`)

Top-level Dart files include (among others): `transactions`, `accounts`, `categories`, `budget`, `sync`, `notifications`, `exchange_rates`, `user_preferences`, `currency_registry`, `local_auth`, `navigation`, `recurring_transactions`, `file_attachment`, `connectivity`, `camera`, `github`, `external_toasts`, `actionable_notifications`.  

Nested capabilities (e.g. iCloud, Siri, Eny) live under **`lib/services/`** subdirectories — search by feature name.

---

## Theming and UI tokens

- **`lib/theme/theme.dart`** — `ThemeFactory`, Material theme assembly; **exports `helpers.dart`**.  
- **`lib/theme/helpers.dart`** — `BuildContext` extensions: `textTheme`, `colorScheme`, `flowColors`, setup/onboarding color getters (e.g. `popularCurrenciesSectionHeadingColor`).  
- **`lib/theme/flow_color_scheme.dart`** — shared palette constants and scheme glue. Setup profile UI reuses neutrals such as **`kFlowSetupAccountsContinueButtonFill`**, **`kFlowSetupProfileProgressTrackLight`**, and **`kFlowWarmOffWhiteSurfaceLight`** (also **Category edit** light canvas).
- **`lib/widgets/general/button.dart`**, **`surface.dart`**, **`flow_icon.dart`** — common controls.

---

## Setup flow — source files

Behavior is summarized under **First-run setup** in the **Routes reference** section above. Implementation files:

| Path | File |
|------|------|
| `/setup` | `lib/routes/setup_page.dart` |
| `/setup/choose` | `lib/routes/setup/setup_onboarding_page.dart` |
| `/setup/currency` | `lib/routes/setup/setup_currency_page.dart` |
| `/setup/accounts` | `lib/routes/setup/setup_accounts_page.dart` + `lib/widgets/setup/accounts/*` |
| `/setup/categories` | `lib/routes/setup/setup_categories_page.dart` |
| `/setup/profile` | `lib/routes/setup/setup_profile_page.dart` · shared UI: `lib/widgets/setup/setup_profile_page_canvas.dart`, `setup_profile_step_header.dart`, `setup_profile_hero_orb.dart` |
| `/setup/profile/photo` | `lib/routes/setup/setup_profile_picture_page.dart` (same canvas + step header widgets) |

Preset accounts: **`lib/data/setup/default_accounts.dart`** (stable UUIDs, order Main → Cash → Savings).

**Setup accounts step UI:** `account_preset_card.dart` uses light-mode fill `rgba(255,255,255,1)`, solid border `kFlowSetupAccountCardBorder` (`rgba(226,232,240,0.5)`), 1px, shadow `kFlowSetupAccountCardShadow` (`0 1px 2px 0 rgba(0,0,0,0.05)`), ~24px corners; preset icon plates stay Main/Cash/Savings tints; **trailing** grey pencil on **`kFlowPopularCurrencySymbolPlate`** circle — tap is separate from the row body: **saved** accounts → `/account/{id}/edit` (`AccountEditPage`); **presets** still in the list → `/account/new` with **`extra: Account`** so `AccountEditPage.create(template: …)` seeds name, icon, currency, balance, etc. **`add_account_card.dart`** is different: full-width **pill** (`BorderRadius.circular(999)`), **dashed** outline (`DashedBorder`, light gray `~#CBD5E1`), same white + shadow spec, **centered** row: circular **stroke** around plus + label, both in **`ColorScheme.primary`** (`w600` title). **`setup_accounts_page.dart`**: bottom **Continue** CTA (localized `setup.continue`) uses **`kFlowSetupAccountsContinueButtonFill`** / **`kFlowSetupAccountsContinueButtonShadows`** — `342×68` (width `min(342, screen−32)`), **24px** radius, white label + outlined forward arrow; **not** the generic `Button` widget. Horizontally centered via full-width `Row`. Other setup steps still use **`setup.next`** where applicable.

**Account edit UI (`lib/routes/account/account_edit_page.dart`)** — redesigned, used by `/account/new` (`AccountEditPage.create`) and `/account/:id/edit`:

- **AppBar**: surface bg, `centerTitle: true`, X close on the left (`FormCloseButton`), localized title `account.new` / `account.edit`, trailing **primary-tinted** check action that calls `save()`.
- **Hero icon block**: **140×140** rounded square (`24px` radius), outer fill **`kFlowAccountEditHeroFill`** (`#EFF6FF`) in light / `surfaceContainerHighest` in dark. **Inner circle** diameter **`outer × kFlowAccountEditHeroInnerCircleScale`** (0.68), fill **`FlowColorScheme.primary`** when a theme color is set, else **`kFlowAccountEditHeroInnerBlue`** (`rgb(37,140,244)`). Center always shows **`assets/images/walletIcon.png`** (no Material-icon fallback). Tap still opens `SelectFlowIconSheet` to change the account icon used elsewhere.
- **Current balance**: small slate **CURRENT BALANCE** label (`account.currentBalance`, uppercase, `kFlowPopularCurrenciesSectionHeading`) above a large `w800` amount; the whole block is an `InkWell` → `updateBalance()`.
- **Account name**: slate **ACCOUNT NAME** label above a **`TextFormField`** capped at **`kFlowAccountEditNameFieldMaxWidth`** (358), height **`kFlowAccountEditNameFieldHeight`** (56), **`12px`** corners, fill **`kFlowAccountEditFieldFill`** (`#F8FAFC`), **`1px`** border **`kFlowAccountEditNameFieldBorder`** (`#E2E8F0`), **`contentPadding`** `16,17,16,17`; focused border uses **`ColorScheme.primary`** (`1px`). Always editable; validated via `validateNameField`.
- **Settings rows** (`_AccountSettingRow` — private helper at bottom of file): grey card `kFlowAccountEditRowFill`, `16px` radius, **40×40** tinted icon plate (`10px` radius), label-on-top (`bodySmall`, slate) + bold value below (`titleSmall`, slate-900), trailing chevron when `onTap != null && showChevron`. Used for **Currency** (green plate, `payments_rounded`, navigates to `SelectCurrencySheet` only on new accounts), **Account type** (blue plate, `category_rounded`, `SelectAccountTypeSheet`), optional **Credit limit** (blue plate, only when `accountType.showCreditLimit`), and **Theme color** (orange plate, `palette_rounded`) — the theme value renders as `dot + scheme.name` and opens `SelectColorSchemeSheet` directly (replaces `SelectColorSchemeListTile`).
- **Exclude from balance** (`_AccountToggleRow` with `useExcludeBalanceCardStyle`): max width **`kFlowAccountEditNameFieldMaxWidth`** (358), height **`kFlowAccountEditExcludeCardHeight`** (74), **`12px`** radius, **`16px`** padding, fill **`kFlowAccountEditFieldFill`** (`#F8FAFC`), **`1px`** border **`kFlowPopularCurrencySymbolPlate`** (`#F1F5F9` — shared with popular-currency symbol plate & setup edit circle). `Row` **`MainAxisAlignment.spaceBetween`**: text block vs `Switch`. Icon plate uses **`kFlowPopularCurrencySymbolPlate`** + **`kFlowAccountEditExcludePlateFg`**. Title uses **`labelSmall`** when `titleUsesLabelSmall`.
- **Primary account** row appears when editing a saved account with a uuid (same `_AccountToggleRow` / `_AccountSettingRow` styling).
- **Archive** + **Delete account** stay below a `WavyDivider`, using the same toggle row + `DeleteButton`; both only visible when editing an existing account, delete only after `_archived`.
- **Dark mode**: every helper branches on `Theme.of(context).brightness`. In light mode it uses the new **`kFlowAccountEdit…`** tokens (`Fill`, `RowFill`, `HeroFill`, `TitleColor`, and four plate pairs: `CurrencyPlateBg/Fg`, `TypePlateBg/Fg`, `ColorPlateBg/Fg`, `ExcludePlateBg/Fg`) declared in `lib/theme/flow_color_scheme.dart`; in dark mode it falls back to `surfaceContainerHighest` + `onSurface` so the page never goes "white-on-white".

Localization keys touched: **`account.currentBalance`**, **`account.themeColor`**, **`account.excludeFromTotalBalance.shortDescription`** added to all 12 locale JSONs.

---

## Tests

- **`test/`** — e.g. `unit/`, `import/`, `serialization/`, `objectbox_erase.dart`.  
- Run: `flutter test` (from project root).

---

## How to use this document (for AI / contributors)

1. **Prefer reading real files** over treating this markdown as complete: APIs and route lists drift.  
2. **Search by feature** in `lib/routes/` and `lib/widgets/` first; put business logic in `services/` or `data/` as the codebase already does.  
3. **After structural refactors**, update this file in the same PR so the map stays honest.  
4. **Do not** try to mirror `build/`, `.dart_tool/`, or entire `ios/Pods/` / `android/.gradle/` — they are generated or vendored.

---

## File count snapshot (approximate)

As of the last refresh of this document, the workspace contained on the order of **650+** tracked paths under the project root (including assets, platforms, and `lib/`). **`lib/` alone** has **450+** Dart files. Exact counts change every commit; use your file tree or `git ls-files` for precision.

---

*End of project context map.*
