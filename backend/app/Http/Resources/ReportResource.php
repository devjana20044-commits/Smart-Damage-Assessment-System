<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReportResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        // معالجة الصور - دعم النظام الجديد والقديم
        $images = [];
        if (! empty($this->images) && is_array($this->images)) {
            // النظام الجديد: مصفوفة صور
            $images = array_map(function ($path) {
                return url('storage/'.$path);
            }, $this->images);
        } elseif (! empty($this->image_path)) {
            // النظام القديم: صورة واحدة
            $images = [url('storage/'.$this->image_path)];
        }

        // معالجة رابط PDF
        $pdfUrl = null;
        if (! empty($this->pdf_file)) {
            $pdfUrl = url('storage/'.$this->pdf_file);
        }

        // معالجة روابط الفيديو
        $videoLinks = [];
        if (! empty($this->video_links) && is_array($this->video_links)) {
            $videoLinks = array_filter($this->video_links, function ($link) {
                return ! empty($link);
            });
        }

        return [
            'id' => $this->id,
            'user' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
            ],
            // الصور (مصفوفة URLs)
            'images' => $images,
            // ملف PDF (URL أو null)
            'pdf_url' => $pdfUrl,
            // روابط الفيديو (مصفوفة)
            'video_links' => array_values($videoLinks),
            'location' => [
                'raw' => $this->raw_location,
                'normalized' => $this->ai_location ?? $this->raw_location,
                'coordinates' => [
                    'latitude' => (float) $this->latitude,
                    'longitude' => (float) $this->longitude,
                ],
            ],
            'description' => [
                'raw' => $this->raw_description,
                'ai_analysis' => $this->ai_analysis,
            ],
            'damage_assessment' => [
                'level' => $this->ai_damage_level,
                'status' => $this->status,
            ],
            'created_at' => $this->created_at->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at->format('Y-m-d H:i:s'),
        ];
    }
}
