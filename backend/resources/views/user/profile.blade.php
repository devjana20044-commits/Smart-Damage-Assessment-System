<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>الملف الشخصي - نظام تقييم الأضرار</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
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
        <div class="max-w-3xl mx-auto">
            <div class="mb-8">
                <h2 class="text-3xl font-bold text-white">الملف الشخصي</h2>
                <p class="text-slate-400 mt-2">إدارة معلومات حسابك</p>
            </div>

            @if(session('success'))
            <div class="mb-6 p-4 bg-green-500/20 border border-green-500/30 rounded-xl text-green-400">
                {{ session('success') }}
            </div>
            @endif

            @if($errors->any())
            <div class="mb-6 p-4 bg-red-500/20 border border-red-500/30 rounded-xl text-red-400 text-sm">
                @foreach($errors->all() as $error)
                <p>{{ $error }}</p>
                @endforeach
            </div>
            @endif

            <div class="glass-card rounded-2xl p-8 mb-6">
                <div class="flex flex-col items-center mb-8 pb-6 border-b border-slate-700/50">
                    <div class="relative group">
                        @if(auth()->user()->profile_image)
                            <img id="profile-avatar" src="{{ asset('storage/' . auth()->user()->profile_image) }}" alt="{{ auth()->user()->name }}"
                                class="w-28 h-28 rounded-full object-cover border-4 border-indigo-500/50">
                        @else
                            <div id="profile-avatar" class="w-28 h-28 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-full flex items-center justify-center">
                                <span class="text-4xl font-bold text-white">{{ strtoupper(mb_substr(auth()->user()->name, 0, 1)) }}</span>
                            </div>
                        @endif
                        <label for="profile_image" class="absolute inset-0 flex items-center justify-center bg-black/50 rounded-full opacity-0 group-hover:opacity-100 cursor-pointer transition-opacity">
                            <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                            </svg>
                        </label>
                        <input type="file" id="profile_image" name="profile_image" accept="image/*" class="hidden" onchange="previewImage(this)">
                    </div>
                    <div class="text-center mt-4">
                        <h3 class="text-xl font-bold text-white">{{ auth()->user()->name }}</h3>
                        <p class="text-slate-400 text-sm">{{ auth()->user()->email }}</p>
                        <p class="text-slate-500 text-xs mt-1">عضو منذ {{ auth()->user()->created_at->format('Y/m/d') }}</p>

                    </div>
                </div>

                <form method="POST" action="{{ route('user.profile.update') }}" enctype="multipart/form-data">
                    @csrf
                    @method('PUT')

                    <div class="space-y-6">
                        <div>
                            <label class="block text-sm font-medium text-slate-300 mb-2">الاسم</label>
                            <input type="text" name="name" value="{{ old('name', auth()->user()->name) }}" required
                                class="w-full px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all"
                                placeholder="أدخل اسمك">
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-slate-300 mb-2">البريد الإلكتروني</label>
                            <input type="email" name="email" value="{{ old('email', auth()->user()->email) }}" required
                                class="w-full px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all"
                                placeholder="أدخل بريدك الإلكتروني">
                        </div>

                        <div class="border-t border-slate-700/50 pt-6">
                            <h4 class="text-white font-semibold mb-4">تغيير كلمة المرور</h4>
                            <div class="space-y-4">
                                <div>
                                    <label class="block text-sm font-medium text-slate-300 mb-2">كلمة المرور الحالية</label>
                                    <input type="password" name="current_password"
                                        class="w-full px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all"
                                        placeholder="أدخل كلمة المرور الحالية">
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-slate-300 mb-2">كلمة المرور الجديدة</label>
                                    <input type="password" name="password"
                                        class="w-full px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all"
                                        placeholder="أدخل كلمة المرور الجديدة">
                                </div>

                                <div>
                                    <label class="block text-sm font-medium text-slate-300 mb-2">تأكيد كلمة المرور الجديدة</label>
                                    <input type="password" name="password_confirmation"
                                        class="w-full px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 transition-all"
                                        placeholder="أعد إدخال كلمة المرور الجديدة">
                                </div>
                            </div>
                        </div>

                        <div class="flex items-center gap-4 pt-4">
                            <button type="submit" class="px-8 py-3 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-semibold rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg shadow-indigo-500/25">
                                حفظ التغييرات
                            </button>
                            <a href="{{ route('user.dashboard') }}" class="px-6 py-3 text-slate-400 hover:text-white rounded-xl border border-slate-600 hover:border-indigo-500 transition-all text-sm">
                                إلغاء
                            </a>
                        </div>
                    </div>
                </form>
            </div>

            <div class="glass-card rounded-2xl p-8 mb-6">
                <div class="flex items-center justify-between">
                    <div>
                        <h4 class="text-white font-semibold">تسجيل الخروج</h4>
                        <p class="text-slate-400 text-sm mt-1">الخروج من حسابك والعودة لصفحة الدخول</p>
                    </div>
                    <form method="POST" action="{{ route('logout') }}">
                        @csrf
                        <button type="submit" class="inline-flex items-center gap-2 px-6 py-3 text-slate-300 hover:text-white rounded-xl border border-slate-600 hover:border-indigo-500 bg-slate-700/30 hover:bg-slate-700/50 transition-all text-sm font-medium">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                            </svg>
                            تسجيل الخروج
                        </button>
                    </form>
                </div>
            </div>

            <div class="glass-card rounded-2xl p-8">
                <h4 class="text-red-400 font-semibold mb-2">حذف الحساب</h4>
                <p class="text-slate-400 text-sm mb-4">سيتم حذف حسابك وجميع بلاغاتك نهائياً</p>
                <form method="POST" action="{{ route('user.profile.destroy') }}" onsubmit="return confirm('هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.')">
                    @csrf
                    @method('DELETE')
                    <div class="flex items-end gap-4">
                        <div class="flex-1">
                            <input type="password" name="password" required
                                class="w-full px-4 py-3 input-style rounded-xl text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-red-500/50 transition-all"
                                placeholder="أدخل كلمة المرور للتأكيد">
                        </div>
                        <button type="submit" class="px-6 py-3 bg-red-500/20 text-red-400 border border-red-500/30 rounded-xl hover:bg-red-500/30 hover:border-red-500 transition-all text-sm font-medium whitespace-nowrap">
                            حذف الحساب
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function previewImage(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const container = input.closest('.relative');
                    const existingImg = container.querySelector('img#profile-avatar');
                    if (existingImg) {
                        existingImg.src = e.target.result;
                    } else {
                        const div = container.querySelector('div#profile-avatar');
                        if (div) {
                            const img = document.createElement('img');
                            img.id = 'profile-avatar';
                            img.src = e.target.result;
                            img.alt = '{{ auth()->user()->name }}';
                            img.className = 'w-28 h-28 rounded-full object-cover border-4 border-indigo-500/50';
                            div.parentNode.replaceChild(img, div);
                        }
                    }
                };
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
</body>
</html>
