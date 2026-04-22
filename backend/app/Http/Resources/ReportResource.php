<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReportResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
            ],
            'images' => $this->image_urls,
            'pdf_url' => $this->pdf_url,
            'video_links' => $this->video_links ?? [],
            'location' => [
                'raw' => $this->raw_location,
                'normalized' => $this->ai_location,
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
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
        ];
    }
}
