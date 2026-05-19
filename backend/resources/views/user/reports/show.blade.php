<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تفاصيل البلاغ - نظام تقييم الأضرار</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        * { font-family: 'Cairo', sans-serif; }
        .hero-gradient { background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 50%, #1e1b4b 100%); }
        .glass-card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        #map { height: 300px; border-radius: 12px; }
    </style>
</head>
<body class="hero-gradient min-h-screen">
    <nav class="bg-slate-900/80 backdrop-blur-md border-b border-slate-700/50 fixed w-full z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-lg flex items-center justify-center">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                    </div>
                    <h1 class="text-xl font-bold text-white">نظام تقييم الأضرار</h1>
                </div>
                <div class="flex items-center gap-3">
                    <a href="{{ route('user.dashboard') }}" class="text-gray-300 hover:text-white px-4 py-2 rounded-lg text-sm font-medium border border-slate-600 hover:border-indigo-500 transition-all">
                        لوحة التحكم
                    </a>
                    <a href="{{ route('user.reports') }}" class="text-gray-300 hover:text-white px-4 py-2 rounded-lg text-sm font-medium border border-slate-600 hover:border-indigo-500 transition-all">
                        بلاغاتي
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <div class="pt-24 pb-12 px-4 min-h-screen">
        <div class="max-w-4xl mx-auto">
            @if(session('success'))
            <div class="mb-6 p-4 bg-green-500/20 border border-green-500/30 rounded-xl text-green-400">
                {{ session('success') }}
            </div>
            @endif

            <div class="glass-card rounded-2xl p-8 shadow-2xl">
                <div class="flex items-center justify-between mb-6">
                    <h2 class="text-2xl font-bold text-white">تفاصيل البلاغ #{{ $report->id }}</h2>
                    @php
                    $statusColors = [
                        'pending' => 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30',
                        'processing' => 'bg-blue-500/20 text-blue-400 border-blue-500/30',
                        'completed' => 'bg-green-500/20 text-green-400 border-green-500/30',
                        'rejected' => 'bg-red-500/20 text-red-400 border-red-500/30',
                    ];
                    $statusLabels = [
                        'pending' => 'قيد الانتظار',
                        'processing' => 'قيد المعالجة',
                        'completed' => 'مكتمل',
                        'rejected' => 'مرفوض',
                    ];
                    @endphp
                    <span class="px-4 py-2 rounded-lg text-sm font-medium border {{ $statusColors[$report->status] ?? 'bg-gray-500/20 text-gray-400 border-gray-500/30' }}">
                        {{ $statusLabels[$report->status] ?? $report->status }}
                    </span>
                </div>

                <div class="grid md:grid-cols-2 gap-6 mb-8">
                    <div>
                        <label class="block text-sm font-medium text-slate-400 mb-2">الموقع الأصلي</label>
                        <p class="text-white bg-slate-800/50 rounded-lg p-3">{{ $report->raw_location }}</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-400 mb-2">الموقع المحلل (AI)</label>
                        <p class="text-white bg-slate-800/50 rounded-lg p-3">{{ $report->ai_location ?? 'لم يتم التحليل بعد' }}</p>
                    </div>
                </div>

                <div class="mb-8">
                    <label class="block text-sm font-medium text-slate-400 mb-2">الوصف</label>
                    <p class="text-white bg-slate-800/50 rounded-lg p-3">{{ $report->raw_description ?? 'لا يوجد وصف' }}</p>
                </div>

                @if($report->ai_analysis)
                <div class="mb-8">
                    <label class="block text-sm font-medium text-slate-400 mb-2">تحليل الذكاء الاصطناعي</label>
                    <p class="text-white bg-slate-800/50 rounded-lg p-3">{{ $report->ai_analysis }}</p>
                </div>
                @endif

                <div class="grid md:grid-cols-2 gap-6 mb-8">
                    <div>
                        <label class="block text-sm font-medium text-slate-400 mb-2">مستوى الضرر</label>
                        <p class="text-white bg-slate-800/50 rounded-lg p-3">{{ $report->ai_damage_level ?? 'غير محدد' }}</p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-400 mb-2">تاريخ الإنشاء</label>
                        <p class="text-white bg-slate-800/50 rounded-lg p-3">{{ $report->created_at->format('Y/m/d H:i') }}</p>
                    </div>
                </div>

                <div class="mb-8">
                    <label class="block text-sm font-medium text-slate-400 mb-2">الموقع على الخريطة</label>
                    <div id="map"></div>
                </div>

                @if($report->images && count($report->images) > 0)
                <div class="mb-8">
                    <label class="block text-sm font-medium text-slate-400 mb-2">الصور</label>
                    <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
                        @foreach($report->images as $image)
                        <img src="{{ asset('storage/' . $image) }}" alt="صورة البلاغ" class="rounded-lg w-full h-40 object-cover">
                        @endforeach
                    </div>
                </div>
                @endif

                @if($report->pdf_file)
                <div class="mb-8">
                    <label class="block text-sm font-medium text-slate-400 mb-2">ملف PDF</label>
                    <a href="{{ asset('storage/' . $report->pdf_file) }}" target="_blank" class="inline-flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg transition-all">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        تحميل PDF
                    </a>
                </div>
                @endif

                @if($report->video_links && count($report->video_links) > 0)
                <div class="mb-8">
                    <label class="block text-sm font-medium text-slate-400 mb-2">روابط الفيديو</label>
                    <div class="space-y-2">
                        @foreach($report->video_links as $link)
                        <a href="{{ $link }}" target="_blank" class="block text-indigo-400 hover:text-indigo-300">{{ $link }}</a>
                        @endforeach
                    </div>
                </div>
                @endif
            </div>
        </div>
    </div>

    <script>
        @if($report->latitude && $report->longitude)
        var map = L.map('map').setView([{{ $report->latitude }}, {{ $report->longitude }}], 13);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap'
        }).addTo(map);
        L.marker([{{ $report->latitude }}, {{ $report->longitude }}]).addTo(map);
        @else
        document.getElementById('map').innerHTML = '<p class="text-slate-400 text-center py-12">الموقع غير محدد</p>';
        @endif
    </script>
</body>
</html>
