# Admin Users Management API Documentation

## Base URL
```
http://localhost:8000/api
```

## Authentication
All endpoints require **Sanctum Bearer Token Authentication** with admin role.

### Headers
```
Authorization: Bearer <your_sanctum_token>
Accept: application/json
Content-Type: application/json
```

### Authentication Error Responses
```json
// 401 Unauthorized - Missing/Invalid Token
{
    "message": "Unauthenticated."
}

// 403 Forbidden - Non-admin User
{
    "success": false,
    "message": "Unauthorized. Admin access required."
}
```

---

## Endpoints Overview

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/users` | List all users (paginated) |
| GET | `/api/admin/users/statistics` | Get user statistics |
| GET | `/api/admin/users/{id}` | Get single user details |
| POST | `/api/admin/users` | Create new user |
| PUT/PATCH | `/api/admin/users/{id}` | Update user |
| DELETE | `/api/admin/users/{id}` | Delete user |

---

## 1. List All Users

### Request
```
GET /api/admin/users
```

### Query Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `search` | string | null | Search by name or email |
| `role` | string | null | Filter by role (`admin`, `field_user`) |
| `from_date` | date | null | Filter users created from date (Y-m-d) |
| `to_date` | date | null | Filter users created until date (Y-m-d) |
| `sort_by` | string | `created_at` | Sort field (id, name, email, role, created_at) |
| `sort_order` | string | `desc` | Sort order (`asc`, `desc`) |
| `per_page` | integer | 15 | Items per page |

### Example Request
```bash
curl -X GET "http://localhost:8000/api/admin/users?search=john&role=field_user&per_page=10" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Success Response (200 OK)
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "John Doe",
            "email": "john@example.com",
            "role": "field_user",
            "created_at": "2024-01-15T10:30:00Z"
        },
        {
            "id": 2,
            "name": "John Smith",
            "email": "john.smith@example.com",
            "role": "field_user",
            "created_at": "2024-01-16T14:20:00Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "last_page": 1,
        "per_page": 10,
        "total": 2
    }
}
```

---

## 2. Get User Statistics

### Request
```
GET /api/admin/users/statistics
```

### Example Request
```bash
curl -X GET "http://localhost:8000/api/admin/users/statistics" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Success Response (200 OK)
```json
{
    "success": true,
    "data": {
        "total_users": 50,
        "admins": 5,
        "field_users": 45,
        "users_with_reports": 32
    }
}
```

---

## 3. Get Single User

### Request
```
GET /api/admin/users/{id}
```

### URL Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | User ID (required) |

### Example Request
```bash
curl -X GET "http://localhost:8000/api/admin/users/5" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Success Response (200 OK)
```json
{
    "success": true,
    "data": {
        "id": 5,
        "name": "John Doe",
        "email": "john@example.com",
        "role": "field_user",
        "reports_count": 12,
        "created_at": "2024-01-15T10:30:00Z",
        "updated_at": "2024-02-20T08:15:00Z"
    }
}
```

### Error Response (404 Not Found)
```json
{
    "success": false,
    "message": "No query results for model [App\\Models\\User] #5"
}
```

---

## 4. Create New User

### Request
```
POST /api/admin/users
```

### Request Body
| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| `name` | string | Yes | max:255 |
| `email` | string | Yes | email, unique:users |
| `password` | string | Yes | min:8 |
| `role` | string | Yes | in:admin,field_user |

### Example Request
```bash
curl -X POST "http://localhost:8000/api/admin/users" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "password": "securepassword123",
    "role": "field_user"
  }'
```

### Success Response (201 Created)
```json
{
    "success": true,
    "message": "User created successfully",
    "data": {
        "id": 15,
        "name": "John Doe",
        "email": "john.doe@example.com",
        "role": "field_user",
        "created_at": "2024-03-15T10:30:00Z"
    }
}
```

### Validation Error Response (422 Unprocessable Entity)
```json
{
    "message": "The email has already been taken.",
    "errors": {
        "email": [
            "The email has already been taken."
        ]
    }
}
```

### Validation Rules Details
```json
{
    "name": ["required", "string", "max:255"],
    "email": ["required", "string", "email", "max:255", "unique:users"],
    "password": ["required", "string", "min:8"],
    "role": ["required", "in:admin,field_user"]
}
```

### Custom Validation Messages
```json
{
    "name.required": "The name field is required.",
    "name.max": "The name may not be greater than 255 characters.",
    "email.required": "The email field is required.",
    "email.email": "Please provide a valid email address.",
    "email.unique": "This email is already taken.",
    "password.required": "The password field is required.",
    "password.min": "The password must be at least 8 characters.",
    "role.required": "The role field is required.",
    "role.in": "The role must be either admin or field_user."
}
```

---

## 5. Update User

### Request
```
PUT /api/admin/users/{id}
```
or
```
PATCH /api/admin/users/{id}
```

### URL Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | User ID (required) |

### Request Body
| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| `name` | string | No | max:255 |
| `email` | string | No | email, unique:users (ignore current) |
| `password` | string | No | min:8 |
| `role` | string | No | in:admin,field_user |

### Example Request
```bash
curl -X PUT "http://localhost:8000/api/admin/users/15" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "role": "admin"
  }'
```

### Success Response (200 OK)
```json
{
    "success": true,
    "message": "User updated successfully",
    "data": {
        "id": 15,
        "name": "John Updated",
        "email": "john.doe@example.com",
        "role": "admin",
        "updated_at": "2024-03-15T12:45:00Z"
    }
}
```

### Validation Rules for Update
```json
{
    "name": ["sometimes", "string", "max:255"],
    "email": ["sometimes", "string", "email", "max:255", "unique:users,id,{id}"],
    "password": ["sometimes", "string", "min:8"],
    "role": ["sometimes", "in:admin,field_user"]
}
```

### Error Response (404 Not Found)
```json
{
    "success": false,
    "message": "No query results for model [App\\Models\\User] #999"
}
```

---

## 6. Delete User

### Request
```
DELETE /api/admin/users/{id}
```

### URL Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | User ID (required) |

### Example Request
```bash
curl -X DELETE "http://localhost:8000/api/admin/users/15" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Success Response (200 OK)
```json
{
    "success": true,
    "message": "User deleted successfully"
}
```

### Error Response (403 Forbidden) - Self-deletion
```json
{
    "success": false,
    "message": "Cannot delete your own account"
}
```

### Error Response (404 Not Found)
```json
{
    "success": false,
    "message": "No query results for model [App\\Models\\User] #999"
}
```

---

## Complete Postman Collection Example

### Environment Variables
```
BASE_URL: http://localhost:8000/api
TOKEN: your_sanctum_token_here
```

### Collection JSON
```json
{
  "info": {
    "name": "Admin Users Management API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "auth": {
    "type": "bearer",
    "bearer": [
      {
        "key": "token",
        "value": "{{TOKEN}}",
        "type": "string"
      }
    ]
  },
  "item": [
    {
      "name": "List Users",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "{{BASE_URL}}/admin/users?per_page=15",
          "host": ["{{BASE_URL}}"],
          "path": ["admin", "users"],
          "query": [
            {
              "key": "search",
              "value": "john",
              "disabled": true
            },
            {
              "key": "role",
              "value": "field_user",
              "disabled": true
            },
            {
              "key": "per_page",
              "value": "15"
            }
          ]
        }
      }
    },
    {
      "name": "Get User Statistics",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "{{BASE_URL}}/admin/users/statistics",
          "host": ["{{BASE_URL}}"],
          "path": ["admin", "users", "statistics"]
        }
      }
    },
    {
      "name": "Get Single User",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "{{BASE_URL}}/admin/users/1",
          "host": ["{{BASE_URL}}"],
          "path": ["admin", "users", "1"]
        }
      }
    },
    {
      "name": "Create User",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          },
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"name\": \"John Doe\",\n  \"email\": \"john.doe@example.com\",\n  \"password\": \"securepassword123\",\n  \"role\": \"field_user\"\n}"
        },
        "url": {
          "raw": "{{BASE_URL}}/admin/users",
          "host": ["{{BASE_URL}}"],
          "path": ["admin", "users"]
        }
      }
    },
    {
      "name": "Update User",
      "request": {
        "method": "PUT",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          },
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"name\": \"John Updated\",\n  \"role\": \"admin\"\n}"
        },
        "url": {
          "raw": "{{BASE_URL}}/admin/users/1",
          "host": ["{{BASE_URL}}"],
          "path": ["admin", "users", "1"]
        }
      }
    },
    {
      "name": "Delete User",
      "request": {
        "method": "DELETE",
        "header": [
          {
            "key": "Accept",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "{{BASE_URL}}/admin/users/1",
          "host": ["{{BASE_URL}}"],
          "path": ["admin", "users", "1"]
        }
      }
    }
  ]
}
```

---

## HTTP Status Codes Reference

| Status Code | Description |
|-------------|-------------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Admin access required |
| 404 | Not Found - User not found |
| 422 | Unprocessable Entity - Validation failed |
| 500 | Internal Server Error - Server error |

---

## Role Management

### Available Roles
| Role | Description |
|------|-------------|
| `admin` | Full administrative access |
| `field_user` | Field user with limited access |

### Role Validation
- Only `admin` and `field_user` values are accepted
- Role is validated on both create and update operations
- Admin middleware ensures only admin users can access these endpoints

---

## Security Notes

1. **Authentication**: All endpoints require valid Sanctum token
2. **Authorization**: Admin role required via `admin.api` middleware
3. **Self-protection**: Users cannot delete their own accounts
4. **Password Hashing**: Passwords are hashed using Laravel's Hash facade
5. **Email Uniqueness**: Email uniqueness is enforced, ignoring current user on update
6. **Validation**: All input is validated before processing

---

## Rate Limiting

Default Laravel rate limiting applies:
- 60 requests per minute per authenticated user
- Rate limit headers included in response

---

## Caching Recommendations

For production, consider caching:
- User statistics (5-15 minute TTL)
- User list with frequent query patterns
- Single user details for frequently accessed profiles

---

## Database Relationships

User model has the following relationships:
- `hasMany` Report - User can have many reports
- Reports count is included in user detail response

---

## Files Created

| File | Path | Purpose |
|------|------|---------|
| UserController | `app/Http/Controllers/Api/Admin/UserController.php` | CRUD operations |
| UserRequest | `app/Http/Requests/UserRequest.php` | Validation rules |
| UserResource | `app/Http/Resources/UserResource.php` | API response transformation |
| Routes | `routes/api.php` | API routes under `/api/admin/users` |

---

## Testing Examples

### PHPUnit Test Examples
```php
// Test list users
public function test_admin_can_list_users()
{
    $admin = User::factory()->create(['role' => 'admin']);
    
    $response = $this->actingAs($admin)
        ->getJson('/api/admin/users');
    
    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'data' => [
                '*' => ['id', 'name', 'email', 'role', 'created_at']
            ],
            'meta' => ['current_page', 'last_page', 'per_page', 'total']
        ]);
}

// Test create user
public function test_admin_can_create_user()
{
    $admin = User::factory()->create(['role' => 'admin']);
    
    $response = $this->actingAs($admin)
        ->postJson('/api/admin/users', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password123',
            'role' => 'field_user'
        ]);
    
    $response->assertStatus(201)
        ->assertJson([
            'success' => true,
            'message' => 'User created successfully'
        ]);
}

// Test non-admin cannot access
public function test_non_admin_cannot_access_users()
{
    $user = User::factory()->create(['role' => 'field_user']);
    
    $response = $this->actingAs($user)
        ->getJson('/api/admin/users');
    
    $response->assertStatus(403);
}
```
