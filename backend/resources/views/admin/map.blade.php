@extends('admin.layouts.app')

@section('title', 'خريطة الأضرار - نظام تقييم الأضرار الذكي')

@push('styles')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
@endpush

@section('content')
<!-- Header -->
<div class="mb-8 fade-in">
    <div class="glass-card rounded-3xl p-8 shadow-xl">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-5">
                <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-green-500 to-emerald-600 flex items-center justify-center shadow-lg">
                    <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path>
                    </svg>
                </div>
                <div>
                    <h2 class="text-3xl font-bold text-slate-800">خريطة الأضرار</h2>
                    <p class="text-slate-500 mt-1">عرض جميع التقارير على الخريطة التفاعلية</p>
                </div>
            </div>
            <div class="flex items-center gap-4">
                <div class="flex items-center gap-2">
                    <span class="w-3 h-3 rounded-full bg-green-500"></span>
                    <span class="text-sm text-slate-600">منخفض</span>
                </div>
                <div class="flex items-center gap-2">
                    <span class="w-3 h-3 rounded-full bg-yellow-500"></span>
                    <span class="text-sm text-slate-600">متوسط</span>
                </div>
                <div class="flex items-center gap-2">
                    <span class="w-3 h-3 rounded-full bg-orange-500"></span>
                    <span class="text-sm text-slate-600">عالي</span>
                </div>
                <div class="flex items-center gap-2">
                    <span class="w-3 h-3 rounded-full bg-red-600"></span>
                    <span class="text-sm text-slate-600">حرج</span>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Map Container -->
<div class="glass-card rounded-2xl shadow-xl overflow-hidden fade-in">
    <div id="map" style="height: 600px; width: 100%;"></div>
</div>
@endsection

@push('scripts')
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script>
    const map = L.map('map').setView([35.0, 38.0], 6);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    const reports = @json($reports);

    const colorMap = {
        'low': '#22c55e',
        'medium': '#eab308',
        'high': '#f97316',
        'critical': '#dc2626'
    };

    const damageLevelLabels = {
        'low': 'منخفض',
        'medium': 'متوسط',
        'high': 'عالي',
        'critical': 'حرج'
    };

    reports.forEach(report => {
        const color = colorMap[report.ai_damage_level] || '#3b82f6';

        const marker = L.marker([report.latitude, report.longitude], {
            icon: L.divIcon({
                className: 'custom-marker',
                html: '<div style="background-color: ' + color + '; width: 24px; height: 24px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 10px rgba(0,0,0,0.3);"></div>',
                iconSize: [24, 24],
                iconAnchor: [12, 12]
            })
        }).addTo(map);

        let popupContent = '<div style="max-width: 320px; font-family: Cairo, sans-serif;">';
        popupContent += '<div style="background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); padding: 12px; border-radius: 8px 8px 0 0; margin: -12px -12px 12px -12px;">';
        popupContent += '<h3 style="color: white; margin: 0; font-size: 18px; font-weight: bold;">تقرير #' + report.id + '</h3>';
        popupContent += '</div>';
        popupContent += '<p style="margin: 8px 0; color: #475569;"><strong>الموقع:</strong> ' + report.raw_location + '</p>';
        popupContent += '<p style="margin: 8px 0; color: #475569;"><strong>مستوى الضرر:</strong> <span style="background: ' + color + '; color: white; padding: 4px 12px; border-radius: 20px; font-size: 12px;">' + (damageLevelLabels[report.ai_damage_level] || report.ai_damage_level) + '</span></p>';

        if (report.images && report.images.length > 0) {
            popupContent += '<div style="margin-top: 12px;"><strong style="color: #475569;">الصور:</strong></div>';
            popupContent += '<div style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px;">';
            report.images.forEach(function(img) {
                const imageUrl = '{{ asset("storage") }}/' + img;
                popupContent += '<a href="' + imageUrl + '" target="_blank"><img src="' + imageUrl + '" alt="صورة" style="width: 70px; height: 50px; object-fit: cover; border-radius: 6px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"></a>';
            });
            popupContent += '</div>';
        } else if (report.image_path) {
            const imageUrl = '{{ asset("storage") }}/' + report.image_path;
            popupContent += '<div style="margin-top: 12px;"><strong style="color: #475569;">الصورة:</strong></div>';
            popupContent += '<a href="' + imageUrl + '" target="_blank"><img src="' + imageUrl + '" alt="صورة التقرير" style="max-width: 200px; max-height: 150px; margin-top: 8px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);"></a>';
        }

        if (report.pdf_file) {
            const pdfUrl = '{{ asset("storage") }}/' + report.pdf_file;
            popupContent += '<a href="' + pdfUrl + '" target="_blank" style="display: inline-block; background: #dc2626; color: white; padding: 8px 16px; border-radius: 8px; text-decoration: none; font-size: 14px; margin-top: 12px;"><span style="margin-left: 6px;">📄</span> تحميل PDF</a>';
        }

        if (report.video_links && report.video_links.length > 0) {
            popupContent += '<div style="margin-top: 12px;"><strong style="color: #475569;">روابط الفيديو:</strong></div>';
            popupContent += '<div style="margin-top: 8px;">';
            report.video_links.forEach(function(link) {
                popupContent += '<a href="' + link + '" target="_blank" style="display: block; color: #6366f1; font-size: 12px; margin-bottom: 4px;">' + link + '</a>';
            });
            popupContent += '</div>';
        }

        popupContent += '<a href="/admin/reports/' + report.id + '" style="display: block; background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); color: white; padding: 10px; border-radius: 8px; text-decoration: none; text-align: center; font-weight: bold; margin-top: 16px;">📋 عرض التفاصيل</a>';
        popupContent += '</div>';

        marker.bindPopup(popupContent);
    });
</script>
@endpush