<?php

namespace App\Jobs;

use App\Models\Report;
use App\Services\GeminiService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessReportWithAI implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;

    public int $timeout = 120;

    public function __construct(
        public Report $report
    ) {}

    public function handle(GeminiService $geminiService): void
    {
        $this->report->update(['status' => 'processing']);

        try {
            $imagePaths = [];

            if ($this->report->images && is_array($this->report->images)) {
                $imagePaths = $this->report->images;
            } elseif ($this->report->image_path) {
                $imagePaths = [$this->report->image_path];
            }

            if (empty($imagePaths)) {
                $this->report->update([
                    'status' => 'completed',
                    'ai_analysis' => 'No images provided for analysis.',
                    'ai_damage_level' => 'low',
                ]);

                return;
            }

            $result = $geminiService->analyzeDamage(
                $imagePaths,
                $this->report->raw_description,
                $this->report->raw_location
            );

            if (! $result['success']) {
                $this->report->update([
                    'status' => 'rejected',
                    'ai_analysis' => $result['error'] ?? 'AI analysis failed',
                ]);

                Log::error("ProcessReportWithAI: Analysis failed for report {$this->report->id}", [
                    'error' => $result['error'] ?? 'Unknown error',
                ]);

                return;
            }

            $this->report->update([
                'status' => 'completed',
                'ai_damage_level' => $result['damage_level'],
                'ai_location' => $result['location_normalized'],
                'ai_analysis' => $result['analysis'],
            ]);

            Log::info("ProcessReportWithAI: Report {$this->report->id} processed successfully", [
                'damage_level' => $result['damage_level'],
            ]);
        } catch (\Exception $e) {
            $this->report->update([
                'status' => 'rejected',
                'ai_analysis' => 'AI processing error: '.$e->getMessage(),
            ]);

            Log::error("ProcessReportWithAI: Exception for report {$this->report->id}", [
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    public function failed(\Throwable $exception): void
    {
        $this->report->update([
            'status' => 'rejected',
            'ai_analysis' => 'AI processing failed: '.$exception->getMessage(),
        ]);

        Log::error("ProcessReportWithAI: Job failed for report {$this->report->id}", [
            'error' => $exception->getMessage(),
        ]);
    }
}
