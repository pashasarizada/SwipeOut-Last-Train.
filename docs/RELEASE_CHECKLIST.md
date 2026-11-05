# Yayın Kontrol Listesi (Faz 4)

Hiçbir adım otomatik yayın yapmaz. İmzalama ve store işlemleri kullanıcının Mac'inde, elle yapılır.

## Ortak
- [ ] 30 bölüm `dart run tool/solve_levels.dart` ile `issues=0`
- [ ] `scripts/check.sh` yeşil
- [ ] TR/EN metin kontrolü (öğretici ≤ 2 satır)
- [ ] Lisans/asset kontrolü: yalnız kendi çizimlerimiz + Material Icons (Apache 2.0); resmî metro logosu/harita **yok**
- [ ] Paket lisansları: `flutter_localizations`, `intl` (BSD-3)
- [ ] Gizlilik: ağ isteği, analytics, reklam yok → store gizlilik formu "veri toplanmıyor"

## iOS
- [ ] Bundle id kararı (şu an geçici `com.example.swipeoutLastTrain`) — **kullanıcı onayı gerekli**
- [ ] Apple Developer hesabı, sertifika ve provisioning profili (Xcode → Signing & Capabilities)
- [ ] Uygulama ikonu (1024×1024, saydamlık yok) ve launch ekranı
- [ ] Gerçek cihazda test: iPhone SE boyutu + büyük ekran, dikey mod, titreşim
- [ ] Ekran görüntüleri: 6.9" ve 6.5" iPhone setleri; içerik: ana ekran, bölüm 1, makaslı bölüm, sonuç ekranı
- [ ] `flutter build ipa` → Xcode Organizer / Transporter ile **elle** yükleme

## Android
- [ ] `applicationId` kararı (şu an geçici `com.example.swipeout_last_train`)
- [ ] Upload keystore yerelde oluşturulur, **repoya girmez**
- [ ] Adaptive icon
- [ ] `flutter build appbundle` → Play Console'a **elle** yükleme
