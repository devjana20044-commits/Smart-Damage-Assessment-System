<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>بلاغاتي - نظام تقييم الأضرار</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <style>
        * { font-family: 'Cairo', sans-serif; }
        body {
            background-color: #F3F2EF;
            color: #0B0B45;
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(11, 11, 69, 0.08);
            transition: all 0.3s ease;
        }
        .glass-card:hover {
            box-shadow: 0 20px 40px -12px rgba(11, 11, 69, 0.12);
        }
        .stat-card { transition: all 0.3s ease; }
        .stat-card:hover { transform: translateY(-5px); }
        .report-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(11, 11, 69, 0.1);
            transition: all 0.3s ease;
        }
        .report-card:hover {
            transform: translateY(-4px);
            border-color: rgba(201, 169, 124, 0.5);
            box-shadow: 0 20px 40px rgba(11, 11, 69, 0.15);
        }
        .filter-btn {
            transition: all 0.2s ease;
            background: rgba(255, 255, 255, 0.6);
            border: 1px solid rgba(11, 11, 69, 0.15);
            color: #0B0B45;
        }
        .filter-btn:hover {
            border-color: #C9A97C;
            color: #C9A97C;
        }
        .filter-btn.active {
            background: linear-gradient(135deg, #0B0B45 0%, #1a1a3e 100%);
            color: #FAFAFA;
            border-color: transparent;
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .animate-in { animation: fadeInUp 0.4s ease forwards; }
        .page-btn { transition: all 0.2s ease; }
    </style>
</head>
<body class="min-h-screen">
    <nav style="background-color: #0B0B45 !important;" class="border-b border-[#0B0B45]/20 fixed w-full z-50 shadow-lg shadow-black/20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-gradient-to-br from-[#C9A97C] to-[#B08D5F] rounded-lg flex items-center justify-center shadow-md">
                        <svg class="w-6 h-6 text-[#FAFAFA]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                    </div>
                    <h1 class="text-xl font-bold text-[#FAFAFA]">نظام تقييم الأضرار</h1>
                </div>
                <div class="flex items-center gap-3">
                    <span class="text-[#FAFAFA]/80">مرحباً، {{ auth()->user()->name }}</span>
                    <a href="{{ route('user.dashboard') }}" class="text-[#FAFAFA]/80 hover:text-[#C9A97C] hover:bg-[#FAFAFA]/10 px-4 py-2 rounded-lg text-sm font-medium border border-[#FAFAFA]/20 hover:border-[#C9A97C] transition-all">
                        لوحة التحكم
                    </a>
                    <a href="{{ route('user.reports.create') }}" class="bg-gradient-to-r from-[#C9A97C] to-[#B08D5F] text-[#0B0B45] px-4 py-2 rounded-lg text-sm font-bold hover:from-[#D6B570] hover:to-[#C9A97C] transition-all shadow-md">
                        + إضافة بلاغ جديد
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <div class="pt-24 pb-12 px-4 min-h-screen">
        <div class="max-w-7xl mx-auto">
            <div class="mb-8">
                <h2 class="text-3xl font-bold text-[#0B0B45]">بلاغاتي</h2>
                <p class="text-[#0B0B45]/60 mt-2">جميع البلاغات التي قمت بإضافتها</p>
            </div>

            @if(session('success'))
            <div class="mb-6 p-4 bg-[#91A68A]/20 border border-[#91A68A]/30 rounded-xl text-[#0B0B45]">
                {{ session('success') }}
            </div>
            @endif

            <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                <div class="glass-card rounded-2xl p-6 stat-card">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-[#0B0B45]/60 text-sm">إجمالي البلاغات</p>
                            <p class="text-3xl font-bold text-[#0B0B45] mt-2">{{ $totalReports }}</p>
                        </div>
                        <div class="w-14 h-14 bg-gradient-to-br from-[#0B0B45] to-[#1e293b] rounded-xl flex items-center justify-center">
                            <svg class="w-7 h-7 text-[#FAFAFA]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass-card rounded-2xl p-6 stat-card">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-[#0B0B45]/60 text-sm">قيد الانتظار</p>
                            <p class="text-3xl font-bold text-[#D6B570] mt-2">{{ $pendingReports }}</p>
                        </div>
                        <div class="w-14 h-14 bg-gradient-to-br from-[#D6B570] to-[#C9A97C] rounded-xl flex items-center justify-center">
                            <svg class="w-7 h-7 text-[#FAFAFA]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass-card rounded-2xl p-6 stat-card">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-[#0B0B45]/60 text-sm">قيد المعالجة</p>
                            <p class="text-3xl font-bold text-[#78A9C1] mt-2">{{ $processingReports }}</p>
                        </div>
                        <div class="w-14 h-14 bg-gradient-to-br from-[#78A9C1] to-[#5A8FA8] rounded-xl flex items-center justify-center">
                            <svg class="w-7 h-7 text-[#FAFAFA]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div class="glass-card rounded-2xl p-6 stat-card">
                    <div class="flex items-center justify-between">
                        <div>
                            <p class="text-[#0B0B45]/60 text-sm">مكتملة</p>
                            <p class="text-3xl font-bold text-[#91A68A] mt-2">{{ $completedReports }}</p>
                        </div>
                        <div class="w-14 h-14 bg-gradient-to-br from-[#91A68A] to-[#7A8F70] rounded-xl flex items-center justify-center">
                            <svg class="w-7 h-7 text-[#FAFAFA]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                        </div>
                    </div>
                </div>
            </div>

            @if($reports->count() > 0)
            <div class="mb-6 flex items-center justify-between">
                <div class="flex items-center gap-2 flex-wrap">
                    <button onclick="filterReports('all')" class="filter-btn active px-4 py-2 rounded-lg text-sm font-medium" data-filter="all">
                        الكل
                    </button>
                    <button onclick="filterReports('pending')" class="filter-btn px-4 py-2 rounded-lg text-sm font-medium" data-filter="pending">
                        قيد الانتظار
                    </button>
                    <button onclick="filterReports('processing')" class="filter-btn px-4 py-2 rounded-lg text-sm font-medium" data-filter="processing">
                        قيد المعالجة
                    </button>
                    <button onclick="filterReports('completed')" class="filter-btn px-4 py-2 rounded-lg text-sm font-medium" data-filter="completed">
                        مكتمل
                    </button>
                </div>
            </div>

            <div id="reports-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                @foreach($reports as $report)
                @php
                $statusColors = [
                    'pending'    => 'bg-[#E8E6E1] text-[#0B0B45] border-[#D6CFC7]',
                    'processing' => 'bg-[#E8E6E1] text-[#0B0B45] border-[#D6CFC7]',
                    'completed'  => 'bg-[#E8E6E1] text-[#0B0B45] border-[#D6CFC7]',
                    'rejected'   => 'bg-[#D6CFC7] text-[#0B0B45] border-[#C9A97C]',
                ];
                $statusLabels = [
                    'pending' => 'قيد الانتظار',
                    'processing' => 'قيد المعالجة',
                    'completed' => 'مكتمل',
                    'rejected' => 'مرفوض',
                ];
                $damageColors = [
                    'critical' => 'bg-[#9C5D4D]/20 text-[#9C5D4D] border-[#9C5D4D]/40',
                    'high' => 'bg-[#9C5D4D]/15 text-[#9C5D4D] border-[#9C5D4D]/30',
                    'medium' => 'bg-[#D6B570]/20 text-[#8A7030] border-[#D6B570]/40',
                    'low' => 'bg-[#91A68A]/20 text-[#5A7050] border-[#91A68A]/40',
                ];
                $damageLabels = [
                    'critical' => 'ضرر كلي',
                    'high' => 'ضرر جزئي',
                    'medium' => 'ضرر جزئي',
                    'low' => 'سليم',
                ];
                $damageBarColors = [
                    'critical' => 'from-[#9C5D4D] to-[#7A4538]',
                    'high' => 'from-[#D6B570] to-[#C9A97C]',
                    'medium' => 'from-[#D6B570] to-[#B08D5F]',
                    'low' => 'from-[#91A68A] to-[#7A8F70]',
                ];
                $damageBarWidths = [
                    'critical' => '100%',
                    'high' => '75%',
                    'medium' => '50%',
                    'low' => '25%',
                ];
                $damageLevel = $report->ai_damage_level;
                $statusColorClass = $statusColors[$report->status] ?? 'bg-[#0B0B45]/10 text-[#0B0B45] border-[#0B0B45]/20';
                $statusLabelText = $statusLabels[$report->status] ?? $report->status;
                $damageColorClass = $damageColors[$damageLevel] ?? 'bg-[#0B0B45]/10 text-[#0B0B45] border-[#0B0B45]/20';
                $damageLabelText = $damageLabels[$damageLevel] ?? 'غير محدد';
                $damageBarColorClass = $damageBarColors[$damageLevel] ?? 'from-[#0B0B45] to-[#1a1a3e]';
                $damageBarWidthVal = $damageBarWidths[$damageLevel] ?? '0%';
                $hasImages = is_array($report->images) && count($report->images) > 0;
                $hasImage = $report->image_path && $report->image_path !== '';
                $reportStatusColorClass = $statusColors[$report->status] ?? 'bg-[#0B0B45]/10 text-[#0B0B45] border-[#0B0B45]/20';
                $reportStatusLabelText = $statusLabels[$report->status] ?? $report->status;
                @endphp
                <div class="report-card rounded-2xl overflow-hidden animate-in" data-status="{{ $report->status }}" data-stagger="{{ $loop->index }}">
                    @if($hasImages)
                    <div class="relative h-44 overflow-hidden">
                        <img src="{{ asset('storage/' . $report->images[0]) }}" alt="صورة البلاغ" class="w-full h-full object-cover">
                        <div class="absolute inset-0 bg-gradient-to-t from-[#0B0B45]/70 to-transparent"></div>
                        <div class="absolute top-3 right-3">
                            <span class="px-3 py-1 rounded-full text-xs font-medium border {{ $statusColors[$report->status] ?? 'bg-[#0B0B45]/10 text-[#0B0B45] border-[#0B0B45]/20' }}">
                                {{ $statusLabels[$report->status] ?? $report->status }}
                            </span>
                        </div>
                    </div>
                    @elseif($hasImage)
                    <div class="relative h-44 overflow-hidden">
                        <img src="{{ asset('storage/' . $report->image_path) }}" alt="صورة البلاغ" class="w-full h-full object-cover">
                        <div class="absolute inset-0 bg-gradient-to-t from-[#0B0B45]/70 to-transparent"></div>
                        <div class="absolute top-3 right-3">
                            <span class="px-3 py-1 rounded-full text-xs font-medium border {{ $statusColors[$report->status] ?? 'bg-[#0B0B45]/10 text-[#0B0B45] border-[#0B0B45]/20' }}">
                                {{ $statusLabels[$report->status] ?? $report->status }}
                            </span>
                        </div>
                    </div>
                    @else
                    <div class="relative h-44 bg-[#E8E6E1]/80 flex items-center justify-center">
                        <div class="text-center">
                            <div class="w-14 h-14 bg-[#0B0B45]/10 rounded-xl flex items-center justify-center mx-auto mb-2">
                                <svg class="w-7 h-7 text-[#0B0B45]/40" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                            </div>
                            <p class="text-[#0B0B45]/50 text-xs">لا توجد صورة</p>
                        </div>
                        <div class="absolute top-3 right-3">
                            <span class="px-3 py-1 rounded-full text-xs font-medium border {{ $statusColors[$report->status] ?? 'bg-[#0B0B45]/10 text-[#0B0B45] border-[#0B0B45]/20' }}">
                                {{ $statusLabels[$report->status] ?? $report->status }}
                            </span>
                        </div>
                    </div>
                    @endif

                    <div class="p-5">
                        <div class="flex items-start justify-between mb-3">
                            <div class="flex-1">
                                <h3 class="text-[#0B0B45] font-semibold text-sm leading-relaxed">{{ Str::limit($report->raw_location, 35) }}</h3>
                                @if($report->ai_location)
                                <p class="text-[#78A9C1] text-xs mt-1">{{ Str::limit($report->ai_location, 30) }}</p>
                                @endif
                            </div>
                            <span class="text-[#0B0B45]/40 text-xs whitespace-nowrap mr-2">#{{ $report->id }}</span>
                        </div>

                        @if($report->raw_description)
                        <p class="text-[#0B0B45]/60 text-xs mb-4 leading-relaxed">{{ Str::limit($report->raw_description, 80) }}</p>
                        @endif

                        @if($damageLevel && isset($damageLabels[$damageLevel]))
                        <div class="mb-4">
                            <div class="flex items-center justify-between mb-1.5">
                                <span class="text-[#0B0B45]/60 text-xs">مستوى الضرر</span>
                                <span class="px-2 py-0.5 rounded-full text-xs font-medium border {{ $damageColors[$damageLevel] ?? 'bg-[#0B0B45]/10 text-[#0B0B45] border-[#0B0B45]/20' }}">
                                    {{ $damageLabels[$damageLevel] }}
                                </span>
                            </div>
                            <div class="w-full bg-[#E8E6E1] rounded-full h-2">
                                <div class="damage-bar h-2 rounded-full bg-gradient-to-r {{ $damageBarColorClass }}" data-width="{{ $damageBarWidthVal }}"></div>
                            </div>
                        </div>
                        @else
                        <div class="mb-4">
                            <div class="flex items-center justify-between mb-1.5">
                                <span class="text-[#0B0B45]/60 text-xs">مستوى الضرر</span>
                                <span class="text-[#0B0B45]/50 text-xs">غير محدد</span>
                            </div>
                            <div class="w-full bg-[#E8E6E1] rounded-full h-2">
                                <div class="h-2 rounded-full bg-[#C9A97C]/30" style="width: 0%"></div>
                            </div>
                        </div>
                        @endif

                        <div class="flex items-center justify-between pt-3 border-t border-[#0B0B45]/10">
                            <div class="flex items-center gap-2 text-[#0B0B45]/50 text-xs">
                                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                                {{ $report->created_at->format('Y/m/d') }}
                            </div>
                            <a href="{{ route('user.reports.show', $report) }}" class="inline-flex items-center gap-1 text-[#C9A97C] hover:text-[#B08D5F] text-xs font-medium transition-all">
                                عرض التفاصيل
                                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
                                </svg>
                            </a>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>

            <div id="no-results" class="hidden text-center py-12">
                <svg class="w-16 h-16 text-[#0B0B45]/30 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <p class="text-[#0B0B45]/60">لا توجد بلاغات بهذه الحالة</p>
            </div>

            @if($reports->lastPage() > 1)
            <div class="mt-8 flex justify-center">
                <div class="flex items-center gap-2">
                    @if($reports->onFirstPage())
                    <span class="page-btn px-3 py-2 rounded-lg text-sm text-[#0B0B45]/30 border border-[#0B0B45]/10 cursor-not-allowed">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
                    </span>
                    @else
                    <a href="{{ $reports->previousPageUrl() }}" class="page-btn px-3 py-2 rounded-lg text-sm text-[#0B0B45] border border-[#0B0B45]/15 hover:border-[#C9A97C] hover:text-[#C9A97C] transition-all">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" /></svg>
                    </a>
                    @endif

                    @foreach(range(1, $reports->lastPage()) as $page)
                    @if($page == $reports->currentPage())
                    <span class="page-btn px-4 py-2 rounded-lg text-sm font-medium bg-gradient-to-r from-[#0B0B45] to-[#4D5A70] text-[#FAFAFA]">
                        {{ $page }}
                    </span>
                    @else
                    <a href="{{ $reports->url($page) }}" class="page-btn px-4 py-2 rounded-lg text-sm text-[#0B0B45] border border-[#0B0B45]/15 hover:border-[#C9A97C] hover:text-[#C9A97C] transition-all">
                        {{ $page }}
                    </a>
                    @endif
                    @endforeach

                    @if($reports->hasMorePages())
                    <a href="{{ $reports->nextPageUrl() }}" class="page-btn px-3 py-2 rounded-lg text-sm text-[#0B0B45] border border-[#0B0B45]/15 hover:border-[#C9A97C] hover:text-[#C9A97C] transition-all">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" /></svg>
                    </a>
                    @else
                    <span class="page-btn px-3 py-2 rounded-lg text-sm text-[#0B0B45]/30 border border-[#0B0B45]/10 cursor-not-allowed">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" /></svg>
                    </span>
                    @endif
                </div>
            </div>
            @endif

            @else
            <div class="glass-card rounded-2xl p-12 text-center">
                <div class="max-w-sm mx-auto">
                    <div class="w-20 h-20 bg-[#0B0B45]/10 rounded-2xl flex items-center justify-center mx-auto mb-6">
                        <svg class="w-10 h-10 text-[#0B0B45]/40" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                    </div>
                    <h3 class="text-[#0B0B45] text-xl font-bold mb-2">لا توجد بلاغات بعد</h3>
                    <p class="text-[#0B0B45]/60 text-sm mb-6">ابدأ بإضافة بلاغ جديد وسيتم تحليله بالذكاء الاصطناعي</p>
                    <a href="{{ route('user.reports.create') }}" class="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-[#C9A97C] to-[#B08D5F] text-[#FAFAFA] rounded-xl hover:from-[#B08D5F] hover:to-[#C9A97C] transition-all shadow-lg shadow-[#C9A97C]/25">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                        </svg>
                        إضافة بلاغ جديد
                    </a>
                </div>
            </div>
            @endif
        </div>
    </div>

    <script>
        function filterReports(status) {
            document.querySelectorAll('.filter-btn').forEach(btn => {
                btn.classList.remove('active');
                if (btn.dataset.filter === status) {
                    btn.classList.add('active');
                }
            });

            const cards = document.querySelectorAll('.report-card');
            let visibleCount = 0;

            cards.forEach(card => {
                if (status === 'all' || card.dataset.status === status) {
                    card.style.display = '';
                    visibleCount++;
                } else {
                    card.style.display = 'none';
                }
            });

            const noResults = document.getElementById('no-results');
            if (visibleCount === 0 && noResults) {
                noResults.classList.remove('hidden');
            } else if (noResults) {
                noResults.classList.add('hidden');
            }
        }
    </script>
</body>
</html>
