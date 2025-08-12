# Privacy Policy - Earthquake Tracker App

**Son Güncelleme:** 12 Ağustos 2025

## Gizlilik Politikası

Bu gizlilik politikası, **Earthquake Tracker** mobil uygulamasının ("Uygulama") kullanıcılarının kişisel verilerinin nasıl toplandığı, kullanıldığı ve korunduğu hakkında bilgi vermektedir.

---

## 📱 Uygulama Hakkında

**Earthquake Tracker**, EMSC ve USGS API'lerinden gerçek zamanlı deprem verilerini çekerek kullanıcılara deprem bilgilerini sunan ücretsiz bir mobil uygulamadır.

---

## 🔍 Toplanan Veriler

### 1. Konum Verileri
- **Ne Topluyoruz:** GPS koordinatlarınız (enlem, boylam)
- **Neden:** Size yakın depremleri hesaplamak ve mesafe tabanlı bildirimler göndermek için
- **Nasıl:** Cihazınızın GPS sensörleri aracılığıyla
- **Depolama:** Sadece cihazınızda yerel olarak saklanır, sunucularımıza gönderilmez

### 2. Uygulama Kullanım Verileri
- **Ne Topluyoruz:** Uygulama açılma/kapanma zamanları, hata logları
- **Neden:** Uygulama performansını iyileştirmek için
- **Nasıl:** Flutter framework'ü aracılığıyla
- **Depolama:** Sadece cihazınızda yerel olarak

### 3. Deprem Raporu Verileri (İsteğe Bağlı)
- **Ne Topluyoruz:** Hissedilen deprem raporları, şiddet bilgileri
- **Neden:** Toplum tabanlı deprem izleme için
- **Nasıl:** Kullanıcı tarafından manuel olarak girilir
- **Depolama:** Cihazınızda yerel SQLite veritabanında

### 4. Telegram Bilgileri (İsteğe Bağlı)
- **Ne Topluyoruz:** Telegram bot token ve chat ID
- **Neden:** Deprem bildirimleri göndermek için
- **Nasıl:** Kullanıcı tarafından manuel olarak girilir
- **Depolama:** Cihazınızda şifrelenmiş olarak

---

## 🚫 Toplamadığımız Veriler

- **Kişisel Kimlik Bilgileri:** Ad, soyad, e-posta, telefon numarası
- **Finansal Bilgiler:** Kredi kartı, banka hesabı bilgileri
- **Sosyal Medya Hesapları:** Facebook, Twitter, Instagram hesapları
- **Cihaz Kimliği:** IMEI, MAC adresi gibi benzersiz tanımlayıcılar

---

## 🔒 Veri Güvenliği

### Yerel Depolama
- Tüm veriler cihazınızda **SQLite veritabanında** şifrelenmiş olarak saklanır
- Hiçbir kişisel veri uzak sunuculara gönderilmez
- Uygulama silindiğinde tüm veriler otomatik olarak silinir

### Network Güvenliği
- Tüm API çağrıları **HTTPS** protokolü ile yapılır
- SSL/TLS sertifikaları doğrulanır
- Man-in-the-middle saldırılarına karşı korunma

### İzinler
- **Konum İzni:** Sadece uygulama kullanılırken (foreground)
- **İnternet İzni:** Sadece deprem verilerini çekmek için
- **Bildirim İzni:** Sadece deprem uyarıları için

---

## 🌐 Üçüncü Taraf Servisler

### EMSC (European-Mediterranean Seismological Centre)
- **Veri:** Avrupa-Akdeniz bölgesi deprem verileri
- **API:** https://www.seismicportal.eu/
- **Gizlilik:** EMSC gizlilik politikası geçerlidir

### USGS (United States Geological Survey)
- **Veri:** Küresel deprem verileri
- **API:** https://earthquake.usgs.gov/
- **Gizlilik:** USGS gizlilik politikası geçerlidir

### Telegram (İsteğe Bağlı)
- **Kullanım:** Bildirim gönderimi
- **Veri:** Bot token ve chat ID
- **Gizlilik:** Telegram gizlilik politikası geçerlidir

---

## 👤 Kullanıcı Hakları

### Veri Erişimi
- Tüm verileriniz cihazınızda saklandığı için istediğiniz zaman erişebilirsiniz
- Uygulama ayarlarından verilerinizi görüntüleyebilirsiniz

### Veri Silme
- Uygulama ayarlarından "Tüm Verileri Sil" seçeneğini kullanabilirsiniz
- Uygulamayı sildiğinizde tüm veriler otomatik olarak silinir

### Veri Taşınabilirliği
- Verilerinizi JSON formatında dışa aktarabilirsiniz
- Başka bir cihaza taşıyabilirsiniz

---

## 🔔 Bildirimler

### Push Notifications
- Sadece deprem uyarıları için kullanılır
- İstediğiniz zaman kapatabilirsiniz
- Reklam veya pazarlama amaçlı kullanılmaz

### Telegram Bildirimleri
- Tamamen isteğe bağlıdır
- Kendi bot token'ınızı kullanır
- İstediğiniz zaman devre dışı bırakabilirsiniz

---

## 👶 Çocukların Gizliliği

Bu uygulama 13 yaş altı çocuklara yönelik değildir. 13 yaş altı çocuklardan bilerek kişisel bilgi toplamayız. Eğer 13 yaş altı bir çocuğun kişisel bilgilerini topladığımızı fark edersek, bu bilgileri derhal sileriz.

---

## 🌍 Uluslararası Veri Transferi

- Hiçbir kişisel veri ülke dışına transfer edilmez
- Tüm veriler cihazınızda yerel olarak saklanır
- EMSC ve USGS API'leri sadece genel deprem verilerini sağlar

---

## 📝 Politika Değişiklikleri

Bu gizlilik politikası zaman zaman güncellenebilir. Önemli değişiklikler olduğunda:
- Uygulama içi bildirim göndeririz
- GitHub repository'de duyuru yaparız
- Yeni politika yürürlük tarihini belirtiriz

---

## 📞 İletişim

Bu gizlilik politikası hakkında sorularınız varsa bizimle iletişime geçebilirsiniz:

- **GitHub:** [@Burakztrk123](https://github.com/Burakztrk123)
- **Repository:** [emsc_usgs_Litpack](https://github.com/Burakztrk123/emsc_usgs_Litpack)
- **Issues:** GitHub Issues bölümünü kullanın

---

## 📋 Özet

✅ **Verileriniz cihazınızda güvende**  
✅ **Hiçbir kişisel veri sunucularımıza gönderilmez**  
✅ **Sadece deprem verileri için konum kullanılır**  
✅ **İstediğiniz zaman verilerinizi silebilirsiniz**  
✅ **Reklam veya pazarlama yok**  
✅ **Açık kaynak ve şeffaf**  

---

*Bu gizlilik politikası GDPR, CCPA ve diğer veri koruma yasalarına uygun olarak hazırlanmıştır.*

**Son Güncelleme:** 12 Ağustos 2025  
**Versiyon:** 1.0
