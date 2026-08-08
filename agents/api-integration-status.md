# API Integration Status

> Last verified: 2026-08-06 against the running backend at `game-trackr-api`.

---

## Connected (backend + apps wired)

### Auth — fully integrated on iOS and Android

| Endpoint | Method | Notes |
|----------|--------|-------|
| `POST /auth/register` | public | `{ name, email, password, password_confirmation }` |
| `POST /auth/login` | public | `{ email, password }` → `{ token, user }` |
| `POST /auth/logout` | auth | Blacklists current JWT |
| `POST /auth/validate` | auth | Returns `{ user }` |
| `POST /auth/refresh` | auth | Single-token rotation (current token in header) |
| `POST /auth/forgot-password` | public | `{ email, client:"mobile" }` → 6-digit OTP email |
| `POST /auth/verify-reset-code` | public | `{ email, code }` |
| `POST /auth/reset-password` | public | `{ email, code, password, password_confirmation, client:"mobile" }` |
| `GET /profile/me` | auth | Returns `{ user }` (thin — no bio/stats) |
| `GET /auth/google/redirect` | public | Web-only OAuth redirect |
| `GET /auth/google/callback` | public | Web-only OAuth callback |

---

## Ready to connect (backend exists, apps use mock data)

### Community

| Endpoint | Method | Auth | Notes |
|----------|--------|------|-------|
| `GET /communities` | GET | public | `?search=`, `?per_page=`, paginated. Returns `is_member` flag if authenticated |
| `GET /communities/joined` | GET | auth | User's joined communities, same pagination |
| `GET /communities/{id}` | GET | public | Detail with author, members |
| `POST /communities` | POST | auth | Multipart: `title`, `description`, `avatar?`, `cover?`. Auto-joins creator |
| `DELETE /communities/{id}` | DELETE | auth | Owner only |
| `POST /communities/join/{id}` | POST | auth | 400 if already member |
| `POST /communities/leave/{id}` | POST | auth | 400 if owner |

### Posts

| Endpoint | Method | Auth | Notes |
|----------|--------|------|-------|
| `GET /posts` | GET | public | `?search=`, `?community_id=`, `?per_page=`. Returns `is_liked` flag if authenticated |
| `GET /posts/{id}` | GET | public | Detail with author, community, comments, `is_liked` |
| `POST /posts` | POST | auth | Multipart: `title`, `description?`, `community_id`, `images[]?` |
| `DELETE /posts/{id}` | DELETE | auth | Author only |
| `POST /posts/{id}/like` | POST | auth | Toggle (like/unlike). Returns `{ is_liked, likes }` |
| `POST /posts/{id}/comment` | POST | auth | `{ comment }`. Returns `{ comment }` with author |
| `POST /posts/{id}/comment/{commentId}/reply` | POST | auth | `{ comment }`. Returns `{ reply }` with author |
| `POST /posts/{id}/comment/{commentId}/like` | POST | auth | Toggle. Returns `{ is_liked, likes }` |

---

## Not in backend (apps use mock, no API exists)

| Feature | App screens exist? | Priority | Notes |
|---------|--------------------|----------|-------|
| **Games / Discovery** | Yes (Home, Search, Game Detail) | Core | Needs IGDB/RAWG integration server-side |
| **Library** | Yes (Library, filters, rating) | **Core MVP** | No controller, no model, no migration |
| **Profile update** | Yes (Edit Profile) | High | Only `GET /profile/me` exists, no `PATCH` |
| **Stats** | Yes (Stats) | Medium | No aggregation endpoint |
| **Notifications** | Yes (Notifications) | Medium | No controller |
| **Achievements** | Yes (Achievements) | Low | No controller, no model |
| **Friends** | **No screen yet** | Medium | No controller. TODO.MD lists this as next |
| **Messaging** | **No screen yet** | Low | No controller, no Reverb config |
| **Collection** | **No screen yet** | Low | No controller |
| **Game Lists** | **No screen yet** | Low | No controller |
| **Activity Feed** | **No screen yet** | Low | No controller |
| **Change password (in-app)** | Yes (Settings) | Low | Exists as OTP reset, not "current→new" flow |

---

## Backend response shapes

### Pagination (Laravel default)

```json
{
  "data": [...],
  "current_page": 1,
  "last_page": 3,
  "per_page": 10,
  "total": 25,
  "links": { "first": "...", "last": "...", "prev": null, "next": "..." }
}
```

### User object

```json
{
  "id": 1,
  "name": "Lucas",
  "email": "lucas@example.com",
  "google_id": null,
  "avatar_url": "https://...",
  "email_verified_at": null,
  "created_at": "2026-06-21T...",
  "updated_at": "2026-06-21T..."
}
```

### Community object

```json
{
  "id": 1,
  "title": "EldenRing",
  "slug": "eldenring",
  "description": "...",
  "author_id": 1,
  "author": { ...user },
  "members": [ { ...user }, ... ],
  "media": [ { "original_url": "...", "collection_name": "avatar|cover" } ],
  "is_member": true,
  "created_at": "...",
  "updated_at": "..."
}
```

### Post object

```json
{
  "id": 1,
  "title": "...",
  "slug": "...",
  "description": "...",
  "community_id": 1,
  "author_id": 1,
  "likes": 5,
  "is_liked": false,
  "author": { ...user },
  "community": { ...community },
  "media": [ { "original_url": "..." } ],
  "comments": [
    {
      "id": 1,
      "content": "...",
      "author_id": 1,
      "post_id": 1,
      "parent_id": null,
      "likes": 2,
      "is_liked": false,
      "author": { ...user },
      "created_at": "..."
    }
  ],
  "created_at": "...",
  "updated_at": "..."
}
```
