# ArchiePOS

Offline-first POS, inventory, and **lista** (utang/credit) ledger for Philippine *sari-sari* stores. Built in Flutter with a photo-tile checkout, tingi (multi-size) selling, customer credit tracking, a daily benta dashboard, and printable receipts.

> Package name: `archie_pos` • Flutter SDK: `^3.9.2`

## Features

- **Photo-tile POS** — tap-to-add product grid with category filter and live cart total.
- **Tingi selling** — products can have multiple sell options (e.g. `1 kg`, `½ kg`, `¼ kg`) tracked against one base-unit stock.
- **Lista / utang ledger** — credit sales tied to a customer record, with running balances and payment entries.
- **Customer & product master data** — add / edit / search products, customers, and categories.
- **Orders** — supports cash, card, mobile, and lista payment methods; receipts can be previewed and printed.
- **Dashboard** — daily benta summary with `fl_chart` visualizations.
- **Offline-first** — local SQLite via Drift; nothing depends on the network.
- **Auth gate** — login screen routed via `go_router` with a redirect guard.
- **Theming** — Material 3 with a dark theme by default (toggleable via `ThemeService`).

## Tech stack

| Concern              | Choice                                                              |
| -------------------- | ------------------------------------------------------------------- |
| UI                   | Flutter (Material 3)                                                |
| State management     | `flutter_bloc` (Cubits) + `provider` for theme                      |
| Routing              | `go_router` with auth redirect                                      |
| Local DB             | `drift` + `sqlite3_flutter_libs`                                    |
| Storage              | `flutter_secure_storage`, `shared_preferences`                      |
| DI                   | `get_it`                                                            |
| Functional errors    | `dartz`                                                             |
| Charts               | `fl_chart`                                                          |
| Misc                 | `intl`, `uuid`, `image_picker`                                      |

## Project structure

```
lib/
├── main.dart
├── 1_domain/                  # Pure Dart — entities, no Flutter imports
│   └── entities/              # Product, Order, Customer, Category, LedgerEntry, User
└── 2_application/             # UI + state
    ├── core/
    │   ├── services/          # auth, theme, router, app_routes
    │   ├── widgets/           # app_drawer, receipt dialogs, base_page
    │   └── utils/             # money formatting
    ├── theme/                 # app_colors, app_theme
    └── pages/
        ├── login/
        ├── dashboard/
        ├── order/             # add_order (POS), order_list
        ├── transaction/       # lista (credit ledger)
        ├── master_data/       # products, customers, categories
        └── settings/
```

The numeric prefixes (`1_domain`, `2_application`) enforce a clean-architecture-style layering: domain has no dependency on application code.

## Getting started

Requires Flutter 3.x with Dart `^3.9.2`.

```bash
flutter pub get
flutter run
```

The app launches at `/login` and routes to the POS (`/order/add-order`) after authentication.

### Code generation

Drift uses `build_runner` for table/dao code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Tests

```bash
flutter test
```

## Domain model highlights

- **`Product`** has one or more `SellOption`s. A non-tingi product has exactly one option labeled `each` with `baseQty: 1.0`. A tingi product (e.g. rice sold by the kilo) has multiple options that consume fractional base units.
- **`Order`** stores a *snapshot* of each line (name, emoji, price, sell-option label) so old receipts still print correctly even after the underlying product is edited.
- **Payment methods**: `cash`, `card`, `mobile`, `lista`. Lista orders are linked to a customer and create a corresponding ledger entry.

## Routes

| Route                                | Purpose                       |
| ------------------------------------ | ----------------------------- |
| `/login`                             | Login                         |
| `/dashboard`                         | Daily benta dashboard         |
| `/order/add-order`                   | POS checkout (post-login)     |
| `/order/order-list`                  | Past orders                   |
| `/transaction`                       | Lista ledger                  |
| `/master-data/products`              | Product list                  |
| `/master-data/products/add`          | Add product                   |
| `/master-data/products/edit/:sku`    | Edit product                  |
| `/master-data/customers`             | Customer list                 |
| `/master-data/customers/add`         | Add customer                  |
| `/master-data/customers/edit/:id`    | Edit customer                 |
| `/master-data/categories`            | Categories                    |
| `/settings`                          | Settings                      |

## Status

Early development. Seed data (`kSeedProducts`, `kSeedOrders`) drives the UI while the Drift schema and repositories are being wired up.
