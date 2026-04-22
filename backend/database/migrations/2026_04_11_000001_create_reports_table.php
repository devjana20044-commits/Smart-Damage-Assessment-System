<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('image_path')->nullable();
            $table->json('images')->nullable();
            $table->string('pdf_file')->nullable();
            $table->json('video_links')->nullable();
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->string('raw_location');
            $table->text('raw_description')->nullable();
            $table->string('ai_location')->nullable();
            $table->enum('ai_damage_level', ['low', 'medium', 'high', 'critical'])->nullable();
            $table->text('ai_analysis')->nullable();
            $table->enum('status', ['pending', 'processing', 'completed', 'rejected'])->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};
