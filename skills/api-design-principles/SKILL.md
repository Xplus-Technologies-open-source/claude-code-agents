---
name: api-design-principles
description: REST and GraphQL API design principles — used by CodeCraft, TestForge, and APIForge for API-related reviews
---

# API Design Principles

## Resource Naming

- Plural nouns for collections: `/users`, `/orders`, `/products`
- No verbs in URLs: `POST /orders` not `POST /createOrder`
- Nested resources for relationships: `/users/{id}/orders`
- Lowercase, hyphen-separated: `/user-profiles` not `/userProfiles`
- Maximum 3 levels of nesting: `/users/{id}/orders/{oid}/items`

## HTTP Methods Contract

| Method | Semantics | Idempotent | Safe | Success |
|--------|----------|------------|------|---------|
| GET | Read | Yes | Yes | 200 |
| POST | Create | No | No | 201 + Location header |
| PUT | Full replace | Yes | No | 200 |
| PATCH | Partial update | No* | No | 200 |
| DELETE | Remove | Yes | No | 204 (no body) |

## Error Response Format (RFC 7807)

```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 422,
  "detail": "Request body contains invalid fields.",
  "errors": [
    { "field": "email", "message": "Must be a valid email", "code": "INVALID_FORMAT" }
  ]
}
```

Every error response must have:
- Machine-readable error code
- Field-level errors for validation failures
- Consistent structure across ALL endpoints
- NO stack traces or internal paths

## Pagination (Required for ALL list endpoints)

Cursor-based (preferred):
```json
{ "data": [...], "meta": { "has_next": true, "next_cursor": "abc123" } }
```

Offset-based (acceptable for small datasets):
```json
{ "data": [...], "meta": { "page": 2, "per_page": 20, "total": 1523 } }
```

## Filtering and Sorting

```
GET /users?status=active&role=admin          # Filtering
GET /users?sort=-created_at,name             # Sorting (- = descending)
GET /users?fields=id,name,email              # Sparse fieldsets
```

## Rate Limiting

- Every endpoint has a rate limit (even if generous)
- Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
- 429 response includes `Retry-After` header
- Stricter limits on auth endpoints

## Versioning

- URL path versioning recommended: `/v1/users`
- Breaking changes require a new version
- Deprecation: `Sunset` header + 6-month notice minimum
- After sunset: return `410 Gone` (not 404)
