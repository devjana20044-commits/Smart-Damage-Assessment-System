<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreReportRequest;
use App\Http\Requests\UpdateReportRequest;
use App\Http\Resources\ReportResource;
use App\Jobs\AnalyzeDamageJob;
use App\Models\Report;

/**
 * @group Report Management
 *
 * APIs for managing damage reports
 */
class ReportController extends Controller
{
    /**
     * Get all reports for the authenticated user.
     *
     * @authenticated
     *
     * @response 200 {
     *   "data": [
     *     {
     *       "id": 1,
     *       "user": {"id": 1, "name": "User"},
     *       "image_url": "http://...",
     *       "location": {...},
     *       "description": {...},
     *       "damage_assessment": {...}
     *     }
     *   ]
     * }
     */
    public function index(): \Illuminate\Http\JsonResponse
    {
        $reports = auth()->user()->reports()->latest()->get();

        return response()->json(ReportResource::collection($reports));
    }

    /**
     * Create a new damage report.
     *
     * @authenticated
     *
     * @bodyParam image file required The damage image. Maximum size: 10MB.
     * @bodyParam latitude number required The GPS latitude. Example: 36.2018
     * @bodyParam longitude number required The GPS longitude. Example: 37.1342
     * @bodyParam raw_location string required The location name as entered by user. Example: "حلب السكري"
     * @bodyParam raw_description string optional Additional description. Maximum: 2000 characters.
     *
     * @response 201 {
     *   "data": {
     *     "id": 1,
     *     "status": "pending",
     *     "message": "Report submitted successfully. Processing will start shortly."
     *   }
     * }
     * @response 422 {
     *   "errors": {
     *     "image": ["The image field is required."]
     *   }
     * }
     */
    public function store(StoreReportRequest $request): \Illuminate\Http\JsonResponse
    {
        // 1. معالجة الصور المتعددة
        $imagePaths = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $path = $image->store('reports/images', 'public');
                $imagePaths[] = $path;
            }
        }
        // دعم الصورة الواحدة القديمة للحفاظ على التوافق
        elseif ($request->hasFile('image')) {
            $path = $request->file('image')->store('reports', 'public');
            $imagePaths = [$path];
        }

        // 2. معالجة ملف PDF
        $pdfPath = null;
        if ($request->hasFile('pdf_file')) {
            $pdfPath = $request->file('pdf_file')->store('reports/docs', 'public');
        }

        // 3. معالجة الروابط (تأكد أنها مصفوفة)
        $links = $request->input('video_links', []);
        // تصفية الروابط الفارغة
        $links = array_filter($links);

        // 4. الحفظ في قاعدة البيانات
        $report = Report::create([
            'user_id' => auth()->id(),
            'image_path' => ! empty($imagePaths) ? $imagePaths[0] : null, // الحفاظ على التوافق
            'images' => ! empty($imagePaths) ? $imagePaths : null,
            'pdf_file' => $pdfPath,
            'video_links' => ! empty($links) ? $links : null,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'raw_location' => $request->raw_location,
            'raw_description' => $request->raw_description ?? '',
            'status' => 'pending',
        ]);

        AnalyzeDamageJob::dispatch($report->id);

        return response()->json([
            'data' => [
                'id' => $report->id,
                'status' => 'pending',
                'message' => 'Report submitted successfully. Processing will start shortly.',
            ],
        ], 201);
    }

    /**
     * Get a specific report.
     *
     * @authenticated
     *
     * @urlParam id required The report ID.
     *
     * @response 200 {
     *   "data": {
     *     "id": 1,
     *     "user": {...},
     *     "image_url": "http://...",
     *     ...
     *   }
     * }
     * @response 404 {"message": "Report not found"}
     */
    public function show(int $id): \Illuminate\Http\JsonResponse
    {
        $report = auth()->user()->reports()->findOrFail($id);

        return response()->json(ReportResource::make($report));
    }

    /**
     * Update a specific report.
     *
     * @authenticated
     *
     * @urlParam id required The report ID.
     */
    public function update(UpdateReportRequest $request, int $id): \Illuminate\Http\JsonResponse
    {
        $report = auth()->user()->reports()->findOrFail($id);

        // 1. معالجة الصور المتبقية (Remaining old images)
        $remainingImages = [];
        if ($request->has('remaining_old_images')) {
            $rawOldImages = $request->input('remaining_old_images', []);
            if (! is_array($rawOldImages)) {
                $rawOldImages = [$rawOldImages];
            }
            foreach ($rawOldImages as $imgUrl) {
                if (empty($imgUrl)) {
                    continue;
                }
                if (preg_match('/storage\/(.*)$/', $imgUrl, $matches)) {
                    $remainingImages[] = $matches[1];
                } else {
                    $remainingImages[] = $imgUrl;
                }
            }
        }

        // حذف الصور القديمة التي لم تعد مرغوبة من القرص
        $oldImages = $report->images ?? [];
        $imagesToDelete = array_diff($oldImages, $remainingImages);
        foreach ($imagesToDelete as $oldImg) {
            if (\Storage::disk('public')->exists($oldImg)) {
                \Storage::disk('public')->delete($oldImg);
            }
        }

        // 2. معالجة الصور الجديدة المرفوعة
        $newImagePaths = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $path = $image->store('reports/images', 'public');
                $newImagePaths[] = $path;
            }
        } elseif ($request->hasFile('image')) {
            $path = $request->file('image')->store('reports', 'public');
            $newImagePaths[] = $path;
        }

        // دمج الصور المتبقية والصور الجديدة
        $updatedImagesList = array_merge($remainingImages, $newImagePaths);

        if (! empty($updatedImagesList)) {
            $report->images = $updatedImagesList;
            $report->image_path = $updatedImagesList[0];
        } else {
            $report->images = null;
            $report->image_path = null;
        }

        // 3. معالجة ملف PDF الجديد
        if ($request->hasFile('pdf_file')) {
            if ($report->pdf_file && \Storage::disk('public')->exists($report->pdf_file)) {
                \Storage::disk('public')->delete($report->pdf_file);
            }
            $pdfPath = $request->file('pdf_file')->store('reports/docs', 'public');
            $report->pdf_file = $pdfPath;
        }

        // 4. معالجة روابط الفيديو
        if ($request->has('video_links')) {
            $links = $request->input('video_links', []);
            if (! is_array($links)) {
                $links = [$links];
            }
            $links = array_filter($links);
            $report->video_links = ! empty($links) ? array_values($links) : null;
        }

        // 5. تحديث بقية الحقول النصية والشرطية
        if ($request->has('raw_location')) {
            $report->raw_location = $request->raw_location;
        }
        if ($request->has('raw_description')) {
            $report->raw_description = $request->raw_description ?? '';
        }
        if ($request->has('latitude')) {
            $report->latitude = $request->latitude;
        }
        if ($request->has('longitude')) {
            $report->longitude = $request->longitude;
        }

        $report->status = 'pending';
        $report->save();

        // إعادة تشغيل المعالجة بالذكاء الاصطناعي
        AnalyzeDamageJob::dispatch($report->id);

        return response()->json([
            'data' => ReportResource::make($report),
            'message' => 'Report updated successfully. AI analysis has been restarted.',
        ]);
    }

    /**
     * Delete a specific report.
     *
     * @authenticated
     *
     * @urlParam id required The report ID.
     *
     * @response 200 {"message": "Report deleted successfully"}
     * @response 404 {"message": "Report not found"}
     */
    public function destroy(int $id): \Illuminate\Http\JsonResponse
    {
        $report = auth()->user()->reports()->findOrFail($id);

        // حذف الصور المتعددة
        if (! empty($report->images) && is_array($report->images)) {
            foreach ($report->images as $imagePath) {
                if (\Storage::disk('public')->exists($imagePath)) {
                    \Storage::disk('public')->delete($imagePath);
                }
            }
        }

        // حذف الصورة القديمة (للتوافق)
        if ($report->image_path && \Storage::disk('public')->exists($report->image_path)) {
            \Storage::disk('public')->delete($report->image_path);
        }

        // حذف ملف PDF
        if ($report->pdf_file && \Storage::disk('public')->exists($report->pdf_file)) {
            \Storage::disk('public')->delete($report->pdf_file);
        }

        $report->delete();

        return response()->json([
            'message' => 'Report deleted successfully',
        ]);
    }
}
