<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Report extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'image_path',
        'latitude',
        'longitude',
        'raw_location',
        'raw_description',
        'ai_location',
        'ai_damage_level',
        'ai_analysis',
        'status',
        'images',
        'pdf_file',
        'video_links',
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'ai_damage_level' => 'string',
        'status' => 'string',
        'images' => 'array',
        'video_links' => 'array',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
