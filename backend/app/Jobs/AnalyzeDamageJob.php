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

class AnalyzeDamageJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected int $reportId;

    protected int $tries = 3;

    protected int $timeout = 60;

    public function __construct(int $reportId)
    {
        $this->reportId = $reportId;
    }

    public function handle(GeminiService $geminiService)
    {
        $report = Report::find($this->reportId);

        if (! $report) {
            Log::warning('Report not found for AI processing', ['report_id' => $this->reportId]);

            return;
        }

        try {
            $report->update(['status' => 'processing']);

            $result = $geminiService->analyzeDamage(
                $report->image_path,
                $report->raw_location,
                $report->raw_description
            );

            $report->update([
                'ai_location' => $result['normalized_location'],
                'ai_damage_level' => $result['damage_level'],
                'ai_analysis' => $result['analysis_text'],
                'status' => 'completed',
            ]);

            Log::info('AI analysis completed', ['report_id' => $this->reportId]);

        } catch (\Exception $e) {
            $report->update(['status' => 'rejected']);

            Log::error('AI processing failed', [
                'report_id' => $this->reportId,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }

    public function failed(\Throwable $exception)
    {
        $report = Report::find($this->reportId);
        if ($report) {
            $report->update(['status' => 'rejected']);
        }
    }
}
