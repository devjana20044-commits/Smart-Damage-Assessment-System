<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class Report extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'image_path',
        'images',
        'pdf_file',
        'video_links',
        'latitude',
        'longitude',
        'raw_location',
        'raw_description',
        'ai_location',
        'ai_damage_level',
        'ai_analysis',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'images' => 'array',
            'video_links' => 'array',
            'latitude' => 'decimal:8',
            'longitude' => 'decimal:8',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function getImageUrlsAttribute(): array
    {
        $urls = [];

        if ($this->images && is_array($this->images)) {
            foreach ($this->images as $path) {
                $urls[] = url(Storage::url($path));
            }
        }

        if (empty($urls) && $this->image_path) {
            $urls[] = url(Storage::url($this->image_path));
        }

        return $urls;
    }

    public function getPdfUrlAttribute(): ?string
    {
        return $this->pdf_file ? url(Storage::url($this->pdf_file)) : null;
    }

    protected static function booted(): void
    {
        static::deleting(function (Report $report) {
            if ($report->image_path) {
                Storage::disk('public')->delete($report->image_path);
            }

            if ($report->images && is_array($report->images)) {
                foreach ($report->images as $path) {
                    Storage::disk('public')->delete($path);
                }
            }

            if ($report->pdf_file) {
                Storage::disk('public')->delete($report->pdf_file);
            }
        });
    }
}
