<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>تسجيل الدخول - نظام تقييم الأضرار</title>
@vite(['resources/css/app.css', 'resources/js/app.js'])
<style>
* { font-family: 'Cairo', sans-serif; }

.hero-bg {
position: relative;
overflow-x: hidden;
}

.hero-bg::before {
content: '';
position: absolute;
top: 0; left: 0; right: 0; bottom: 0;
background: url('/storage/imge/rock.jpg') center center / cover no-repeat;
filter: brightness(0.25) saturate(0.4);
pointer-events: none;
}

.hero-bg::after {
content: '';
position: absolute;
top: 0; left: 0; right: 0; bottom: 0;
background: linear-gradient(135deg, rgba(217, 210, 197, 0.95) 0%, rgba(217, 210, 197, 0.85) 30%, rgba(242, 242, 242, 0.9) 100%);
pointer-events: none;
}

.hero-bg > * { position: relative; z-index: 1; }

.glass {
background: rgba(255, 255, 255, 0.6);
backdrop-filter: blur(20px);
border: 1px solid rgba(45, 62, 78, 0.1);
}

.btn-primary {
background: #C9A97C;
color: white;
transition: all 0.3s ease;
position: relative;
overflow: hidden;
}

.btn-primary::before {
content: '';
position: absolute;
top: 0; left: -100%; width: 100%; height: 100%;
background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
transition: left 0.5s;
}

.btn-primary:hover::before { left: 100%; }

.btn-primary:hover {
transform: translateY(-2px);
box-shadow: 0 15px 30px rgba(194, 162, 111, 0.4);
}

.input-modern {
background: rgba(255, 255, 255, 0.8);
border: 1px solid rgba(45, 62, 78, 0.15);
color: #2D3A50;
transition: all 0.3s ease;
}

.input-modern::placeholder { color: rgba(45, 62, 78, 0.5); }

.input-modern:focus {
background: rgba(255, 255, 255, 1);
border-color: #78A9C1;
box-shadow: 0 0 0 3px rgba(141, 161, 142, 0.2);
outline: none;
}

.gradient-text {
background: linear-gradient(135deg, #C9A97C, #78A9C1);
-webkit-background-clip: text;
-webkit-text-fill-color: transparent;
background-clip: text;
}

.orb {
position: absolute;
border-radius: 50%;
filter: blur(80px);
opacity: 0.3;
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

html {
scroll-behavior: smooth;
}
</style>
</head>
<body class="hero-bg min-h-screen">
<div class="orb w-96 h-96 bg-sand top-[-10%] right-[-5%]"></div>
<div class="orb w-80 h-80 bg-charcoal bottom-[10%] left-[-5%]"></div>

<nav id="navbar" class="fixed w-full z-50 transition-all duration-300 bg-charcoal">
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
<div class="flex justify-between items-center h-20">
<div class="flex items-center gap-3">
<a href="{{ route('home') }}" class="flex items-center gap-3">
<div class="w-11 h-11 rounded-xl bg-sand text-white flex items-center justify-center shadow-lg shadow-sand/30">
<svg class="w-6 h-6 text-charcoal" fill="none" stroke="currentColor" viewBox="0 0 24 24">
<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
</svg>
</div>
<div>
<h1 class="text-lg font-bold text-light leading-tight">نظام تقييم الأضرار</h1>
<span class="text-[10px] text-sage font-medium tracking-wider">SMART DAMAGE ASSESSMENT</span>
</div>
</a>
</div>
<div class="flex items-center gap-3">
<a href="{{ route('home') }}" class="text-light/80 hover:text-light transition-colors text-sm font-medium px-4 py-2">
الصفحة الرئيسية
</a>
<a href="{{ route('register') }}" class="btn-primary px-6 py-2.5 text-sm font-semibold rounded-xl">
إنشاء حساب
</a>
</div>
</div>
</div>
</nav>

<div class="pt-28 pb-12 px-4 min-h-screen flex items-center justify-center relative z-[1]">
<div class="w-full max-w-md">
<div class="glass rounded-3xl p-8 shadow-2xl">
<div class="text-center mb-8">
<div class="w-20 h-20 bg-gradient-to-br from-sage to-sand rounded-2xl flex items-center justify-center mx-auto mb-5 shadow-xl">
<svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
</svg>
</div>
<h2 class="text-3xl font-black text-charcoal mb-2">تسجيل الدخول</h2>
<p class="text-charcoal/70">أدخل بياناتك للوصول إلى حسابك</p>
</div>

@if(session('status'))
<div class="mb-6 p-4 bg-sage/10 border border-sage/30 rounded-xl text-sage text-sm">
{{ session('status') }}
</div>
@endif

@if($errors->any())
<div class="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm">
@foreach($errors->all() as $error)<p>{{ $error }}</p>@endforeach
</div>
@endif

<form method="POST" action="{{ route('login') }}">
@csrf
<div class="space-y-5">
<div>
<label class="block text-sm font-semibold text-charcoal mb-2">البريد الإلكتروني</label>
<input type="email" name="email" value="{{ old('email') }}" required autofocus
class="w-full px-4 py-3.5 input-modern rounded-xl" placeholder="example@email.com">
</div>
<div>
<label class="block text-sm font-semibold text-charcoal mb-2">كلمة المرور</label>
<input type="password" name="password" required
class="w-full px-4 py-3.5 input-modern rounded-xl" placeholder="••••••••">
</div>
<div class="flex items-center justify-between">
<label class="flex items-center cursor-pointer">
<input type="checkbox" name="remember" class="w-4 h-4 rounded border-charcoal/20 text-sand focus:ring-sage">
<span class="ms-2 text-sm text-charcoal/70">تذكرني</span>
</label>
@if(Route::has('password.request'))
<a href="{{ route('password.request') }}" class="text-sm text-sand hover:text-sage transition-colors font-medium">
نسيت كلمة المرور؟
</a>
@endif
</div>
<button type="submit" class="w-full py-4 btn-primary text-white font-bold rounded-xl text-lg">
تسجيل الدخول
</button>
</div>
</form>

<div class="mt-8 pt-6 border-t border-charcoal/10">
<p class="text-center text-charcoal/60 text-sm mb-4">أو تابع باستخدام</p>
<div class="grid grid-cols-2 gap-3">
<a href="{{ route('admin.login') }}" class="flex items-center justify-center gap-2 py-3 px-4 bg-charcoal/5 hover:bg-charcoal/10 rounded-xl text-charcoal/70 hover:text-charcoal transition-all text-sm font-medium border border-charcoal/10">
<svg class="w-5 h-5 text-sand" fill="none" stroke="currentColor" viewBox="0 0 24 24">
<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
</svg>
<span>دخول الأدمن</span>
</a>
<a href="{{ route('register') }}" class="flex items-center justify-center gap-2 py-3 px-4 bg-charcoal/5 hover:bg-charcoal/10 rounded-xl text-charcoal/70 hover:text-charcoal transition-all text-sm font-medium border border-charcoal/10">
<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
</svg>
<span>إنشاء حساب</span>
</a>
</div>
</div>
</div>
</div>
</div>

<footer class="text-center py-6 text-charcoal/60 text-sm">
<p>© 2026 نظام تقييم الأضرار الذكي</p>
</footer>
</body>
</html>
