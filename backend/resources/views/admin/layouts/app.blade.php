<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'نظام تقييم الأضرار الذكي')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <style>
        * {
            font-family: 'Cairo', sans-serif;
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(45, 62, 78, 0.08);
            transition: all 0.3s ease;
        }

        .glass-card:hover {
            box-shadow: 0 20px 40px -12px rgba(45, 62, 78, 0.12);
        }

        .sidebar-item {
            transition: all 0.3s ease;
        }

        .sidebar-item:hover {
            background: rgba(194, 162, 111, 0.15);
            transform: translateX(-5px);
        }

        .sidebar-item.active {
            background: linear-gradient(135deg, #C9A97C 0%, #78A9C1 100%);
            color: white;
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
    @stack('styles')
</head>
<body class="bg-beige min-h-screen">
    <div class="flex min-h-screen">
        @include('admin.partials.sidebar')

        <main class="flex-1 mr-72 p-8">
            @yield('content')
        </main>
    </div>

    @stack('scripts')
</body>
</html>
