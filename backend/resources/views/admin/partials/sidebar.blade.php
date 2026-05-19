<aside class="w-72 bg-charcoal shadow-2xl fixed h-full overflow-y-auto">
    <div class="p-6 border-b border-charcoal/50">
        <div class="flex items-center gap-3">
            <a href="{{ route('home') }}" class="flex items-center gap-3">
                <div class="w-12 h-12 rounded-xl bg-sand flex items-center justify-center shadow-lg shadow-sand/30">
                    <svg class="w-7 h-7 text-charcoal" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                    </svg>
                </div>
                <div>
                    <h1 class="text-light text-lg font-bold leading-tight">نظام تقييم الأضرار</h1>
                    <span class="text-sage text-[10px] font-medium tracking-wider">SMART DAMAGE ASSESSMENT</span>
                </div>
            </a>
        </div>
    </div>

    <nav class="p-4 space-y-2">
        <a href="{{ route('admin.dashboard') }}" class="sidebar-item flex items-center gap-3 px-4 py-3 text-light/70 rounded-xl {{ request()->routeIs('admin.dashboard') ? 'active' : 'hover:text-light' }}">
            <div class="w-10 h-10 rounded-lg {{ request()->routeIs('admin.dashboard') ? 'bg-white/20' : 'bg-charcoal/60' }} flex items-center justify-center">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                </svg>
            </div>
            <span class="font-medium">لوحة القيادة</span>
        </a>

        <a href="{{ route('admin.map') }}" class="sidebar-item flex items-center gap-3 px-4 py-3 text-light/70 rounded-xl {{ request()->routeIs('admin.map') ? 'active' : 'hover:text-light' }}">
            <div class="w-10 h-10 rounded-lg {{ request()->routeIs('admin.map') ? 'bg-white/20' : 'bg-charcoal/60' }} flex items-center justify-center">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"></path>
                </svg>
            </div>
            <span class="font-medium">الخريطة</span>
        </a>

        <a href="{{ route('admin.reports') }}" class="sidebar-item flex items-center gap-3 px-4 py-3 text-light/70 rounded-xl {{ (request()->routeIs('admin.reports') || request()->routeIs('admin.reports.*')) ? 'active' : 'hover:text-light' }}">
            <div class="w-10 h-10 rounded-lg {{ (request()->routeIs('admin.reports') || request()->routeIs('admin.reports.*')) ? 'bg-white/20' : 'bg-charcoal/60' }} flex items-center justify-center">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
            </div>
            <span class="font-medium">التقارير</span>
        </a>

        <a href="{{ route('admin.reports.create') }}" class="sidebar-item flex items-center gap-3 px-4 py-3 text-light/70 rounded-xl {{ request()->routeIs('admin.reports.create') ? 'active' : 'hover:text-light' }}">
            <div class="w-10 h-10 rounded-lg {{ request()->routeIs('admin.reports.create') ? 'bg-white/20' : 'bg-charcoal/60' }} flex items-center justify-center">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                </svg>
            </div>
            <span class="font-medium">تقرير جديد</span>
        </a>
    </nav>

    <div class="p-4 border-t border-charcoal/50 mt-4">
        <div class="bg-charcoal/50 rounded-xl p-4">
            <h3 class="text-sage text-xs font-bold mb-3 uppercase tracking-wider">إحصائيات سريعة</h3>
            <div class="grid grid-cols-2 gap-3">
                <div class="bg-charcoal/60 rounded-lg p-3 text-center">
                    <p class="text-2xl font-bold text-sand">{{ \App\Models\Report::count() }}</p>
                    <p class="text-xs text-light/50">تقرير</p>
                </div>
                <div class="bg-charcoal/60 rounded-lg p-3 text-center">
                    <p class="text-2xl font-bold text-sage">{{ \App\Models\User::count() }}</p>
                    <p class="text-xs text-light/50">مستخدم</p>
                </div>
            </div>
        </div>
    </div>

    <div class="absolute bottom-0 left-0 right-0 p-4 border-t border-charcoal/50 bg-charcoal">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-sand to-sage flex items-center justify-center text-white font-bold shadow-lg">
                {{ auth()->user()->name[0] ?? 'م' }}
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-light text-sm font-medium truncate">{{ auth()->user()->name ?? 'المستخدم' }}</p>
                <p class="text-light/40 text-xs truncate">{{ auth()->user()->email ?? '' }}</p>
            </div>
            <form action="{{ route('logout') }}" method="POST" style="display: inline;">
                @csrf
                <button type="submit" class="w-8 h-8 rounded-lg bg-sand/20 text-sand flex items-center justify-center hover:bg-sand/30 transition-colors" title="تسجيل الخروج">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                    </svg>
                </button>
            </form>
        </div>
    </div>
</aside>
