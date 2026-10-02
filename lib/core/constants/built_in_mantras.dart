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
    Mantra(
      id: 'builtin.sita-ram',
      name: 'सीता राम',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 11,
    ),
    Mantra(
      id: 'builtin.shri-ram-jai-ram',
      name: 'श्री राम जय राम जय जय राम',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 12,
    ),
    Mantra(
      id: 'builtin.om-gam-ganapataye-namah',
      name: 'ॐ गं गणपतये नमः',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 13,
    ),
    Mantra(
      id: 'builtin.om-shri-mahalakshmyai-namah',
      name: 'ॐ श्री महालक्ष्म्यै नमः',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 14,
    ),
    Mantra(
      id: 'builtin.om-aim-saraswatyai-namah',
      name: 'ॐ ऐं सरस्वत्यै नमः',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 15,
    ),
    Mantra(
      id: 'builtin.om',
      name: 'ॐ',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 16,
    ),
    Mantra(
      id: 'builtin.radhe-krishna',
      name: 'राधे कृष्ण',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 17,
    ),
    Mantra(
      id: 'builtin.om-namo-narayanaya',
      name: 'ॐ नमो नारायणाय',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 18,
    ),
    Mantra(
      id: 'builtin.om-sai-ram',
      name: 'ॐ साईं राम',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 19,
    ),
    Mantra(
      id: 'builtin.om-dum-durgayei-namah',
      name: 'ॐ दुं दुर्गायै नमः',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 20,
    ),
    // The Hare Rama half of the Maha Mantra, chanted on its own.
    Mantra(
      id: 'builtin.hare-rama',
      name: 'हरे राम हरे राम राम राम हरे हरे',
      malaSize: 108,
      isBuiltIn: true,
      sortOrder: 21,
    ),
  ];

  /// Each built-in in Roman letters, shown when the app is in English. Kept
  /// out of the database: the stored text stays the Devanagari one, and
  /// only what the screen shows changes with the language.
  static const Map<String, String> english = {
    'builtin.ram': 'Ram',
    'builtin.radha': 'Radha',
    'builtin.om-namah-shivaya': 'Om Namah Shivaya',
    'builtin.om-hanumate-namah': 'Om Hanumate Namah',
    'builtin.hare-krishna': 'Hare Krishna',
    'builtin.hare-krishna-mahamantra':
        'Hare Krishna Hare Krishna Krishna Krishna Hare Hare\n'
        'Hare Rama Hare Rama Rama Rama Hare Hare',
    'builtin.om-namo-bhagavate-vasudevaya': 'Om Namo Bhagavate Vasudevaya',
    'builtin.gayatri':
        'Om Bhur Bhuvah Svah Tat Savitur Varenyam\n'
        'Bhargo Devasya Dhimahi Dhiyo Yo Nah Prachodayat',
    'builtin.mahamrityunjaya':
        'Om Tryambakam Yajamahe Sugandhim Pushtivardhanam\n'
        'Urvarukamiva Bandhanan Mrityor Mukshiya Maamritat',
    'builtin.waheguru': 'Waheguru',
    'builtin.satnam-waheguru': 'Satnam Waheguru',
    'builtin.sita-ram': 'Sita Ram',
    'builtin.shri-ram-jai-ram': 'Shri Ram Jai Ram Jai Jai Ram',
    'builtin.om-gam-ganapataye-namah': 'Om Gam Ganapataye Namah',
    'builtin.om-shri-mahalakshmyai-namah': 'Om Shri Mahalakshmyai Namah',
    'builtin.om-aim-saraswatyai-namah': 'Om Aim Saraswatyai Namah',
    'builtin.om': 'Om',
    'builtin.radhe-krishna': 'Radhe Krishna',
    'builtin.om-namo-narayanaya': 'Om Namo Narayanaya',
    'builtin.om-sai-ram': 'Om Sai Ram',
    'builtin.om-dum-durgayei-namah': 'Om Dum Durgayei Namah',
    'builtin.hare-rama': 'Hare Rama Hare Rama Rama Rama Hare Hare',
  };

  static final Map<String, String> _shipped = {
    for (final mantra in all) mantra.id: mantra.name,
  };

  /// The text a built-in shipped with, or null for anything else.
  static String? shippedName(String id) => _shipped[id];

  /// Built-ins that earlier versions shipped and this one no longer does.
  static const List<String> retiredIds = [
    'builtin.mool-mantar',
    'builtin.navkar',
    'builtin.om-hreem-arham-namah',
  ];

  static Mantra get fallback => all.first;
}
