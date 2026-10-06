# Pixel Bar (`bar_app`)

Bar cashier terminal: a Flutter desktop POS for **Windows** and **macOS**.
Bars are separate from the park, with their own cashiers, products, shifts and
sales. The app talks only to the `/api/v1/bar/*` endpoints of
`maestro_backend` (bar cashier tokens; park cashier tokens are rejected).
Spec: `maestro_backend/docs/superpowers/specs/2026-10-06-bar-design.md`.

The architecture is copied from the park cashier app (`cashier_app`): features
split into `data/domain/presentation`, `flutter_bloc` + `get_it` + `dartz`,
`dio` with refresh-on-401, `hive_ce` for tokens, Nocturne dark theme,
`window_manager` frameless window, and l10n with uz (primary) and ru.

## Run

```bash
flutter pub get
# test backend (the default)
flutter run -d macos
# a specific backend
flutter run -d windows --dart-define=API_BASE_URL=https://api.pixelpark.uz/api
```

`API_BASE_URL` is a compile-time define. The default is
`https://test.api.pixelpark.uz/api`. CI builds `main` against production and
every other ref against test.

To change the l10n strings, edit `lib/l10n/intl_uz.arb` / `intl_ru.arb`, then
run `dart run intl_utils:generate`. The output in `lib/generated/` is
committed.

Checks:

```bash
flutter analyze
flutter test
flutter build macos --debug
```

## Screens

1. **Login**: username + password. Enter moves to the next field and submits.
   With saved tokens the app skips login and validates them with
   `GET /bar/auth/me`.
2. **No open shift**: the "Smenani ochish" button.
3. **Sale**: category tabs + product grid on the left, cart on the right,
   and big **Naqd** / **Karta** buttons.
4. **Smena tarixi**: the open shift's sales, with whole-sale refund (optional
   reason + confirm).
5. **Smenani yopish**: shift totals, counted cash, live difference, confirm,
   then a summary.
6. **Sozlamalar**: receipt printer, version + update check, logout.

### Retry safety

Each cart gets one `clientSaleId` (UUID v4), created on the first payment
attempt. Every failure keeps the cart and that id, so pressing Naqd/Karta
again after a timeout re-sends the same id. The backend then returns the sale
it already recorded instead of charging twice. The id is replaced only after
a successful sale or when the cart content changes. See
`lib/features/sale/domain/cart.dart`.

### Printing

Printing is optional. The default is "Printer yo'q", and a receipt prints
(80 mm, PDF via `printing`) only after a printer is picked in Settings. A
print failure never blocks the sale; it only shows a warning.

## Releases and self-update

- Bumping `version:` in `pubspec.yaml` on **`main`** is the release.
  `.github/workflows/windows-build.yml` builds Windows. If the tag `v<version>`
  doesn't exist yet, it publishes a GitHub Release (draft first, then live)
  with `bar_app-windows-v<version>.zip` + `.sha256`. Both go to **the repo the
  workflow runs in**.
- The same workflow builds macOS (`flutter build macos --release`) and
  uploads the zipped `Pixel Bar.app` as an Actions artifact. The .app is
  unsigned, so open it the first time with right-click → Open.
- The app checks `SilasTravis/Bar---Pixelpark` GitHub Releases every 4 h and
  from Settings. Download, install and restart work on Windows only. Only the
  `bar_app-windows-*.zip` asset is ever installed.
- v1 has no backend update mirror (the cashier has `/v1/pos/app-update/*`).
  Bar tills need to reach github.com to update.

> **Before the first release:** create the GitHub repository
> **`SilasTravis/Bar---Pixelpark`** (public, so the app can read releases
> without a token) and push this repo's `main` there.
>
> **Never share the cashier's release repo** (`SilasTravis/Cashier---Pixelpark`).
> Both apps install whatever their repo's latest release is: bar tills would
> install the cashier build, and cashier tills the bar build.
