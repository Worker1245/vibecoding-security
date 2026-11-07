# PHP (language, standard library, Laravel, Symfony)

These rules add to `security.md` and also hold for WordPress; where WordPress has its own API, `wordpress.md` wins (e.g. `$wpdb->prepare()`, `wp_handle_upload`, nonces). Versions and defaults are as of November 2026; check the project's versions before relying on a default.

## Runtime
- New code targets a supported PHP branch (8.3 or later; 8.2 gets security fixes only until 31 Dec 2026). Pin it in `composer.json` (`"php": ">=8.3"`).
- Production settings: `display_errors=Off`, `log_errors=On`, `expose_php=Off`, `allow_url_include=Off`, `zend.exception_ignore_args=On`, `display_startup_errors=Off`, `enable_dl=Off`; `allow_url_fopen=Off` unless the code needs it.
- Mark parameters that take passwords, tokens or keys with `#[\SensitiveParameter]` (PHP 8.2+), so their values are redacted in stack traces; never log them yourself.

## Injection
- SQL: bind every value (PDO prepared statements, Doctrine `setParameter()`, Laravel bindings such as `whereRaw('email = ?', [$email])`). Identifiers (columns, `ORDER BY`, table names) come only from a hard-coded allowlist, e.g. validated with `in:price,updated_at`; hard-code the column in Laravel `Rule::unique(...)->ignore($id, 'id')`.
- PDO: set `PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION` and `PDO::ATTR_EMULATE_PREPARES => false`. PDO_MYSQL emulates prepares by default, and `false` only requests native prepares; binding stays the actual protection.
- No shell: start programs with `proc_open([...])` or Symfony `new Process([...])` with an absolute program path. Put `--` before user values and validate their format, because an array still allows a value starting with `-` to act as an option. `escapeshellcmd()` is no protection. With `Process::fromShellCommandline()` pass data only through environment variables and `"${:NAME}"`.
- Anchor allowlist regexes with `\A…\z` (or the `D` modifier): `$` also matches before a trailing newline.
- No `eval()`, `extract()`, dynamic `include`/`require`, variable functions or classes, or `call_user_func()` with names from input; map input to code with `match` over an allowlist.

## Deserialization and comparison
- Never `unserialize()` untrusted data, not even with `allowed_classes` (php.net warns against it regardless of that option). Use `json_decode()`; sign stored serialized data with an HMAC checked by `hash_equals()`.
- Never call `Phar::getMetadata()` on foreign archives.
- Laravel: a leaked `APP_KEY` lets attackers decrypt and forge encrypted cookies and data, and run code wherever decrypted values are unserialized (CVE-2018-15133). Keep it in a secret store; rotate it via `APP_PREVIOUS_KEYS`.
- Compare secrets, tokens and hashes only with `hash_equals($known, $user)`, known value first. Never `==` for them: numeric strings compare as numbers, so `"0e…"` hashes can match.
- Use strict comparison: `===`, and `in_array($v, $list, true)` / `array_search($v, $list, true)`.

## Files, XML, outbound requests
- Resolve the base and the user-influenced path with `realpath()`; reject if either is `false` (for a file not yet created, resolve its parent directory); then check that the path starts with the base plus `DIRECTORY_SEPARATOR`. Or reduce the name to `basename()`. Reject `://` in user-controlled paths (stream wrappers).
- Uploads: generated file names, content-based type check (Laravel `mimes:`, Symfony `File` constraint), storage outside the web root, no execution in the upload directory.
- Archives: check every entry name for `..` and absolute paths before extracting; do not rely on `ZipArchive::extractTo()` to do it. Cap the number of entries and the total uncompressed bytes, counted while reading (zip bombs).
- XML from outside: never `LIBXML_NOENT`, `LIBXML_DTDLOAD` or `LIBXML_DTDVALID`; block external entities with `libxml_set_external_entity_loader(fn() => null)` (passing `null` blocks nothing). Do not use the deprecated `libxml_disable_entity_loader()`.
- curl: restrict protocols with `CURLOPT_PROTOCOLS_STR` and `CURLOPT_REDIR_PROTOCOLS_STR` set to `"https"` (PHP 8.3+, libcurl 7.85+). For user-supplied URLs also reject private and reserved address ranges, pin the checked address (`CURLOPT_RESOLVE`) against DNS rebinding, and re-check every redirect. Never set `CURLOPT_SSL_VERIFYPEER` or `CURLOPT_SSL_VERIFYHOST` to off.

## Crypto and sessions
- Randomness for secrets only from `random_bytes()`, `random_int()` or `Random\Randomizer` with `Random\Engine\Secure`; never `rand()`, `mt_rand()`, `uniqid()` or `lcg_value()`.
- Passwords: `password_hash($pw, PASSWORD_DEFAULT)` or `PASSWORD_ARGON2ID`, `password_verify()`, `password_needs_rehash()`; column up to 255 characters; bcrypt uses only the first 72 bytes. Symfony: `password_hashers` with `'auto'`.
- Sessions: `session.use_strict_mode=1`, `session.use_only_cookies=1`, `session.use_trans_sid=0`, cookies with `secure`, `httponly` and `samesite`. Symfony: `cookie_secure: auto` guarantees nothing, and `cookie_lifetime` is no server-side timeout. Do not change `session.sid_length` or `session.sid_bits_per_character` (deprecated in PHP 8.4).
- Renew the session ID on login and on every privilege change. `session_regenerate_id(true)` deletes the old session at once, which php.net warns can break on unstable networks; follow the manual's timestamp approach where that matters.

## Laravel and Symfony
- Production: `APP_DEBUG=false` (debug mode enabled RCE via Ignition, CVE-2021-3129); never the Symfony profiler; a random `APP_SECRET`/`kernel.secret` from a secret store.
- Mass assignment: save `$request->validated()` or `only([...])`, never `$request->all()`; no `$guarded = []`, no `forceFill()` with request data.
- Keep CSRF protection on; exempt only stateless routes that verify a signature. Symfony login forms need `enable_csrf: true` (off by default).
- Authorization: Laravel policies or gates; Symfony `denyAccessUnlessGranted()` or `#[IsGranted]`, never `getRoles()`. In `access_control` the first match wins and patterns need `^`. Show login errors with `error.messageKey`, not `error.message`.
- Output: Blade `{{ }}` and Twig autoescaping; never `{!! !!}` or `|raw` on outside data; `Js::from()` for JavaScript contexts. Plain PHP: `htmlspecialchars($s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')`.
- Rate-limit login and other expensive routes (`throttle`, Symfony `login_throttling`).

## Dependencies
- Commit `composer.lock`. Keep `allow-plugins` an explicit allowlist (never `true`), `secure-http` on, never `disable-tls`.
- Composer 2.9+ blocks known-vulnerable versions by default; from 2.10 configure this in the `policy` block, not the deprecated `audit` keys. Run `composer audit` (needs network) in the check command.
- Never add `@psalm-suppress`, `@phpstan-ignore`, baseline entries or `// nosemgrep` to get a scan green.
