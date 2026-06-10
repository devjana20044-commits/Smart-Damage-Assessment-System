<?php

use Illuminate\Support\Facades\Route;

/**
 * Health check endpoint to test API connection
 *
 * @response 200 {"status":"ok","message":"API is running","version":"1.0.0"}
 */
Route::get('/', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API is running',
        'version' => '1.0.0',
        'timestamp' => now()->toIso8601String(),
    ]);
});

// Auth routes
Route::post('/login', [App\Http\Controllers\Api\AuthController::class, 'login']);
Route::post('/register', [App\Http\Controllers\Api\AuthController::class, 'register']);
Route::post('/logout', [App\Http\Controllers\Api\AuthController::class, 'logout'])->middleware('auth:sanctum');
Route::get('/me', [App\Http\Controllers\Api\AuthController::class, 'me'])->middleware('auth:sanctum');
Route::match(['put', 'post'], '/me', [App\Http\Controllers\Api\AuthController::class, 'updateMe'])->middleware('auth:sanctum');

// User routes (for field users)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/reports', [App\Http\Controllers\Api\ReportController::class, 'index']);
    Route::post('/reports', [App\Http\Controllers\Api\ReportController::class, 'store']);
    Route::get('/reports/{id}', [App\Http\Controllers\Api\ReportController::class, 'show']);
    Route::match(['post', 'put'], '/reports/{id}', [App\Http\Controllers\Api\ReportController::class, 'update']);
    Route::delete('/reports/{id}', [App\Http\Controllers\Api\ReportController::class, 'destroy']);
});

// Admin routes (admin role required)
Route::middleware(['auth:sanctum', 'admin.api'])->prefix('admin')->group(function () {
    // User management
    Route::get('/users', [App\Http\Controllers\Api\Admin\UserController::class, 'index']);
    Route::post('/users', [App\Http\Controllers\Api\Admin\UserController::class, 'store']);
    Route::get('/users/statistics', [App\Http\Controllers\Api\Admin\UserController::class, 'statistics']);
    Route::get('/users/{user}', [App\Http\Controllers\Api\Admin\UserController::class, 'show']);
    Route::put('/users/{user}', [App\Http\Controllers\Api\Admin\UserController::class, 'update']);
    Route::delete('/users/{user}', [App\Http\Controllers\Api\Admin\UserController::class, 'destroy']);
});
