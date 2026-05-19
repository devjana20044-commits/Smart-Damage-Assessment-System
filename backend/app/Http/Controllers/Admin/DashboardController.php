<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class DashboardController extends Controller
{
    public function index()
    {
        $totalReports = Report::count();
        $completedReports = Report::where('status', 'completed')->count();
        $pendingReports = Report::where('status', 'pending')->count();
        $totalUsers = User::count();

        // Damage level statistics
        $damageStats = Report::whereNotNull('ai_damage_level')
            ->selectRaw('ai_damage_level, COUNT(*) as count')
            ->groupBy('ai_damage_level')
            ->get()
            ->pluck('count', 'ai_damage_level')
            ->toArray();

        // Reports over time (last 7 days)
        $reportsOverTime = Report::selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->where('created_at', '>=', now()->subDays(7))
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->pluck('count', 'date')
            ->toArray();

        // Reports by location (top 10 cities)
        $reportsByLocation = Report::selectRaw('ai_location, COUNT(*) as count')
            ->whereNotNull('ai_location')
            ->groupBy('ai_location')
            ->orderByDesc('count')
            ->limit(10)
            ->get()
            ->pluck('count', 'ai_location')
            ->toArray();

        // Status distribution
        $statusStats = Report::selectRaw('status, COUNT(*) as count')
            ->groupBy('status')
            ->get()
            ->pluck('count', 'status')
            ->toArray();

        $recentReports = Report::with('user')
            ->latest()
            ->take(10)
            ->get();

        return view('admin.dashboard', compact(
            'totalReports',
            'completedReports',
            'pendingReports',
            'totalUsers',
            'damageStats',
            'reportsOverTime',
            'reportsByLocation',
            'statusStats',
            'recentReports'
        ));
    }

    public function map()
    {
        $reports = Report::where('status', 'completed')
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->get(['id', 'latitude', 'longitude', 'ai_damage_level', 'raw_location', 'image_path', 'images', 'pdf_file', 'video_links']);

        return view('admin.map', compact('reports'));
    }

    public function reports()
    {
        $reports = Report::with('user')->latest()->paginate(20);

        return view('admin.reports', compact('reports'));
    }

    public function create()
    {
        $users = User::all();

        return view('admin.reports.create', compact('users'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'raw_location' => 'required|string|max:255',
            'raw_description' => 'nullable|string|max:2000',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'ai_damage_level' => 'nullable|in:low,medium,high,critical',
            'status' => 'nullable|in:pending,processing,completed,rejected',
            'images' => 'nullable|array',
            'images.*' => 'nullable|image|max:10240', // Max 10MB per image
            'pdf_file' => 'nullable|file|mimes:pdf|max:20480', // Max 20MB
            'video_links' => 'nullable|array',
            'video_links.*' => 'nullable|url|max:500',
        ]);

        // Handle images
        $images = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                if ($image->isValid()) {
                    $path = $image->store('reports', 'public');
                    $images[] = $path;
                }
            }
        }

        // Handle PDF file
        $pdfPath = null;
        if ($request->hasFile('pdf_file')) {
            $pdfPath = $request->file('pdf_file')->store('reports', 'public');
        }

        // Handle video links
        $videoLinks = array_filter($request->input('video_links', []), function ($link) {
            return ! empty($link) && filter_var($link, FILTER_VALIDATE_URL);
        });

        Report::create([
            'user_id' => $validated['user_id'],
            'raw_location' => $validated['raw_location'],
            'raw_description' => $validated['raw_description'] ?? '',
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'ai_damage_level' => $validated['ai_damage_level'] ?? null,
            'status' => $validated['status'] ?? 'pending',
            'image_path' => '',
            'images' => $images,
            'pdf_file' => $pdfPath,
            'video_links' => array_values($videoLinks),
        ]);

        return redirect()->route('admin.reports')->with('success', 'تم إنشاء التقرير بنجاح.');
    }

    public function edit(Report $report)
    {
        $users = User::all();

        return view('admin.reports.edit', compact('report', 'users'));
    }

    public function update(Request $request, Report $report)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'raw_location' => 'required|string|max:255',
            'raw_description' => 'nullable|string|max:2000',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'ai_damage_level' => 'nullable|in:low,medium,high,critical',
            'status' => 'nullable|in:pending,processing,completed,rejected',
            'images' => 'nullable|array',
            'images.*' => 'nullable|image|max:10240', // Max 10MB per image
            'existing_images' => 'nullable|array',
            'pdf_file' => 'nullable|file|mimes:pdf|max:20480', // Max 20MB
            'remove_pdf' => 'nullable|boolean',
            'video_links' => 'nullable|array',
            'video_links.*' => 'nullable|url|max:500',
            'keep_old_image' => 'nullable|string',
        ]);

        // Handle images
        $images = $request->input('existing_images', []);

        // Add old image if keeping it
        if ($request->input('keep_old_image') == '1' && $report->image_path) {
            if (! in_array($report->image_path, $images)) {
                $images[] = $report->image_path;
            }
        }

        // Upload new images
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                if ($image->isValid()) {
                    $path = $image->store('reports', 'public');
                    $images[] = $path;
                }
            }
        }

        // Handle PDF file
        $pdfPath = $report->pdf_file;

        if ($request->hasFile('pdf_file')) {
            // Delete old PDF if exists
            if ($report->pdf_file && Storage::disk('public')->exists($report->pdf_file)) {
                Storage::disk('public')->delete($report->pdf_file);
            }

            // Upload new PDF
            $pdfPath = $request->file('pdf_file')->store('reports', 'public');
        } elseif ($request->has('remove_pdf')) {
            // Delete PDF if requested
            if ($report->pdf_file && Storage::disk('public')->exists($report->pdf_file)) {
                Storage::disk('public')->delete($report->pdf_file);
            }
            $pdfPath = null;
        }

        // Handle video links
        $videoLinks = array_filter($request->input('video_links', []), function ($link) {
            return ! empty($link) && filter_var($link, FILTER_VALIDATE_URL);
        });

        $report->update([
            'user_id' => $validated['user_id'],
            'raw_location' => $validated['raw_location'],
            'raw_description' => $validated['raw_description'] ?? $report->raw_description,
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'ai_damage_level' => $validated['ai_damage_level'] ?? $report->ai_damage_level,
            'status' => $validated['status'] ?? $report->status,
            'images' => $images,
            'pdf_file' => $pdfPath,
            'video_links' => array_values($videoLinks),
        ]);

        return redirect()->route('admin.reports.show', $report)->with('success', 'تم تحديث التقرير بنجاح.');
    }

    public function show(Report $report)
    {
        $report->load('user');

        return view('admin.reports.show', compact('report'));
    }

    public function destroy(Report $report)
    {
        $report->delete();

        return redirect()->route('admin.reports')->with('success', 'تم حذف التقرير بنجاح.');
    }
}
