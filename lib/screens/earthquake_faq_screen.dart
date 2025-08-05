import 'package:flutter/material.dart';

class EarthquakeFaqScreen extends StatefulWidget {
  const EarthquakeFaqScreen({super.key});

  @override
  State<EarthquakeFaqScreen> createState() => _EarthquakeFaqScreenState();
}

class _EarthquakeFaqScreenState extends State<EarthquakeFaqScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqData = [
    {
      'question': 'Sismometre, Sismograf ve Sismogram arasındaki fark nedir?',
      'answer': '''**Sismometre:** Yer hareketlerini algılayan hassas cihazdır. Deprem dalgalarını elektrik sinyallerine çevirir.

**Sismograf:** Sismometrenin kaydettiği verileri kağıda veya dijital ortama aktaran sistemdir. Sismometre + kayıt sistemi = Sismograf.

**Sismogram:** Sismografın ürettiği kayıt, yani deprem dalgalarının görsel temsilidir. Zaman-genlik grafiği şeklindedir.

Kısaca: Sismometre algılar, sismograf kaydeder, sismogram ise kayıttır.'''
    },
    {
      'question': 'Levha sınırlarında neden bu kadar çok deprem oluyor?',
      'answer': '''Dünya'nın kabuğu büyük levhalar halinde bölünmüştür ve bu levhalar sürekli hareket eder. Levha sınırlarında üç tür hareket olur:

**1. Ayrılma Sınırları:** Levhalar birbirinden uzaklaşır (okyanus ortası sırtları)
**2. Çarpışma Sınırları:** Levhalar birbirine çarpar (dağ zincirleri, çukurlar)
**3. Dönüşüm Sınırları:** Levhalar yan yana kayar (San Andreas Fayı gibi)

Bu hareketler sırasında biriken gerilim aniden boşalır ve deprem oluşur. Dünya'daki depremlerin %95'i levha sınırlarında meydana gelir.'''
    },
    {
      'question': 'Hangi deprem kategorisi acil durum olarak kabul edilir?',
      'answer': '''Deprem büyüklüğüne göre acil durum kategorileri:

**Büyüklük 6.0-6.9:** Orta şiddetli - Yerel hasarlar, izleme gerekir
**Büyüklük 7.0-7.9:** Büyük deprem - Bölgesel acil durum
**Büyüklük 8.0+:** Çok büyük deprem - Ulusal/uluslararası acil durum

**Acil durum kriterleri:**
- Can kaybı riski
- Yapısal hasarlar
- Altyapı kesintileri
- Tsunami riski (deniz altı depremlerde)
- Nüfus yoğunluğu

Türkiye'de 5.0+ büyüklükteki depremler AFAD tarafından yakından izlenir.'''
    },
    {
      'question': 'Deprem ne tür hasarlara yol açabilir?',
      'answer': '''Depremler çok çeşitli hasarlara neden olabilir:

**Yapısal Hasarlar:**
- Binaların çökmesi veya ağır hasar görmesi
- Köprü ve yolların zarar görmesi
- Barajlarda çatlaklar

**Altyapı Hasarları:**
- Elektrik kesintileri
- Su ve kanalizasyon sistemlerinde arızalar
- Doğalgaz boru hatlarında sızıntılar
- Haberleşme sistemlerinde aksaklıklar

**Doğal Hasarlar:**
- Toprak kayması
- Çığ
- Tsunami (deniz altı depremlerde)
- Sıvılaşma (kumlu zeminlerde)

**İnsani Hasarlar:**
- Can kayıpları ve yaralanmalar
- Evsiz kalma
- Psikolojik travma
- Ekonomik kayıplar'''
    },
    {
      'question': 'Depremler ne kadar tehlikelidir?',
      'answer': '''Depremlerin tehlike düzeyi birçok faktöre bağlıdır:

**Büyüklük:** Richter ölçeğinde her 1 birim artış, 10 kat daha fazla enerji demektir.

**Derinlik:** Sığ depremler (0-70 km) daha tehlikelidir.

**Mesafe:** Episantra yakınlık tehlikeyi artırır.

**Zemin Koşulları:** Yumuşak zeminler sarsıntıyı büyütür.

**Yapı Kalitesi:** Depreme dayanıklı binalar hayat kurtarır.

**Nüfus Yoğunluğu:** Kalabalık alanlarda risk artar.

**İstatistikler:**
- Yılda ~500.000 deprem olur
- Bunların sadece ~100.000'i hissedilir
- ~100 tanesi hasar verir
- ~10-15 tanesi büyük felaket yaratır'''
    },
    {
      'question': 'Her yıl depremlerden kaç kişi etkileniyor?',
      'answer': '''Dünya genelinde yıllık deprem etkileri:

**Ortalama İstatistikler:**
- **10.000-15.000 kişi** hayatını kaybeder
- **Milyonlarca kişi** evsiz kalır
- **100+ milyar dolar** ekonomik kayıp

**Son 20 yılın büyük depremleri:**
- 2004 Sumatra: 230.000+ ölü (tsunami dahil)
- 2010 Haiti: 200.000+ ölü
- 2008 Sichuan (Çin): 87.000+ ölü
- 2005 Pakistan: 86.000+ ölü

**Türkiye'de:**
- 1999 Marmara: 17.000+ ölü
- 2023 Kahramanmaraş: 50.000+ ölü

Bu rakamlar deprem hazırlığının ve dayanıklı yapılaşmanın önemini gösterir.'''
    },
    {
      'question': 'Depremleri tahmin edebilir miyiz?',
      'answer': '''**Kısa cevap: Hayır, kesin tahmin mümkün değil.**

**Neden tahmin edemiyoruz?**
- Yer kabuğu çok karmaşık bir sistem
- Fay sistemleri öngörülemez davranır
- Tetikleyici faktörler çok çeşitli

**Yapabileceklerimiz:**
**1. Olasılık Hesaplamaları:** Belirli bölgelerde 30-50 yıl içinde deprem olasılığı
**2. Erken Uyarı:** Deprem başladıktan sonra 10-60 saniye önceden uyarı
**3. Hazard Haritaları:** Risk bölgelerinin belirlenmesi

**Sahte Tahminler:**
- Astrolojik tahminler
- Hayvan davranışları
- Hava durumu bağlantıları
Bu yöntemlerin bilimsel dayanağı yoktur.

**En iyi koruma:** Hazırlıklı olmak ve dayanıklı yapılar inşa etmek.'''
    },
    {
      'question': '10 km derinlikte neden bu kadar çok deprem oluyor?',
      'answer': '''10 km derinlik sıklıkla görülmesinin nedenleri:

**1. Varsayılan Değer:**
Birçok deprem izleme merkezi, derinliği kesin belirlenemediğinde 10 km'yi varsayılan değer olarak kullanır.

**2. Yer Kabuğunun Yapısı:**
- Yer kabuğunun üst kısmı (0-15 km) en kırılgan bölgedir
- Bu derinlikte kayalar daha soğuk ve sert
- Gerilim birikimi ve kırılma daha kolay

**3. Ölçüm Zorluğu:**
- Küçük depremlerde derinlik tespiti zor
- Az sayıda sismometre verisi
- Otomatik sistemler 10 km varsayımı kullanır

**4. Gerçek Fiziksel Neden:**
Kıtasal kabuğun üst tabakalarında fay aktivitesi yoğun. Özellikle 5-15 km arası "sismojenik zon" olarak bilinir.

**Not:** Büyük depremler için derinlik daha hassas ölçülür ve gerçek değerler kullanılır.'''
    },
    {
      'question': '2 büyüklüğündeki küçük bir deprem hissedilebilir mi?',
      'answer': '''**Genellikle hayır, ama bazı durumlarda evet.**

**Normal Koşullarda:**
- Büyüklük 2.0 depremleri çok zayıf
- Sadece hassas cihazlar algılar
- İnsanlar hissetmez

**Hissedilebilir Durumlar:**
**1. Çok Sığ Depremler:** 1-2 km derinlikte
**2. Çok Yakın Mesafe:** Episantrın tam üzerinde
**3. Sessiz Ortam:** Gece, hareketsiz durumda
**4. Hassas Kişiler:** Bazı insanlar daha duyarlı
**5. Sert Zemin:** Kayalık arazide titreşim daha iyi iletilir

**Hissedilme Skalası:**
- **1.0-2.9:** Sadece cihazlar algılar
- **3.0-3.9:** Çok az kişi hisseder
- **4.0-4.9:** Birçok kişi hisseder
- **5.0+:** Herkes hisseder

**Sonuç:** 2.0 büyüklüğündeki deprem çok özel koşullarda hissedilebilir, ama bu çok nadir.'''
    },
    {
      'question': 'Depremler ne kadar sürer?',
      'answer': '''Deprem süresi büyüklüğe ve fay uzunluğuna bağlıdır:

**Büyüklüğe Göre Süreler:**
- **Büyüklük 4.0-5.0:** 5-15 saniye
- **Büyüklük 5.0-6.0:** 15-30 saniye
- **Büyüklük 6.0-7.0:** 30-60 saniye
- **Büyüklük 7.0-8.0:** 1-3 dakika
- **Büyüklük 8.0+:** 3-5 dakika

**Örnekler:**
- 1999 Marmara Depremi: ~45 saniye
- 2011 Japonya Depremi: ~6 dakika
- 2004 Sumatra Depremi: ~10 dakika

**Süreyi Etkileyen Faktörler:**
- Fay kırığının uzunluğu
- Kırılma hızı
- Deprem türü (tek kırık vs çoklu kırık)

**Önemli Not:**
Artçı depremler saatlerce, günlerce sürebilir. Ana deprem kısa sürer ama etkileri uzun süre devam eder.

**Psikolojik Algı:**
Deprem anında zaman daha uzun hissedilir. 30 saniyelik deprem saatlerce sürmüş gibi gelir.'''
    },
    {
      'question': 'Depremlerin Enerjisi',
      'answer': '''Deprem enerjisi büyüklükle üstel olarak artar:

**Richter Ölçeği:**
Her 1 birim artış = 32 kat daha fazla enerji
Her 2 birim artış = 1000 kat daha fazla enerji

**Enerji Karşılaştırmaları:**
- **Büyüklük 4.0:** 1 ton TNT
- **Büyüklük 5.0:** 32 ton TNT
- **Büyüklük 6.0:** 1.000 ton TNT (Hiroshima bombası)
- **Büyüklük 7.0:** 32.000 ton TNT
- **Büyüklük 8.0:** 1 milyon ton TNT
- **Büyüklük 9.0:** 32 milyon ton TNT

**Büyük Depremlerin Enerjisi:**
- 2011 Japonya (9.1): Tüm ABD'nin 6 aylık enerji tüketimi
- 2004 Sumatra (9.1): Dünya'nın günlük enerji tüketiminin 23.000 katı

**Enerji Dağılımı:**
- %5'i sismik dalgalar (hissettiğimiz kısım)
- %95'i ısı enerjisine dönüşür

Bu muazzam enerji miktarları depremlerin neden bu kadar yıkıcı olduğunu açıklar.'''
    },
    {
      'question': 'Avustralya\'da deprem oluyor mu?',
      'answer': '''**Evet, Avustralya'da da deprem olur, ama nadir.**

**Avustralya'nın Durumu:**
- Büyük bir kıtasal levhanın ortasında yer alır
- Levha sınırlarından uzak (en yakın sınır 1000+ km)
- "İntraplate" (levha içi) depremler yaşar

**Deprem Aktivitesi:**
- Yılda ~100 hissedilir deprem
- Çoğu büyüklük 3-4 arası
- Büyük depremler çok nadir

**Tarihi Büyük Depremler:**
- 1989 Newcastle: 5.6 büyüklük, 13 ölü
- 2016 Petermann Ranges: 6.1 büyüklük
- 1968 Meckering: 6.8 büyüklük

**Neden Oluyor?**
- Eski fay hatları yeniden aktifleşir
- Levha içi gerilim birikimi
- Uzak levha hareketlerinin etkisi

**Sonuç:**
Avustralya dünya'nın en az sismik aktif kıtalarından biri, ama tamamen deprem-siz değil. Deprem riski düşük ama sıfır değil.'''
    },
    {
      'question': 'Tarihin en büyük depremleri hangileridir?',
      'answer': '''**En Büyük Depremler (Modern Kayıtlar):**

**1. Şili - 1960: 9.5 büyüklük**
- Tarihin en büyük kaydedilen depremi
- 1.000+ ölü, milyonlarca evsiz
- Pasifik çapında tsunami

**2. Alaska - 1964: 9.2 büyüklük**
- Good Friday Depremi
- 131 ölü, büyük tsunami

**3. Sumatra - 2004: 9.1 büyüklük**
- Hint Okyanusu tsunamisi
- 230.000+ ölü (14 ülke)

**4. Japonya - 2011: 9.1 büyüklük**
- Tōhoku depremi
- 20.000+ ölü, Fukushima nükleer krizi

**5. Kamçatka - 1952: 9.0 büyüklük**
- Rusya, az nüfuslu bölge
- Büyük tsunami

**Tarihi Büyük Depremler:**
- 1755 Lizbon: ~8.5, 60.000+ ölü
- 1556 Shaanxi (Çin): 8.0+, 830.000 ölü
- 1906 San Francisco: 7.9, 3.000+ ölü

**Türkiye'nin En Büyükleri:**
- 1939 Erzincan: 7.9
- 1999 Marmara: 7.6
- 2023 Kahramanmaraş: 7.8'''
    },
    {
      'question': 'Depremlerin ciddiyeti neden bazen düşürülür?',
      'answer': '''Deprem büyüklüğü revize edilmesinin nedenleri:

**1. İlk Hesaplamalar Hızlı Yapılır:**
- Acil durum için hızlı tahmin gerekir
- Az veri ile hesaplama
- Otomatik sistemler kullanılır

**2. Daha Fazla Veri Toplanır:**
- Daha çok sismometre verisi
- Uzak istasyonlardan veriler
- Daha hassas analiz

**3. Farklı Büyüklük Ölçekleri:**
- **Mb (Body wave):** İlk hesaplama
- **Ms (Surface wave):** Daha hassas
- **Mw (Moment):** En doğru, ama yavaş

**4. Çoklu Deprem Durumu:**
- İlk anda tek deprem sanılır
- Sonra birden fazla olduğu anlaşılır
- Ana şok belirlenir

**Örnek:**
İlk açıklama: "7.2 büyüklüğünde deprem"
Revize: "6.8 büyüklüğünde deprem"

**Neden Önemli:**
- Doğru bilgi acil müdahale için kritik
- Tsunami uyarıları etkilenir
- Hasar tahminleri değişir

Bu normal bir süreçtir ve bilimsel doğruluğu artırır.'''
    },
    {
      'question': 'Depremler bazen neden bir ızgara üzerinde konumlanmış gibi görünür?',
      'answer': '''Depremlerin ızgara şeklinde görünmesinin nedenleri:

**1. Harita Projeksiyon Hatası:**
- Küresel koordinatlar düz haritaya aktarılır
- Projeksiyon hataları ızgara etkisi yaratır
- Özellikle geniş alan haritalarında

**2. Konum Belirleme Hassasiyeti:**
- GPS koordinatları yuvarlanır
- Örnek: 39.123° → 39.1° (daha az hassas)
- Bu yuvarlamalar ızgara etkisi yaratır

**3. Otomatik Konum Sistemleri:**
- Bilgisayar algoritmaları varsayılan değerler kullanır
- Belirsiz konumlar en yakın ızgara noktasına atanır
- Özellikle küçük depremler için

**4. Veri Tabanı Formatı:**
- Koordinatlar belirli ondalık basamakla saklanır
- 0.1° hassasiyetle kayıt = ~11 km ızgara
- Daha hassas veriler daha az ızgara etkisi

**5. Gerçek Fay Geometrisi:**
- Bazı fay sistemleri gerçekten düzenli
- Paralel faylar doğal ızgara oluşturur
- Özellikle genişleme zonlarında

**Sonuç:**
Çoğunlukla teknik bir görsel etkidir, gerçek deprem dağılımını tam yansıtmaz.'''
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deprem SSS'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 48,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Sık Sorulan Sorular',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Depremler ve deprem bilimi hakkında merak ettikleriniz',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // SSS Listesi
            ...List.generate(_faqData.length, (index) {
              return _buildFaqItem(index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    final faq = _faqData[index];
    final isExpanded = _expandedIndex == index;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq['question']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  top: BorderSide(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                faq['answer']!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// SSS kısa kartı (ana ekranda göstermek için)
class EarthquakeFaqTip extends StatelessWidget {
  const EarthquakeFaqTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EarthquakeFaqScreen(),
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
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deprem SSS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Depremler hakkında sık sorulan sorular',
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
