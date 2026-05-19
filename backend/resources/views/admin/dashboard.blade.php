@extends('admin.layouts.app')

@section('title', 'لوحة القيادة - نظام تقييم الأضرار الذكي')

@push('styles')
<style>
    .stat-card {
        transition: all 0.3s ease;
    }
    .stat-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 20px 40px -12px rgba(45, 62, 78, 0.2);
    }
    .chart-header {
        background: linear-gradient(135deg, #2D3A50 0%, #3D4A60 100%);
    }
</style>
@endpush

@section('content')
<div class="mb-5 fade-in">
    <div class="glass-card rounded-2xl p-4 shadow-lg">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-sand to-sage flex items-center justify-center shadow-md">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                    </svg>
                </div>
                <div>
                    <h2 class="text-lg font-bold text-charcoal">لوحة القيادة</h2>
                    <p class="text-charcoal/50 text-xs">نظرة عامة على التقارير والإحصائيات</p>
                </div>
            </div>
            <div class="flex items-center gap-1.5">
                <span class="pulse-dot w-2 h-2 rounded-full bg-sage"></span>
                <span class="text-xs text-charcoal/50">متصل</span>
            </div>
        </div>
    </div>
</div>

<div class="grid grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-8 fade-in">
    <div class="stat-card glass-card rounded-2xl p-4 lg:p-5 shadow-lg">
        <div class="flex items-center gap-3 lg:gap-4">
            <div class="w-11 h-11 lg:w-12 lg:h-12 shrink-0 rounded-xl bg-gradient-to-br from-sand to-sand/80 flex items-center justify-center shadow-lg shadow-sand/20">
                <svg class="w-5 h-5 lg:w-6 lg:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
            </div>
            <div class="min-w-0">
                <p class="text-charcoal/60 text-xs lg:text-sm truncate">إجمالي التقارير</p>
                <p class="text-xl lg:text-2xl font-bold text-sand mt-0.5">{{ $totalReports }}</p>
            </div>
        </div>
    </div>

    <div class="stat-card glass-card rounded-2xl p-4 lg:p-5 shadow-lg">
        <div class="flex items-center gap-3 lg:gap-4">
            <div class="w-11 h-11 lg:w-12 lg:h-12 shrink-0 rounded-xl bg-gradient-to-br from-sage to-sage/80 flex items-center justify-center shadow-lg shadow-sage/20">
                <svg class="w-5 h-5 lg:w-6 lg:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
            </div>
            <div class="min-w-0">
                <p class="text-charcoal/60 text-xs lg:text-sm truncate">مكتملة</p>
                <p class="text-xl lg:text-2xl font-bold text-sage mt-0.5">{{ $completedReports }}</p>
            </div>
        </div>
    </div>

    <div class="stat-card glass-card rounded-2xl p-4 lg:p-5 shadow-lg">
        <div class="flex items-center gap-3 lg:gap-4">
            <div class="w-11 h-11 lg:w-12 lg:h-12 shrink-0 rounded-xl bg-gradient-to-br from-charcoal to-charcoal/80 flex items-center justify-center shadow-lg shadow-charcoal/20">
                <svg class="w-5 h-5 lg:w-6 lg:h-6 text-light" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
            </div>
            <div class="min-w-0">
                <p class="text-charcoal/60 text-xs lg:text-sm truncate">قيد الانتظار</p>
                <p class="text-xl lg:text-2xl font-bold text-charcoal mt-0.5">{{ $pendingReports }}</p>
            </div>
        </div>
    </div>

    <div class="stat-card glass-card rounded-2xl p-4 lg:p-5 shadow-lg">
        <div class="flex items-center gap-3 lg:gap-4">
            <div class="w-11 h-11 lg:w-12 lg:h-12 shrink-0 rounded-xl bg-gradient-to-br from-charcoal/80 to-charcoal/60 flex items-center justify-center shadow-lg shadow-charcoal/20">
                <svg class="w-5 h-5 lg:w-6 lg:h-6 text-sand" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path>
                </svg>
            </div>
            <div class="min-w-0">
                <p class="text-charcoal/60 text-xs lg:text-sm truncate">المستخدمين</p>
                <p class="text-xl lg:text-2xl font-bold text-charcoal mt-0.5">{{ $totalUsers }}</p>
            </div>
        </div>
    </div>
</div>

<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8 fade-in">
    <div class="glass-card rounded-2xl shadow-xl overflow-hidden flex flex-col h-full">
        <div class="chart-header px-6 py-4">
            <h3 class="text-lg font-bold text-light flex items-center gap-2">
                <svg class="w-5 h-5 text-sand" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 11H9V3.055z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z"></path>
                </svg>
                توزيع الأضرار
            </h3>
        </div>
        <div class="p-6 flex-1 flex items-center justify-center">
            <div class="w-full h-48 relative flex justify-center">
                <canvas id="damageChart"></canvas>
            </div>
        </div>
    </div>

    <div class="glass-card rounded-2xl shadow-xl overflow-hidden flex flex-col h-full">
        <div class="chart-header px-6 py-4">
            <h3 class="text-lg font-bold text-light flex items-center gap-2">
                <svg class="w-5 h-5 text-sage" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                </svg>
                حالة التقارير
            </h3>
        </div>
        <div class="p-6 flex-1 flex items-center justify-center">
            <div class="w-full h-48 relative flex justify-center">
                <canvas id="statusChart"></canvas>
            </div>
        </div>
    </div>

    <div class="glass-card rounded-2xl shadow-xl overflow-hidden flex flex-col h-full">
        <div class="chart-header px-6 py-4">
            <h3 class="text-lg font-bold text-light flex items-center gap-2">
                <svg class="w-5 h-5 text-sand" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z"></path>
                </svg>
                التقارير خلال آخر 7 أيام
            </h3>
        </div>
        <div class="p-6 flex-1 flex items-center justify-center">
            <div class="w-full h-48 relative flex justify-center">
                <canvas id="timeChart"></canvas>
            </div>
        </div>
    </div>

    <div class="glass-card rounded-2xl shadow-xl overflow-hidden flex flex-col h-full">
        <div class="chart-header px-6 py-4">
            <h3 class="text-lg font-bold text-light flex items-center gap-2">
                <svg class="w-5 h-5 text-sage" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                التقارير حسب الموقع
            </h3>
        </div>
        <div class="p-6 flex-1 flex items-center justify-center">
            <div class="w-full h-48 relative flex justify-center">
                <canvas id="locationChart"></canvas>
            </div>
        </div>
    </div>
</div>

<div class="glass-card rounded-2xl shadow-xl overflow-hidden fade-in">
    <div class="chart-header px-6 py-4">
        <h3 class="text-lg font-bold text-light flex items-center gap-2">
            <svg class="w-5 h-5 text-sand" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            أحدث التقارير
        </h3>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-beige/50">
                <tr>
                    <th class="px-6 py-4 text-right text-sm font-bold text-charcoal/70">المعرف</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-charcoal/70">الموقع</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-charcoal/70">مستوى الضرر</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-charcoal/70">الحالة</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-charcoal/70">التاريخ</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-charcoal/5">
                @forelse($recentReports as $report)
                <tr class="hover:bg-beige/30 transition-colors">
                    <td class="px-6 py-4 font-bold text-sand">#{{ $report->id }}</td>
                    <td class="px-6 py-4 text-charcoal/80">{{ $report->raw_location }}</td>
                    <td class="px-6 py-4">
                        @php
                            $damageColors = [
                                'critical' => 'bg-red-100 text-red-700 border-red-200',
                                'high' => 'bg-orange-100 text-orange-700 border-orange-200',
                                'medium' => 'bg-yellow-100 text-yellow-700 border-yellow-200',
                                'low' => 'bg-emerald-100 text-emerald-700 border-emerald-200'
                            ];
                            $damageLabels = [
                                'critical' => 'حرج',
                                'high' => 'عالي',
                                'medium' => 'متوسط',
                                'low' => 'منخفض'
                            ];
                            $colorClass = $damageColors[$report->ai_damage_level] ?? 'bg-gray-100 text-gray-700 border-gray-200';
                            $label = $damageLabels[$report->ai_damage_level] ?? 'غير محدد';
                        @endphp
                        <span class="px-3 py-1 rounded-full text-xs font-bold border {{ $colorClass }}">
                            {{ $label }}
                        </span>
                    </td>
                    <td class="px-6 py-4">
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
                        <span class="px-3 py-1 rounded-full text-xs font-bold border {{ $statusColor }}">
                            {{ $statusLabel }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-charcoal/50 text-sm">{{ $report->created_at->format('Y-m-d H:i') }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="5" class="px-6 py-8 text-center text-charcoal/50">لا توجد تقارير بعد</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    const damageLabels = {
        'low': 'منخفض',
        'medium': 'متوسط',
        'high': 'عالي',
        'critical': 'حرج'
    };

    new Chart(document.getElementById('damageChart'), {
        type: 'doughnut',
        data: {
            labels: @json(array_keys($damageStats)).map(level => damageLabels[level] || level),
            datasets: [{
                data: @json(array_values($damageStats)),
                backgroundColor: [
                    'rgba(34, 197, 94, 0.8)',
                    'rgba(234, 179, 8, 0.8)',
                    'rgba(249, 115, 22, 0.8)',
                    'rgba(239, 68, 68, 0.8)'
                ],
                borderColor: [
                    'rgb(34, 197, 94)',
                    'rgb(234, 179, 8)',
                    'rgb(249, 115, 22)',
                    'rgb(239, 68, 68)'
                ],
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    rtl: true,
                    labels: {
                        font: { family: 'Cairo' },
                        color: '#2D3A50'
                    }
                }
            }
        }
    });

    const statusLabels = {
        'pending': 'قيد الانتظار',
        'processing': 'قيد المعالجة',
        'completed': 'مكتمل',
        'rejected': 'مرفوض'
    };

    new Chart(document.getElementById('statusChart'), {
        type: 'pie',
        data: {
            labels: @json(array_keys($statusStats)).map(status => statusLabels[status] || status),
            datasets: [{
                data: @json(array_values($statusStats)),
                backgroundColor: [
                    'rgba(234, 179, 8, 0.8)',
                    'rgba(59, 130, 246, 0.8)',
                    'rgba(34, 197, 94, 0.8)',
                    'rgba(239, 68, 68, 0.8)'
                ],
                borderColor: [
                    'rgb(234, 179, 8)',
                    'rgb(59, 130, 246)',
                    'rgb(34, 197, 94)',
                    'rgb(239, 68, 68)'
                ],
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    rtl: true,
                    labels: {
                        font: { family: 'Cairo' },
                        color: '#2D3A50'
                    }
                }
            }
        }
    });

    new Chart(document.getElementById('timeChart'), {
        type: 'line',
        data: {
            labels: @json(array_keys($reportsOverTime)),
            datasets: [{
                label: 'عدد التقارير',
                data: @json(array_values($reportsOverTime)),
                fill: true,
                borderColor: 'rgb(59, 130, 246)',
                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                tension: 0.4,
                pointBackgroundColor: 'rgb(59, 130, 246)',
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                pointRadius: 6
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { stepSize: 1, color: '#2D3A50' },
                    grid: { color: 'rgba(45, 62, 78, 0.06)' }
                },
                x: {
                    ticks: { color: '#2D3A50' },
                    grid: { color: 'rgba(45, 62, 78, 0.06)' }
                }
            }
        }
    });

    new Chart(document.getElementById('locationChart'), {
        type: 'bar',
        data: {
            labels: @json(array_keys($reportsByLocation)),
            datasets: [{
                label: 'عدد التقارير',
                data: @json(array_values($reportsByLocation)),
                backgroundColor: 'rgba(139, 92, 246, 0.8)',
                borderColor: 'rgb(139, 92, 246)',
                borderWidth: 2,
                borderRadius: 8
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: { stepSize: 1, color: '#2D3A50' },
                    grid: { color: 'rgba(45, 62, 78, 0.06)' }
                },
                x: {
                    ticks: { color: '#2D3A50' },
                    grid: { color: 'rgba(45, 62, 78, 0.06)' }
                }
            }
        }
    });
</script>
@endpush
