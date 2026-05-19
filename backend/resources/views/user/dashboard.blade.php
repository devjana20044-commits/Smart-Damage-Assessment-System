<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>لوحة التحكم - نظام تقييم الأضرار</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <style>
        * { font-family: 'Cairo', sans-serif; }

        .glass-card {
            background: rgba(250, 250, 250, 0.75);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(45, 62, 78, 0.06);
            transition: all 0.3s ease;
        }

        .glass-card:hover {
            box-shadow: 0 16px 40px -12px rgba(45, 62, 78, 0.12);
        }

        .stat-card {
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px -12px rgba(45, 62, 78, 0.18);
        }

        .section-header {
            background: linear-gradient(135deg, #2D3A50 0%, #3D4A60 100%);
        }

        .fade-in {
            animation: fadeIn 0.5s ease forwards;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .pulse-dot {
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .nav-link {
            transition: all 0.2s ease;
        }

        .nav-link:hover {
            background: rgba(201, 169, 124, 0.12);
        }

        .btn-primary {
            background: linear-gradient(135deg, #C9A97C 0%, #78A9C1 100%);
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            box-shadow: 0 8px 24px rgba(201, 169, 124, 0.35);
            transform: translateY(-1px);
        }

        .badge-critical {
            background: rgba(156, 93, 77, 0.12);
            color: #9C5D4D;
            border: 1px solid rgba(156, 93, 77, 0.2);
        }

        .badge-high {
            background: rgba(214, 181, 112, 0.15);
            color: #B8942E;
            border: 1px solid rgba(214, 181, 112, 0.25);
        }

        .badge-medium {
            background: rgba(201, 169, 124, 0.12);
            color: #C9A97C;
            border: 1px solid rgba(201, 169, 124, 0.2);
        }

        .badge-low {
            background: rgba(145, 166, 138, 0.15);
            color: #7A9473;
            border: 1px solid rgba(145, 166, 138, 0.25);
        }

        .badge-pending {
            background: rgba(214, 181, 112, 0.12);
            color: #B8942E;
            border: 1px solid rgba(214, 181, 112, 0.2);
        }

        .badge-processing {
            background: rgba(120, 169, 193, 0.12);
            color: #5A8DA8;
            border: 1px solid rgba(120, 169, 193, 0.2);
        }

        .badge-completed {
            background: rgba(145, 166, 138, 0.15);
            color: #7A9473;
            border: 1px solid rgba(145, 166, 138, 0.25);
        }

        .badge-rejected {
            background: rgba(156, 93, 77, 0.12);
            color: #9C5D4D;
            border: 1px solid rgba(156, 93, 77, 0.2);
        }

        .badge-unknown {
            background: rgba(45, 62, 78, 0.08);
            color: #2D3A50;
            border: 1px solid rgba(45, 62, 78, 0.12);
        }

        ::-webkit-scrollbar {
            width: 8px;
        }

        ::-webkit-scrollbar-track {
            background: #E8E6E1;
        }

        ::-webkit-scrollbar-thumb {
            background: #C9A97C;
            border-radius: 4px;
        }

        ::-webkit-scrollbar-thumb:hover {
            background: #78A9C1;
        }
    </style>
</head>
<body class="min-h-screen" style="background-color: #E8E6E1;">
    <nav class="fixed w-full z-50 shadow-sm" style="background: rgba(250, 250, 250, 0.85); backdrop-filter: blur(12px); border-bottom: 1px solid rgba(45, 62, 78, 0.08);">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-xl flex items-center justify-center shadow-md" style="background: linear-gradient(135deg, #C9A97C, #78A9C1); box-shadow: 0 4px 12px rgba(201, 169, 124, 0.3);">
                        <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                    </div>
                    <div>
                        <h1 class="text-lg font-bold leading-tight" style="color: #2D3A50;">نظام تقييم الأضرار</h1>
                        <span class="text-[10px] font-medium tracking-wider" style="color: #78A9C1;">SMART DAMAGE ASSESSMENT</span>
                    </div>
                </div>
                <div class="flex items-center gap-2">
                    <span class="text-sm hidden sm:inline" style="color: rgba(45, 62, 78, 0.6);">مرحباً، <strong style="color: #2D3A50;">{{ auth()->user()->name }}</strong></span>
                    <a href="{{ route('user.profile') }}" class="nav-link px-3 py-2 rounded-lg text-sm font-medium" style="color: rgba(45, 62, 78, 0.7);">
                        الملف الشخصي
                    </a>
                    <a href="{{ route('user.reports') }}" class="nav-link px-3 py-2 rounded-lg text-sm font-medium" style="color: rgba(45, 62, 78, 0.7);">
                        بلاغاتي
                    </a>
                    <a href="{{ route('user.reports.create') }}" class="btn-primary text-white px-4 py-2 rounded-xl text-sm font-medium">
                        + إضافة بلاغ
                    </a>
                    <form action="{{ route('logout') }}" method="POST" class="inline">
                        @csrf
                        <button type="submit" class="w-9 h-9 rounded-lg flex items-center justify-center transition-colors" style="background: rgba(45, 62, 78, 0.08); color: rgba(45, 62, 78, 0.5);" title="تسجيل الخروج">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                            </svg>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </nav>

    <div class="pt-24 pb-12 px-4 min-h-screen">
        <div class="max-w-7xl mx-auto">
            <div class="mb-5 fade-in">
                <div class="glass-card rounded-2xl p-4 shadow-lg">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl flex items-center justify-center shadow-md" style="background: linear-gradient(135deg, #C9A97C, #78A9C1);">
                                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                                </svg>
                            </div>
                            <div>
                                <h2 class="text-lg font-bold" style="color: #2D3A50;">لوحة التحكم</h2>
                                <p class="text-xs" style="color: rgba(45, 62, 78, 0.5);">نظرة عامة على بلاغاتك</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-1.5">
                            <span class="pulse-dot w-2 h-2 rounded-full" style="background: #78A9C1;"></span>
                            <span class="text-xs" style="color: rgba(45, 62, 78, 0.5);">متصل</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 lg:gap-6 mb-8 fade-in">
                <div class="stat-card glass-card rounded-2xl p-4 lg:p-5 shadow-lg">
                    <div class="flex items-center gap-3 lg:gap-4">
                        <div class="w-11 h-11 lg:w-12 lg:h-12 shrink-0 rounded-xl flex items-center justify-center shadow-lg" style="background: linear-gradient(135deg, #C9A97C, rgba(201, 169, 124, 0.8)); box-shadow: 0 8px 16px rgba(201, 169, 124, 0.2);">
                            <svg class="w-5 h-5 lg:w-6 lg:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                        </div>
                        <div class="min-w-0">
                            <p class="text-xs lg:text-sm truncate" style="color: rgba(45, 62, 78, 0.6);">إجمالي البلاغات</p>
                            <p class="text-xl lg:text-2xl font-bold mt-0.5" style="color: #C9A97C;">{{ $totalReports }}</p>
                        </div>
                    </div>
                </div>

                <div class="stat-card glass-card rounded-2xl p-4 lg:p-5 shadow-lg">
                    <div class="flex items-center gap-3 lg:gap-4">
                        <div class="w-11 h-11 lg:w-12 lg:h-12 shrink-0 rounded-xl flex items-center justify-center shadow-lg" style="background: linear-gradient(135deg, #2D3A50, rgba(45, 62, 78, 0.8)); box-shadow: 0 8px 16px rgba(45, 62, 78, 0.2);">
                            <svg class="w-5 h-5 lg:w-6 lg:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <div class="min-w-0">
                            <p class="text-xs lg:text-sm truncate" style="color: rgba(45, 62, 78, 0.6);">قيد الانتظار</p>
                            <p class="text-xl lg:text-2xl font-bold mt-0.5" style="color: #2D3A50;">{{ $pendingReports }}</p>
                        </div>
                    </div>
                </div>

                <div class="stat-card glass-card rounded-2xl p-4 lg:p-5 shadow-lg">
                    <div class="flex items-center gap-3 lg:gap-4">
                        <div class="w-11 h-11 lg:w-12 lg:h-12 shrink-0 rounded-xl flex items-center justify-center shadow-lg" style="background: linear-gradient(135deg, #78A9C1, rgba(120, 169, 193, 0.8)); box-shadow: 0 8px 16px rgba(120, 169, 193, 0.2);">
                            <svg class="w-5 h-5 lg:w-6 lg:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                        <div class="min-w-0">
                            <p class="text-xs lg:text-sm truncate" style="color: rgba(45, 62, 78, 0.6);">مكتملة</p>
                            <p class="text-xl lg:text-2xl font-bold mt-0.5" style="color: #78A9C1;">{{ $completedReports }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="glass-card rounded-2xl shadow-xl overflow-hidden fade-in">
                <div class="section-header px-6 py-4 flex items-center justify-between">
                    <h3 class="text-lg font-bold flex items-center gap-2" style="color: #FAFAFA;">
                        <svg class="w-5 h-5" style="color: #C9A97C;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        آخر البلاغات
                    </h3>
                    <a href="{{ route('user.reports') }}" class="text-sm transition-colors" style="color: #C9A97C;" onmouseover="this.style.color='#FAFAFA'" onmouseout="this.style.color='#C9A97C'">عرض الكل</a>
                </div>

                @if($recentReports->count() > 0)
                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead style="background: rgba(232, 230, 225, 0.5);">
                            <tr>
                                <th class="px-6 py-4 text-right text-sm font-bold" style="color: rgba(45, 62, 78, 0.7);">الموقع</th>
                                <th class="px-6 py-4 text-right text-sm font-bold" style="color: rgba(45, 62, 78, 0.7);">الحالة</th>
                                <th class="px-6 py-4 text-right text-sm font-bold" style="color: rgba(45, 62, 78, 0.7);">مستوى الضرر</th>
                                <th class="px-6 py-4 text-right text-sm font-bold" style="color: rgba(45, 62, 78, 0.7);">التاريخ</th>
                                <th class="px-6 py-4 text-right text-sm font-bold" style="color: rgba(45, 62, 78, 0.7);">إجراءات</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($recentReports as $report)
                            @php
                            $statusBadge = [
                                'completed' => 'badge-completed',
                                'pending' => 'badge-pending',
                                'processing' => 'badge-processing',
                                'rejected' => 'badge-rejected',
                            ];
                            $statusLabels = [
                                'pending' => 'قيد الانتظار',
                                'processing' => 'قيد المعالجة',
                                'completed' => 'مكتمل',
                                'rejected' => 'مرفوض',
                            ];
                            $damageBadge = [
                                'critical' => 'badge-critical',
                                'high' => 'badge-high',
                                'medium' => 'badge-medium',
                                'low' => 'badge-low',
                            ];
                            $damageLabels = [
                                'critical' => 'حرج',
                                'high' => 'عالي',
                                'medium' => 'متوسط',
                                'low' => 'منخفض',
                            ];
                            @endphp
                            <tr class="transition-colors" style="border-bottom: 1px solid rgba(45, 62, 78, 0.05);" onmouseover="this.style.background='rgba(232, 230, 225, 0.3)'" onmouseout="this.style.background='transparent'">
                                <td class="px-6 py-4 font-medium" style="color: rgba(45, 62, 78, 0.8);">{{ Str::limit($report->raw_location, 30) }}</td>
                                <td class="px-6 py-4">
                                    <span class="px-3 py-1 rounded-full text-xs font-bold {{ $statusBadge[$report->status] ?? 'badge-unknown' }}">
                                        {{ $statusLabels[$report->status] ?? $report->status }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="px-3 py-1 rounded-full text-xs font-bold {{ $damageBadge[$report->ai_damage_level] ?? 'badge-unknown' }}">
                                        {{ $damageLabels[$report->ai_damage_level] ?? 'غير محدد' }}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-sm" style="color: rgba(45, 62, 78, 0.5);">{{ $report->created_at->format('Y-m-d H:i') }}</td>
                                <td class="px-6 py-4">
                                    <a href="{{ route('user.reports.show', $report) }}" class="inline-flex items-center gap-1 text-sm font-medium transition-colors" style="color: #C9A97C;" onmouseover="this.style.color='#78A9C1'" onmouseout="this.style.color='#C9A97C'">
                                        عرض
                                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                                        </svg>
                                    </a>
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
                @else
                <div class="text-center py-12">
                    <div class="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-4" style="background: rgba(45, 62, 78, 0.08);">
                        <svg class="w-8 h-8" style="color: rgba(45, 62, 78, 0.25);" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                    </div>
                    <h3 class="text-lg font-bold mb-2" style="color: rgba(45, 62, 78, 0.6);">لا توجد بلاغات بعد</h3>
                    <p class="text-sm mb-6" style="color: rgba(45, 62, 78, 0.4);">ابدأ بإضافة بلاغ جديد وسيتم تحليله بالذكاء الاصطناعي</p>
                    <a href="{{ route('user.reports.create') }}" class="btn-primary inline-flex items-center gap-2 px-6 py-3 text-white rounded-xl text-sm font-medium">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                        </svg>
                        إضافة بلاغ جديد
                    </a>
                </div>
                @endif
            </div>
        </div>
    </div>
</body>
</html>
