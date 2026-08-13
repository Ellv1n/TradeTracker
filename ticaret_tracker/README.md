# Ticarət Tracker (Flutter)

Topdan mal alışı, satışı, nisyə borc izləmə və anbar idarəetməsi üçün sadə Flutter tətbiqi.
Bütün məlumatlar telefonun yaddaşında (SharedPreferences) saxlanılır — internet lazım deyil, backend yoxdur.

## Xüsusiyyətlər

- **Ana səhifə**: cəmi borc, bugünkü satış/alış, borclu təchizatçılar, son əməliyyatlar
- **Alış (təchizatçıdan)**: konkret mala bağlı deyil — **kateqoriya** üzrə ümumi məbləğ daxil edilir (məs. "Dəftərxana"), nağd və ya nisyə seçilir, **tarix seçilə bilir** (keçmiş günə də əlavə edə bilərsiniz)
- **Mallarım**: öz satdığınız malları bir-bir, **ad + kod (SKU) + maya qiyməti + satış qiyməti** ilə əlavə edirsiniz; ümumi siyahıda axtaranda satış qiyməti də görünür, adına və ya koduna görə axtarmaq mümkündür
- **Satışlar (ayrı ekran)**: bütün satış qeydlərini görürsünüz, bugün/həftə/ay/hamısı üzrə filtr, mal adı/koduna görə axtarış, cəmi satış və mənfəət, tarixlə əlavə etmə, sağa sürüşdürüb silmək
- **Borclarım (ayrı ekran)**: təchizatçılara olan borclar — Hamısı/Borclu/Borcsuz filtri, təchizatçı axtarışı, ümumi borc məbləği, ödəniş qeydi (tarixlə)
- **Kateqoriyalar**: Alış ekranından "Yeni kateqoriya əlavə et" və ya idarəetmə (redaktə/silmə) düyməsi ilə istənilən qədər kateqoriya yarada bilərsiniz
- **Hesabat**: seçilmiş dövr üzrə satış/alış cəmi, təxmini mənfəət, kateqoriya üzrə xərc bölgüsü, ən çox satılan mallar

## İşə salmaq

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) quraşdırılmalıdır (3.0+)
2. Layihə qovluğuna keçin:
   ```
   cd ticaret_tracker
   flutter pub get
   ```
3. Telefon/emulyator qoşub işə salın:
   ```
   flutter run
   ```
4. APK almaq üçün:
   ```
   flutter build apk --release
   ```
   Fayl: `build/app/outputs/flutter-apk/app-release.apk`

## Qeyd

- **Alış ≠ Mal.** Təchizatçıdan aldığınız topdan malı ayrı-ayrı mal kimi qeyd etmirsiniz — sadəcə hansı kateqoriyaya aid olduğunu (Dəftərxana və s.) və ümumi məbləği yazırsınız. Nisyə olarsa təchizatçının borcu artır.
- **Mallarım** ekranı isə sizin öz satdığınız (özünüzün elan etdiyiniz) malların kataloqudur — ad, kod, maya və satış qiyməti ilə. Satış edərkən elə buradan mal seçilir.
- Satış zamanı mənfəət hesabatı, malın həmin an kataloqdakı maya qiymətinə əsaslanır.
- Alış və satış əlavə edərkən tarixi dəyişə bilərsiniz — beləliklə keçmiş günlərin əməliyyatlarını da sonradan daxil edə bilərsiniz.
- Mal, təchizatçı, kateqoriya və əməliyyat siyahıları tamamilə telefon daxilində saxlanılır — tətbiqi silsəniz məlumat itir. İstəsəniz export/import funksiyası da əlavə edə bilərəm.
