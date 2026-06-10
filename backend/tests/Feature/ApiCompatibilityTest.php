<?php

namespace Tests\Feature;

use App\Models\Report;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ApiCompatibilityTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_via_api()
    {
        $response = $this->postJson('/api/register', [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'token',
                'user' => ['id', 'name', 'email', 'role', 'profile_image'],
            ])
            ->assertJson([
                'user' => [
                    'name' => 'John Doe',
                    'email' => 'john@example.com',
                    'role' => 'field_user',
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
        ]);
    }

    public function test_user_can_login_via_api()
    {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password123'),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'test@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'token',
                'user' => ['id', 'name', 'email', 'role', 'profile_image'],
            ]);
    }

    public function test_user_can_get_current_user_via_api()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/me');

        $response->assertStatus(200)
            ->assertJsonStructure(['id', 'name', 'email', 'role', 'profile_image']);
    }

    public function test_user_can_update_profile_via_api()
    {
        Storage::fake('public');
        $user = User::factory()->create();

        $file = UploadedFile::fake()->image('avatar.jpg');

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/me', [
                'name' => 'Updated Name',
                'email' => 'updated@example.com',
                'profile_image' => $file,
            ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'user' => ['id', 'name', 'email', 'role', 'profile_image'],
            ])
            ->assertJson([
                'user' => [
                    'name' => 'Updated Name',
                    'email' => 'updated@example.com',
                ],
            ]);

        $user->refresh();
        $this->assertEquals('Updated Name', $user->name);
        $this->assertNotNull($user->profile_image);
        Storage::disk('public')->assertExists($user->profile_image);
    }

    public function test_user_can_change_password_with_correct_current_password_via_api()
    {
        $user = User::factory()->create([
            'password' => Hash::make('old-password'),
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/me', [
                'name' => $user->name,
                'email' => $user->email,
                'current_password' => 'old-password',
                'password' => 'new-password123',
                'password_confirmation' => 'new-password123',
            ]);

        $response->assertStatus(200);
        $user->refresh();
        $this->assertTrue(Hash::check('new-password123', $user->password));
    }

    public function test_user_cannot_change_password_with_wrong_current_password_via_api()
    {
        $user = User::factory()->create([
            'password' => Hash::make('old-password'),
        ]);

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/me', [
                'name' => $user->name,
                'email' => $user->email,
                'current_password' => 'wrong-old-password',
                'password' => 'new-password123',
                'password_confirmation' => 'new-password123',
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['current_password']);
        
        $user->refresh();
        $this->assertTrue(Hash::check('old-password', $user->password));
    }

    public function test_user_can_update_report_via_api()
    {
        Queue::fake();
        Storage::fake('public');

        $user = User::factory()->create();

        // Create a dummy report
        $report = Report::create([
            'user_id' => $user->id,
            'image_path' => 'reports/image1.jpg',
            'images' => ['reports/image1.jpg'],
            'latitude' => 35.123456,
            'longitude' => 36.654321,
            'raw_location' => 'Original Location',
            'raw_description' => 'Original Description',
            'status' => 'completed',
        ]);

        // Mock files
        $file1 = UploadedFile::fake()->image('image2.jpg');
        $file2 = UploadedFile::fake()->image('image3.jpg');

        $response = $this->actingAs($user, 'sanctum')
            ->postJson("/api/reports/{$report->id}", [
                'raw_location' => 'Updated Location',
                'raw_description' => 'Updated Description',
                'latitude' => 36.1111,
                'longitude' => 37.2222,
                'images' => [$file1, $file2],
                'remaining_old_images' => ['reports/image1.jpg'], // keep original
            ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'images',
                    'location' => [
                        'raw',
                        'coordinates' => ['latitude', 'longitude'],
                    ],
                    'description' => ['raw'],
                    'damage_assessment' => ['status'],
                ],
                'message',
            ]);

        $report->refresh();
        $this->assertEquals('Updated Location', $report->raw_location);
        $this->assertEquals('Updated Description', $report->raw_description);
        $this->assertEquals(36.1111, (float) $report->latitude);
        $this->assertEquals(37.2222, (float) $report->longitude);
        $this->assertEquals('pending', $report->status);

        // Check that images now contain the remaining old image + 2 new images
        $this->assertCount(3, $report->images);
        $this->assertEquals('reports/image1.jpg', $report->images[0]);

        Queue::assertPushed(\App\Jobs\AnalyzeDamageJob::class);
    }
}
