<?php

namespace App\Http\Controllers\User;

use App\Http\Controllers\Controller;
use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class DashboardController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        $totalReports = Report::where('user_id', $user->id)->count();
        $pendingReports = Report::where('user_id', $user->id)->where('status', 'pending')->count();
        $completedReports = Report::where('user_id', $user->id)->where('status', 'completed')->count();
        $recentReports = Report::where('user_id', $user->id)
            ->with('user')
            ->latest()
            ->take(10)
            ->get();

        return view('user.dashboard', compact(
            'totalReports',
            'pendingReports',
            'completedReports',
            'recentReports'
        ));
    }

    public function reports()
    {
        $userId = auth()->id();
        $query = Report::where('user_id', $userId);

        $totalReports = (clone $query)->count();
        $pendingReports = (clone $query)->where('status', 'pending')->count();
        $processingReports = (clone $query)->where('status', 'processing')->count();
        $completedReports = (clone $query)->where('status', 'completed')->count();
        $reports = (clone $query)->latest()->paginate(9);

        return view('user.reports.index', compact('reports', 'totalReports', 'pendingReports', 'processingReports', 'completedReports'));
    }

    public function create()
    {
        return view('user.reports.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'raw_location' => 'required|string|max:255',
            'raw_description' => 'nullable|string|max:2000',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'images' => 'nullable|array',
            'images.*' => 'nullable|image|max:10240',
            'pdf_file' => 'nullable|file|mimes:pdf|max:20480',
            'video_links' => 'nullable|array',
            'video_links.*' => 'nullable|url|max:500',
        ]);

        $images = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                if ($image->isValid()) {
                    $path = $image->store('reports', 'public');
                    $images[] = $path;
                }
            }
        }

        $pdfPath = null;
        if ($request->hasFile('pdf_file')) {
            $pdfPath = $request->file('pdf_file')->store('reports', 'public');
        }

        $videoLinks = array_filter($request->input('video_links', []), function ($link) {
            return ! empty($link) && filter_var($link, FILTER_VALIDATE_URL);
        });

        Report::create([
            'user_id' => auth()->id(),
            'raw_location' => $validated['raw_location'],
            'raw_description' => $validated['raw_description'] ?? '',
            'latitude' => $validated['latitude'],
            'longitude' => $validated['longitude'],
            'status' => 'pending',
            'image_path' => '',
            'images' => $images,
            'pdf_file' => $pdfPath,
            'video_links' => array_values($videoLinks),
        ]);

        return redirect()->route('user.reports')->with('success', 'تم إرسال البلاغ بنجاح. سيتم تحليله بالذكاء الاصطناعي.');
    }

    public function profile()
    {
        return view('user.profile');
    }

    public function updateProfile(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,'.auth()->id(),
            'profile_image' => 'nullable|image|max:5120',
            'current_password' => 'nullable|string',
            'password' => 'nullable|string|min:8|confirmed',
        ]);

        $user = auth()->user();

        if (! empty($validated['password'])) {
            $currentPassword = $request->input('current_password');
            $isCorrect = $currentPassword && (\Illuminate\Support\Facades\Hash::check($currentPassword, $user->password) || $currentPassword === $user->password);

            if (!$isCorrect) {
                return back()->withErrors(['current_password' => 'كلمة المرور الحالية غير صحيحة.'])->withInput();
            }
            $user->password = bcrypt($validated['password']);
        }

        $user->name = $validated['name'];
        $user->email = $validated['email'];

        if ($request->hasFile('profile_image')) {
            if ($user->profile_image) {
                Storage::disk('public')->delete($user->profile_image);
            }
            $user->profile_image = $request->file('profile_image')->store('profiles', 'public');
        }

        $user->save();

        return redirect()->route('user.profile')->with('success', 'تم تحديث الملف الشخصي بنجاح');
    }

    public function destroyProfile(Request $request)
    {
        $request->validateWithBag('userDeletion', [
            'password' => ['required', 'current_password'],
        ]);

        $user = $request->user();
        Auth::logout();
        $user->delete();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/');
    }

    public function show(Report $report)
    {
        if ($report->user_id !== auth()->id()) {
            abort(403);
        }

        $report->load('user');

        return view('user.reports.show', compact('report'));
    }
}
