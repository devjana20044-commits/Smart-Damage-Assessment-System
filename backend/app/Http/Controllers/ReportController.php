<?php

namespace App\Http\Controllers;

use App\Http\Resources\ReportResource;
use App\Jobs\ProcessReportWithAI;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ReportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $reports = $request->user()
            ->reports()
            ->latest()
            ->paginate($request->query('per_page', 20));

        return response()->json(
            ReportResource::collection($reports)
                ->response()
                ->getData(true)
        );
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'image' => 'nullable|image|max:10240',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:10240',
            'pdf_file' => 'nullable|mimes:pdf|max:20480',
            'video_links' => 'nullable|array',
            'video_links.*' => 'nullable|url',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'raw_location' => 'required|string|max:255',
            'raw_description' => 'nullable|string|max:2000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();

        $imagePaths = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $imagePaths[] = $image->store('reports/images', 'public');
            }
        }

        $legacyImagePath = null;
        if ($request->hasFile('image')) {
            $legacyImagePath = $request->file('image')->store('reports/images', 'public');
        }

        $pdfFilePath = null;
        if ($request->hasFile('pdf_file')) {
            $pdfFilePath = $request->file('pdf_file')->store('reports/docs', 'public');
        }

        $report = $request->user()->reports()->create([
            'image_path' => $legacyImagePath,
            'images' => ! empty($imagePaths) ? $imagePaths : null,
            'pdf_file' => $pdfFilePath,
            'video_links' => $data['video_links'] ?? null,
            'latitude' => $data['latitude'],
            'longitude' => $data['longitude'],
            'raw_location' => $data['raw_location'],
            'raw_description' => $data['raw_description'] ?? null,
            'status' => 'pending',
        ]);

        ProcessReportWithAI::dispatch($report);

        return response()->json([
            'data' => [
                'id' => $report->id,
                'status' => $report->status,
                'message' => 'Report submitted successfully. Processing will start shortly.',
            ],
        ], 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $report = $request->user()->reports()->findOrFail($id);

        return response()->json(
            ReportResource::make($report)->resolve()
        );
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $report = $request->user()->reports()->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'raw_location' => 'sometimes|string|max:255',
            'raw_description' => 'nullable|string|max:2000',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'image' => 'nullable|image|max:10240',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:10240',
            'pdf_file' => 'nullable|mimes:pdf|max:20480',
            'video_links' => 'nullable|array',
            'video_links.*' => 'nullable|url',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = array_filter($validator->validated(), function ($value) {
            return $value !== null;
        });

        $imagePaths = $report->images ?? [];
        
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $imagePaths[] = $image->store('reports/images', 'public');
            }
            $data['images'] = $imagePaths;
        }

        if ($request->hasFile('image')) {
            $data['image_path'] = $request->file('image')->store('reports/images', 'public');
        }

        if ($request->hasFile('pdf_file')) {
            $data['pdf_file'] = $request->file('pdf_file')->store('reports/docs', 'public');
        }

        if ($request->has('video_links')) {
            $data['video_links'] = $request->input('video_links');
        }

        $report->update($data);

        return response()->json([
            'data' => ReportResource::make($report->fresh())->resolve(),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $report = $request->user()->reports()->findOrFail($id);
        $report->delete();

        return response()->json([
            'message' => 'Report deleted successfully',
        ]);
    }
}
