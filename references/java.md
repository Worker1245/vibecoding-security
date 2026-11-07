# Java (JDK, Spring Boot, Spring Security, Jakarta EE)

These rules add to `security.md`. A large 2025 study of AI-generated code (Veracode) found security flaws in over 70 % of Java samples, more than in any other language it tested, so check AI-written Java with extra care. Versions and defaults are as of November 2026; check the project's versions before relying on a default.

## Platform
- New code targets a current LTS (Java 25) and a supported Spring Boot line (4.1; 4.0 until 31 Dec 2026; 3.5 has no free support since 30 Jun 2026).
- Isolation never relies on `SecurityManager` or `AccessController.doPrivileged`: the Security Manager is permanently disabled since JDK 24 (JEP 486). Isolate with containers and the operating system.

## Injection
- SQL and JPA: `PreparedStatement` with `setString()` etc., JPQL/HQL with named parameters (`:name` plus `setParameter()`); never concatenate input into JDBC, JPQL, HQL or native queries. Identifiers come only from a hard-coded allowlist.
- No `Runtime.exec(String…)` (deprecated since JDK 18), no `sh -c` or `cmd.exe /c`. Use `ProcessBuilder(List<String>)` with an absolute program path, `--` before user values, and validate their format.
- No user-controlled SpEL, EL or OGNL expressions. Never evaluate outside input with `StandardEvaluationContext`; `SimpleEvaluationContext` is only best-effort, not a sandbox.
- Never `InitialContext.lookup()` with input (JNDI injection, Log4Shell).
- Logging: parameterized messages (`log.info("user {}", id)`); neutralize CR/LF in logged input. Log injection had the highest failure rate (88 %) of all flaw types in that study.

## Deserialization and data formats
- Never `ObjectInputStream` or `XMLDecoder` on untrusted data. If native serialization is unavoidable, set an allowlist filter with limits (`jdk.serialFilter`, or `ObjectInputFilter.Config.createFilter("com.example.*;java.base/*;maxdepth=…;maxrefs=…;!*")`; per context via `jdk.serialFilterFactory`, JDK 17+); a filter does not make arbitrary untrusted deserialization safe.
- Jackson: no `enableDefaultTyping()`, and `activateDefaultTyping()` only with a strict `PolymorphicTypeValidator`; no `@JsonTypeInfo(use = Id.CLASS)` on outside JSON. Check the rules again for Jackson 3 (Spring Boot 4) in the project's documentation.
- SnakeYAML: 2.0 or later (CVE-2022-1471), and `SafeConstructor` for outside YAML. XStream 1.4.18 or later; do not relax its default allowlist.
- XML: harden every JAXP factory. Prefer `newDefaultInstance()`; set `http://apache.org/xml/features/disallow-doctype-decl` to `true` and `XMLConstants.FEATURE_SECURE_PROCESSING`; StAX `XMLInputFactory.SUPPORT_DTD` to `false`; `TransformerFactory` and `SchemaFactory` with `ACCESS_EXTERNAL_DTD` and `ACCESS_EXTERNAL_STYLESHEET`/`ACCESS_EXTERNAL_SCHEMA` set to `""`. If a setting is not supported, fail instead of continuing.

## Crypto, files, TLS
- Never `Cipher.getInstance("AES")`: without mode and padding the JDK providers use ECB. Use `"AES/GCM/NoPadding"` with a fresh random IV for every encryption under a key.
- Randomness for secrets only from `SecureRandom`, never `java.util.Random` or `Math.random()`.
- Passwords: Spring Security `PasswordEncoderFactories.createDelegatingPasswordEncoder()` (bcrypt) or Argon2; never `NoOpPasswordEncoder`. Compare secrets with `MessageDigest.isEqual()`.
- Paths: `base = baseDir.toRealPath()`, `p = base.resolve(name).normalize()`, reject unless `p.startsWith(base)` with `Path.startsWith(Path)`, never `String.startsWith`; once the file exists, check `p.toRealPath()` again (symlinks). Do the same for every archive entry (Zip Slip), and cap entry count and uncompressed bytes counted while reading, not via `ZipEntry.getSize()` (zip bombs). Never trust `MultipartFile.getOriginalFilename()`; generate stored names.
- TLS: never a trust-all `X509TrustManager`, a `HostnameVerifier` that returns `true`, or code that disables certificate checks, not even in tests or "for now". Use the default `SSLContext`, or one initialised from a dedicated truststore for a private CA.
- For user-supplied URLs reject private and reserved address ranges, connect to the checked address (DNS rebinding) and re-check every redirect (SSRF).

## Spring Security and Spring Boot
- `authorizeHttpRequests`: the first matching rule wins; end with `.anyRequest().denyAll()` (or `.authenticated()` where every route needs only a login). Prefer `permitAll()` over `web.ignoring()`, which skips security headers.
- Method security with `@EnableMethodSecurity` and `@PreAuthorize`; check ownership of the object, not only the role.
- CSRF stays on for everything a browser can reach; statelessness does not protect when cookies or HTTP Basic are sent automatically. Exempt single endpoints with `ignoringRequestMatchers(...)`, never a global `csrf.disable()`.
- CORS: list origins explicitly; never `"*"` or `allowedOriginPatterns("*")` together with `allowCredentials(true)`.
- Actuator: expose only what is needed (`health` by default) via `management.endpoints.web.exposure.include`; once you define your own `SecurityFilterChain`, secure actuator endpoints explicitly (`EndpointRequest.toAnyEndpoint()`). No H2 console, DevTools or stack traces in error responses in production (`server.error.include-stacktrace=never`).
- Bind requests to DTOs or records, never to JPA entities (mass assignment), and validate them with `@Valid`. Keep Spring Framework patched: Spring4Shell (CVE-2022-22965) hit data binding itself and was fixed only by upgrading.
- Output: Thymeleaf `th:text`, never `th:utext` on outside data; JSP `<c:out>` or `fn:escapeXml()`.

## Jakarta EE
- Deny by default: `@DenyAll` on the class, `@RolesAllowed` on the methods that need it; method annotations take precedence over class annotations. Use Bean Validation on all input.

## Dependencies and build
- Log4j 2: the newest 2.x version; 2.15.0 is not a safe floor, and Log4j 1 is banned.
- Maven: Enforcer rules `bannedDependencies`, `dependencyConvergence` and `requireUpperBoundDeps` catch downgrades and banned artifacts, not CVEs; scan the resolved dependencies (`pom.xml`, `gradle.lockfile`, the built JAR/WAR) for known vulnerabilities separately.
- Create an SBOM with the CycloneDX plugin (`makeAggregateBom`) where the project ships software to others.
- Never add `@SuppressFBWarnings`, `// nosemgrep`, scanner exclusions or weakened security config to get a scan or test green.
