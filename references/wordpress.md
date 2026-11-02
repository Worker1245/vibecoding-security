# WordPress plugins and themes

WordPress applies its plugin guidelines regardless of how the code was produced, so review everything before release.

## Access
- Every state-changing handler (admin-post, AJAX, REST, form) needs both a nonce or authenticated REST request and a capability check; neither replaces the other. `is_admin()` proves nothing. `wp_ajax_` admits any logged-in user.
- Every REST route has a `permission_callback`. Treat `__return_true` as a review flag: legitimate only on routes that are meant to be public.

## Data
- Validate first, sanitize as fallback, escape as late as possible with the context-specific function (`esc_html`, `esc_attr`, `esc_url`, `wp_kses*`).
- All SQL through `$wpdb->prepare()` with unquoted placeholders; `%i` for identifiers, `esc_like()` for LIKE.
- Uploads via `wp_handle_upload`, never `move_uploaded_file()`.

## Files and lifecycle
- Files with top-level code start with the `ABSPATH` guard. Prefix all globals. Remove data only on uninstall, never on deactivation.
- Do not ship AI configuration (`CLAUDE.md`, `.claude/`, `AGENTS.md`, `.agents/`, `.github/copilot-instructions.md`) in release packages; exclude it via the build or `.distignore`.
- Use `strict_types` with care: type hook callbacks loosely and validate inside. This is untested guidance, so verify it in the project.

## Checks
- The check command runs PHPCS with WordPress Coding Standards, PHPStan with WordPress stubs, Plugin Check and `composer audit`, plus PHPUnit in wp-env. Static tools do not verify that the right capability is checked, so test handlers as anonymous, subscriber and admin.
