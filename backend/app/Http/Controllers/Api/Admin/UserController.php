<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "data": [
     *     {"id": 1, "name": "Admin", "email": "admin@example.com", "role": "admin", "created_at": "2024-01-01"},
     *     {"id": 2, "name": "User", "email": "user@example.com", "role": "field_user", "created_at": "2024-01-02"}
     *   ],
     *   "meta": {"current_page": 1, "last_page": 1, "per_page": 15, "total": 2}
     * }
     */
    public function index(Request $request): JsonResponse
    {
        $query = User::query();

        // Search by name or email
        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%");
            });
        }

        // Filter by role
        if ($request->has('role') && $request->role) {
            $query->where('role', $request->role);
        }

        // Filter by date range
        if ($request->has('from_date') && $request->from_date) {
            $query->whereDate('created_at', '>=', $request->from_date);
        }
        if ($request->has('to_date') && $request->to_date) {
            $query->whereDate('created_at', '<=', $request->to_date);
        }

        // Sort
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);

        $users = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $users->items(),
            'meta' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
            ],
        ]);
    }

    /**
     * @authenticated
     *
     * @bodyParam name string required The user's name. Example: John Doe
     * @bodyParam email string required The user's email. Example: john@example.com
     * @bodyParam password string required The user's password (min 8 characters). Example: password123
     * @bodyParam role string required The user's role (admin or field_user). Example: field_user
     *
     * @response 201 {
     *   "success": true,
     *   "message": "User created successfully",
     *   "data": {"id": 3, "name": "John Doe", "email": "john@example.com", "role": "field_user"}
     * }
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'role' => 'required|in:admin,field_user',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User created successfully',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'created_at' => $user->created_at->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "data": {"id": 1, "name": "Admin", "email": "admin@example.com", "role": "admin", "created_at": "2024-01-01"}
     * }
     */
    public function show(User $user): JsonResponse
    {
        $reportsCount = $user->reports()->count();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'reports_count' => $reportsCount,
                'created_at' => $user->created_at->toIso8601String(),
                'updated_at' => $user->updated_at->toIso8601String(),
            ],
        ]);
    }

    /**
     * @authenticated
     *
     * @bodyParam name string The user's name. Example: John Updated
     * @bodyParam email string The user's email (must be unique). Example: john.updated@example.com
     * @bodyParam password string New password (min 8 characters, optional). Example: newpassword123
     * @bodyParam role string The user's role (admin or field_user). Example: admin
     *
     * @response 200 {
     *   "success": true,
     *   "message": "User updated successfully",
     *   "data": {"id": 1, "name": "John Updated", "email": "john.updated@example.com", "role": "admin"}
     * }
     */
    public function update(Request $request, User $user): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => ['sometimes', 'string', 'email', 'max:255', Rule::unique('users')->ignore($user->id)],
            'password' => 'sometimes|string|min:8',
            'role' => 'sometimes|in:admin,field_user',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'User updated successfully',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'updated_at' => $user->updated_at->toIso8601String(),
            ],
        ]);
    }

    /**
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "message": "User deleted successfully"
     * }
     */
    public function destroy(User $user): JsonResponse
    {
        // Prevent deleting yourself
        if ($user->id === auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete your own account',
            ], 403);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'User deleted successfully',
        ]);
    }

    /**
     * @authenticated
     *
     * @response 200 {
     *   "success": true,
     *   "data": {"total_users": 10, "admins": 2, "field_users": 8, "users_with_reports": 5}
     * }
     */
    public function statistics(): JsonResponse
    {
        $totalUsers = User::count();
        $admins = User::where('role', 'admin')->count();
        $fieldUsers = User::where('role', 'field_user')->count();
        $usersWithReports = User::has('reports')->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_users' => $totalUsers,
                'admins' => $admins,
                'field_users' => $fieldUsers,
                'users_with_reports' => $usersWithReports,
            ],
        ]);
    }
}
