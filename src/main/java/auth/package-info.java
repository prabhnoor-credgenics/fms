/**
 * Authentication and authorization for API tests.
 *
 * <ul>
 *   <li>{@code auth.manager} — {@link auth.manager.AuthManager}</li>
 *   <li>{@code auth.service} — login and API-key flows</li>
 *   <li>{@code auth.cache} — per-slot token cache</li>
 *   <li>{@code auth.allocator} — parallel user slot assignment</li>
 *   <li>{@code auth.resolver} / {@code auth.model} — credentials</li>
 *   <li>{@code auth.crypto} — RSA encryption for login</li>
 * </ul>
 */
package auth;
