<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GeminiService
{
    protected string $apiKey;

    public function __construct()
    {
        $this->apiKey = config('services.gemini.api_key');
    }

    public function analyzeDamage(string $imagePath, string $rawLocation, string $rawDescription): array
    {
        try {
            $imageUrl = $this->getImageUrl($imagePath);

            $prompt = 'Analyze the image and text. 1. Normalize location in Syria. 2. Assess damage level 1-10. 3. Extract description. Return JSON with: normalized_location, damage_level (low/medium/high/critical), analysis_text.';

            $response = Http::timeout(30)->post(
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={$this->apiKey}",
                [
                    'contents' => [
                        [
                            'parts' => [
                                ['text' => $prompt],
                                ['text' => "Location: {$rawLocation}. Description: {$rawDescription}"],
                                [
                                    'inline_data' => [
                                        'mime_type' => 'image/jpeg',
                                        'data' => base64_encode(file_get_contents(storage_path('app/public/'.$imagePath))),
                                    ],
                                ],
                            ],
                        ],
                    ],
                ]
            );

            if ($response->failed()) {
                Log::error('Gemini API error', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
                throw new \Exception('AI analysis failed');
            }

            return $this->parseResponse($response->json());

        } catch (\Exception $e) {
            Log::error('Gemini service error', [
                'error' => $e->getMessage(),
                'image_path' => $imagePath,
            ]);
            throw $e;
        }
    }

    protected function getImageUrl(string $imagePath): string
    {
        return url('storage/'.$imagePath);
    }

    protected function parseResponse(array $data): array
    {
        $text = $data['candidates'][0]['content']['parts'][0]['text'] ?? '';

        $result = [
            'normalized_location' => 'Unknown',
            'damage_level' => 'medium',
            'analysis_text' => 'Analysis unavailable',
        ];

        if (preg_match('/normalized_location["\s:]+([^,}]+)/i', $text, $matches)) {
            $result['normalized_location'] = trim($matches[1], '" ');
        }

        if (preg_match('/damage_level["\s:]+([^,}]+)/i', $text, $matches)) {
            $level = strtolower(trim($matches[1], '" '));
            if (in_array($level, ['low', 'medium', 'high', 'critical'])) {
                $result['damage_level'] = $level;
            }
        }

        if (preg_match('/analysis_text["\s:]+([^}]+)/i', $text, $matches)) {
            $result['analysis_text'] = trim($matches[1], '" ');
        }

        return $result;
    }
}
