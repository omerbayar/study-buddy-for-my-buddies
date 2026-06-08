# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır (macOS)
flutter run -d macos

# Hive model kodlarını yeniden oluştur (model değişikliklerinden sonra)
dart run build_runner build --delete-conflicting-outputs

# Testleri çalıştır
flutter test

# Tek bir test dosyası çalıştır
flutter test test/widget_test.dart

# Analiz
flutter analyze
```

## Mimari

Bu proje **Study Buddy** adlı bir Flutter ders takip uygulamasıdır. Paket adı `bullet_list`'tir ancak uygulamanın işlevi ders takibidir.

### Katmanlar

- **`lib/models/`** — Hive ile persist edilen veri modelleri (typeId'ler: Subject=0, StudySession=1, DailyGoal=2, QuestionLog=3, Note=4). Her modelin bir `.g.dart` dosyası vardır; bunlar `build_runner` ile üretilir, elle düzenlenmez.

- **`lib/repositories/`** — `StudyRepository`: tüm Hive box erişimi tek bir yerden yönetilir. `StudyRepository.init()` uygulama başlangıcında çağrılmalıdır (tüm adaptörleri ve box'ları açar). Tarih bazlı sorgular `'yyyy-MM-dd'` string key kullanır.

- **`lib/providers/`** — `provider` paketi ile state yönetimi:
  - `ThemeProvider`: light/dark/system tema modu
  - `StatsProvider`: bugünkü dakika, streak, haftalık istatistikler — `watchSessions()` listenable'ı ile otomatik güncellenir
  - `TimerProvider`: Pomodoro zamanlayıcısı (25/5/15 dk), odak tamamlanınca otomatik `StudySession` kaydeder

- **`lib/screens/`** — Beş ana ekran: Dashboard, Dersler (SubjectsScreen), Sorular (QuestionsPanel), İstatistik (StatsScreen), Notlar (NotesScreen)

- **`lib/widgets/`** — Paylaşılan widget'lar:
  - `AdaptiveScaffold`: ≥600px genişlikte `NavigationRail`, daha dar ekranlarda `NavigationBar` gösterir
  - `CommandPalette`: Cmd/Ctrl+K ile açılır, ekranlar arası hızlı geçiş
  - `ShortcutHelpModal`: `?` tuşuyla açılır

### Veri akışı

`main()` → `StudyRepository.init()` → `MultiProvider` (ThemeProvider, StudyRepository, StatsProvider, TimerProvider) → `HomeShell` → `AdaptiveScaffold`

Klavye kısayolları `HomeShell`'deki `KeyboardListener`'da yakalanır ve ilgili widget'lara yönlendirilir.

### Lokalizasyon

Çeviri sistemi JSON tabanlıdır (`assets/translations/{tr,en,de,fr,ro}.json`). Global `translate(slug, [params])` veya `t(slug, [params])` fonksiyonu (`lib/l10n/translations.dart`) her dosyadan direkt çağrılabilir. Parametre içeren string'ler `{key}` placeholder kullanır: `translate('subjects.delete_confirm', {'name': subject.name})`.

Dil seçimi `LocaleProvider` üzerinden yapılır ve Hive'ın `settings` box'ında `'locale'` anahtarıyla persist edilir. Dil değişince `LocaleProvider.setLocale()` → `Translations.instance.load()` → `notifyListeners()` → `MaterialApp` rebuild.

Yeni bir string eklendiğinde: önce 5 JSON dosyasına aynı slug'u ekle, sonra kodda `translate('slug')` kullan.

### Hive model değişiklikleri

Yeni bir `@HiveField` eklendiğinde veya yeni bir model oluşturulduğunda mutlaka `build_runner` çalıştırılmalıdır. Yeni model için `typeId` mevcut en yüksek değerin bir üstü olmalı ve `StudyRepository.init()` içinde adapter kaydedilmeli ve box açılmalıdır.
