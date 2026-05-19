<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>نظام تقييم الأضرار الذكي</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <style>
        * {
            font-family: 'Cairo', sans-serif;
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        .hero-bg {
            position: relative;
        }

        .hero-bg::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(217, 210, 197, 0.95) 0%, rgba(217, 210, 197, 0.85) 30%, rgba(242, 242, 242, 0.9) 100%);
            pointer-events: none;
            z-index: 0;
        }

        .hero-stone {
            position: absolute;
            top: 0;
            left: 0;
            width: 55%;
            height: 200%;
            background: url('/storage/imge/rock.jpg') center center / cover no-repeat;
            filter: contrast(1.2) brightness(0.65) saturate(0.4);
            opacity: 0.4;
            pointer-events: none;
            z-index: 1;
            mix-blend-mode: multiply;
            -webkit-mask-image: linear-gradient(to right, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.7) 50%, rgba(0,0,0,0) 100%),
                              linear-gradient(to bottom, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.7) 60%, rgba(0,0,0,0) 100%);
            mask-image: linear-gradient(to right, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.7) 50%, rgba(0,0,0,0) 100%),
                        linear-gradient(to bottom, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.7) 60%, rgba(0,0,0,0) 100%);
            -webkit-mask-composite: intersect;
            mask-composite: intersect;
        }

        .hero-stone-detail {
            position: absolute;
            top: 0;
            left: 0;
            width: 55%;
            height: 200%;
            pointer-events: none;
            z-index: 2;
            opacity: 0.2;
            mix-blend-mode: overlay;
            -webkit-mask-image: linear-gradient(to right, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.7) 50%, rgba(0,0,0,0) 100%),
                              linear-gradient(to bottom, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.7) 60%, rgba(0,0,0,0) 100%);
            mask-image: linear-gradient(to right, rgba(0,0,0,0.9) 0%, rgba(0,0,0,0.7) 50%, rgba(0,0,0,0) 100%),
                        linear-gradient(to bottom, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.7) 60%, rgba(0,0,0,0) 100%);
            -webkit-mask-composite: intersect;
            mask-composite: intersect;
            background:
                radial-gradient(ellipse at 15% 25%, rgba(180,160,130,0.3) 0%, transparent 25%),
                radial-gradient(ellipse at 45% 65%, rgba(160,140,110,0.25) 0%, transparent 30%),
                radial-gradient(ellipse at 30% 85%, rgba(140,120,90,0.2) 0%, transparent 20%),
                radial-gradient(ellipse at 55% 15%, rgba(100,90,75,0.15) 0%, transparent 25%),
                radial-gradient(ellipse at 10% 55%, rgba(190,170,140,0.2) 0%, transparent 20%),
                radial-gradient(ellipse at 40% 40%, rgba(130,115,95,0.18) 0%, transparent 35%);
        }

        .orb {
            z-index: 0;
        }

.gradient-text {
background: linear-gradient(135deg, #C9A97C, #78A9C1);
-webkit-background-clip: text;
-webkit-text-fill-color: transparent;
background-clip: text;
}

.glass {
background: rgba(255, 255, 255, 0.6);
backdrop-filter: blur(20px);
border: 1px solid rgba(45, 62, 78, 0.1);
}

.glass-light {
background: rgba(255, 255, 255, 0.8);
backdrop-filter: blur(15px);
border: 1px solid rgba(45, 62, 78, 0.15);
}

        .card-hover {
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .card-hover:hover {
            transform: translateY(-8px);
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
        }

.btn-primary {
background: #C9A97C;
color: #FAFAFA !important;
transition: all 0.3s ease;
position: relative;
overflow: hidden;
}

        .btn-primary::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s;
        }

        .btn-primary:hover::before {
            left: 100%;
        }

.btn-primary:hover {
transform: translateY(-2px);
box-shadow: 0 15px 30px rgba(194, 162, 111, 0.4);
}

        .floating {
            animation: floating 6s ease-in-out infinite;
        }

        @keyframes floating {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
        }

        .pulse-ring {
            animation: pulseRing 2s ease-out infinite;
        }

@keyframes pulseRing {
0% { box-shadow: 0 0 0 0 rgba(194, 162, 111, 0.4); }
70% { box-shadow: 0 0 0 15px rgba(59, 130, 246, 0); }
100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0); }
}

        .animate-in {
            opacity: 0;
            transform: translateY(30px);
            animation: fadeInUp 0.8s ease forwards;
        }

        @keyframes fadeInUp {
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .delay-1 { animation-delay: 0.2s; }
        .delay-2 { animation-delay: 0.4s; }
        .delay-3 { animation-delay: 0.6s; }
        .delay-4 { animation-delay: 0.8s; }

        .stat-card {
            position: relative;
            overflow: hidden;
        }

        .stat-card::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: #C9A97C;
            transform: scaleX(0);
            transition: transform 0.3s ease;
        }

        .stat-card:hover::after {
            transform: scaleX(1);
        }

        .step-connector {
            position: relative;
        }

        .step-connector::after {
            content: '';
            position: absolute;
            top: 50%;
            left: -100%;
            width: 100%;
            height: 2px;
            background: linear-gradient(90deg, transparent, #C9A97C);
        }

.nav-blur {
background: rgba(45, 62, 78, 0.95);
backdrop-filter: blur(20px);
}

        .orb {
            position: absolute;
            border-radius: 50%;
            filter: blur(80px);
            opacity: 0.3;
        }

        .counter {
            font-variant-numeric: tabular-nums;
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

        .mobile-menu {
            transform: translateX(100%);
            transition: transform 0.3s ease;
        }

        .mobile-menu.active {
            transform: translateX(0);
        }

    </style>
</head>
<body class="bg-beige text-charcoal overflow-x-hidden">

<nav id="navbar" class="fixed w-full z-50 transition-all duration-300 text-light bg-charcoal">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-20">
                <div class="flex items-center gap-3">
<div class="w-11 h-11 rounded-xl bg-sand text-white flex items-center justify-center shadow-lg shadow-sand/30">
<svg class="w-6 h-6 text-charcoal" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                        </svg>
                    </div>
                    <div>
<h1 class="text-lg font-bold text-light leading-tight">نظام تقييم الأضرار</h1>
<span class="text-[10px] text-sage font-medium tracking-wider">SMART DAMAGE ASSESSMENT</span>
                    </div>
                </div>

                <div class="hidden md:flex items-center gap-8">
<a href="#home" class="text-charcoal/80 hover:text-charcoal transition-colors text-sm font-medium">الرئيسية</a>
<a href="#features" class="text-charcoal/80 hover:text-charcoal transition-colors text-sm font-medium">المميزات</a>
<a href="#how-it-works" class="text-charcoal/80 hover:text-charcoal transition-colors text-sm font-medium">كيف يعمل</a>
<a href="#stats" class="text-charcoal/80 hover:text-charcoal transition-colors text-sm font-medium">الإحصائيات</a>
                </div>

                <div class="hidden md:flex items-center gap-3">
                    <button id="langToggle" class="flex items-center gap-2 px-3 py-2 text-sm text-charcoal/80 hover:text-charcoal glass rounded-lg transition-all">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5H11m18 0h-2m-2 0h-2m-2 0h-2m-2 0h-2"/>
                        </svg>
                        <span id="langText">English</span>
                    </button>
                    @guest
<a href="{{ route('login') }}" class="px-5 py-2.5 text-sm font-medium text-charcoal glass rounded-xl hover:bg-charcoal/10 transition-all">
<span data-ar="تسجيل الدخول" data-en="Login">تسجيل الدخول</span>
</a>
<a href="{{ route('register') }}" class="btn-primary px-6 py-2.5 text-sm font-semibold text-charcoal rounded-xl shadow-lg">
                        <span data-ar="إنشاء حساب" data-en="Register">إنشاء حساب</span>
                    </a>
                    @endguest
                    @auth
                    <div class="flex items-center gap-3">
<span class="text-charcoal/80 text-sm" data-ar="مرحباً،" data-en="Welcome,">مرحباً،</span>
<span class="text-charcoal font-medium">{{ auth()->user()->name }}</span>
<form method="POST" action="{{ route('logout') }}" class="inline">
@csrf
<button type="submit" class="px-4 py-2 text-sm font-medium text-sand glass rounded-lg hover:border-sand/50 transition-all" data-ar="خروج" data-en="Logout">خروج</button>
                        </form>
                    </div>
                    @endauth
                </div>

                <button id="mobileMenuBtn" class="md:hidden text-charcoal p-2">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
                    </svg>
                </button>
            </div>
        </div>

<div id="mobileMenu" class="mobile-menu fixed top-0 right-0 w-72 h-full bg-charcoal z-50 p-6 md:hidden">
<button id="closeMobileMenu" class="absolute top-4 left-4 text-charcoal">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
            </button>
            <div class="mt-12 space-y-4">
<a href="#home" class="block text-charcoal/80 hover:text-charcoal py-2 text-lg">الرئيسية</a>
<a href="#features" class="block text-charcoal/80 hover:text-charcoal py-2 text-lg">المميزات</a>
<a href="#how-it-works" class="block text-charcoal/80 hover:text-charcoal py-2 text-lg">كيف يعمل</a>
<a href="#stats" class="block text-charcoal/80 hover:text-charcoal py-2 text-lg">الإحصائيات</a>
<hr class="border-charcoal/10">
@guest
<a href="{{ route('login') }}" class="block text-center py-3 glass rounded-xl text-charcoal font-medium">تسجيل الدخول</a>
<a href="{{ route('register') }}" class="block text-center py-3 btn-primary rounded-xl text-charcoal font-semibold">إنشاء حساب</a>
                @endguest
            </div>
        </div>
    </nav>

    <section id="home" class="hero-bg min-h-screen relative flex items-center">
<div class="orb w-96 h-96 bg-sand top-[-10%] right-[-5%]"></div>
<div class="orb w-80 h-80 bg-charcoal bottom-[10%] left-[-5%]"></div>
<div class="orb w-64 h-64 bg-sage top-[40%] right-[30%] opacity-10"></div>

<div class="hero-stone"></div>
<div class="hero-stone-detail"></div>

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 pt-20">
            <div class="grid lg:grid-cols-2 gap-16 items-center">
                <div class="animate-in">
                    <div class="inline-flex items-center gap-2 px-5 py-2.5 glass-light rounded-full mb-8">
<span class="w-2.5 h-2.5 bg-sage rounded-full pulse-ring"></span>
<span class="text-sage text-sm font-medium" data-ar="النظام متاح الآن • معالجة فورية بالذكاء الاصطناعي" data-en="System Online • Instant AI Processing">النظام متاح الآن • معالجة فورية بالذكاء الاصطناعي</span>
                    </div>

                    <h1 class="text-4xl sm:text-5xl lg:text-6xl xl:text-7xl font-black leading-tight">
                        <span class="block text-charcoal" data-ar="نظام تقييم" data-en="Smart Damage">نظام تقييم</span>
                        <span class="block gradient-text mt-2" data-ar="الأضرار الذكي" data-en="Assessment System">الأضرار الذكي</span>
                    </h1>

                    <p class="mt-8 text-lg text-charcoal/80 leading-relaxed max-w-xl" data-ar="منصة متطورة تعتمد على الذكاء الاصطناعي لتحليل وتقييم الأضرار فورياً. ارفع تقريراً بالصور والموقع الجغرافي واحصل على تقييم دقيق خلال ثوانٍ." data-en="An advanced AI-powered platform for instant damage analysis and assessment. Upload reports with images and GPS location to get accurate evaluation within seconds.">
                        منصة متطورة تعتمد على الذكاء الاصطناعي لتحليل وتقييم الأضرار فورياً. ارفع تقريراً بالصور والموقع الجغرافي واحصل على تقييم دقيق خلال ثوانٍ.
                    </p>

                    <div class="mt-10 flex flex-col sm:flex-row gap-4">
                        @guest
                        <a href="{{ route('register') }}" class="btn-primary inline-flex items-center justify-center px-8 py-4 text-lg font-bold rounded-2xl">
                            <span data-ar="ابدأ الآن مجاناً" data-en="Get Started Free">ابدأ الآن مجاناً</span>
                            <svg class="w-5 h-5 mr-2 rtl:mr-0 rtl:ml-2 rotate-180 rtl:rotate-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
                            </svg>
                        </a>
                        <a href="#how-it-works" class="inline-flex items-center justify-center px-8 py-4 text-lg font-semibold text-charcoal glass rounded-2xl hover:bg-charcoal/10 transition-all">
                            <svg class="w-5 h-5 ml-2 rtl:ml-0 rtl:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"/>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                            <span data-ar="شاهد كيف يعمل" data-en="See How It Works">شاهد كيف يعمل</span>
                        </a>
                        @endguest
                        @auth
                        <a href="{{ auth()->user()->role === 'admin' ? route('admin.dashboard') : route('user.dashboard') }}" class="btn-primary inline-flex items-center justify-center px-8 py-4 text-lg font-bold rounded-2xl">
                            <span data-ar="الذهاب للوحة التحكم" data-en="Go to Dashboard">الذهاب للوحة التحكم</span>
                            <svg class="w-5 h-5 mr-2 rtl:mr-0 rtl:ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
                            </svg>
                        </a>
                        @endauth
                    </div>

                    <div class="mt-14 flex items-center gap-8">
                        <div class="flex -space-x-3 rtl:space-x-reverse">
<div class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 border-2 border-beige flex items-center justify-center text-xs font-bold">م</div>
<div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-400 to-purple-600 border-2 border-beige flex items-center justify-center text-xs font-bold">أ</div>
<div class="w-10 h-10 rounded-full bg-gradient-to-br from-pink-400 to-pink-600 border-2 border-beige flex items-center justify-center text-xs font-bold">س</div>
<div class="w-10 h-10 rounded-full bg-gradient-to-br from-emerald-400 to-emerald-600 border-2 border-beige flex items-center justify-center text-xs font-bold text-charcoal">+</div>
                        </div>
                        <div>
                            <div class="flex items-center gap-1">
<svg class="w-4 h-4 text-sand" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
<svg class="w-4 h-4 text-sand" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
<svg class="w-4 h-4 text-sand" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
<svg class="w-4 h-4 text-sand" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
<svg class="w-4 h-4 text-sand" fill="currentColor" viewBox="0 0 20 20"><path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/></svg>
</div>
<p class="text-charcoal/70 text-sm mt-1" data-ar="موثوق من مئات المستخدمين" data-en="Trusted by hundreds of users">موثوق من مئات المستخدمين</p>
                        </div>
                    </div>
                </div>

                <div class="animate-in delay-2 hidden lg:block">
                    <div class="relative floating">
                        <div class="glass rounded-3xl p-2 shadow-2xl shadow-sand/20 overflow-hidden">
                            <img src="{{ asset('storage/imge/nn.png') }}" alt="Smart Damage Assessment" class="rounded-2xl w-full h-auto object-cover" style="max-height: 520px;" loading="lazy" decoding="async">
                        </div>

                        <div class="absolute -top-4 -right-4 glass rounded-2xl p-3 shadow-xl animate-in delay-3">
                            <div class="flex items-center gap-2">
                                <div class="w-8 h-8 rounded-lg bg-emerald-500/20 flex items-center justify-center">
                                    <svg class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                    </svg>
                                </div>
                                <span class="text-xs text-emerald-300 font-medium">AI جاهز</span>
                            </div>
                        </div>

                        <div class="absolute -bottom-4 -left-4 glass rounded-2xl p-3 shadow-xl animate-in delay-4">
                            <div class="flex items-center gap-2">
                                <div class="w-8 h-8 rounded-lg bg-blue-500/20 flex items-center justify-center">
                                    <svg class="w-4 h-4 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                                    </svg>
                                </div>
                                <span class="text-xs text-blue-300 font-medium">GPS نشط</span>
                            </div>
                        </div>
                    </div>
                </div>

<div class="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
<svg class="w-6 h-6 text-charcoal/60" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3"/>
            </svg>
        </div>
    </section>

    <section id="features" class="pt-8 pb-24 relative">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-20">
                <div class="inline-flex items-center gap-2 px-4 py-2 glass-light rounded-full mb-6">
                    <svg class="w-4 h-4 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
                    </svg>
                    <span class="text-sand text-sm font-medium" data-ar="المميزات الرئيسية" data-en="Key Features">المميزات الرئيسية</span>
                </div>
                <h2 class="text-3xl sm:text-4xl lg:text-5xl font-black text-charcoal mb-6">
                    <span data-ar="حل متكامل لتقييم" data-en="Complete Solution for">حل متكامل لتقييم</span>
                    <br>
                    <span class="gradient-text" data-ar="الأضرار بكفاءة عالية" data-en="Efficient Damage Assessment">الأضرار بكفاءة عالية</span>
                </h2>
                <p class="text-charcoal/70 max-w-2xl mx-auto text-lg" data-ar="نظام يجمع بين أحدث تقنيات الذكاء الاصطناعي والخرائط التفاعلية لتقديم حل شامل لإدارة الأزمات" data-en="A system combining the latest AI technology and interactive maps for a comprehensive crisis management solution">
                    نظام يجمع بين أحدث تقنيات الذكاء الاصطناعي والخرائط التفاعلية لتقديم حل شامل لإدارة الأزمات
                </p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div class="card-hover glass rounded-2xl p-8 group">
                    <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-blue-500/20 to-blue-600/20 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform border border-blue-500/20">
                        <svg class="w-7 h-7 text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"/>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-charcoal mb-3" data-ar="تحليل Gemini AI" data-en="Gemini AI Analysis">تحليل Gemini AI</h3>
                    <p class="text-charcoal/70 leading-relaxed" data-ar="محرك ذكاء اصطناعي متقدم يحلل صور الأضرار تلقائياً ويحدد مستوى الضرر من 1 إلى 10 مع وصف تفصيلي دقيق" data-en="Advanced AI engine that automatically analyzes damage images and determines damage level from 1-10 with accurate detailed description">
                        محرك ذكاء اصطناعي متقدم يحلل صور الأضرار تلقائياً ويحدد مستوى الضرر من 1 إلى 10 مع وصف تفصيلي دقيق
                    </p>
                </div>

                <div class="card-hover glass rounded-2xl p-8 group">
                    <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-emerald-500/20 to-emerald-600/20 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform border border-emerald-500/20">
                        <svg class="w-7 h-7 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-charcoal mb-3" data-ar="تتبع GPS دقيق" data-en="Precise GPS Tracking">تتبع GPS دقيق</h3>
                    <p class="text-charcoal/70 leading-relaxed" data-ar="ترميز جغرافي تلقائي مع توحيد العناوين السورية لتنسيق دقيق لجهود الإغاثة والتدخل السريع" data-en="Automatic geocoding with normalized Syrian addresses for precise coordination of relief and rapid intervention efforts">
                        ترميز جغرافي تلقائي مع توحيد العناوين السورية لتنسيق دقيق لجهود الإغاثة والتدخل السريع
                    </p>
                </div>

                <div class="card-hover glass rounded-2xl p-8 group">
                    <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-purple-500/20 to-purple-600/20 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform border border-purple-500/20">
                        <svg class="w-7 h-7 text-purple-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-charcoal mb-3" data-ar="لوحة تحكم متقدمة" data-en="Advanced Dashboard">لوحة تحكم متقدمة</h3>
                    <p class="text-charcoal/70 leading-relaxed" data-ar="واجهة إدارية شاملة مع إحصائيات لحظية وخرائط تفاعلية وإدارة كاملة لجميع التقارير" data-en="Comprehensive admin interface with real-time statistics, interactive maps, and complete management of all reports">
                        واجهة إدارية شاملة مع إحصائيات لحظية وخرائط تفاعلية وإدارة كاملة لجميع التقارير
                    </p>
                </div>

                <div class="card-hover glass rounded-2xl p-8 group">
                    <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-orange-500/20 to-orange-600/20 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform border border-orange-500/20">
                        <svg class="w-7 h-7 text-orange-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-charcoal mb-3" data-ar="تطبيق موبايل" data-en="Mobile App">تطبيق موبايل</h3>
                    <p class="text-charcoal/70 leading-relaxed" data-ar="تطبيق أصلي لـ iOS و Android للإبلاغ الفوري عن الأضرار من الميدان مع رفع الصور مباشرة" data-en="Native iOS and Android app for instant damage reporting from the field with direct image upload">
                        تطبيق أصلي لـ iOS و Android للإبلاغ الفوري عن الأضرار من الميدان مع رفع الصور مباشرة
                    </p>
                </div>

                <div class="card-hover glass rounded-2xl p-8 group">
                    <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-pink-500/20 to-pink-600/20 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform border border-pink-500/20">
                        <svg class="w-7 h-7 text-pink-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-charcoal mb-3" data-ar="رفع متعدد الوسائط" data-en="Multimedia Upload">رفع متعدد الوسائط</h3>
                    <p class="text-charcoal/70 leading-relaxed" data-ar="دعم رفع الصور والفيديوهات بجودة عالية مع ضغط تلقائي ذكي للملفات الكبيرة" data-en="Support for high-quality image and video uploads with smart automatic compression for large files">
                        دعم رفع الصور والفيديوهات بجودة عالية مع ضغط تلقائي ذكي للملفات الكبيرة
                    </p>
                </div>

                <div class="card-hover glass rounded-2xl p-8 group">
                    <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-cyan-500/20 to-cyan-600/20 flex items-center justify-center mb-6 group-hover:scale-110 transition-transform border border-cyan-500/20">
                        <svg class="w-7 h-7 text-cyan-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                        </svg>
                    </div>
                    <h3 class="text-xl font-bold text-charcoal mb-3" data-ar="آمن وسريع" data-en="Secure & Fast">آمن وسريع</h3>
                    <p class="text-charcoal/70 leading-relaxed" data-ar="معالجة عبر طوابير Redis مع تشفير كامل للبيانات وحماية متقدمة للمعلومات الحساسة" data-en="Redis queue-based processing with full data encryption and advanced protection for sensitive information">
                        معالجة عبر طوابير Redis مع تشفير كامل للبيانات وحماية متقدمة للمعلومات الحساسة
                    </p>
                </div>
            </div>
        </div>
    </section>

    <section id="how-it-works" class="py-24 relative">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            <div class="text-center mb-20">
                <div class="inline-flex items-center gap-2 px-4 py-2 glass-light rounded-full mb-6">
                    <svg class="w-4 h-4 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                    </svg>
                    <span class="text-sand text-sm font-medium" data-ar="كيف يعمل النظام" data-en="How It Works">كيف يعمل النظام</span>
                </div>
                <h2 class="text-3xl sm:text-4xl lg:text-5xl font-black text-charcoal mb-6">
                    <span data-ar="ثلاث خطوات بسيطة" data-en="Three Simple Steps">ثلاث خطوات بسيطة</span>
                </h2>
                <p class="text-charcoal/70 max-w-2xl mx-auto text-lg" data-ar="عملية سهلة وسريعة لتقييم الأضرار والحصول على نتائج دقيقة" data-en="An easy and fast process for damage assessment with accurate results">
                    عملية سهلة وسريعة لتقييم الأضرار والحصول على نتائج دقيقة
                </p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-8 relative">
                <div class="hidden md:block absolute top-1/2 left-[33%] right-[33%] h-0.5 bg-gradient-to-r from-blue-500/30 via-purple-500/30 to-pink-500/30 -translate-y-1/2"></div>

                <div class="card-hover glass rounded-2xl p-8 text-center relative z-10">
                    <div class="w-20 h-20 rounded-full bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center mx-auto mb-6 shadow-lg shadow-blue-500/30">
                        <span class="text-3xl font-black text-white">1</span>
                    </div>
                    <h3 class="text-xl font-bold text-charcoal mb-3" data-ar="ارفع التقرير" data-en="Submit Report">ارفع التقرير</h3>
                    <p class="text-charcoal/70" data-ar="التقط صورة للضرر وحدد الموقع الجغرافي تلقائياً أو يدوياً مع إضافة وصف للحالة" data-en="Take a photo of the damage and set the geographic location automatically or manually with a description">
                        التقط صورة للضرر وحدد الموقع الجغرافي تلقائياً أو يدوياً مع إضافة وصف للحالة
                    </p>
                </div>

                <div class="card-hover glass rounded-2xl p-8 text-center relative z-10">
                    <div class="w-20 h-20 rounded-full bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center mx-auto mb-6 shadow-lg shadow-purple-500/30">
                        <span class="text-3xl font-black text-white">2</span>
                    </div>
                    <h3 class="text-xl font-bold text-charcoal mb-3" data-ar="تحليل AI فوري" data-en="Instant AI Analysis">تحليل AI فوري</h3>
                    <p class="text-charcoal/70" data-ar="يقوم محرك Gemini AI بتحليل الصورة وتحديد مستوى الضرر وتوحيد الموقع الجغرافي فوراً" data-en="Gemini AI engine analyzes the image, determines damage level, and normalizes geographic location instantly">
                        يقوم محرك Gemini AI بتحليل الصورة وتحديد مستوى الضرر وتوحيد الموقع الجغرافي فوراً
                    </p>
                </div>

                <div class="card-hover glass rounded-2xl p-8 text-center relative z-10">
                    <div class="w-20 h-20 rounded-full bg-gradient-to-br from-pink-500 to-pink-600 flex items-center justify-center mx-auto mb-6 shadow-lg shadow-pink-500/30">
                        <span class="text-3xl font-black text-white">3</span>
                    </div>
                    <h3 class="text-xl font-bold text-charcoal mb-3" data-ar="استلم النتائج" data-en="Get Results">استلم النتائج</h3>
                    <p class="text-charcoal/70" data-ar="احصل على تقييم شامل مع مستوى الضرر والوصف والموقع الموحد على الخريطة التفاعلية" data-en="Get a comprehensive assessment with damage level, description, and normalized location on the interactive map">
                        احصل على تقييم شامل مع مستوى الضرر والوصف والموقع الموحد على الخريطة التفاعلية
                    </p>
                </div>
            </div>
        </div>
    </section>

    <section id="stats" class="py-24 relative">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-20">
                <div class="inline-flex items-center gap-2 px-4 py-2 glass-light rounded-full mb-6">
                    <svg class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                    </svg>
                    <span class="text-sage text-sm font-medium" data-ar="بالأرقام" data-en="By The Numbers">بالأرقام</span>
                </div>
                <h2 class="text-3xl sm:text-4xl lg:text-5xl font-black text-charcoal mb-6">
                    <span data-ar="تأثير حقيقي" data-en="Real Impact">تأثير حقيقي</span>
                </h2>
            </div>

            <div class="grid grid-cols-2 lg:grid-cols-4 gap-6">
                <div class="stat-card card-hover glass rounded-2xl p-8 text-center">
                    <div class="w-14 h-14 rounded-2xl bg-blue-500/10 flex items-center justify-center mx-auto mb-4">
                        <svg class="w-7 h-7 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                        </svg>
                    </div>
                    <div class="text-4xl font-black text-charcoal counter" data-target="500">0</div>
                    <div class="text-sm text-charcoal/70 mt-2" data-ar="تقرير تم تحليله" data-en="Reports Analyzed">تقرير تم تحليله</div>
                </div>

                <div class="stat-card card-hover glass rounded-2xl p-8 text-center">
                    <div class="w-14 h-14 rounded-2xl bg-emerald-500/10 flex items-center justify-center mx-auto mb-4">
                        <svg class="w-7 h-7 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                        </svg>
                    </div>
                    <div class="text-4xl font-black text-charcoal"><span class="counter" data-target="3">0</span>s</div>
                    <div class="text-sm text-charcoal/70 mt-2" data-ar="متوسط وقت التحليل" data-en="Avg. Analysis Time">متوسط وقت التحليل</div>
                </div>

                <div class="stat-card card-hover glass rounded-2xl p-8 text-center">
                    <div class="w-14 h-14 rounded-2xl bg-purple-500/10 flex items-center justify-center mx-auto mb-4">
                        <svg class="w-7 h-7 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
                        </svg>
                    </div>
                    <div class="text-4xl font-black text-charcoal counter" data-target="14">0</div>
                    <div class="text-sm text-charcoal/70 mt-2" data-ar="محافظة مغطاة" data-en="Governorates Covered">محافظة مغطاة</div>
                </div>

                <div class="stat-card card-hover glass rounded-2xl p-8 text-center">
                    <div class="w-14 h-14 rounded-2xl bg-pink-500/10 flex items-center justify-center mx-auto mb-4">
                        <svg class="w-7 h-7 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                        </svg>
                    </div>
                    <div class="text-4xl font-black text-charcoal counter" data-target="200">0</div>
                    <div class="text-sm text-charcoal/70 mt-2" data-ar="مستخدم نشط" data-en="Active Users">مستخدم نشط</div>
                </div>
            </div>
        </div>
    </section>

    <section class="py-24 relative">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
            <div class="glass rounded-3xl p-12 md:p-16 relative overflow-hidden">
                <div class="absolute top-0 right-0 w-64 h-64 bg-blue-500/10 rounded-full blur-3xl"></div>
                <div class="absolute bottom-0 left-0 w-64 h-64 bg-purple-500/10 rounded-full blur-3xl"></div>

                <div class="relative z-10">
                    <h2 class="text-3xl sm:text-4xl font-black text-charcoal mb-6">
                        <span data-ar="جاهز للمساهمة؟" data-en="Ready to Contribute?">جاهز للمساهمة؟</span>
                    </h2>
                    <p class="text-charcoal/70 text-lg mb-10 max-w-xl mx-auto" data-ar="انضم إلينا في جهود الإغاثة والتقييم. ساعد في توثيق الأضرار وتسهيل عمليات المساعدة." data-en="Join us in relief and assessment efforts. Help document damage and facilitate assistance operations.">
                        انضم إلينا في جهود الإغاثة والتقييم. ساعد في توثيق الأضرار وتسهيل عمليات المساعدة.
                    </p>
                    <div class="flex flex-col sm:flex-row gap-4 justify-center">
                        @guest
                        <a href="{{ route('register') }}" class="btn-primary inline-flex items-center justify-center px-10 py-4 text-lg font-bold rounded-2xl">
                            <span data-ar="ابدأ الآن" data-en="Start Now">ابدأ الآن</span>
                            <svg class="w-5 h-5 mr-2 rtl:mr-0 rtl:ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
                            </svg>
                        </a>
                        <a href="{{ route('login') }}" class="inline-flex items-center justify-center px-10 py-4 text-lg font-semibold text-charcoal glass rounded-2xl hover:bg-charcoal/10 transition-all">
                            <span data-ar="لديك حساب؟ سجل دخول" data-en="Have an account? Login">لديك حساب؟ سجل دخول</span>
                        </a>
                        @endguest
                        @auth
                        <a href="{{ auth()->user()->role === 'admin' ? route('admin.dashboard') : route('user.dashboard') }}" class="btn-primary inline-flex items-center justify-center px-10 py-4 text-lg font-bold rounded-2xl">
                            <span data-ar="الذهاب للوحة التحكم" data-en="Go to Dashboard">الذهاب للوحة التحكم</span>
                        </a>
                        @endauth
                    </div>
                </div>
            </div>
        </div>
    </section>

    <footer class="border-t border-charcoal/10 pt-16 pb-8">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-12 mb-12">
                <div class="md:col-span-2">
                    <div class="flex items-center gap-3 mb-4">
                        <div class="w-11 h-11 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                            </svg>
                        </div>
                        <div>
                            <h3 class="text-charcoal font-bold text-lg">نظام تقييم الأضرار</h3>
                            <p class="text-charcoal/50 text-xs">Smart Damage Assessment System</p>
                        </div>
                    </div>
                    <p class="text-charcoal/70 text-sm leading-relaxed max-w-md" data-ar="نظام ذكي متطور يعتمد على الذكاء الاصطناعي لتقييم وتحليل الأضرار، يهدف لدعم جهود الإغاثة والطوارئ في سوريا." data-en="An advanced AI-powered system for damage assessment and analysis, aimed at supporting relief and emergency efforts in Syria.">
                        نظام ذكي متطور يعتمد على الذكاء الاصطناعي لتقييم وتحليل الأضرار، يهدف لدعم جهود الإغاثة والطوارئ في سوريا.
                    </p>
                </div>

                <div>
                    <h4 class="text-charcoal font-semibold mb-4" data-ar="روابط سريعة" data-en="Quick Links">روابط سريعة</h4>
                    <ul class="space-y-3">
                        <li><a href="#home" class="text-charcoal/60 hover:text-sand transition-colors text-sm" data-ar="الرئيسية" data-en="Home">الرئيسية</a></li>
                        <li><a href="#features" class="text-charcoal/60 hover:text-sand transition-colors text-sm" data-ar="المميزات" data-en="Features">المميزات</a></li>
                        <li><a href="#how-it-works" class="text-charcoal/60 hover:text-sand transition-colors text-sm" data-ar="كيف يعمل" data-en="How It Works">كيف يعمل</a></li>
                        <li><a href="#stats" class="text-charcoal/60 hover:text-sand transition-colors text-sm" data-ar="الإحصائيات" data-en="Statistics">الإحصائيات</a></li>
                    </ul>
                </div>

                <div>
                    <h4 class="text-charcoal font-semibold mb-4" data-ar="التقنيات" data-en="Technologies">التقنيات</h4>
                    <div class="flex flex-wrap gap-2">
                        <span class="px-3 py-1.5 glass rounded-lg text-charcoal/70 text-xs font-medium">Laravel</span>
                        <span class="px-3 py-1.5 glass rounded-lg text-charcoal/70 text-xs font-medium">Flutter</span>
                        <span class="px-3 py-1.5 glass rounded-lg text-charcoal/70 text-xs font-medium">Gemini AI</span>
                        <span class="px-3 py-1.5 glass rounded-lg text-charcoal/70 text-xs font-medium">MySQL</span>
                        <span class="px-3 py-1.5 glass rounded-lg text-charcoal/70 text-xs font-medium">Tailwind</span>
                        <span class="px-3 py-1.5 glass rounded-lg text-charcoal/70 text-xs font-medium">Redis</span>
                    </div>
                </div>
            </div>

            <div class="border-t border-charcoal/10 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
                <p class="text-charcoal/50 text-sm" data-ar="© 2026 نظام تقييم الأضرار الذكي. جميع الحقوق محفوظة." data-en="© 2026 Smart Damage Assessment System. All rights reserved.">© 2026 نظام تقييم الأضرار الذكي. جميع الحقوق محفوظة.</p>
                <div class="flex items-center gap-2 text-charcoal/50 text-sm">
                    <span data-ar="بدعم من" data-en="Powered by">بدعم من</span>
                    <span class="font-semibold text-sand">Google Gemini AI</span>
                </div>
            </div>
        </div>
    </footer>

    <script>
        let currentLang = localStorage.getItem('lang') || 'ar';

        function applyLanguage(lang) {
            const html = document.documentElement;
            const langText = document.getElementById('langText');

            html.setAttribute('lang', lang);
            html.setAttribute('dir', lang === 'ar' ? 'rtl' : 'ltr');
            langText.textContent = lang === 'ar' ? 'English' : 'العربية';

            document.querySelectorAll('[data-' + lang + ']').forEach(el => {
                el.textContent = el.getAttribute('data-' + lang);
            });
        }

        applyLanguage(currentLang);

        document.getElementById('langToggle').addEventListener('click', function() {
            currentLang = currentLang === 'ar' ? 'en' : 'ar';
            localStorage.setItem('lang', currentLang);
            applyLanguage(currentLang);
        });

        window.addEventListener('scroll', function() {
            const navbar = document.getElementById('navbar');
            if (window.scrollY > 50) {
                navbar.classList.add('nav-blur', 'border-b', 'border-white/5');
            } else {
                navbar.classList.remove('nav-blur', 'border-b', 'border-white/5');
            }
        });

        function animateCounters() {
            const counters = document.querySelectorAll('.counter');
            counters.forEach(counter => {
                const target = parseInt(counter.getAttribute('data-target'));
                const duration = 2000;
                const step = target / (duration / 16);
                let current = 0;

                const timer = setInterval(() => {
                    current += step;
                    if (current >= target) {
                        current = target;
                        clearInterval(timer);
                    }
                    counter.textContent = Math.floor(current);
                }, 16);
            });
        }

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    animateCounters();
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.5 });

        const statsSection = document.getElementById('stats');
        if (statsSection) observer.observe(statsSection);

        document.getElementById('mobileMenuBtn').addEventListener('click', function() {
            document.getElementById('mobileMenu').classList.add('active');
        });

        document.getElementById('closeMobileMenu').addEventListener('click', function() {
            document.getElementById('mobileMenu').classList.remove('active');
        });

        document.querySelectorAll('#mobileMenu a[href^="#"]').forEach(link => {
            link.addEventListener('click', function() {
                document.getElementById('mobileMenu').classList.remove('active');
            });
        });

    </script>
</body>
</html>
