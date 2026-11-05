/// The built-in mantras written in the scripts of the app's other Indian
/// languages, so a Tamil reader sees தமிழ் letters and a Punjabi reader sees
/// ਗੁਰਮੁਖੀ, not Roman letters or Devanagari they may not read.
///
/// Marathi and Hindi read the Devanagari the mantras are stored in, so they
/// have no table here. Like the English names, these are display text only:
/// the database keeps the Devanagari, and a built-in the user has rewritten
/// shows as they wrote it.
///
/// These are transliterations of sacred text. They follow common printed
/// usage in each script, but have not been checked by a native speaker; have
/// one review them before a release (the Gurmukhi and Tamil Sanskrit lines,
/// the Gayatri and Mahamrityunjaya, most of all).
abstract final class MantraScripts {
  static const Map<String, Map<String, String>> byLanguage = {
    'gu': _gujarati,
    'pa': _gurmukhi,
    'ta': _tamil,
    'te': _telugu,
    'ru': _cyrillic,
    'th': _thai,
  };

  static const Map<String, String> _gujarati = {
    'builtin.ram': 'રામ રામ',
    'builtin.radha': 'રાધા રાધા',
    'builtin.om-namah-shivaya': 'ૐ નમઃ શિવાય',
    'builtin.om-hanumate-namah': 'ૐ હનુમતે નમઃ',
    'builtin.hare-krishna': 'હરે કૃષ્ણ',
    'builtin.hare-krishna-mahamantra':
        'હરે કૃષ્ણ હરે કૃષ્ણ કૃષ્ણ કૃષ્ણ હરે હરે\n'
        'હરે રામ હરે રામ રામ રામ હરે હરે',
    'builtin.om-namo-bhagavate-vasudevaya': 'ૐ નમો ભગવતે વાસુદેવાય',
    'builtin.gayatri':
        'ૐ ભૂર્ભુવઃ સ્વઃ તત્સવિતુર્વરેણ્યં\n'
        'ભર્ગો દેવસ્ય ધીમહિ ધિયો યો નઃ પ્રચોદયાત્',
    'builtin.mahamrityunjaya':
        'ૐ ત્ર્યમ્બકં યજામહે સુગન્ધિં પુષ્ટિવર્ધનમ્\n'
        'ઉર્વારુકમિવ બન્ધનાન્ મૃત્યોર્મુક્ષીય મામૃતાત્',
    'builtin.waheguru': 'વાહેગુરુ વાહેગુરુ',
    'builtin.satnam-waheguru': 'સતનામ વાહેગુરુ',
    'builtin.sita-ram': 'સીતા રામ',
    'builtin.shri-ram-jai-ram': 'શ્રી રામ જય રામ જય જય રામ',
    'builtin.om-gam-ganapataye-namah': 'ૐ ગં ગણપતયે નમઃ',
    'builtin.om-shri-mahalakshmyai-namah': 'ૐ શ્રી મહાલક્ષ્મ્યૈ નમઃ',
    'builtin.om-aim-saraswatyai-namah': 'ૐ ઐં સરસ્વત્યૈ નમઃ',
    'builtin.om': 'ૐ',
    'builtin.radhe-krishna': 'રાધે કૃષ્ણ',
    'builtin.om-namo-narayanaya': 'ૐ નમો નારાયણાય',
    'builtin.om-sai-ram': 'ૐ સાંઈ રામ',
    'builtin.hare-rama': 'હરે રામ હરે રામ રામ રામ હરે હરે',
    'builtin.shri-krishna': 'શ્રી કૃષ્ણ',
  };

  /// Gurmukhi has no Om sign of its own, so Om is written ਓਮ.
  static const Map<String, String> _gurmukhi = {
    'builtin.ram': 'ਰਾਮ ਰਾਮ',
    'builtin.radha': 'ਰਾਧਾ ਰਾਧਾ',
    'builtin.om-namah-shivaya': 'ਓਮ ਨਮਃ ਸ਼ਿਵਾਯ',
    'builtin.om-hanumate-namah': 'ਓਮ ਹਨੁਮਤੇ ਨਮਃ',
    'builtin.hare-krishna': 'ਹਰੇ ਕ੍ਰਿਸ਼ਨ',
    'builtin.hare-krishna-mahamantra':
        'ਹਰੇ ਕ੍ਰਿਸ਼ਨ ਹਰੇ ਕ੍ਰਿਸ਼ਨ ਕ੍ਰਿਸ਼ਨ ਕ੍ਰਿਸ਼ਨ ਹਰੇ ਹਰੇ\n'
        'ਹਰੇ ਰਾਮ ਹਰੇ ਰਾਮ ਰਾਮ ਰਾਮ ਹਰੇ ਹਰੇ',
    'builtin.om-namo-bhagavate-vasudevaya': 'ਓਮ ਨਮੋ ਭਗਵਤੇ ਵਾਸੁਦੇਵਾਯ',
    'builtin.gayatri':
        'ਓਮ ਭੂਰ੍ਭੁਵਃ ਸ੍ਵਃ ਤਤ੍ਸਵਿਤੁਰ੍ਵਰੇਣ੍ਯੰ\n'
        'ਭਰ੍ਗੋ ਦੇਵਸ੍ਯ ਧੀਮਹਿ ਧਿਯੋ ਯੋ ਨਃ ਪ੍ਰਚੋਦਯਾਤ੍',
    'builtin.mahamrityunjaya':
        'ਓਮ ਤ੍ਰ੍ਯੰਬਕੰ ਯਜਾਮਹੇ ਸੁਗੰਧਿੰ ਪੁਸ਼ਟਿਵਰ੍ਧਨਮ੍\n'
        'ਉਰ੍ਵਾਰੁਕਮਿਵ ਬੰਧਨਾਨ੍ ਮ੍ਰਿਤ੍ਯੋਰ੍ਮੁਕ੍ਸ਼ੀਯ ਮਾਮ੍ਰਿਤਾਤ੍',
    'builtin.waheguru': 'ਵਾਹਿਗੁਰੂ ਵਾਹਿਗੁਰੂ',
    'builtin.satnam-waheguru': 'ਸਤਿ ਨਾਮੁ ਵਾਹਿਗੁਰੂ',
    'builtin.sita-ram': 'ਸੀਤਾ ਰਾਮ',
    'builtin.shri-ram-jai-ram': 'ਸ਼੍ਰੀ ਰਾਮ ਜੈ ਰਾਮ ਜੈ ਜੈ ਰਾਮ',
    'builtin.om-gam-ganapataye-namah': 'ਓਮ ਗੰ ਗਣਪਤਯੇ ਨਮਃ',
    'builtin.om-shri-mahalakshmyai-namah': 'ਓਮ ਸ਼੍ਰੀ ਮਹਾਲਕ੍ਸ਼੍ਮ੍ਯੈ ਨਮਃ',
    'builtin.om-aim-saraswatyai-namah': 'ਓਮ ਐਂ ਸਰਸ੍ਵਤ੍ਯੈ ਨਮਃ',
    'builtin.om': 'ਓਮ',
    'builtin.radhe-krishna': 'ਰਾਧੇ ਕ੍ਰਿਸ਼ਨ',
    'builtin.om-namo-narayanaya': 'ਓਮ ਨਮੋ ਨਾਰਾਯਣਾਯ',
    'builtin.om-sai-ram': 'ਓਮ ਸਾਈਂ ਰਾਮ',
    'builtin.hare-rama': 'ਹਰੇ ਰਾਮ ਹਰੇ ਰਾਮ ਰਾਮ ਰਾਮ ਹਰੇ ਹਰੇ',
    'builtin.shri-krishna': 'ਸ਼੍ਰੀ ਕ੍ਰਿਸ਼ਨ',
  };

  /// Sanskrit sounds Tamil script lacks are written with the Grantha letters
  /// (ஸ, ஷ, ஹ, க்ஷ), as in Tamil devotional printing.
  static const Map<String, String> _tamil = {
    'builtin.ram': 'ராம ராம',
    'builtin.radha': 'ராதா ராதா',
    'builtin.om-namah-shivaya': 'ஓம் நமஃ சிவாய',
    'builtin.om-hanumate-namah': 'ஓம் ஹனுமதே நமஃ',
    'builtin.hare-krishna': 'ஹரே கிருஷ்ண',
    'builtin.hare-krishna-mahamantra':
        'ஹரே கிருஷ்ண ஹரே கிருஷ்ண கிருஷ்ண கிருஷ்ண ஹரே ஹரே\n'
        'ஹரே ராம ஹரே ராம ராம ராம ஹரே ஹரே',
    'builtin.om-namo-bhagavate-vasudevaya': 'ஓம் நமோ பகவதே வாஸுதேவாய',
    'builtin.gayatri':
        'ஓம் பூர்ப்புவஸ்ஸுவஃ தத்ஸவிதுர்வரேண்யம்\n'
        'பர்கோ தேவஸ்ய தீமஹி தியோ யோ நஃ ப்ரசோதயாத்',
    'builtin.mahamrityunjaya':
        'ஓம் த்ர்யம்பகம் யஜாமஹே ஸுகந்திம் புஷ்டிவர்தனம்\n'
        'உர்வாருகமிவ பந்தனாந் ம்ருத்யோர்முக்ஷீய மாம்ருதாத்',
    'builtin.waheguru': 'வாஹேகுரு வாஹேகுரு',
    'builtin.satnam-waheguru': 'சத்நாம் வாஹேகுரு',
    'builtin.sita-ram': 'சீதா ராம',
    'builtin.shri-ram-jai-ram': 'ஸ்ரீ ராம ஜெய ராம ஜெய ஜெய ராம',
    'builtin.om-gam-ganapataye-namah': 'ஓம் கம் கணபதயே நமஃ',
    'builtin.om-shri-mahalakshmyai-namah': 'ஓம் ஸ்ரீ மஹாலக்ஷ்ம்யை நமஃ',
    'builtin.om-aim-saraswatyai-namah': 'ஓம் ஐம் ஸரஸ்வத்யை நமஃ',
    'builtin.om': 'ஓம்',
    'builtin.radhe-krishna': 'ராதே கிருஷ்ண',
    'builtin.om-namo-narayanaya': 'ஓம் நமோ நாராயணாய',
    'builtin.om-sai-ram': 'ஓம் ஸாயி ராம',
    'builtin.hare-rama': 'ஹரே ராம ஹரே ராம ராம ராம ஹரே ஹரே',
    'builtin.shri-krishna': 'ஸ்ரீ கிருஷ்ண',
  };

  static const Map<String, String> _telugu = {
    'builtin.ram': 'రామ రామ',
    'builtin.radha': 'రాధా రాధా',
    'builtin.om-namah-shivaya': 'ఓం నమః శివాయ',
    'builtin.om-hanumate-namah': 'ఓం హనుమతే నమః',
    'builtin.hare-krishna': 'హరే కృష్ణ',
    'builtin.hare-krishna-mahamantra':
        'హరే కృష్ణ హరే కృష్ణ కృష్ణ కృష్ణ హరే హరే\n'
        'హరే రామ హరే రామ రామ రామ హరే హరే',
    'builtin.om-namo-bhagavate-vasudevaya': 'ఓం నమో భగవతే వాసుదేవాయ',
    'builtin.gayatri':
        'ఓం భూర్భువః స్వః తత్సవితుర్వరేణ్యం\n'
        'భర్గో దేవస్య ధీమహి ధియో యో నః ప్రచోదయాత్',
    'builtin.mahamrityunjaya':
        'ఓం త్ర్యంబకం యజామహే సుగంధిం పుష్టివర్ధనం\n'
        'ఉర్వారుకమివ బంధనాన్ మృత్యోర్ముక్షీయ మామృతాత్',
    'builtin.waheguru': 'వాహెగురు వాహెగురు',
    'builtin.satnam-waheguru': 'సత్నామ్ వాహెగురు',
    'builtin.sita-ram': 'సీతా రామ',
    'builtin.shri-ram-jai-ram': 'శ్రీ రామ జయ రామ జయ జయ రామ',
    'builtin.om-gam-ganapataye-namah': 'ఓం గం గణపతయే నమః',
    'builtin.om-shri-mahalakshmyai-namah': 'ఓం శ్రీ మహాలక్ష్మ్యై నమః',
    'builtin.om-aim-saraswatyai-namah': 'ఓం ఐం సరస్వత్యై నమః',
    'builtin.om': 'ఓం',
    'builtin.radhe-krishna': 'రాధే కృష్ణ',
    'builtin.om-namo-narayanaya': 'ఓం నమో నారాయణాయ',
    'builtin.om-sai-ram': 'ఓం సాయి రామ',
    'builtin.hare-rama': 'హరే రామ హరే రామ రామ రామ హరే హరే',
    'builtin.shri-krishna': 'శ్రీ కృష్ణ',
  };

  /// Russian, as Russian Vaishnava printing writes these names: Харе Кришна,
  /// Рама, Радха, with Ом for Om.
  static const Map<String, String> _cyrillic = {
    'builtin.ram': 'Рам Рам',
    'builtin.radha': 'Радха Радха',
    'builtin.om-namah-shivaya': 'Ом Намах Шивая',
    'builtin.om-hanumate-namah': 'Ом Хануматэ Намах',
    'builtin.hare-krishna': 'Харе Кришна',
    'builtin.hare-krishna-mahamantra':
        'Харе Кришна Харе Кришна Кришна Кришна Харе Харе\n'
        'Харе Рама Харе Рама Рама Рама Харе Харе',
    'builtin.om-namo-bhagavate-vasudevaya': 'Ом Намо Бхагавате Васудевая',
    'builtin.gayatri':
        'Ом Бхур Бхувах Сваха Тат Савитур Варениям\n'
        'Бхарго Девасья Дхимахи Дхийо Йо Нах Прачодаят',
    'builtin.mahamrityunjaya':
        'Ом Трьямбакам Яджамахе Сугандхим Пуштивардханам\n'
        'Урварукамива Бандханан Мритьор Мукшия Мамритат',
    'builtin.waheguru': 'Вахегуру Вахегуру',
    'builtin.satnam-waheguru': 'Сатнам Вахегуру',
    'builtin.sita-ram': 'Сита Рам',
    'builtin.shri-ram-jai-ram': 'Шри Рам Джай Рам Джай Джай Рам',
    'builtin.om-gam-ganapataye-namah': 'Ом Гам Ганапатайе Намах',
    'builtin.om-shri-mahalakshmyai-namah': 'Ом Шри Махалакшмьяй Намах',
    'builtin.om-aim-saraswatyai-namah': 'Ом Айм Сарасватьяй Намах',
    'builtin.om': 'Ом',
    'builtin.radhe-krishna': 'Радхе Кришна',
    'builtin.om-namo-narayanaya': 'Ом Намо Нараянайя',
    'builtin.om-sai-ram': 'Ом Саи Рам',
    'builtin.hare-rama': 'Харе Рама Харе Рама Рама Рама Харе Харе',
    'builtin.shri-krishna': 'Шри Кришна',
  };

  /// Thai, as Thai devotional printing writes Sanskrit: โอม for Om, the
  /// visarga as ห์ (นมะห์), and the familiar Thai names สีดา and กฤษณะ.
  static const Map<String, String> _thai = {
    'builtin.ram': 'ราม ราม',
    'builtin.radha': 'ราธา ราธา',
    'builtin.om-namah-shivaya': 'โอม นมัส ศิวายะ',
    'builtin.om-hanumate-namah': 'โอม หนุมะเต นมะห์',
    'builtin.hare-krishna': 'ฮาเร กฤษณะ',
    'builtin.hare-krishna-mahamantra':
        'ฮาเร กฤษณะ ฮาเร กฤษณะ กฤษณะ กฤษณะ ฮาเร ฮาเร\n'
        'ฮาเร ราม ฮาเร ราม ราม ราม ฮาเร ฮาเร',
    'builtin.om-namo-bhagavate-vasudevaya': 'โอม นโม ภควเต วาสุเทวายะ',
    'builtin.gayatri':
        'โอม ภูร์ ภุวะห์ สวะห์ ตัต สะวิตุร์ วะเรณยัม\n'
        'ภัรโค เทวัสยะ ธีมะหิ ธิโย โย นะห์ ประโจทะยาต',
    'builtin.mahamrityunjaya':
        'โอม ตรยัมพะกัม ยะชามะเห สุคันธิม ปุษฏิวรรธะนัม\n'
        'อุรวารุกะมิวะ พันธะนาน มฤตโยร์ มุกษียะ มามฤตาต',
    'builtin.waheguru': 'วาเหคุรุ วาเหคุรุ',
    'builtin.satnam-waheguru': 'สัตนาม วาเหคุรุ',
    'builtin.sita-ram': 'สีดา ราม',
    'builtin.shri-ram-jai-ram': 'ศรี ราม ชัย ราม ชัย ชัย ราม',
    'builtin.om-gam-ganapataye-namah': 'โอม กัม คณปตเย นมะห์',
    'builtin.om-shri-mahalakshmyai-namah': 'โอม ศรี มหาลักษมไย นมะห์',
    'builtin.om-aim-saraswatyai-namah': 'โอม ไอม สรัสวัตไย นมะห์',
    'builtin.om': 'โอม',
    'builtin.radhe-krishna': 'ราเธ กฤษณะ',
    'builtin.om-namo-narayanaya': 'โอม นโม นารายณายะ',
    'builtin.om-sai-ram': 'โอม ไซ ราม',
    'builtin.hare-rama': 'ฮาเร ราม ฮาเร ราม ราม ราม ฮาเร ฮาเร',
    'builtin.shri-krishna': 'ศรี กฤษณะ',
  };
}
