@extends('admin.layouts.app')

@section('title', 'التقارير - نظام تقييم الأضرار الذكي')

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
                    <h2 class="text-3xl font-bold text-slate-800">جميع التقارير</h2>
                    <p class="text-slate-500 mt-1">إدارة وعرض جميع التقارير</p>
                </div>
            </div>
            <a href="{{ route('admin.reports.create') }}" class="btn-gradient px-6 py-3 text-white rounded-xl font-bold flex items-center gap-2">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                </svg>
                تقرير جديد
            </a>
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

<!-- Reports Table -->
<div class="glass-card rounded-2xl shadow-xl overflow-hidden fade-in">
    <div class="overflow-x-auto">
        <table class="w-full">
            <thead class="bg-gradient-to-r from-slate-700 to-slate-800">
                <tr>
                    <th class="px-6 py-4 text-right text-sm font-bold text-white">#</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-white">الصورة</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-white">المستخدم</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-white">الموقع</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-white">مستوى الضرر</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-white">الحالة</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-white">التاريخ</th>
                    <th class="px-6 py-4 text-right text-sm font-bold text-white">الإجراءات</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-200">
                @forelse($reports as $report)
                <tr class="hover:bg-slate-50 transition-colors">
                    <td class="px-6 py-4">
                        <span class="font-bold text-indigo-600">#{{ $report->id }}</span>
                    </td>
                    <td class="px-6 py-4">
                        @php
                            $images = $report->images ?? [];
                            $firstImage = count($images) > 0 ? $images[0] : $report->image_path;
                            $imageCount = count($images);
                        @endphp
                        <div class="flex items-center gap-3">
                            @if($firstImage)
                                <img src="{{ asset('storage/' . $firstImage) }}" alt="صورة" class="w-14 h-14 object-cover rounded-xl shadow-md">
                                @if($imageCount > 1)
                                    <span class="text-xs text-slate-500 bg-slate-100 px-2 py-1 rounded-full">+{{ $imageCount - 1 }}</span>
                                @endif
                            @else
                                <div class="w-14 h-14 bg-slate-200 rounded-xl flex items-center justify-center">
                                    <svg class="w-6 h-6 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                    </svg>
                                </div>
                            @endif
                            @if($report->pdf_file)
                                <span class="text-xs text-red-600 bg-red-50 px-2 py-1 rounded-full">PDF</span>
                            @endif
                            @if($report->video_links && count($report->video_links) > 0)
                                <span class="text-xs text-purple-600 bg-purple-50 px-2 py-1 rounded-full">فيديو</span>
                            @endif
                        </div>
                    </td>
                    <td class="px-6 py-4">
                        <span class="font-medium text-slate-700">{{ $report->user->name }}</span>
                    </td>
                    <td class="px-6 py-4">
                        <span class="text-slate-600">{{ $report->raw_location }}</span>
                    </td>
                    <td class="px-6 py-4">
                        @php
                            $damageColors = [
                                'critical' => 'bg-red-100 text-red-700 border-red-200',
                                'high' => 'bg-orange-100 text-orange-700 border-orange-200',
                                'medium' => 'bg-yellow-100 text-yellow-700 border-yellow-200',
                                'low' => 'bg-green-100 text-green-700 border-green-200'
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
                    <td class="px-6 py-4">
                        <span class="text-slate-500 text-sm">{{ $report->created_at->format('Y-m-d H:i') }}</span>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex items-center gap-2">
                            <a href="{{ route('admin.reports.show', $report) }}" class="w-9 h-9 rounded-lg bg-green-100 text-green-600 flex items-center justify-center hover:bg-green-200 transition-colors" title="عرض">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                </svg>
                            </a>
                            <a href="{{ route('admin.reports.edit', $report) }}" class="w-9 h-9 rounded-lg bg-blue-100 text-blue-600 flex items-center justify-center hover:bg-blue-200 transition-colors" title="تعديل">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                </svg>
                            </a>
                            <form action="{{ route('admin.reports.destroy', $report) }}" method="POST" class="inline-block" onsubmit="return confirm('هل أنت متأكد من حذف هذا التقرير؟');">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="w-9 h-9 rounded-lg bg-red-100 text-red-600 flex items-center justify-center hover:bg-red-200 transition-colors" title="حذف">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                    </svg>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="8" class="px-6 py-12 text-center">
                        <div class="flex flex-col items-center">
                            <svg class="w-16 h-16 text-slate-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                            </svg>
                            <p class="text-slate-500 text-lg font-medium">لا توجد تقارير</p>
                        </div>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>

@if($reports->hasPages())
<div class="mt-6 flex justify-center">
    {{ $reports->links() }}
</div>
@endif
@endsection