<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class GeminiService
{
    private string $apiKey;

    private string $model;

    private string $baseUrl;

    public function __construct()
    {
        $this->apiKey = config('services.gemini.api_key');
        $this->model = config('services.gemini.model', 'gemini-2.0-flash');
        $this->baseUrl = config(
            'services.gemini.base_url',
            'https://generativelanguage.googleapis.com/v1beta'
        );
    }

    public function analyzeDamage(array $imagePaths, ?string $rawDescription = null, ?string $rawLocation = null): array
    {
        $contents = [];

        $textPrompt = $this->buildPrompt($rawDescription, $rawLocation);
        $contents[] = ['text' => $textPrompt];

        foreach ($imagePaths as $imagePath) {
            $fullPath = Storage::disk('public')->path($imagePath);

            if (! file_exists($fullPath)) {
                Log::warning("GeminiService: Image not found at {$fullPath}");

                continue;
            }

            $mimeType = $this->getMimeType($fullPath);
            $base64Data = base64_encode(file_get_contents($fullPath));

            $contents[] = [
                'inline_data' => [
                    'mime_type' => $mimeType,
                    'data' => $base64Data,
                ],
            ];
        }

        $response = Http::withHeaders([
            'Content-Type' => 'application/json',
        ])->post("{$this->baseUrl}/models/{$this->model}:generateContent?key={$this->apiKey}", [
            'contents' => [
                ['parts' => $contents],
            ],
            'generationConfig' => [
                'temperature' => 0.4,
                'maxOutputTokens' => 2048,
            ],
        ]);

        if ($response->failed()) {
            Log::error('GeminiService: API request failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return [
                'success' => false,
                'error' => 'AI analysis failed: '.$response->status(),
            ];
        }

        $result = $response->json();
        $generatedText = $result['candidates'][0]['content']['parts'][0]['text'] ?? '';

        return $this->parseAIResponse($generatedText);
    }

    private function buildPrompt(?string $description, ?string $location): string
    {
        $prompt = "You are a damage assessment expert. Analyze the provided image(s) of damage and provide a detailed assessment.\n\n";

        if ($description) {
            $prompt .= "User description: {$description}\n\n";
        }

        if ($location) {
            $prompt .= "Location: {$location}\n\n";
        }

        $prompt .= "Please provide your analysis in the following JSON format ONLY (no markdown, no code blocks):\n";
        $prompt .= "{\n";
        $prompt .= '  "damage_level": "low|medium|high|critical",';
        $prompt .= "\n";
        $prompt .= '  "location_normalized": "normalized location name in Arabic if applicable",';
        $prompt .= "\n";
        $prompt .= '  "analysis": "detailed analysis in Arabic describing the damage, affected areas, and recommendations",';
        $prompt .= "\n";
        $prompt .= "}\n\n";
        $prompt .= "Damage level criteria:\n";
        $prompt .= "- low: Minor cosmetic damage, no structural concerns\n";
        $prompt .= "- medium: Moderate damage, some structural concerns\n";
        $prompt .= "- high: Severe structural damage, building partially compromised\n";
        $prompt .= "- critical: Catastrophic damage, building at risk of collapse\n";

        return $prompt;
    }

    private function parseAIResponse(string $text): array
    {
        $text = trim($text);
        $text = preg_replace('/^```json\s*/i', '', $text);
        $text = preg_replace('/\s*```$/i', '', $text);
        $text = trim($text);

        $decoded = json_decode($text, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            Log::warning('GeminiService: Failed to parse AI JSON response', [
                'text' => $text,
                'error' => json_last_error_msg(),
            ]);

            return [
                'success' => true,
                'damage_level' => 'medium',
                'location_normalized' => null,
                'analysis' => $text,
            ];
        }

        return [
            'success' => true,
            'damage_level' => $decoded['damage_level'] ?? 'medium',
            'location_normalized' => $decoded['location_normalized'] ?? null,
            'analysis' => $decoded['analysis'] ?? $text,
        ];
    }

    private function getMimeType(string $path): string
    {
        $extension = strtolower(pathinfo($path, PATHINFO_EXTENSION));

        return match ($extension) {
            'jpg', 'jpeg' => 'image/jpeg',
            'png' => 'image/png',
            'gif' => 'image/gif',
            'webp' => 'image/webp',
            default => 'image/jpeg',
        };
    }
}
