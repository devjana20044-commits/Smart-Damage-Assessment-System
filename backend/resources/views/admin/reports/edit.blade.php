<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تعديل التقرير - نظام تقييم الأضرار الذكي</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <style>
        * {
            font-family: 'Cairo', sans-serif;
        }
        
        .glass-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .gradient-bg {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .input-modern {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .input-modern:focus {
            transform: translateY(-2px);
            box-shadow: 0 10px 40px rgba(99, 102, 241, 0.2);
        }
        
        .btn-gradient {
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
            transition: all 0.3s ease;
        }
        
        .btn-gradient:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(99, 102, 241, 0.4);
        }
        
        .sidebar-item {
            transition: all 0.3s ease;
        }
        
        .sidebar-item:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateX(-5px);
        }
        
        .sidebar-item.active {
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
        }
        
        .upload-zone {
            border: 2px dashed #cbd5e1;
            transition: all 0.3s ease;
        }
        
        .upload-zone:hover {
            border-color: #6366f1;
            background: rgba(99, 102, 241, 0.05);
        }
        
        .upload-zone.dragover {
            border-color: #6366f1;
            background: rgba(99, 102, 241, 0.1);
            transform: scale(1.02);
        }
        
        .image-card {
            transition: all 0.3s ease;
        }
        
        .image-card:hover {
            transform: scale(1.05);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }
        
        .progress-bar {
            background: linear-gradient(90deg, #6366f1, #8b5cf6, #6366f1);
            background-size: 200% 100%;
            animation: shimmer 2s infinite;
        }
        
        @keyframes shimmer {
            0% { background-position: -200% 0; }
            100% { background-position: 200% 0; }
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
    </style>
</head>
<body class="bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 min-h-screen">
    <div class="flex min-h-screen">
        <!-- Sidebar -->
        <aside class="w-72 bg-gradient-to-b from-slate-900 via-slate-800 to-slate-900 shadow-2xl fixed h-full">
            <div class="p-6 border-b border-slate-700">
                <div class="flex items-center gap-3">
                    <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-lg">
                        <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                        </svg>
                    </div>
                    <div>
                        <h1 class="text-white text-lg font-bold">نظام الأضرار</h1>
                        <p class="text-slate-400 text-xs">لوحة الإدارة</p>
                    </div>
                </div>
            </div>
            
            <nav class="p-4 space-y-2">
                <a href="{{ route('admin.dashboard') }}" class="sidebar-item flex items-center gap-3 px-4 py-3 text-slate-300 rounded-xl">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                    </svg>
                    <span class="font-medium">لوحة القيادة</span>
                </a>
                
                <a href="{{ route('admin.map') }}" class="sidebar-item flex items-center gap-3 px-4 py-3 text-slate-300 rounded-xl">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path>
                    </svg>
                    <span class="font-medium">الخريطة</span>
                </a>
                
                <a href="{{ route('admin.reports') }}" class="sidebar-item active flex items-center gap-3 px-4 py-3 text-white rounded-xl">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                    <span class="font-medium">التقارير</span>
                </a>
                
                <div class="pt-4 mt-4 border-t border-slate-700">
                    <div class="flex items-center gap-3 px-4 py-3">
                        <div class="w-10 h-10 rounded-full bg-gradient-to-br from-green-400 to-emerald-500 flex items-center justify-center text-white font-bold">
                            {{ auth()->user()->name[0] ?? 'م' }}
                        </div>
                        <div>
                            <p class="text-white text-sm font-medium">{{ auth()->user()->name ?? 'المستخدم' }}</p>
                            <p class="text-slate-400 text-xs">{{ auth()->user()->email ?? '' }}</p>
                        </div>
                    </div>
                </div>
            </nav>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 mr-72 p-8">
            <!-- Header -->
            <div class="mb-8 fade-in">
                <div class="glass-card rounded-3xl p-8 shadow-xl">
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-5">
                            <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center shadow-lg">
                                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                </svg>
                            </div>
                            <div>
                                <h2 class="text-3xl font-bold text-slate-800">تعديل التقرير #{{ $report->id }}</h2>
                                <p class="text-slate-500 mt-1">قم بتحديث بيانات التقرير والملفات المرفقة</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-2">
                            <span class="pulse-dot w-3 h-3 rounded-full bg-green-500"></span>
                            <span class="text-sm text-slate-500">متصل</span>
                        </div>
                    </div>
                </div>
            </div>

            @if ($errors->any())
                <div class="mb-6 fade-in">
                    <div class="bg-gradient-to-r from-red-50 to-rose-50 border border-red-200 rounded-2xl p-5 shadow-lg">
                        <div class="flex items-start gap-4">
                            <div class="w-12 h-12 rounded-xl bg-red-100 flex items-center justify-center flex-shrink-0">
                                <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                            </div>
                            <div>
                                <h3 class="font-bold text-red-800 text-lg mb-2">يرجى تصحيح الأخطاء التالية:</h3>
                                <ul class="text-red-700 space-y-1">
                                    @foreach ($errors->all() as $error)
                                        <li class="flex items-center gap-2">
                                            <svg class="w-4 h-4 text-red-500" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                                            </svg>
                                            {{ $error }}
                                        </li>
                                    @endforeach
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            @endif

            <form action="{{ route('admin.reports.update', $report) }}" method="POST" enctype="multipart/form-data" class="space-y-6">
                @csrf
                @method('PUT')

                <!-- Basic Info Card -->
                <div class="glass-card rounded-3xl shadow-xl overflow-hidden fade-in">
                    <div class="bg-gradient-to-r from-indigo-500 to-purple-600 px-8 py-5">
                        <h3 class="text-xl font-bold text-white flex items-center gap-3">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                            </svg>
                            المعلومات الأساسية
                        </h3>
                    </div>
                    
                    <div class="p-8">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <!-- User -->
                            <div>
                                <label for="user_id" class="block text-sm font-bold text-slate-700 mb-2">
                                    المستخدم
                                </label>
                                <select name="user_id" id="user_id" class="input-modern w-full px-5 py-4 border-2 border-slate-200 rounded-2xl bg-white focus:border-indigo-500 focus:ring-4 focus:ring-indigo-100 outline-none" required>
                                    <option value="">اختر مستخدم</option>
                                    @foreach($users as $user)
                                        <option value="{{ $user->id }}" {{ old('user_id', $report->user_id) == $user->id ? 'selected' : '' }}>{{ $user->name }}</option>
                                    @endforeach
                                </select>
                            </div>

                            <!-- Location -->
                            <div>
                                <label for="raw_location" class="block text-sm font-bold text-slate-700 mb-2">
                                    الموقع
                                </label>
                                <input type="text" name="raw_location" id="raw_location" value="{{ old('raw_location', $report->raw_location) }}" class="input-modern w-full px-5 py-4 border-2 border-slate-200 rounded-2xl bg-white focus:border-indigo-500 focus:ring-4 focus:ring-indigo-100 outline-none" placeholder="مثال: دمشق، حي الميدان" required>
                            </div>

                            <!-- Latitude -->
                            <div>
                                <label for="latitude" class="block text-sm font-bold text-slate-700 mb-2">
                                    خط العرض
                                </label>
                                <input type="number" step="any" name="latitude" id="latitude" value="{{ old('latitude', $report->latitude) }}" class="input-modern w-full px-5 py-4 border-2 border-slate-200 rounded-2xl bg-white focus:border-indigo-500 focus:ring-4 focus:ring-indigo-100 outline-none" placeholder="33.5138" required>
                            </div>

                            <!-- Longitude -->
                            <div>
                                <label for="longitude" class="block text-sm font-bold text-slate-700 mb-2">
                                    خط الطول
                                </label>
                                <input type="number" step="any" name="longitude" id="longitude" value="{{ old('longitude', $report->longitude) }}" class="input-modern w-full px-5 py-4 border-2 border-slate-200 rounded-2xl bg-white focus:border-indigo-500 focus:ring-4 focus:ring-indigo-100 outline-none" placeholder="36.2765" required>
                            </div>

                            <!-- Damage Level -->
                            <div>
                                <label for="ai_damage_level" class="block text-sm font-bold text-slate-700 mb-2">
                                    مستوى الضرر (AI)
                                </label>
                                <select name="ai_damage_level" id="ai_damage_level" class="input-modern w-full px-5 py-4 border-2 border-slate-200 rounded-2xl bg-white focus:border-indigo-500 focus:ring-4 focus:ring-indigo-100 outline-none">
                                    <option value="">غير محدد</option>
                                    <option value="low" {{ old('ai_damage_level', $report->ai_damage_level) == 'low' ? 'selected' : '' }}>منخفض</option>
                                    <option value="medium" {{ old('ai_damage_level', $report->ai_damage_level) == 'medium' ? 'selected' : '' }}>متوسط</option>
                                    <option value="high" {{ old('ai_damage_level', $report->ai_damage_level) == 'high' ? 'selected' : '' }}>عالي</option>
                                    <option value="critical" {{ old('ai_damage_level', $report->ai_damage_level) == 'critical' ? 'selected' : '' }}>حرج</option>
                                </select>
                            </div>

                            <!-- Status -->
                            <div>
                                <label for="status" class="block text-sm font-bold text-slate-700 mb-2">
                                    الحالة
                                </label>
                                <select name="status" id="status" class="input-modern w-full px-5 py-4 border-2 border-slate-200 rounded-2xl bg-white focus:border-indigo-500 focus:ring-4 focus:ring-indigo-100 outline-none">
                                    <option value="pending" {{ old('status', $report->status) == 'pending' ? 'selected' : '' }}>قيد الانتظار</option>
                                    <option value="processing" {{ old('status', $report->status) == 'processing' ? 'selected' : '' }}>قيد المعالجة</option>
                                    <option value="completed" {{ old('status', $report->status) == 'completed' ? 'selected' : '' }}>مكتمل</option>
                                    <option value="rejected" {{ old('status', $report->status) == 'rejected' ? 'selected' : '' }}>مرفوض</option>
                                </select>
                            </div>

                            <!-- Description -->
                            <div class="md:col-span-2">
                                <label for="raw_description" class="block text-sm font-bold text-slate-700 mb-2">
                                    الوصف
                                </label>
                                <textarea name="raw_description" id="raw_description" rows="4" class="input-modern w-full px-5 py-4 border-2 border-slate-200 rounded-2xl bg-white focus:border-indigo-500 focus:ring-4 focus:ring-indigo-100 outline-none resize-none" placeholder="اكتب وصفاً تفصيلياً للضرر...">{{ old('raw_description', $report->raw_description) }}</textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Images Card -->
                <div class="glass-card rounded-3xl shadow-xl overflow-hidden fade-in">
                    <div class="bg-gradient-to-r from-green-500 to-emerald-600 px-8 py-5">
                        <h3 class="text-xl font-bold text-white flex items-center gap-3">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                            </svg>
                            الصور
                        </h3>
                    </div>
                    
                    <div class="p-8">
                        @php
                            $existingImages = $report->images ?? [];
                            $hasOldImage = !empty($report->image_path) && !in_array($report->image_path, $existingImages);
                        @endphp
                        
                        @if(count($existingImages) > 0 || $hasOldImage)
                            <div class="mb-6">
                                <p class="text-sm font-bold text-slate-600 mb-4">الصور الحالية:</p>
                                <div class="grid grid-cols-3 md:grid-cols-5 lg:grid-cols-6 gap-4" id="existing-images">
                                    @foreach($existingImages as $image)
                                        <div class="image-card relative group rounded-2xl overflow-hidden shadow-lg">
                                            <img src="{{ asset('storage/' . $image) }}" alt="صورة" class="w-full h-28 object-cover">
                                            <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                                <button type="button" onclick="removeImage('{{ $image }}')" class="w-10 h-10 rounded-full bg-red-500 text-white flex items-center justify-center hover:bg-red-600 transition-colors">
                                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                                                    </svg>
                                                </button>
                                            </div>
                                            <input type="hidden" name="existing_images[]" value="{{ $image }}">
                                        </div>
                                    @endforeach
                                    @if($hasOldImage)
                                        <div class="image-card relative group rounded-2xl overflow-hidden shadow-lg">
                                            <img src="{{ asset('storage/' . $report->image_path) }}" alt="صورة" class="w-full h-28 object-cover">
                                            <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                                <button type="button" onclick="removeOldImage()" class="w-10 h-10 rounded-full bg-red-500 text-white flex items-center justify-center hover:bg-red-600 transition-colors">
                                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                                                    </svg>
                                                </button>
                                            </div>
                                            <input type="hidden" name="keep_old_image" value="1" id="keep_old_image">
                                        </div>
                                    @endif
                                </div>
                            </div>
                        @endif
                        
                        <div class="upload-zone rounded-2xl p-8 text-center" id="image-drop-zone">
                            <div class="w-20 h-20 mx-auto rounded-2xl bg-green-100 flex items-center justify-center mb-4">
                                <svg class="w-10 h-10 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                                </svg>
                            </div>
                            <p class="text-slate-700 font-bold mb-2">اسحب الصور هنا أو انقر للاختيار</p>
                            <p class="text-slate-400 text-sm mb-4">JPG, PNG, GIF - حتى 10 صور</p>
                            <input type="file" name="images[]" id="images" multiple accept="image/*" class="hidden">
                            <label for="images" class="cursor-pointer inline-flex items-center gap-2 px-6 py-3 bg-green-500 text-white rounded-xl font-bold hover:bg-green-600 transition-colors">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                                </svg>
                                اختيار صور
                            </label>
                        </div>
                    </div>
                </div>

                <!-- PDF Card -->
                <div class="glass-card rounded-3xl shadow-xl overflow-hidden fade-in">
                    <div class="bg-gradient-to-r from-red-500 to-rose-600 px-8 py-5">
                        <h3 class="text-xl font-bold text-white flex items-center gap-3">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                            </svg>
                            ملف PDF
                        </h3>
                    </div>
                    
                    <div class="p-8">
                        @if($report->pdf_file)
                            <div class="mb-6 p-5 bg-gradient-to-r from-red-50 to-rose-50 rounded-2xl border-2 border-red-200">
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center gap-4">
                                        <div class="w-14 h-14 rounded-xl bg-red-500 flex items-center justify-center">
                                            <svg class="w-7 h-7 text-white" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" clip-rule="evenodd"></path>
                                            </svg>
                                        </div>
                                        <div>
                                            <p class="font-bold text-slate-800">ملف PDF موجود</p>
                                            <a href="{{ asset('storage/' . $report->pdf_file) }}" target="_blank" class="text-sm text-indigo-600 hover:text-indigo-800 font-medium">عرض الملف</a>
                                        </div>
                                    </div>
                                    <label class="flex items-center gap-2 cursor-pointer">
                                        <input type="checkbox" name="remove_pdf" value="1" class="w-5 h-5 text-red-600 rounded">
                                        <span class="text-sm text-red-600 font-bold">حذف الملف</span>
                                    </label>
                                </div>
                            </div>
                        @endif
                        
                        <div class="upload-zone rounded-2xl p-8 text-center">
                            <div class="w-20 h-20 mx-auto rounded-2xl bg-red-100 flex items-center justify-center mb-4">
                                <svg class="w-10 h-10 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                                </svg>
                            </div>
                            <p class="text-slate-700 font-bold mb-2">رفع ملف PDF جديد</p>
                            <p class="text-slate-400 text-sm mb-4">الحد الأقصى: 10 ميجابايت</p>
                            <input type="file" name="pdf_file" id="pdf_file" accept=".pdf,application/pdf" class="hidden">
                            <label for="pdf_file" class="cursor-pointer inline-flex items-center gap-2 px-6 py-3 bg-red-500 text-white rounded-xl font-bold hover:bg-red-600 transition-colors">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"></path>
                                </svg>
                                اختيار ملف
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Video Links Card -->
                <div class="glass-card rounded-3xl shadow-xl overflow-hidden fade-in">
                    <div class="bg-gradient-to-r from-purple-500 to-violet-600 px-8 py-5">
                        <h3 class="text-xl font-bold text-white flex items-center gap-3">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
                            </svg>
                            روابط الفيديو
                        </h3>
                    </div>
                    
                    <div class="p-8">
                        @if($report->video_links && count($report->video_links) > 0)
                            <div class="mb-6 space-y-3" id="existing-videos">
                                @foreach($report->video_links as $index => $link)
                                    <div class="flex items-center gap-3 p-4 bg-purple-50 rounded-xl border-2 border-purple-200">
                                        <div class="w-10 h-10 rounded-lg bg-purple-500 flex items-center justify-center flex-shrink-0">
                                            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"></path>
                                            </svg>
                                        </div>
                                        <input type="text" value="{{ $link }}" readonly class="flex-1 px-4 py-3 bg-white border-2 border-slate-200 rounded-xl text-sm">
                                        <button type="button" onclick="this.parentElement.remove()" class="w-10 h-10 rounded-lg bg-red-500 text-white flex items-center justify-center hover:bg-red-600 transition-colors">
                                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                            </svg>
                                        </button>
                                    </div>
                                @endforeach
                            </div>
                        @endif
                        
                        <div id="video-links-container" class="space-y-3">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-lg bg-purple-500 flex items-center justify-center flex-shrink-0">
                                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"></path>
                                    </svg>
                                </div>
                                <input type="url" name="video_links[]" placeholder="https://youtube.com/watch?v=..." class="input-modern flex-1 px-5 py-4 border-2 border-slate-200 rounded-xl bg-white focus:border-purple-500 focus:ring-4 focus:ring-purple-100 outline-none">
                                <button type="button" onclick="addVideoLink()" class="w-10 h-10 rounded-lg bg-green-500 text-white flex items-center justify-center hover:bg-green-600 transition-colors">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                                    </svg>
                                </button>
                            </div>
                        </div>
                        <p class="text-slate-400 text-sm mt-4 text-center">YouTube, Vimeo, أو أي رابط فيديو آخر</p>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="flex items-center justify-end gap-4 pt-4">
                    <a href="{{ route('admin.reports') }}" class="px-8 py-4 bg-slate-200 text-slate-700 rounded-xl font-bold hover:bg-slate-300 transition-colors flex items-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                        </svg>
                        إلغاء
                    </a>
                    <a href="{{ route('admin.reports.show', $report) }}" class="px-8 py-4 bg-slate-700 text-white rounded-xl font-bold hover:bg-slate-800 transition-colors flex items-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                        </svg>
                        عرض التفاصيل
                    </a>
                    <button type="submit" class="btn-gradient px-8 py-4 text-white rounded-xl font-bold flex items-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                        </svg>
                        حفظ التغييرات
                    </button>
                </div>
            </form>
        </main>
    </div>

    <script>
        function addVideoLink() {
            const container = document.getElementById('video-links-container');
            const newDiv = document.createElement('div');
            newDiv.className = 'flex items-center gap-3 fade-in';
            newDiv.innerHTML = `
                <div class="w-10 h-10 rounded-lg bg-purple-500 flex items-center justify-center flex-shrink-0">
                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"></path>
                    </svg>
                </div>
                <input type="url" name="video_links[]" placeholder="https://youtube.com/watch?v=..." class="input-modern flex-1 px-5 py-4 border-2 border-slate-200 rounded-xl bg-white focus:border-purple-500 focus:ring-4 focus:ring-purple-100 outline-none">
                <button type="button" onclick="this.parentElement.remove()" class="w-10 h-10 rounded-lg bg-red-500 text-white flex items-center justify-center hover:bg-red-600 transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            `;
            container.appendChild(newDiv);
        }

        function removeImage(imagePath) {
            if (confirm('هل أنت متأكد من حذف هذه الصورة؟')) {
                const input = document.querySelector(`input[value="${imagePath}"]`);
                if (input) {
                    const previewDiv = input.closest('.image-card');
                    if (previewDiv) {
                        previewDiv.style.transform = 'scale(0.8)';
                        previewDiv.style.opacity = '0';
                        previewDiv.style.transition = 'all 0.3s ease';
                        setTimeout(() => previewDiv.remove(), 300);
                    }
                }
            }
        }

        function removeOldImage() {
            if (confirm('هل أنت متأكد من حذف الصورة القديمة؟')) {
                const checkbox = document.getElementById('keep_old_image');
                if (checkbox) {
                    checkbox.value = '0';
                    const previewDiv = checkbox.closest('.image-card');
                    if (previewDiv) {
                        previewDiv.style.transform = 'scale(0.8)';
                        previewDiv.style.opacity = '0';
                        previewDiv.style.transition = 'all 0.3s ease';
                    }
                }
            }
        }

        // Drag and drop for images
        const dropZone = document.getElementById('image-drop-zone');
        if (dropZone) {
            dropZone.addEventListener('dragover', (e) => {
                e.preventDefault();
                dropZone.classList.add('dragover');
            });
            
            dropZone.addEventListener('dragleave', () => {
                dropZone.classList.remove('dragover');
            });
            
            dropZone.addEventListener('drop', (e) => {
                e.preventDefault();
                dropZone.classList.remove('dragover');
                const files = e.dataTransfer.files;
                const input = document.getElementById('images');
                input.files = files;
            });
        }
    </script>
</body>
</html>