import 'package:flutter/material.dart';

class EarthquakeSafetyScreen extends StatelessWidget {
  const EarthquakeSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deprem Güvenlik Rehberi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ana başlık ve resim
            _buildHeaderSection(),
            
            const SizedBox(height: 24),
            
            // Deprem öncesi hazırlık
            _buildPreparationSection(),
            
            const SizedBox(height: 24),
            
            // Deprem anında yapılacaklar
            _buildDuringEarthquakeSection(),
            
            const SizedBox(height: 24),
            
            // Deprem sonrası yapılacaklar
            _buildAfterEarthquakeSection(),
            
            const SizedBox(height: 24),
            
            // Acil durum çantası
            _buildEmergencyKitSection(),
            
            const SizedBox(height: 24),
            
            // Önemli telefon numaraları
            _buildEmergencyContactsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Deprem güvenlik ikonu (resim yerine ikon kullanıyoruz)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Depreme Hazırlıklı Olun!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Deprem anında hayatınızı kurtarabilecek önemli bilgiler',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreparationSection() {
    return _buildSectionCard(
      title: '🏠 Deprem Öncesi Hazırlık',
      color: Colors.blue,
      items: [
        'Evinizde güvenli alanları belirleyin (masa altı, duvar kenarları)',
        'Ağır eşyaları duvara sabitleyin',
        'Acil durum çantası hazırlayın',
        'Aile bireylerinin toplanma noktasını belirleyin',
        'Su, elektrik ve gaz vanalarının yerini öğrenin',
        'Deprem sigortası yaptırın',
        'Acil durum planı yapın ve ailenizle paylaşın',
      ],
    );
  }

  Widget _buildDuringEarthquakeSection() {
    return _buildSectionCard(
      title: '⚡ Deprem Anında Yapılacaklar',
      color: Colors.red,
      items: [
        'SAKIN KALIN ve panik yapmayın',
        'İçerideyseniz: "ÇÖK, SIĞIN, TUTUN" kuralını uygulayın',
        'Sağlam masa altına girin veya duvar kenarına çömelip başınızı koruyun',
        'Dışarıdaysanız: Binalardan, direklerden ve camlardan uzak durun',
        'Araçtaysanız: Güvenli bir yere park edin ve içeride kalın',
        'Asansör kullanmayın',
        'Kapı eşiklerinde durmayın',
        'Balkon ve merdivenlerden uzak durun',
      ],
    );
  }

  Widget _buildAfterEarthquakeSection() {
    return _buildSectionCard(
      title: '✅ Deprem Sonrası Yapılacaklar',
      color: Colors.green,
      items: [
        'Yaralı varsa ilk yardım uygulayın',
        'Gaz kaçağı kontrolü yapın, şüphe varsa gazı kapatın',
        'Elektrik tesisatını kontrol edin',
        'Binada hasar varsa dışarı çıkın',
        'Artçı depremler için hazırlıklı olun',
        'Radyo dinleyin, resmi açıklamaları takip edin',
        'Gereksiz telefon kullanmayın',
        'Hasarlı binaların içine girmeyin',
      ],
    );
  }

  Widget _buildEmergencyKitSection() {
    return _buildSectionCard(
      title: '🎒 Acil Durum Çantası',
      color: Colors.orange,
      items: [
        'Su (kişi başı günde 4 litre, 3 günlük)',
        'Konserve yiyecekler ve açacak',
        'İlk yardım malzemeleri',
        'El feneri ve piller',
        'Radyo (pilli)',
        'Önemli belgeler (nüfus cüzdanı, pasaport, sigorta)',
        'Nakit para',
        'İlaçlar (kronik hastalık ilaçları)',
        'Battaniye ve sıcak tutacak giysiler',
        'Islık (yardım çağırmak için)',
        'Çok amaçlı bıçak',
        'Hijyen malzemeleri',
      ],
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone, color: Colors.red.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Acil Durum Telefonları',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactRow('İtfaiye', '110', Icons.local_fire_department),
            _buildContactRow('Polis', '155', Icons.local_police),
            _buildContactRow('Sağlık', '112', Icons.local_hospital),
            _buildContactRow('AFAD', '122', Icons.warning),
            _buildContactRow('Doğalgaz Acil', '187', Icons.gas_meter),
            _buildContactRow('Elektrik Arıza', '186', Icons.electrical_services),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color color,
    required List<String> items,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String service, String number, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Deprem güvenlik ipuçları widget'ı (ana ekranda göstermek için)
class EarthquakeSafetyTip extends StatelessWidget {
  const EarthquakeSafetyTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EarthquakeSafetyScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.security,
                  color: Colors.red.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deprem Güvenlik Rehberi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Deprem anında ne yapmalısınız?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
