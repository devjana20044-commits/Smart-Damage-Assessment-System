<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProfileUpdateRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

/**
 * @group Authentication
 *
 * APIs for user authentication
 */
class AuthController extends Controller
{
    /**
     * Register a new user.
     *
     * @response 201 {
     *   "token": "1|xyz...",
     *   "user": {
     *     "id": 2,
     *     "name": "Jane Doe",
     *     "email": "jane@example.com",
     *     "role": "field_user",
     *     "profile_image": null
     *   }
     * }
     * @response 422 {"success": false, "message": "Validation error", "errors": {...}}
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'field_user',
        ]);

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'profile_image' => null,
            ],
        ], 201);
    }

    /**
     * Login user and return API token.
     *
     * @bodyParam email string required The user email. Example: admin@test.com
     * @bodyParam password string required The user password. Example: password
     *
     * @response 200 {
     *   "token": "1|xyz...",
     *   "user": {
     *     "id": 1,
     *     "name": "Admin User",
     *     "email": "admin@test.com",
     *     "role": "admin",
     *     "profile_image": "http://localhost:8000/storage/profiles/abc.png"
     *   }
     * }
     * @response 401 {"error": "Invalid credentials"}
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json(['error' => 'Invalid credentials'], 401);
        }

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'profile_image' => $user->profile_image ? url('storage/'.$user->profile_image) : null,
            ],
        ]);
    }

    /**
     * Logout user and invalidate token.
     *
     * @authenticated
     *
     * @response 200 {"message": "Logged out successfully"}
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out successfully']);
    }

    /**
     * Get the authenticated user.
     *
     * @authenticated
     *
     * @response 200 {
     *   "id": 1,
     *   "name": "Admin User",
     *   "email": "admin@test.com",
     *   "role": "admin",
     *   "profile_image": "http://localhost:8000/storage/profiles/abc.png"
     * }
     */
    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'profile_image' => $user->profile_image ? url('storage/'.$user->profile_image) : null,
        ]);
    }

    /**
     * Update the authenticated user's profile.
     *
     * @authenticated
     *
     * @response 200 {
     *   "user": {
     *     "id": 1,
     *     "name": "Updated User",
     *     "email": "updated@test.com",
     *     "role": "field_user",
     *     "profile_image": "http://localhost:8000/storage/profiles/xyz.png"
     *   },
     *   "message": "Profile updated successfully"
     * }
     */
    public function updateMe(ProfileUpdateRequest $request)
    {
        $user = $request->user();

        $user->name = $request->name;
        $user->email = $request->email;

        if ($request->filled('password')) {
            // Verify current password is correct (supporting both hashed and plain text fallback for development)
            $isCorrect = false;
            if ($request->filled('current_password')) {
                $isCorrect = Hash::check($request->current_password, $user->password) 
                    || $request->current_password === $user->password;
            }

            if (!$isCorrect) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => [
                        'current_password' => ['كلمة المرور الحالية غير صحيحة.']
                    ]
                ], 422);
            }
            $user->password = Hash::make($request->password);
        }

        if ($request->hasFile('profile_image')) {
            // Delete old profile image if it exists
            if ($user->profile_image && Storage::disk('public')->exists($user->profile_image)) {
                Storage::disk('public')->delete($user->profile_image);
            }

            $path = $request->file('profile_image')->store('profiles', 'public');
            $user->profile_image = $path;
        }

        $user->save();

        return response()->json([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'profile_image' => $user->profile_image ? url('storage/'.$user->profile_image) : null,
            ],
            'message' => 'Profile updated successfully',
        ]);
    }
}
