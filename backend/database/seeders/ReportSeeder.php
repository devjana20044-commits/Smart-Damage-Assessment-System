<?php

namespace Database\Seeders;

use App\Models\Report;
use App\Models\User;
use Illuminate\Database\Seeder;

class ReportSeeder extends Seeder
{
    /**
     * Syrian cities with coordinates
     */
    private $syrianLocations = [
        ['city' => 'دمشق', 'latitude' => 33.5138, 'longitude' => 36.2765],
        ['city' => 'حلب', 'latitude' => 36.2012, 'longitude' => 37.1612],
        ['city' => 'حمص', 'latitude' => 34.7264, 'longitude' => 36.7234],
        ['city' => 'حماة', 'latitude' => 35.1318, 'longitude' => 36.7579],
        ['city' => 'اللاذقية', 'latitude' => 35.5256, 'longitude' => 35.8194],
        ['city' => 'طرطوس', 'latitude' => 34.8892, 'longitude' => 35.8853],
        ['city' => 'الرقة', 'latitude' => 35.9506, 'longitude' => 38.9968],
        ['city' => 'دير الزور', 'latitude' => 35.3336, 'longitude' => 40.1454],
        ['city' => 'إدلب', 'latitude' => 35.9319, 'longitude' => 36.6344],
        ['city' => 'درعا', 'latitude' => 32.6253, 'longitude' => 36.1039],
        ['city' => 'السويداء', 'latitude' => 32.6972, 'longitude' => 36.5678],
        ['city' => 'القنيطرة', 'latitude' => 33.1208, 'longitude' => 35.8250],
        ['city' => 'حلب الشمالي', 'latitude' => 36.3500, 'longitude' => 37.2000],
        ['city' => 'ريف دمشق', 'latitude' => 33.4500, 'longitude' => 36.3000],
        ['city' => 'ريف حمص', 'latitude' => 34.8000, 'longitude' => 36.8000],
    ];

    private $damageLevels = ['low', 'medium', 'high', 'critical'];

    private $statuses = ['pending', 'processing', 'completed', 'rejected'];

    private $descriptions = [
        'تضرر في المباني السكنية بسبب القصف',
        'أضرار في البنية التحتية للكهرباء',
        'تضرر شبكة المياه الرئيسية',
        'أضرار جسيمة في الجسور والطرق',
        'تضرر في المستشفيات والمراكز الصحية',
        'أضرار في المدارس والمنشآت التعليمية',
        'تضرر في الأسواق التجارية',
        'أضرار في شبكات الاتصالات',
        'تضرر في المساجد والكنائس',
        'أضرار في المزارع والمناطق الزراعية',
    ];

    public function run()
    {
        // Get existing users
        $users = User::all();
        if ($users->isEmpty()) {
            $this->command->warn('No users found. Please run UserSeeder first.');

            return;
        }

        // Create 50 dummy reports
        for ($i = 0; $i < 50; $i++) {
            $location = $this->syrianLocations[array_rand($this->syrianLocations)];

            // Add slight random variation to coordinates
            $latitude = $location['latitude'] + (rand(-100, 100) / 10000);
            $longitude = $location['longitude'] + (rand(-100, 100) / 10000);

            $damageLevel = $this->damageLevels[array_rand($this->damageLevels)];
            $status = $this->statuses[array_rand($this->statuses)];
            $description = $this->descriptions[array_rand($this->descriptions)];

            $user = $users->random();

            Report::create([
                'user_id' => $user->id,
                'image_path' => 'reports/'.rand(1, 100).'.jpg',
                'latitude' => $latitude,
                'longitude' => $longitude,
                'raw_location' => $location['city'].' - '.$this->generateNeighborhood(),
                'raw_description' => $description,
                'ai_location' => $location['city'],
                'ai_damage_level' => $damageLevel,
                'ai_analysis' => $this->generateAnalysis($damageLevel),
                'status' => $status,
                'created_at' => $this->generateRandomDate(),
                'updated_at' => now(),
            ]);
        }

        $this->command->info('50 dummy reports created successfully.');
    }

    private function generateNeighborhood()
    {
        $neighborhoods = [
            'حي السلام', 'حي النور', 'حي الأمل', 'حي الفرات', 'حي العروبة',
            'حي التحرير', 'حي الاستقلال', 'حي الوحدة', 'حي الياسمين', 'حي الزهور',
            'المنطقة الصناعية', 'المركز التجاري', 'الحي القديم', 'الحي الجديد',
        ];

        return $neighborhoods[array_rand($neighborhoods)];
    }

    private function generateAnalysis($damageLevel)
    {
        $analyses = [
            'low' => [
                'أضرار طفيفة في المباني، يمكن إصلاحها بسهولة',
                'تضرر بسيط في البنية التحتية، لا يشكل خطراً كبيراً',
                'أضرار سطحية، الوضع تحت السيطرة',
            ],
            'medium' => [
                'أضرار متوسطة في المباني السكنية، تحتاج إلى إصلاحات',
                'تضرر جزئي في شبكة الخدمات، يتطلب تدخلاً سريعاً',
                'أضرار ملحوظة لكنها ليست حرجة',
            ],
            'high' => [
                'أضرار جسيمة في المباني، تحتاج إلى إعادة بناء جزئية',
                'تضرر كبير في البنية التحتية، الوضع خطير',
                'أضرار بالغة تتطلب تدخلاً عاجلاً',
            ],
            'critical' => [
                'أضرار كارثية في المباني، غير صالحة للسكن',
                'دمار شامل في البنية التحتية، حالة طوارئ',
                'أضرار فادحة، تتطلب إخلاء فوري',
            ],
        ];

        return $analyses[$damageLevel][array_rand($analyses[$damageLevel])];
    }

    private function generateRandomDate()
    {
        // Generate random date within the last 30 days
        $daysAgo = rand(0, 30);

        return now()->subDays($daysAgo)->subHours(rand(0, 23))->subMinutes(rand(0, 59));
    }
}
