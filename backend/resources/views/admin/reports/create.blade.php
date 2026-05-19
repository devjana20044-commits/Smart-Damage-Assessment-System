@extends('admin.layouts.app')

@section('title', 'إضافة تقرير جديد - نظام تقييم الأضرار الذكي')

@section('content')
<!-- Header -->
<div class="mb-8 fade-in">
    <div class="glass-card rounded-3xl p-8 shadow-xl">
        <div class="flex items-center gap-5">
            <div class="w-16 h-16 rounded-2xl bg-gradient-to-br from-sand to-sand/80 flex items-center justify-center shadow-lg">
                <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                </svg>
            </div>
            <div>
                <h2 class="text-3xl font-bold text-charcoal">إضافة تقرير جديد</h2>
                <p class="text-charcoal/60 mt-1">قم بإنشاء تقرير جديد مع جميع التفاصيل</p>
            </div>
        </div>
    </div>
</div>

@if ($errors->any())
<div class="mb-6 fade-in">
    <div class="bg-gradient-to-r from-red-50 to-rose-50 border-2 border-red-200 rounded-2xl p-5 shadow-lg">
        <div class="flex items-start gap-4">
            <div class="w-12 h-12 rounded-xl bg-red-500 flex items-center justify-center flex-shrink-0">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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

<form action="{{ route('admin.reports.store') }}" method="POST" enctype="multipart/form-data" class="space-y-6">
    @csrf

    <!-- Basic Info Card -->
    <div class="glass-card rounded-3xl shadow-xl overflow-hidden fade-in">
        <div class="bg-gradient-to-r from-charcoal to-charcoal/80 px-8 py-5">
            <h3 class="text-xl font-bold text-light flex items-center gap-3">
                <svg class="w-6 h-6 text-sand" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
                المعلومات الأساسية
            </h3>
        </div>
        
        <div class="p-8">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- User -->
                <div>
                    <label for="user_id" class="block text-sm font-bold text-charcoal mb-2">المستخدم</label>
                    <select name="user_id" id="user_id" class="w-full px-5 py-4 border-2 border-charcoal/10 rounded-xl bg-white focus:border-sand focus:ring-4 focus:ring-sand/20 outline-none transition-all" required>
                        <option value="">اختر مستخدم</option>
                        @foreach($users as $user)
                        <option value="{{ $user->id }}" {{ old('user_id') == $user->id ? 'selected' : '' }}>{{ $user->name }}</option>
                        @endforeach
                    </select>
                </div>

                <!-- Location -->
                <div>
                    <label for="raw_location" class="block text-sm font-bold text-charcoal mb-2">الموقع</label>
                    <input type="text" name="raw_location" id="raw_location" value="{{ old('raw_location') }}" class="w-full px-5 py-4 border-2 border-charcoal/10 rounded-xl bg-white focus:border-sand focus:ring-4 focus:ring-sand/20 outline-none transition-all" placeholder="مثال: دمشق، حي الميدان" required>
                </div>

                <!-- Latitude -->
                <div>
                    <label for="latitude" class="block text-sm font-bold text-charcoal mb-2">خط العرض</label>
                    <input type="number" step="any" name="latitude" id="latitude" value="{{ old('latitude') }}" class="w-full px-5 py-4 border-2 border-charcoal/10 rounded-xl bg-white focus:border-sand focus:ring-4 focus:ring-sand/20 outline-none transition-all" placeholder="33.5138" required>
                </div>

                <!-- Longitude -->
                <div>
                    <label for="longitude" class="block text-sm font-bold text-charcoal mb-2">خط الطول</label>
                    <input type="number" step="any" name="longitude" id="longitude" value="{{ old('longitude') }}" class="w-full px-5 py-4 border-2 border-charcoal/10 rounded-xl bg-white focus:border-sand focus:ring-4 focus:ring-sand/20 outline-none transition-all" placeholder="36.2765" required>
                </div>

                <!-- Damage Level -->
                <div>
                    <label for="ai_damage_level" class="block text-sm font-bold text-charcoal mb-2">مستوى الضرر (AI)</label>
                    <select name="ai_damage_level" id="ai_damage_level" class="w-full px-5 py-4 border-2 border-charcoal/10 rounded-xl bg-white focus:border-sand focus:ring-4 focus:ring-sand/20 outline-none transition-all">
                        <option value="">غير محدد</option>
                        <option value="low" {{ old('ai_damage_level') == 'low' ? 'selected' : '' }}>منخفض</option>
                        <option value="medium" {{ old('ai_damage_level') == 'medium' ? 'selected' : '' }}>متوسط</option>
                        <option value="high" {{ old('ai_damage_level') == 'high' ? 'selected' : '' }}>عالي</option>
                        <option value="critical" {{ old('ai_damage_level') == 'critical' ? 'selected' : '' }}>حرج</option>
                    </select>
                </div>

                <!-- Status -->
                <div>
                    <label for="status" class="block text-sm font-bold text-charcoal mb-2">الحالة</label>
                    <select name="status" id="status" class="w-full px-5 py-4 border-2 border-charcoal/10 rounded-xl bg-white focus:border-sand focus:ring-4 focus:ring-sand/20 outline-none transition-all">
                        <option value="pending" {{ old('status') == 'pending' ? 'selected' : '' }}>قيد الانتظار</option>
                        <option value="processing" {{ old('status') == 'processing' ? 'selected' : '' }}>قيد المعالجة</option>
                        <option value="completed" {{ old('status') == 'completed' ? 'selected' : '' }}>مكتمل</option>
                        <option value="rejected" {{ old('status') == 'rejected' ? 'selected' : '' }}>مرفوض</option>
                    </select>
                </div>

                <!-- Description -->
                <div class="md:col-span-2">
                    <label for="raw_description" class="block text-sm font-bold text-charcoal mb-2">الوصف</label>
                    <textarea name="raw_description" id="raw_description" rows="4" class="w-full px-5 py-4 border-2 border-charcoal/10 rounded-xl bg-white focus:border-sand focus:ring-4 focus:ring-sand/20 outline-none transition-all resize-none" placeholder="اكتب وصفاً تفصيلياً للضرر...">{{ old('raw_description') }}</textarea>
                </div>
            </div>
        </div>
    </div>

    <!-- Images Card -->
    <div class="glass-card rounded-3xl shadow-xl overflow-hidden fade-in">
        <div class="bg-gradient-to-r from-sage to-sage/80 px-8 py-5">
            <h3 class="text-xl font-bold text-white flex items-center gap-3">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                </svg>
                الصور
            </h3>
        </div>
        
        <div class="p-8">
            <div class="border-2 border-dashed border-charcoal/10 rounded-2xl p-8 text-center hover:border-sage hover:bg-sage/5 transition-all">
                <div class="w-20 h-20 mx-auto rounded-2xl bg-sage/20 flex items-center justify-center mb-4">
                    <svg class="w-10 h-10 text-sage" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                    </svg>
                </div>
                <p class="text-charcoal font-bold mb-2">اسحب الصور هنا أو انقر للاختيار</p>
                <p class="text-charcoal/50 text-sm mb-4">JPG, PNG, GIF - حتى 10 صور</p>
                <input type="file" name="images[]" id="images" multiple accept="image/*" class="hidden">
                <label for="images" class="cursor-pointer inline-flex items-center gap-2 px-6 py-3 bg-sage text-white rounded-xl font-bold hover:bg-sage/80 transition-colors">
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
        <div class="bg-gradient-to-r from-sand to-sand/80 px-8 py-5">
            <h3 class="text-xl font-bold text-white flex items-center gap-3">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                </svg>
                ملف PDF
            </h3>
        </div>
        
        <div class="p-8">
            <div class="border-2 border-dashed border-charcoal/10 rounded-2xl p-8 text-center hover:border-sand hover:bg-sand/5 transition-all">
                <div class="w-20 h-20 mx-auto rounded-2xl bg-sand/20 flex items-center justify-center mb-4">
                    <svg class="w-10 h-10 text-sand" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
                    </svg>
                </div>
                <p class="text-charcoal font-bold mb-2">رفع ملف PDF جديد</p>
                <p class="text-charcoal/50 text-sm mb-4">الحد الأقصى: 20 ميجابايت</p>
                <input type="file" name="pdf_file" id="pdf_file" accept=".pdf,application/pdf" class="hidden">
                <label for="pdf_file" class="cursor-pointer inline-flex items-center gap-2 px-6 py-3 bg-sand text-white rounded-xl font-bold hover:bg-sand/80 transition-colors">
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
        <div class="bg-gradient-to-r from-sage to-sage/80 px-8 py-5">
            <h3 class="text-xl font-bold text-white flex items-center gap-3">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
                </svg>
                روابط الفيديو
            </h3>
        </div>
        
        <div class="p-8">
            <div id="video-links-container" class="space-y-3">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-lg bg-sage flex items-center justify-center flex-shrink-0">
                        <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"></path>
                        </svg>
                    </div>
                    <input type="url" name="video_links[]" placeholder="https://youtube.com/watch?v=..." class="flex-1 px-5 py-4 border-2 border-charcoal/10 rounded-xl bg-white focus:border-sage focus:ring-4 focus:ring-sage/20 outline-none transition-all">
                    <button type="button" onclick="addVideoLink()" class="w-10 h-10 rounded-lg bg-sage text-white flex items-center justify-center hover:bg-sage/80 transition-colors">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                        </svg>
                    </button>
                </div>
            </div>
            <p class="text-charcoal/50 text-sm mt-4 text-center">YouTube, Vimeo, أو أي رابط فيديو آخر</p>
        </div>
    </div>

    <!-- Action Buttons -->
    <div class="flex items-center justify-end gap-4 pt-4 fade-in">
        <a href="{{ route('admin.reports') }}" class="px-8 py-4 bg-beige text-charcoal rounded-xl font-bold hover:bg-beige/80 transition-colors flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
            إلغاء
        </a>
        <button type="submit" class="bg-gradient-to-r from-sand to-sand/80 hover:from-sand/90 hover:to-sand/70 px-8 py-4 text-white rounded-xl font-bold flex items-center gap-2 transition-all">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            حفظ التقرير
        </button>
    </div>
</form>
@endsection

@push('scripts')
<script>
    function addVideoLink() {
        const container = document.getElementById('video-links-container');
        const newDiv = document.createElement('div');
        newDiv.className = 'flex items-center gap-3 fade-in';
        newDiv.innerHTML = `
            <div class="w-10 h-10 rounded-lg bg-sage flex items-center justify-center flex-shrink-0">
                <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"></path>
                </svg>
            </div>
            <input type="url" name="video_links[]" placeholder="https://youtube.com/watch?v=..." class="flex-1 px-5 py-4 border-2 border-charcoal/10 rounded-xl bg-white focus:border-sage focus:ring-4 focus:ring-sage/20 outline-none transition-all">
            <button type="button" onclick="this.parentElement.remove()" class="w-10 h-10 rounded-lg bg-red-500 text-white flex items-center justify-center hover:bg-red-600 transition-colors">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        `;
        container.appendChild(newDiv);
    }
</script>
@endpush