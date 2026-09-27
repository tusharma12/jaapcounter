import '../../features/mantras/domain/mantra.dart';

/// Seeded on first launch. These can be edited and hidden but never deleted,
/// so a fresh install always has something to chant immediately.
///
/// Each is just the mantra as it is chanted. Sikh mantras are written in
/// Devanagari as they are commonly spelt in Hindi (Gurmukhi: ਵਾਹਿਗੁਰੂ,
/// ਸਤਿਨਾਮੁ).
abstract final class BuiltInMantras {
  static const List<Mantra> all = [
    Mantra(
      id: 'builtin.ram',
      name: 'राम',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 0,
    ),
    Mantra(
      id: 'builtin.radha',
      name: 'राधा',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 1,
    ),
    Mantra(
      id: 'builtin.om-namah-shivaya',
      name: 'ॐ नमः शिवाय',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 2,
    ),
    Mantra(
      id: 'builtin.om-hanumate-namah',
      name: 'ॐ हनुमते नमः',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 3,
    ),
    Mantra(
      id: 'builtin.hare-krishna',
      name: 'हरे कृष्ण',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 4,
    ),
    // The full sixteen-word Maha Mantra, as chanted on a japa mala.
    Mantra(
      id: 'builtin.hare-krishna-mahamantra',
      name:
          'हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे\nहरे राम हरे राम राम राम हरे हरे',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 5,
    ),
    Mantra(
      id: 'builtin.om-namo-bhagavate-vasudevaya',
      name: 'ॐ नमो भगवते वासुदेवाय',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 6,
    ),
    Mantra(
      id: 'builtin.gayatri',
      name:
          'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि धियो यो नः प्रचोदयात्',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 7,
    ),
    Mantra(
      id: 'builtin.mahamrityunjaya',
      name:
          'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्\nउर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय मामृतात्',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 8,
    ),
    // Sikh
    Mantra(
      id: 'builtin.waheguru',
      name: 'वाहेगुरु',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 9,
    ),
    Mantra(
      id: 'builtin.satnam-waheguru',
      name: 'सतनाम वाहेगुरु',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 10,
    ),
  ];

  /// Built-ins that earlier versions shipped and this one no longer does.
  static const List<String> retiredIds = [
    'builtin.mool-mantar',
    'builtin.navkar',
    'builtin.om-hreem-arham-namah',
  ];

  static Mantra get fallback => all.first;
}
