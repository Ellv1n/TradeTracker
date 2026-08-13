# Ticarət Tracker (Flutter)

Topdan mal alışı, satışı, nisyə borc izləmə və anbar idarəetməsi üçün sadə Flutter tətbiqi.
Bütün məlumatlar telefonun yaddaşında (SharedPreferences) saxlanılır — internet lazım deyil, backend yoxdur.

## Xüsusiyyətlər

- **Ana səhifə**: cəmi borc, bugünkü satış, az qalan mallar, borclu təchizatçılar, son əməliyyatlar
- **Anbar**: mal əlavə et/redaktə et/sil, axtarış, minimum stok həddi ilə xəbərdarlıq
- **Təchizatçılar**: hər təchizatçı üzrə nisyə borcunu izlə, ödəniş qeyd et, əməliyyat tarixçəsi
- **Alış**: mövcud maldan seç və ya yenisini əlavə et, nağd/nisyə seç, qismən ödəniş
- **Satış**: mal seç, miqdar/qiymət daxil et, avtomatik anbar azalır
- **Hesabat**: bugün/həftə/ay/hamısı üzrə satış, alış və təxmini mənfəət

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

- Bir mal üçün alış qiyməti hər yeni alışda **ortalama maya dəyəri** kimi yenilənir (əvvəlki qalıq + yeni alış üzrə çəkili orta).
- Nisyə alışlarda təchizatçının borcu avtomatik artır; "Borc ödə" düyməsi ilə azaldırsınız.
- Satış zamanı mənfəət hesabatı satış anındakı maya dəyərinə əsaslanır.
- Mal, təchizatçı və əməliyyat siyahıları tamamilə telefon daxilində saxlanılır — tətbiqi silsəniz məlumat itir, ona görə tez-tez ehtiyat nüsxə almaq istəsəniz mənə deyin, əlavə funksiya (export/import) yığa bilərəm.
