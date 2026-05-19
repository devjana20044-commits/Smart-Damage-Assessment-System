@extends('admin.layouts.app')

@section('title', 'تفاصيل التقرير #' . $report->id . ' - نظام تقييم الأضرار الذكي')

@push('styles')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<style>
    .image-gallery {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 1rem;
    }
    .image-item {
        position: relative;
        overflow: hidden;
        border-radius: 16px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        transition: transform 0.3s ease;
    }
    .image-item:hover {
        transform: scale(1.05);
    }
    .image-item img {
        width: 100%;
        height: 150px;
        object-fit: cover;
        cursor: pointer;
    }
    .lightbox {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.9);
        z-index: 9999;
        justify-content: center;
        align-items: center;
    }
    .lightbox.active {
        display: flex;
    }
    .lightbox img {
        max-width: 90%;
        max-height: 90%;
        object-fit: contain;
    }
</style>
@endpush

@section('content')
<!-- Header -->
<div class="mb-8 fade-in">
    <div class="glass-card rounded-3xl p-8 shadow-xl">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-5">
                <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-lg">
                    <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                </div>
                <div>
                    <h2 class="text-3xl font-bold text-slate-800">تفاصيل التقرير #{{ $report->id }}</h2>
                    <p class="text-slate-500 mt-1">تم الإنشاء: {{ $report->created_at->format('Y-m-d H:i') }}</p>
                </div>
            </div>
            <div class="flex items-center gap-3">
                <a href="{{ route('admin.reports') }}" class="px-5 py-3 bg-slate-200 text-slate-700 rounded-xl font-bold hover:bg-slate-300 transition-colors flex items-center gap-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path>
                    </svg>
                    العودة
                </a>
                <a href="{{ route('admin.reports.edit', $report) }}" class="btn-gradient px-5 py-3 text-white rounded-xl font-bold flex items-center gap-2">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                    </svg>
                    تعديل
                </a>
                <form action="{{ route('admin.reports.destroy', $report) }}" method="POST" onsubmit="return confirm('هل أنت متأكد من حذف هذا التقرير؟');">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="px-5 py-3 bg-red-500 text-white rounded-xl font-bold hover:bg-red-600 transition-colors flex items-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                        </svg>
                        حذف
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

@if(session('success'))
<div class="mb-6 fade-in">
    <div class="bg-gradient-to-r from-green-50 to-emerald-50 border-2 border-green-200 rounded-2xl p-5 shadow-lg">
        <div class="flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-green-500 flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
            </div>
            <p class="text-green-800 font-bold text-lg">{{ session('success') }}</p>
        </div>
    </div>
</div>
@endif

<!-- Info Cards -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8 fade-in">
    <!-- Basic Information -->
    <div class="glass-card rounded-2xl shadow-xl overflow-hidden">
        <div class="bg-gradient-to-r from-indigo-500 to-purple-600 px-6 py-4">
            <h3 class="text-lg font-bold text-white flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                معلومات أساسية
            </h3>
        </div>
        <div class="p-6 space-y-4">
            <div class="flex justify-between items-center py-3 border-b border-slate-100">
                <span class="text-slate-500">معرف التقرير</span>
                <span class="font-bold text-indigo-600">#{{ $report->id }}</span>
            </div>
            <div class="flex justify-between items-center py-3 border-b border-slate-100">
                <span class="text-slate-500">المستخدم</span>
                <span class="font-bold text-slate-700">{{ $report->user->name }}</span>
            </div>
            <div class="flex justify-between items-center py-3 border-b border-slate-100">
                <span class="text-slate-500">تاريخ الإنشاء</span>
                <span class="font-medium text-slate-700">{{ $report->created_at->format('Y-m-d H:i:s') }}</span>
            </div>
            <div class="flex justify-between items-center py-3 border-b border-slate-100">
                <span class="text-slate-500">آخر تحديث</span>
                <span class="font-medium text-slate-700">{{ $report->updated_at->format('Y-m-d H:i:s') }}</span>
            </div>
            <div class="flex justify-between items-center py-3">
                <span class="text-slate-500">الحالة</span>
                @php
                    $statusColors = [
                        'completed' => 'bg-green-100 text-green-700 border-green-200',
                        'pending' => 'bg-yellow-100 text-yellow-700 border-yellow-200',
                        'processing' => 'bg-blue-100 text-blue-700 border-blue-200',
                        'rejected' => 'bg-red-100 text-red-700 border-red-200'
                    ];
                    $statusLabels = [
                        'completed' => 'مكتمل',
                        'pending' => 'قيد الانتظار',
                        'processing' => 'قيد المعالجة',
                        'rejected' => 'مرفوض'
                    ];
                    $statusColor = $statusColors[$report->status] ?? 'bg-gray-100 text-gray-700 border-gray-200';
                    $statusLabel = $statusLabels[$report->status] ?? 'غير محدد';
                @endphp
                <span class="px-4 py-2 rounded-full text-sm font-bold border {{ $statusColor }}">
                    {{ $statusLabel }}
                </span>
            </div>
        </div>
    </div>

    <!-- Location Information -->
    <div class="glass-card rounded-2xl shadow-xl overflow-hidden">
        <div class="bg-gradient-to-r from-green-500 to-emerald-600 px-6 py-4">
            <h3 class="text-lg font-bold text-white flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                معلومات الموقع
            </h3>
        </div>
        <div class="p-6 space-y-4">
            <div class="py-3 border-b border-slate-100">
                <span class="text-slate-500 block mb-1">الموقع الأصلي</span>
                <span class="font-bold text-lg text-slate-700">{{ $report->raw_location }}</span>
            </div>
            @if($report->ai_location)
            <div class="py-3 border-b border-slate-100">
                <span class="text-slate-500 block mb-1">الموقع المُحسّن (AI)</span>
                <span class="font-bold text-lg text-indigo-600">{{ $report->ai_location }}</span>
            </div>
            @endif
            <div class="flex justify-between items-center py-3 border-b border-slate-100">
                <span class="text-slate-500">خط العرض</span>
                <span class="font-medium text-slate-700">{{ number_format($report->latitude, 6) }}°</span>
            </div>
            <div class="flex justify-between items-center py-3">
                <span class="text-slate-500">خط الطول</span>
                <span class="font-medium text-slate-700">{{ number_format($report->longitude, 6) }}°</span>
            </div>
            <div id="mini-map" class="h-48 rounded-xl mt-4 shadow-md"></div>
        </div>
    </div>

    <!-- Damage Level -->
    <div class="glass-card rounded-2xl shadow-xl overflow-hidden">
        <div class="bg-gradient-to-r from-red-500 to-rose-600 px-6 py-4">
            <h3 class="text-lg font-bold text-white flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                </svg>
                مستوى الضرر
            </h3>
        </div>
        <div class="p-8 text-center">
            @php
                $damageColors = [
                    'low' => 'bg-green-500',
                    'medium' => 'bg-yellow-500',
                    'high' => 'bg-orange-500',
                    'critical' => 'bg-red-600'
                ];
                $damageLabels = [
                    'low' => 'منخفض',
                    'medium' => 'متوسط',
                    'high' => 'عالي',
                    'critical' => 'حرج'
                ];
                $colorClass = $damageColors[$report->ai_damage_level] ?? 'bg-gray-500';
                $label = $damageLabels[$report->ai_damage_level] ?? 'غير محدد';
            @endphp
            <div class="inline-block {{ $colorClass }} text-white px-10 py-5 rounded-2xl text-2xl font-bold shadow-lg">
                {{ $label }}
            </div>
            <p class="text-slate-500 mt-4">مستوى الضرر المُحدد بواسطة الذكاء الاصطناعي</p>
        </div>
    </div>

    <!-- Description -->
    <div class="glass-card rounded-2xl shadow-xl overflow-hidden">
        <div class="bg-gradient-to-r from-blue-500 to-cyan-500 px-6 py-4">
            <h3 class="text-lg font-bold text-white flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
                الوصف والتحليل
            </h3>
        </div>
        <div class="p-6 space-y-4">
            @if($report->raw_description)
            <div>
                <h4 class="font-bold text-slate-700 mb-2">الوصف الأصلي:</h4>
                <p class="text-slate-600 bg-slate-50 p-4 rounded-xl">{{ $report->raw_description }}</p>
            </div>
            @endif
            @if($report->ai_analysis)
            <div>
                <h4 class="font-bold text-slate-700 mb-2">تحليل الذكاء الاصطناعي:</h4>
                <p class="text-slate-600 bg-indigo-50 p-4 rounded-xl border-2 border-indigo-100">{{ $report->ai_analysis }}</p>
            </div>
            @endif
        </div>
    </div>
</div>

<!-- Images Gallery -->
@php
    $images = $report->images ?? [];
    $hasImages = count($images) > 0;
    $hasOldImage = !empty($report->image_path);
@endphp
@if($hasImages || $hasOldImage)
<div class="glass-card rounded-2xl shadow-xl overflow-hidden mb-8 fade-in">
    <div class="bg-gradient-to-r from-purple-500 to-pink-500 px-6 py-4">
        <h3 class="text-lg font-bold text-white flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
            </svg>
            صور التقرير
            @if($hasImages)
                <span class="text-sm font-normal opacity-80">({{ count($images) }} صورة)</span>
            @endif
        </h3>
    </div>
    <div class="p-6">
        <div class="image-gallery">
            @if($hasImages)
                @foreach($images as $image)
                <div class="image-item">
                    <img src="{{ asset('storage/' . $image) }}" alt="صورة" onclick="openLightbox('{{ asset('storage/' . $image) }}')">
                </div>
                @endforeach
            @endif
            @if($hasOldImage && !in_array($report->image_path, $images))
                <div class="image-item">
                    <img src="{{ asset('storage/' . $report->image_path) }}" alt="صورة" onclick="openLightbox('{{ asset('storage/' . $report->image_path) }}')">
                </div>
            @endif
        </div>
    </div>
</div>
@endif

<!-- PDF File -->
@if($report->pdf_file)
<div class="glass-card rounded-2xl shadow-xl overflow-hidden mb-8 fade-in">
    <div class="bg-gradient-to-r from-red-500 to-rose-600 px-6 py-4">
        <h3 class="text-lg font-bold text-white flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
            </svg>
            ملف PDF
        </h3>
    </div>
    <div class="p-6">
        <div class="flex items-center gap-4">
            <div class="w-16 h-16 rounded-xl bg-red-100 flex items-center justify-center">
                <svg class="w-8 h-8 text-red-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clip-rule="evenodd"></path>
                </svg>
            </div>
            <div class="flex-1">
                <p class="text-slate-700 font-bold">ملف التقرير بصيغة PDF</p>
                <div class="flex gap-3 mt-2">
                    <a href="{{ asset('storage/' . $report->pdf_file) }}" target="_blank" class="px-4 py-2 bg-red-500 text-white rounded-lg font-bold hover:bg-red-600 transition-colors">
                        عرض PDF
                    </a>
                    <a href="{{ asset('storage/' . $report->pdf_file) }}" download class="px-4 py-2 bg-slate-200 text-slate-700 rounded-lg font-bold hover:bg-slate-300 transition-colors">
                        تحميل
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>
@endif

<!-- Video Links -->
@if($report->video_links && count($report->video_links) > 0)
<div class="glass-card rounded-2xl shadow-xl overflow-hidden mb-8 fade-in">
    <div class="bg-gradient-to-r from-violet-500 to-purple-600 px-6 py-4">
        <h3 class="text-lg font-bold text-white flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
            </svg>
            روابط الفيديو
            <span class="text-sm font-normal opacity-80">({{ count($report->video_links) }} فيديو)</span>
        </h3>
    </div>
    <div class="p-6 space-y-3">
        @foreach($report->video_links as $index => $link)
        <div class="flex items-center justify-between bg-slate-50 p-4 rounded-xl hover:bg-slate-100 transition-colors">
            <div class="flex items-center gap-4">
                <div class="w-10 h-10 rounded-lg bg-purple-500 flex items-center justify-center">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                </div>
                <div>
                    <span class="text-slate-500 text-sm">فيديو #{{ $index + 1 }}</span>
                    <p class="text-slate-700 font-medium text-sm break-all">{{ $link }}</p>
                </div>
            </div>
            <a href="{{ $link }}" target="_blank" class="px-4 py-2 bg-purple-500 text-white rounded-lg font-bold hover:bg-purple-600 transition-colors">
                مشاهدة
            </a>
        </div>
        @endforeach
    </div>
</div>
@endif

<!-- Lightbox Modal -->
<div id="lightbox" class="lightbox" onclick="closeLightbox()">
    <button class="absolute top-5 left-5 bg-white text-slate-800 px-4 py-2 rounded-lg font-bold hover:bg-slate-100 transition-colors" onclick="closeLightbox()">
        إغلاق
    </button>
    <img id="lightbox-img" src="" alt="صورة مكبرة">
</div>
@endsection

@push('scripts')
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
    @if($report->latitude && $report->longitude)
    const miniMap = L.map('mini-map').setView([{{ $report->latitude }}, {{ $report->longitude }}], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(miniMap);
    L.marker([{{ $report->latitude }}, {{ $report->longitude }}]).addTo(miniMap);
    @endif

    function openLightbox(imageSrc) {
        document.getElementById('lightbox-img').src = imageSrc;
        document.getElementById('lightbox').classList.add('active');
    }

    function closeLightbox() {
        document.getElementById('lightbox').classList.remove('active');
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeLightbox();
        }
    });
</script>
@endpush