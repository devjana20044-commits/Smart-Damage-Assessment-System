<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>إضافة بلاغ جديد - نظام تقييم الأضرار</title>
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
        .input-style {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .input-style:focus {
            background: rgba(255, 255, 255, 0.1);
            border-color: rgba(99, 102, 241, 0.5);
        }
        #map { height: 400px; border-radius: 12px; }
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
            <div class="glass-card rounded-2xl p-8 shadow-2xl">
                <div class="text-center mb-8">
                    <div class="w-16 h-16 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl flex items-center justify-center mx-auto mb-4">
                        <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                    </div>
                    <h2 class="text-2xl font-bold text-white">إضافة بلاغ جديد</h2>
                    <p class="text-slate-400 mt-2">أدخل تفاصيل البلاغ وسيتم تحليله بالذكاء الاصطناعي</p>
                </div>

                @if($errors->any())
                <div class="mb-6 p-4 bg-red-500/20 border border-red-500/30 rounded-xl text-red-400 text-sm">
                    @foreach($errors->all() as $error)
                    <p>{{ $error }}</p>
                    @endforeach
                </div>
                @endif

                <form method="POST" action="{{ route('user.reports.store') }}" enctype="multipart/form-data">
                    @csrf

                    <div class="space-y-6">
                        <div>
                            <label class="block text-sm font-medium text-slate-300 mb-2">الموقع *</label>
                            <input type="text" name="raw_location" value="{{ old('raw_location') }}" required
                                class="w-full px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all"
                                placeholder="مثال: دمشق - المزة">
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-slate-300 mb-2">الوصف</label>
                            <textarea name="raw_description" rows="4"
                                class="w-full px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all"
                                placeholder="اكتب وصفاً للأضرار...">{{ old('raw_description') }}</textarea>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-slate-300 mb-2">الموقع على الخريطة *</label>
                            <div id="map" class="mb-2"></div>
                            <p class="text-slate-500 text-sm">انقر على الخريطة لتحديد الموقع</p>
                            <input type="hidden" name="latitude" id="latitude" required>
                            <input type="hidden" name="longitude" id="longitude" required>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-slate-300 mb-2">الصور</label>
                            <input type="file" name="images[]" multiple accept="image/*"
                                class="w-full px-4 py-3 input-style rounded-xl text-white file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-indigo-600 file:text-white hover:file:bg-indigo-700 transition-all">
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-slate-300 mb-2">ملف PDF</label>
                            <input type="file" name="pdf_file" accept=".pdf"
                                class="w-full px-4 py-3 input-style rounded-xl text-white file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-indigo-600 file:text-white hover:file:bg-indigo-700 transition-all">
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-slate-300 mb-2">روابط الفيديو</label>
                            <div id="video-links">
                                <div class="flex gap-2 mb-2">
                                    <input type="url" name="video_links[]"
                                        class="flex-1 px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all"
                                        placeholder="https://youtube.com/watch?v=...">
                                </div>
                            </div>
                            <button type="button" onclick="addVideoLink()" class="text-indigo-400 hover:text-indigo-300 text-sm mt-2">
                                + إضافة رابط فيديو آخر
                            </button>
                        </div>

                        <button type="submit" class="w-full py-3 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-semibold rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg shadow-indigo-500/25">
                            إرسال البلاغ
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        var map = L.map('map').setView([33.5, 36.3], 7);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap'
        }).addTo(map);

        var marker;
        map.on('click', function(e) {
            if (marker) {
                map.removeLayer(marker);
            }
            marker = L.marker(e.latlng).addTo(map);
            document.getElementById('latitude').value = e.latlng.lat;
            document.getElementById('longitude').value = e.latlng.lng;
        });

        function addVideoLink() {
            var div = document.createElement('div');
            div.className = 'flex gap-2 mb-2';
            div.innerHTML = '<input type="url" name="video_links[]" class="flex-1 px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all" placeholder="https://youtube.com/watch?v=...">';
            document.getElementById('video-links').appendChild(div);
        }
    </script>
</body>
</html>
