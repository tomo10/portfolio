# Changelog

## 1.6.0 - 2023-7-05

### New

- <.image_upload> component for uploading single images like avatars. Used in user settings
- Local, Cloudinary and S3 support for <.image_upload>
- User impersonation - admins can login as any user without knowing their password - available via the Admin console (under the User menu).

### Updated

- All forms now use the new FormField structure
- <.public_layout> has been moved into public.html.heex (it's likely you'll want to modify this to your brand and hence a component doesn't make sense)

### Fixed

- Reset password page now accessible when logged in (previously would redirect)

### Removed

- Page builder (it was getting too complex to manage - let us know if you used this a lot and we'll consider bringing it back)

## 1.5.2 - 2023-4-20

### New

- Uses the `petal_framework` private package (deletes all the `_petal_framework` folders). This will allow for an easier upgrade process in the future, especially for components like the data table.
- Data Table supports `base_url_params`. Keep custom query params when changing sort order.
- Data Table is now self contained in the live view - code isn't scattered across the model and context.
- Added `mix recode` for code linting and refactoring
- Use `<.flash_group>` to show flash messages (Petal Framework 0.3.0)

### Changes

- Enabled Wallaby tests by default (`mix test`)
- Updated Tailwind to 3.3
- Updated Erlang to 25.3
- Added `rename_project` lib to replace custom mix task

### Breaking

- Data table API has changed slightly. See our docs https://petal.build/components/data-table on how to use

### Fixed

- Data table going blank when changing page size
- Navigation problems for the Data Table when setting the `default_limit` via a schema file
- Fix Finch issue with email sending

## 1.5.1 - 2023-3-10

### New

- Develop Petal Pro in GitHub CodeSpaces!
- Data Table column - can now filter by a select list
- Data Table column - can now filter by a float

### Changed

- topbar.js version updated to 2.0
- mix setup no longer fetches tailwind/esbuild if they already exist
- Upgrade Petal Components to 1.0
- Data Table is now a function component

### Fixed

- Github auth working again

## 1.5.0 - 2023-2-10

### Changed

- Upgraded Phoenix to 1.7
- Routes use the new verified routes
- Authentication pages converted to live views
- Upgraded fully from Hericons v1 to v2
- `petal.gen.live` now uses the Data Table component
- Tesla now uses the more secure Finch over Hackney (https://github.com/petalframework/portfolio/issues/66)
- Confirmation page will redirect to org invitations if invitation exists (https://github.com/petalframework/portfolio/issues/68)
- Removed Petal Enhance (it was more complex than we thought)

### Fixes

- Redirect to `/app/orgs` if an invalid org slug is used (https://github.com/petalframework/portfolio/issues/70)
- When editing user via `/admin/users` - `patch_back_to_index` no longer crashes (https://github.com/petalframework/portfolio/issues/61)
- Always show Data Table filters (https://github.com/petalframework/portfolio/issues/60)

## 1.4.1 - 2022-11-15 16:30:00

### Added

- Add Petal Enhance (recipes)

### Fixes

- Fix admin users modal. Clicking off the modal now works
- Change avatar_url to text in DB for long URLs
- Whitelist Google profile picture images in CSP
- Fix Mailbluster unsubscribe route + documentation

## 1.4.0 - 2022-10-12 23:44:20

### Added

- Updated to LiveView 0.18 + Petal Components 0.18
- All components updated with declarative assigns (attr / slot)
- Data table component
- Local time component
- Sobelow for security checking
- Coveralls for code test coverage
- test.yml Github action for code quality
- Easily modifiable content security policy to help prevent XSS
- Added a docker-compose.yaml that adds Postgres so you don't need to install it

### Changed

- Router significantly more streamlined
- Some routes have been moved into their own files: AdminRoutes, AuthRoutes, DevRoutes, MailblusterRoutes
- Users are forced to be confirmed to access /app routes (easily configurable)
- Use Ecto enums for org roles

### Fixes

- Fix reset password failing when signed in
- Clean up dashboard_live.ex - some old code unused was left in there
- Improved SEO meta tags in \_head.html.eex
- Show a warning in the logs when no title/meta_desciprion is set on a public page
- Added `open-graph.png` (to be replaced by dev)
- Fix require_confirmed_user plug
- Fix landing page GSAP not working

## 1.3.0 - 2022-06-17 02:43:55

### Added

- Two-factor authentication using time-based one time passwords (paired with something like Google Authenticator)

### Changed

- Decoupled DashboardLive from Orgs so you can get started quicker if you don't want orgs
- Can pass a custom header class to the public layout
- Sidebar and stacked layouts now support grouped menu items (see dev_layout_component.ex for an example)
- Update Tailwind to 3.1
- Split CSS into different files thanks to Tailwind 3.1

### Fixed

- Onboarding now remembers user_return_to
- Fixed nav dropdown bug after modal toggle
- Fixed gettext in live views

## 1.2.0 - 2022-05-31 07:34:11

### Added

- Login with Google & Github - easy to add more auth providers
- Passwordless auth - register/sign in via a code sent to your email
- Orgs - create an org, invite & manage members, and more
- User lifecycle actions - run code after actions like register, sign_in, sign_out, password_reset, etc
- New generator: mix petal.gen.html (same args as phx.gen.html)
- New component: <.markdown content=""> & <.pretty_markdown content=""> (uses Tailwind Typography plugin)
- Added License and Privacy pages (with some content from a template to get you started)
- New layout: <.layout type="public">, for public marketing related pages like landing, about us, privacy, etc
- Hooks can now be run in dead views if compatible (see color-scheme-hook.js as an example)

### Changed

- Simpler config access (`Portfolio.config(:app_name)` instead of `Application.get_env(:portfolio, :app_name)`)
- Refactor <.layout> to take less props
- Refactor dark/light mode system. Much simpler now and no longer needs cookies
- Put Petal Pro Components in their own folder for easier future upgrades (can duplicate if you want to modify them)
- Sidebar and stacked layout have a new slot for the top right corner (if you want to add something like a notifications bell)

### Fixed

- Log metadata wasn't being cast
- More user actions are logged
- Fixed petal.live generator tests
- Added tests for user settings live views

## 1.1.1 - 2022-03-12 20:45:36

- Bump Oban version to stop random error showing
- Bump Petal Components
- Use new <.table> component in petal.gen.live generator & logs
- Dark mode persists on all pages with cookies
- Fix logo showing twice in emails
- Improved the Fly.io deploy flow
- Fix admin user search
- Remove guide (this is now online)

## 1.1.0 - 2022-02-28 00:08:52

- Added generator `mix petal.gen.live`
- Add gettext throughout public facing templates
- Improved dev_guide
- Add Oban
- Easy Fly.io deployment
