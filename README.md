# cg-api-automation

API automation for Credgenics recovery services (RestAssured · TestNG · Cucumber).

## Configuration

1. **`src/main/resources/global.properties`** — set `environment` to `dev`, `stag`, `uat`, or `prod`, plus framework-wide flags (`user_type`, parallel pool, defaults).
2. **`src/main/resources/<env>.properties`** — same name as `environment` (e.g. `stag.properties`). Holds that env’s `{env}.base.url`, login emails/passwords, `{env}.api.key.global.company.id`, etc.
3. **`src/main/resources/secrets/crypto.properties`** — RSA keys, JDBC URLs, API keys (keep local; do not commit real secrets).

Override the active env without editing files: `mvn test -Denvironment=dev`.

## Run

```bash
mvn clean compile test-compile
mvn clean test
```

See `loggings/CODE_DOCUMENTATION.md` (if present in your clone) for the full framework guide.
