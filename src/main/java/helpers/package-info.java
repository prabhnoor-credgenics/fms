/**
 * Stateless helper utilities used across step definitions and services.
 *
 * <p>Helpers in this package are intentionally <strong>static</strong> and have no constructor
 * dependencies, so they are not injected via Cucumber's PicoContainer. Use them for cross-cutting
 * concerns: logging response details, transforming payloads, mapping endpoints to response schemas,
 * validating request bodies against registered JSON Schemas, etc.
 *
 * <p>Per-scenario stateful collaborators (auth, config, context, services) live in their respective
 * packages and are injected by PicoContainer.
 */
package helpers;
