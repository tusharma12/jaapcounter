"""JaapMitra: 13-week content calendar (12 Oct 2026 – 10 Jan 2027), one post a day.

Pillars: spiritual/emotional 25% · daily jaap habits 20% · hook/curiosity 20% ·
app demos 15% · family/older audience 10% · mantra-specific 10%.

Rule for every post: hook -> emotional/spiritual value -> tiny insight -> the app
appears naturally. No "download now" endings.

Motion posts are rendered by reels.py from `beats`. UGC posts carry a casting
brief (Indian creator archetypes, not real people), shot list, voiceover and
the app moment. Saints appear through their public-domain teachings; any clip
of a living saint must be licensed or used as a credited stitch with
permission, and never implied as an endorsement.
"""
import datetime as _dt

START = _dt.date(2026, 10, 12)


def H(text, **o): return ('hook', text, o)
def Ln(text, vis=None, **o): return ('line', text, dict(o, vis=vis))
def B(text, sub=None, **o): return ('big', text, dict(o, sub=sub))
def LI(title, items, **o): return ('list', title, dict(o, items=items))
def M(deva, translit=None, meaning=None, **o): return ('mantra', deva, dict(o, translit=translit, meaning=meaning))
def Q(text, by=None, meaning=None, **o): return ('quote', text, dict(o, by=by, meaning=meaning))
def G(text, n, **o): return ('grid', text, dict(o, n=n))
def A(text, screen='counter', **o): return ('app', text, dict(o, screen=screen))
def C(text, **o): return ('close', text, o)


def UGC(creator, setting, length, shots, vo, onscreen, app_moment, sound='Original voice + JaapMitra temple palette (tanpura + ghanti)', notes=''):
    return dict(creator=creator, setting=setting, length=length, shots=shots, vo=vo, onscreen=onscreen,
                app_moment=app_moment, sound=sound, notes=notes)


TAGS_EN = '#naamjaap #japamala #mantra #bhakti #sadhana #108'
TAGS_HI = '#नामजप #जपमाला #भक्ति #साधना #राधेराधे #naamjaap'

# Casting archetypes for UGC (Indian creators; brief your creator against one of these).
CREATORS = {
    'ananya': 'Ananya type: 20s woman, Delhi, Hindi + English, aesthetic puja-corner and morning-routine creator',
    'rohit': 'Rohit type: early-30s working professional, Mumbai, Hinglish, commute/office life',
    'kamla': 'Kamla Devi type: grandmother, 65–75, Varanasi or Prayagraj, Hindi, warm and unscripted',
    'meenakshi': 'Meenakshi type: mother in her 40s, Chennai, Tamil + English, home and family',
    'gurpreet': 'Gurpreet type: Punjabi family, Ludhiana/Amritsar, Punjabi + Hindi, Sikh household',
    'vrindavan': 'Braj couple type: young Krishna-devotee couple, Vrindavan/Mathura, Hindi, kirtan and seva',
    'priya': 'Priya type: new mother, late 20s, Ahmedabad, Gujarati + Hindi',
    'arjun': 'Arjun type: 19–21 student, Pune/Kota, Hindi + Marathi, exams and hostel life',
    'sharma': 'Sharma family type: three generations, Jaipur, Hindi, joint-family home',
    'swati': 'Swati type: mid-30s yoga/meditation teacher, Bengaluru/Rishikesh, English',
}

P = []


def post(pillar, fmt, lang, title, slug, hook, caption, tags, beats=None, ugc=None, sound='temple', bg='dawn',
         occasion='', notes=''):
    n = len(P) + 1
    d = START + _dt.timedelta(days=n - 1)
    P.append(dict(id=f'D{n:02d}', date=d.isoformat(), day=d.strftime('%a'), week=(n - 1) // 7 + 1, pillar=pillar,
                  format=fmt, lang=lang, title=title, slug=slug, hook=hook, caption=caption, tags=tags,
                  beats=beats or [], ugc=ugc, sound=sound, bg=bg, occasion=occasion, notes=notes))


SPIRIT, HABIT, HOOK, APP, FAMILY, MANTRA = ('Spiritual/emotional', 'Daily Jaap habit', 'Hook/curiosity',
                                            'App demonstration', 'Family/older audience', 'Mantra-specific')

# ================================================================ Week 1 · 12–18 Oct · Sharad Navratri

post(HABIT, 'motion', 'hi', 'Navratri 9-day jaap sankalp', 'navratri_9_din',
     'नवरात्रि के 9 दिन। रोज़ एक माला?',
     'नवरात्रि के 9 दिन, रोज़ एक माला। गिनती फ़ोन पर छोड़ दें, मन माँ में लगाएँ। कमेंट में "जय माता दी" लिखें और साथ जुड़ें।',
     '#नवरात्रि #जयमातादी #navratri2026 ' + TAGS_HI,
     [H('नवरात्रि के 9 दिन।\n*रोज़ एक माला?*', vis='diya', chip='नवरात्रि · दिन 2'),
      Ln('माँ के नाम\n*हर दिन 108 बार।*', vis='diyas'),
      G('9 दिन का संकल्प', 9, label='दिन {}'),
      A('गिनती ऐप पर छोड़ दें।\n*मन माँ में लगाएँ।*', mantra='जय माता दी'),
      C('जय माता दी।')],
     sound='conch', bg='temple', occasion='Sharad Navratri (11–19 Oct)')

post(HOOK, 'motion', 'en', 'Why 108 beads?', 'why_108',
     'Why does a mala have 108 beads?',
     'Every tradition has its own answer to 108. Which one did you learn at home?',
     '#why108 ' + TAGS_EN,
     [H('Why does a mala\n*have 108 beads?*', vis='hanging'),
      LI('A few traditional answers', ['108 Upanishads (Muktika canon)', '27 nakshatras × 4 padas', '1¹ × 2² × 3³ = 108']),
      B('108', sub='one full round of the mind'),
      A('One tap, one bead.\n*Never lose your place.*'),
      C('Which answer did\n*you grow up with?*')],
     sound='bowl')

post(SPIRIT, 'ugc', 'hi', "Grandmother's mala", 'dadi_ki_mala',
     'यह माला मेरी दादी की है।',
     'उनकी माला, मेरी साधना। आपके घर में किसकी माला है?',
     '#दादी #यादें ' + TAGS_HI,
     ugc=UGC(CREATORS['ananya'], 'Home puja corner, soft morning window light', '25–35s',
             ['ECU: पुरानी तुलसी माला हथेली में, अंगूठा मनकों पर (हुक बोलें)',
              'MS: दादी की फ़ोटो के पास दीया जलाना',
              'CU: माला फेरते हुए होंठों पर धीमे से "राधे राधे"',
              'OTS: गोद में दादी की माला, हाथ में फ़ोन पर जापमित्र, एक टैप',
              'WS: आँखें बंद, हल्की मुस्कान, दीये की लौ'],
             'यह माला मेरी दादी की है। वो रोज़ सुबह 11 माला करती थीं, एक भी दिन छोड़े बिना। अब मैं करती हूँ, उनकी माला के साथ। गिनती फ़ोन पर रहती है, ताकि मन बस नाम पर रहे। दादी, आप आज भी साथ हैं।',
             ['यह माला मेरी दादी की है।', 'रोज़ 11 माला। एक भी दिन नहीं छूटा।', 'उनकी माला, मेरी साधना।'],
             'शॉट 4: 2 सेकंड, फ़ोन पर काउंटर दिखे। ऐप का नाम न बोलें।'))

post(APP, 'motion', 'en', 'Blackout mode', 'blackout_eyes_closed',
     'Chant with your eyes closed?',
     'Pure black screen, a soft buzz on every bead. Chant at night without lighting up the room.',
     '#nightchanting #blackoutmode ' + TAGS_EN,
     [H('Chant with your\n*eyes closed?*', vis='moon', vis_y=1400),
      A('Blackout mode.\n*Pure black screen.*', 'blackout', dur=6.0),
      Ln('A gentle buzz\n*on every bead.*', vis='moon'),
      C('Nothing lights the room.\n*Only the Naam.*')],
     sound='night', bg='night')

post(MANTRA, 'motion', 'hi', 'Om Dum Durgayei Namah', 'om_dum_durgayei',
     'नवरात्रि का बीज मंत्र: ॐ दुं दुर्गायै नमः',
     'नवरात्रि में माँ दुर्गा का बीज मंत्र। ऐप में अपना मंत्र जोड़ें और 108 बार जप करें।',
     '#दुर्गा #नवरात्रि #बीजमंत्र ' + TAGS_HI,
     [H('नवरात्रि का\n*बीज मंत्र*', vis='om', chip='नवरात्रि · दिन 6'),
      M('ॐ दुं दुर्गायै नमः', 'Om Dum Durgayei Namah', 'माँ दुर्गा को नमन:\n*साहस और रक्षा की प्रार्थना*'),
      A('अपना मंत्र जोड़ें,\n*किसी भी लिपि में।*', 'add', typed='ॐ दुं दुर्गायै नमः', dur=6.4),
      A('और 108 बार\n*बिना गिने जपें।*', mantra='ॐ दुं दुर्गायै नमः', dur=5.0),
      C('जय माँ दुर्गा।')],
     sound='conch', bg='temple', occasion='Sharad Navratri')

post(SPIRIT, 'ugc', 'en', 'POV: first mala of Navratri morning', 'pov_navratri_morning',
     'POV: 5:30am, Navratri, first mala of the day.',
     'The house is still asleep. Just me, Maa and 108 names.',
     '#navratri #morningroutine ' + TAGS_EN,
     ugc=UGC(CREATORS['ananya'], 'Dawn, puja thali, red chunri, single diya', '15–20s',
             ['WS: alarm off at 5:30, window still blue',
              'CU: lighting the diya, flame catches',
              'Top shot: hand on phone screen tapping, mala beside it',
              'CU: lips moving softly, eyes closed',
              'End: counter hits 108, small smile, folds hands'],
             '(No VO. Text on screen only.)',
             ['POV: 5:30am. Navratri.', 'First mala of the day.', 'The house is asleep. Maa is awake.'],
             'Top shot of the counter filling (3s); the 108 completion glow is the payoff.',
             sound='Trending devotional audio (soft Durga stuti), or JaapMitra conch palette'))

post(HOOK, 'motion', 'hi', 'Where does the mind run during jaap?', 'man_kahan_bhagta',
     'जप करते समय आपका मन कहाँ भागता है?',
     'भटकना स्वाभाविक है। लौट आना ही साधना है। आपका मन कहाँ भागता है? कमेंट करें।',
     '#मन #ध्यान ' + TAGS_HI,
     [H('जप करते समय\n*मन कहाँ भागता है?*', vis='hanging'),
      LI('अक्सर यहाँ…', ['आज के काम', 'कल की बातें', '“कितनी गिनती हुई?”']),
      Ln('भटकना स्वाभाविक है।\n*लौट आना ही साधना है।*', vis='lotus'),
      A('कम से कम गिनती\n*की चिंता छोड़ें।*'),
      C('मन लौटे,\n*नाम पर।*')],
     sound='bowl', bg='lotus')

# ================================================================ Week 2 · 19–25 Oct · Dussehra, Sharad Purnima

post(HABIT, 'motion', 'en', "Navratri ends. Don't let the practice end.", 'navratri_ends_keep_going',
     "Navratri ends tomorrow. Your practice doesn't have to.",
     "Nine days built the habit. Day 10 keeps it. Keep your streak going after Navratri.",
     '#navratri #streak ' + TAGS_EN,
     [H("Navratri ends tomorrow.\n*Your practice doesn't.*", vis='diya'),
      G('9 days done', 9, upto=9, label='{} days'),
      Ln('Day 10 is where\n*a habit begins.*', vis='flame'),
      A('Keep the streak\n*going.*', 'progress', dur=5.0),
      C('One mala a day.\n*That is enough.*')],
     sound='temple')

post(MANTRA, 'motion', 'hi', 'Dussehra: Shri Ram Jai Ram', 'dussehra_shri_ram_jai_ram',
     'विजयादशमी पर 13 अक्षरों का मंत्र',
     'विजयादशमी की शुभकामनाएँ। "कलियुग केवल नाम अधारा।" आज 108 बार: श्री राम जय राम जय जय राम।',
     '#दशहरा #विजयादशमी #जयश्रीराम ' + TAGS_HI,
     [H('विजयादशमी पर\n*13 अक्षरों का मंत्र*', vis='sun', chip='दशहरा · 20 अक्टूबर'),
      M('श्री राम जय राम\nजय जय राम', 'Shri Ram Jai Ram Jai Jai Ram', 'राम नाम की विजय'),
      Q('कलियुग केवल नाम अधारा।\nसुमिरि सुमिरि नर उतरहिं पारा॥', 'गोस्वामी तुलसीदास, रामचरितमानस',
        'इस युग में नाम ही आधार है'),
      A('आज 108 बार।', mantra='श्री राम जय राम', dur=5.0),
      C('जय श्री राम।')],
     sound='conch', bg='temple', occasion='Dussehra 20 Oct')

post(SPIRIT, 'ugc', 'hi', 'What I did on a bad day', 'bure_din_me',
     'आज का दिन बहुत भारी था। फिर मैंने यह किया।',
     'हर दिन अच्छा नहीं होता। पर एक माला हमेशा साथ होती है।',
     '#मनकीबात ' + TAGS_HI,
     ugc=UGC(CREATORS['rohit'], 'Evening, office bag dropped by the door, dim room', '25–30s',
             ['CU: थका हुआ चेहरा, टाई ढीली करते हुए (हुक)',
              'MS: फ़ोन पर नोटिफ़िकेशन, उसे उल्टा रख देना',
              'CU: पुरानी माला दराज़ से निकालना',
              'Top shot: फ़ोन पर जापमित्र, अंधकार मोड, धीमे टैप',
              'WS: 10 मिनट बाद, कंधे ढीले, लंबी साँस'],
             'आज का दिन बहुत भारी था। मीटिंग, ट्रैफ़िक, बहस। घर आकर मैंने कुछ नहीं सोचा, बस एक माला की। 108 बार "राम"। समस्याएँ वहीं थीं, पर मैं थोड़ा शांत था। बस इतना ही चाहिए था।',
             ['आज का दिन बहुत भारी था।', 'फिर मैंने बस एक माला की।', 'समस्या वही, मन थोड़ा हल्का।'],
             'अंधकार मोड वाला टॉप शॉट, 3 सेकंड।',
             notes='Keep it honest; no claims of curing stress. Optional stitch: credited, permitted clip of a saint on naam jap, with the creator reacting.'))

post(APP, 'motion', 'en', '21 mantras or your own', 'mantra_library_paths',
     '21 sacred mantras. Or your own.',
     'Ram, Radha, Om Namah Shivaya, Waheguru, Gayatri, Maha Mantra… or add yours in any script.',
     '#mantras ' + TAGS_EN,
     [H('Every mantra\n*is a path.*', vis='lotus'),
      Q('As many faiths,\nso many paths.', 'Sri Ramakrishna', dur=4.2),
      A('21 sacred mantras\n*built in.*', 'list', dur=4.6),
      A('Or add your own,\n*in any script.*', 'add', typed='ॐ नमो नारायणाय', dur=7.0),
      C('Your mantra.\n*Your path.*')],
     sound='chimes', bg='lotus')

post(FAMILY, 'ugc', 'hi', 'Teaching Papa the app', 'papa_ko_sikhaya',
     'पापा को जप ऐप चलाना सिखाया…',
     'पापा कहते थे "मोबाइल में भगवान?" अब रोज़ सुबह उनका पहला टैप वही होता है।',
     '#पापा #परिवार ' + TAGS_HI,
     ugc=UGC(CREATORS['sharma'], 'Living room sofa, father (60s) with reading glasses', '25–40s',
             ['MS: बेटा/बेटी फ़ोन पकड़ाते हुए, पापा शक भरी नज़र (हुक)',
              'CU: "बस कहीं भी टैप करो, पापा"',
              'CU: पापा का पहला टैप, स्क्रीन पर मनका भरता है',
              'MS: पापा मुस्कुराते हुए "अरे, खुद गिन रहा है!"',
              'WS (अगली सुबह): पापा अकेले बालकनी में, फ़ोन और माला'],
             'बेटा: "पापा, बस कहीं भी टैप करो।" पापा: "मोबाइल में माला?" … (108 पूरे होने पर) पापा: "अरे, ये तो खुद गिन रहा है। अब गिनती की गड़बड़ नहीं।"',
             ['पापा को जप ऐप सिखाया…', '"मोबाइल में माला?"', 'अगली सुबह 👇'],
             'शॉट 3–4: असली प्रतिक्रिया ही असली विज्ञापन है।',
             sound='Natural audio; soft tanpura under the final shot'))

post(HABIT, 'ugc', 'en', '30 days of one mala a day', '30_days_one_mala',
     'I chanted one mala a day for 30 days. Honest results.',
     'No miracles, just a quieter mind and a habit I actually kept.',
     '#30daychallenge #habit ' + TAGS_EN,
     ugc=UGC(CREATORS['swati'], 'Yoga mat by a window, journal, phone', '30–45s',
             ['CU: progress screen showing a 30-day streak (hook)',
              'Talking head: three honest changes, counted on fingers',
              'B-roll: chai, mala, tapping the counter',
              'CU: journal page with "Day 30" written',
              'End: looking at camera, "start with one mala"'],
             "I chanted one mala a day for 30 days. Honest results. One: I stopped reaching for my phone first thing. Two: the 8 minutes became the calmest part of my day. Three: I missed one day, and the grace day saved my streak. No miracles, just a habit I kept. Start with one mala.",
             ['30 days. 1 mala a day.', '1. Phone second, Naam first', '2. Calmest 8 minutes of my day',
              '3. Missed a day, streak survived'],
             'Open on the real streak screen (2s); mention grace days naturally.',
             notes='Results must be the creator’s own experience; no health claims.'))

post(HOOK, 'motion', 'hi', 'Sharad Purnima: who is awake?', 'sharad_purnima_kojagari',
     'आज रात लक्ष्मी जी पूछती हैं: "को जागर्ति?"',
     'शरद पूर्णिमा को कोजागरी भी कहते हैं, यानी "कौन जाग रहा है?" आज चाँदनी में एक माला।',
     '#शरदपूर्णिमा #कोजागरी #लक्ष्मी ' + TAGS_HI,
     [H('आज रात पूछा जाता है:\n*"को जागर्ति?"*', vis='fullmoon', vis_y=1420, chip='शरद पूर्णिमा · 25 अक्टूबर'),
      Ln('यानी\n*"कौन जाग रहा है?"*', vis='fullmoon'),
      Ln('चाँदनी में बैठें,\n*एक माला करें।*', vis='moon'),
      A('अंधकार मोड:\n*चाँदनी ही रोशनी।*', 'blackout', mantra='ॐ श्री महालक्ष्म्यै नमः', dur=5.6),
      C('आज रात\n*आप जागिए।*')],
     sound='night', bg='night', occasion='Sharad Purnima 25 Oct')

# ================================================================ Week 3 · 26 Oct–1 Nov · Karwa Chauth

post(HABIT, 'motion', 'en', 'Start with one mala', 'start_with_one_mala',
     'The smallest sadhana that actually lasts.',
     'Same time. Same place. One mala. Make it too easy to skip skipping.',
     '#habits #morningroutine ' + TAGS_EN,
     [H('The smallest sadhana\n*that actually lasts.*', vis='mala', mala_to=108),
      LI('The rule', ['Same time', 'Same place', 'Just one mala']),
      B('8 min', sub='about one mala of a short mantra'),
      A('Tap anywhere.\n*Close your eyes.*'),
      C('Small. Daily.\n*Forever.*')],
     sound='bowl', bg='sage')

post(HOOK, 'motion', 'en', '3 traditional mala rules', 'mala_rules',
     '3 mala rules your grandmother knew.',
     'Traditions vary by sampradaya. Which of these were you taught?',
     '#japamala #tradition ' + TAGS_EN,
     [H('3 mala rules\n*your Nani knew.*', vis='hanging'),
      LI('Taught in many homes', ["Don't cross the guru bead", 'Turn the mala, start again', 'Index finger stays away']),
      Ln('Traditions differ.\n*The intention is the same.*', vis='lotus'),
      A('No mala today?\n*Your phone counts.*'),
      C('Which rule did\n*you grow up with?*')],
     sound='temple', notes='Phrase as tradition, not rules everyone must follow.')

post(SPIRIT, 'ugc', 'hi', '5am jaap routine', 'subah_5_baje',
     'सुबह 5 बजे का जप, बिना फ़िल्टर।',
     'ब्रह्म मुहूर्त, गरम पानी, एक दीया और 108 नाम। आपका जप कब होता है?',
     '#ब्रह्ममुहूर्त #सुबह ' + TAGS_HI,
     ugc=UGC(CREATORS['arjun'], 'Hostel room / small flat, desk lamp, winter shawl', '20–30s',
             ['घड़ी 4:58 (हुक टेक्स्ट)', 'चेहरे पर पानी, शॉल ओढ़ना', 'छोटा दीया, फ़ोटो फ़्रेम',
              'फ़ोन पर टैप, आँखें बंद, 3 सेकंड', 'खिड़की से पहली रोशनी'],
             '(बिना VO। सिर्फ़ टेक्स्ट और प्राकृतिक आवाज़ें।)',
             ['सुबह 5 बजे का जप।', 'कोई फ़िल्टर नहीं।', 'बस मैं, दीया और नाम।'],
             'टैप वाला शॉट: स्क्रीन पर मनके भरते दिखें।',
             sound='JaapMitra bowl palette, or trending soft flute'))

post(FAMILY, 'ugc', 'hi', 'Karwa Chauth: waiting for the moon', 'karwa_chauth_chand',
     'चाँद का इंतज़ार… नाम जप के साथ।',
     'करवा चौथ की शाम: व्रत, इंतज़ार और 108 बार नाम। सभी व्रतियों को शुभकामनाएँ।',
     '#करवाचौथ #चाँद ' + TAGS_HI,
     ugc=UGC(CREATORS['sharma'], 'Terrace at dusk, decorated thali, chalni, family in festive clothes', '20–30s',
             ['WS: छत पर सजी थाली, आसमान की ओर देखती महिलाएँ (हुक)',
              'CU: मेहंदी लगे हाथ फ़ोन पर टैप',
              'MS: सास-बहू साथ बैठकर जप',
              'CU: चाँद निकलता है (या छलनी से)',
              'MS: मुस्कान, प्रणाम'],
             'हर साल चाँद का इंतज़ार लंबा लगता था। इस बार हमने इंतज़ार को जप बना दिया। सास और मैं, साथ में, 108 बार।',
             ['चाँद का इंतज़ार…', '…इस बार नाम जप के साथ।', 'सास और बहू, एक साथ 108।'],
             'मेहंदी वाले हाथ और स्क्रीन, 2 सेकंड।',
             sound='Soft festive dhol fading into tanpura'),
     occasion='Karwa Chauth 29 Oct')

post(MANTRA, 'motion', 'en', 'Om Namah Shivaya: five syllables', 'om_namah_shivaya_5',
     'Om Namah Shivaya has 5 syllables. Each is said to stand for something.',
     'Na-Ma-Shi-Va-Ya, the Panchakshara. One traditional reading links the syllables to the five elements.',
     '#omnamahshivaya #mahadev #panchakshara ' + TAGS_EN,
     [H('5 syllables.\n*5 elements.*', vis='om'),
      M('ॐ नमः शिवाय', 'Om Namah Shivaya', 'The Panchakshara mantra'),
      LI('One traditional reading', ['Na · Ma: earth, water', 'Shi · Va: fire, air', 'Ya: space (akasha)']),
      A('108 times,\n*no counting stress.*', mantra='ॐ नमः शिवाय', dur=5.0),
      C('Har Har\n*Mahadev.*')],
     sound='om', bg='dark', notes='Interpretations vary across Shaiva traditions; keep "one traditional reading".')

post(SPIRIT, 'ugc', 'en', 'I chant on the metro', 'metro_chanting',
     'Nobody on this train knows I am chanting.',
     'A packed metro, earphones in, 108 Ram naam. Your commute can be your temple.',
     '#mumbailocal #commute ' + TAGS_EN,
     ugc=UGC(CREATORS['rohit'], 'Mumbai local / Delhi metro, standing, earphones in', '15–25s',
             ['POV crowded coach (hook text)', 'CU: thumb tapping phone at side, screen dimmed',
              'CU: lips barely moving', 'Window: city rushing by', 'Station arrives: counter at 108, small nod'],
             '(Text only.) Optional VO: "Two stops, one mala. Nobody knows. That\'s the point."',
             ['Nobody on this train knows…', "…I'm on my 3rd mala.", 'Commute = my temple.'],
             'Mention Blackout mode / volume buttons in caption, not on screen.',
             sound='Train ambience + soft tanpura'))

post(HABIT, 'motion', 'hi', '21-day sankalp', 'sankalp_21_din',
     '21 दिन। एक संकल्प। रोज़ 108।',
     'एक इरादा चुनें, उसे मन में रखें और 21 दिन रोज़ 108 बार जप करें। संकल्प मन को एक दिशा देता है।',
     '#संकल्प #21दिन ' + TAGS_HI,
     [H('21 दिन।\n*एक संकल्प।*', vis='flame'),
      Ln('एक इरादा चुनें।\n*उसे मन में रखें।*', vis='diya'),
      G('रोज़ 108 बार', 21, label='दिन {}'),
      A('संकल्प लें,\n*हर दिन निभाएँ।*', 'sankalp', day_to=9, dur=6.0),
      C('आज से दिन 1।')],
     sound='temple', bg='temple')

# ================================================================ Week 4 · 2–8 Nov · Dhanteras, Diwali

post(HOOK, 'motion', 'en', 'Manifest with a Sankalp', 'manifest_sankalp',
     'Forget vision boards. Try a Sankalp.',
     'Manifesting, the old way: one clear intention, one mantra, 108 times a day, 21 days. Write yours below.',
     '#manifestation #sankalp ' + TAGS_EN,
     [H('Forget vision boards.\n*Try a Sankalp.*', vis='flame'),
      LI('The old way to manifest', ['Say one clear intention', 'Chant 108 times', 'Repeat for 21 days']),
      Ln('Intention + repetition\n*= a focused mind.*', vis='mala'),
      A('Track every day\n*of your Sankalp.*', 'sankalp', day_to=12, dur=6.0),
      C('What is your\n*Sankalp?*')],
     sound='bowl', bg='lotus', notes='Frame as focus and intention; never promise money, love or health outcomes.')

post(APP, 'motion', 'hi', 'Progress & streaks', 'pragati_dekhen',
     'आपने इस हफ़्ते कितना जप किया?',
     'दैनिक, साप्ताहिक, मासिक और वार्षिक: अपनी साधना को बढ़ते देखें।',
     '#प्रगति ' + TAGS_HI,
     [H('इस हफ़्ते आपने\n*कितना जप किया?*', vis='mala', mala_to=72),
      A('अपनी साधना को\n*बढ़ते देखें।*', 'progress', dur=6.0),
      Ln('लय टूटने का डर?\n*छूट के दिन साथ हैं।*', vis='flame'),
      C('हर दिन,\n*थोड़ा और।*')],
     sound='bowl')

post(SPIRIT, 'ugc', 'en', 'Diwali puja-room clean-up', 'diwali_puja_clean',
     'Cleaning my puja room before Diwali, and finding this.',
     'Every Diwali I find something in the puja room I had forgotten. This year: my first mala.',
     '#diwali2026 #pujaroom ' + TAGS_EN,
     ugc=UGC(CREATORS['meenakshi'], 'Puja room, brass lamps, kolam at the door', '25–35s',
             ['Fast clean-up montage (hook)', 'CU: finding an old sandalwood mala in a drawer',
              'Talking head: who gave it to her', 'Polishing brass diya, kolam',
              'End: chanting with old mala, phone counting beside her'],
             'Every year before Diwali I clean the puja room, and every year I find something. This year it was my first mala, from my mother. It needs restringing. Until then, I chant with this, and let the phone keep count.',
             ['Cleaning my puja room before Diwali…', '…and I found this.', 'My first mala. From Amma.'],
             'Last shot: phone on the floor beside the brass lamp, counter visible.',
             sound='Soft nadaswaram / veena, or JaapMitra temple palette'))

post(HABIT, 'motion', 'en', 'Diwali week: protect your streak', 'diwali_streak',
     'Diwali week will try to break your streak.',
     'Guests, shopping, sweets, cleaning. Even one mala keeps the streak alive, and grace days cover a missed day.',
     '#diwali #streak ' + TAGS_EN,
     [H('Diwali week will try\n*to break your streak.*', vis='diyas'),
      LI('Busy-day plan', ['One mala before chai', 'One mala in the car', 'One before sleep']),
      A('Missed a day?\n*Grace days have you.*', 'progress', dur=5.4),
      C('Light the diya.\n*Keep the streak.*')],
     sound='temple', bg='temple', occasion='Diwali week')

post(MANTRA, 'motion', 'hi', 'Dhanteras: Mahalakshmi mantra', 'dhanteras_lakshmi',
     'धनतेरस पर लक्ष्मी जी का मंत्र, 108 बार।',
     'धनतेरस की शुभकामनाएँ। ॐ श्री महालक्ष्म्यै नमः, आज 108 बार। असली धन मन की शांति है।',
     '#धनतेरस #लक्ष्मी #दीपावली ' + TAGS_HI,
     [H('धनतेरस पर\n*लक्ष्मी जी का मंत्र*', vis='diyas', chip='धनतेरस · 6 नवंबर'),
      M('ॐ श्री महालक्ष्म्यै नमः', 'Om Shri Mahalakshmyai Namah', 'माँ लक्ष्मी को नमन'),
      A('आज 108 बार।', mantra='ॐ श्री महालक्ष्म्यै नमः', dur=5.2),
      C('शुभ धनतेरस।')],
     sound='temple', bg='temple', occasion='Dhanteras 6 Nov')

post(FAMILY, 'ugc', 'hi', 'Dadi and granddaughter chant together', 'dadi_poti_jap',
     'दादी माला पर, मैं फ़ोन पर। देखते हैं पहले कौन 108 पूरे करता है।',
     'एक तरफ़ 60 साल पुरानी आदत, दूसरी तरफ़ नई। नाम वही।',
     '#दादीपोती #दिवाली ' + TAGS_HI,
     ugc=UGC(CREATORS['kamla'] + ' + granddaughter (10–16)', 'Courtyard/aangan, rangoli, afternoon sun', '30–40s',
             ['WS: दोनों आमने-सामने बैठी (हुक टेक्स्ट)', 'CU: दादी की उँगलियाँ माला पर',
              'CU: पोती का अंगूठा फ़ोन पर', 'MS: दादी चुपके से फ़ोन में झाँकती हैं', 'End: दोनों एक साथ "राधे राधे", हँसी'],
             'पोती: "दादी, रेस?" दादी: "जप में रेस नहीं होती, बेटा।" (अंत में) दादी: "पर तेरी मशीन अच्छी है… मुझे भी सिखा।"',
             ['दादी माला पर, मैं फ़ोन पर।', 'पहले कौन 108?', 'अंत में दादी ने क्या कहा 👇'],
             'दादी का फ़ोन में झाँकना ही ऐप का प्राकृतिक क्षण है।',
             sound='Natural audio + ghanti at the end'))

post(SPIRIT, 'motion', 'en', 'Diwali: the diya at the door of the tongue', 'diwali_tulsidas_manideep',
     'This Diwali, light one more diya, at the door of your tongue.',
     'Tulsidas: keep the jewel-lamp of Ram naam at the threshold of your tongue, and there is light within and without. Shubh Deepavali.',
     '#diwali #tulsidas #ramnaam ' + TAGS_EN,
     [H('This Diwali,\n*light one more diya.*', vis='diyas', chip='Diwali · 8 Nov'),
      Q('राम नाम मनिदीप धरु\nजीह देहरीं द्वार।', 'Goswami Tulsidas',
        'Keep Ram naam like a lamp\n*at the door of your tongue.*', dur=5.6),
      Ln('Light inside,\n*light outside.*', vis='diya'),
      A('108 lamps of Naam\n*tonight.*', mantra='राम राम', dur=5.0),
      C('Shubh Deepavali.')],
     sound='temple', bg='temple', occasion='Diwali 8 Nov')

# ================================================================ Week 5 · 9–15 Nov · Govardhan, Bhai Dooj

post(HABIT, 'motion', 'hi', 'Back on track after Diwali', 'diwali_ke_baad',
     'दिवाली के बाद साधना की लय टूट गई?',
     'मिठाई, मेहमान, थकान, सब ठीक है। आज बस एक माला से फिर शुरू करें।',
     '#दिवाली ' + TAGS_HI,
     [H('दिवाली के बाद\n*लय टूट गई?*', vis='diya'),
      Ln('कोई बात नहीं।\n*आज फिर से शुरू।*', vis='sun'),
      B('1', sub='आज बस एक माला'),
      A('गिनती की चिंता नहीं।', mantra='राम राम', dur=5.0),
      C('फिर से,\n*दिन 1।*')],
     sound='bowl', bg='sage')

post(HOOK, 'motion', 'hi', 'Govardhan: 7 days on one finger', 'govardhan_7_din',
     'कृष्ण ने 7 दिन तक पर्वत उठाए रखा। और हम?',
     'गोवर्धन पूजा की शुभकामनाएँ। 7 दिन, एक उँगली, अडिग विश्वास। हम एक माला तो रोज़ कर सकते हैं।',
     '#गोवर्धनपूजा #कृष्ण #हरेकृष्ण ' + TAGS_HI,
     [H('7 दिन, एक उँगली पर\n*पूरा पर्वत।*', vis='rays', chip='गोवर्धन पूजा · 10 नवंबर'),
      Ln('अडिग रहना ही\n*भक्ति है।*', vis='lotus'),
      B('108', sub='हम रोज़ एक माला तो कर सकते हैं'),
      A('हरे कृष्ण,\n*108 बार।*', mantra='हरे कृष्ण', dur=5.0),
      C('जय गिरिराज धरण।')],
     sound='conch', bg='temple', occasion='Govardhan Puja 10 Nov')

post(FAMILY, 'ugc', 'hi', 'Bhai Dooj: 108 for my sister', 'bhai_dooj_108',
     'इस भाई दूज, मैंने बहन के लिए 108 बार जप किया।',
     'तिलक, मिठाई… और इस बार एक माला, बहन के नाम।',
     '#भाईदूज #भाईबहन ' + TAGS_HI,
     ugc=UGC(CREATORS['arjun'] + ' + elder sister', 'Home, tilak thali, morning', '25–35s',
             ['CU: तिलक लगते हुए (हुक टेक्स्ट)', 'MS: भाई चुपचाप फ़ोन पर जप कर रहा है',
              'CU: स्क्रीन 108 पर पहुँचती है', 'MS: बहन को स्क्रीन दिखाना, "तेरे लिए"', 'CU: बहन भावुक, हँसकर गले लगना'],
             'हर साल बहन मेरे लिए दुआ करती है। इस बार मैंने उसके लिए किया। 108 बार।',
             ['इस भाई दूज…', '…मैंने बहन के लिए 108 बार जप किया।'],
             'स्क्रीन दिखाने वाला पल ही payoff है।',
             sound='Emotional trending audio, or tanpura + chime'),
     occasion='Bhai Dooj 11 Nov')

post(APP, 'motion', 'en', 'Auto Jaap: hands-free', 'auto_jaap',
     'What if the beads moved for you?',
     'Auto Jaap counts at a steady pace you choose, from 1 second a bead. Chant along, hands free.',
     '#autojaap ' + TAGS_EN,
     [H('What if the beads\n*moved for you?*', vis='hanging'),
      A('Auto Jaap.\n*A steady pace you choose.*', 'auto', dur=6.0),
      Ln('Hands free.\n*Heart full.*', vis='lotus'),
      C('Just chant\n*along.*')],
     sound='bowl', bg='sage')

post(HOOK, 'motion', 'en', 'Bead 54', 'bead_54',
     'Something happens at bead 54.',
     'Halfway is where the mind usually wanders. Notice, smile, come back. That is the practice.',
     '#mindfulness ' + TAGS_EN,
     [H('Something happens\n*at bead 54.*', vis='mala', mala_to=54),
      B('54', sub='halfway: the mind starts to wander'),
      Ln('Notice it.\n*Smile. Come back.*', vis='lotus'),
      A("You don't lose your place.\n*The count waits.*", **{'from': 54}),
      C('Coming back\n*is the practice.*')],
     sound='bowl', bg='lotus')

post(SPIRIT, 'ugc', 'en', 'Chanting while my baby sleeps', 'baby_sleeps',
     'My baby finally fell asleep. This is my 10 minutes.',
     'New-mom sadhana: a dark room, a sleeping baby, 108 whispered names.',
     '#newmom #motherhood ' + TAGS_EN,
     ugc=UGC(CREATORS['priya'], 'Dark nursery, night light, baby in crib (face not shown)', '15–25s',
             ['CU: tiny hand curled around finger (hook)', 'MS: tiptoe away from crib',
              'CU: phone in Blackout mode, thumb tapping', 'CU: whisper "Shree Krishna"', 'End: text over dark frame'],
             '(Whisper) "Shree Krishna Sharanam Mamah"… (text only otherwise)',
             ['He finally fell asleep.', 'This is my 10 minutes.', 'Blackout mode. No light. Just Naam.'],
             'Blackout screen in the dark: show the pure-black screen and the dim count.',
             sound='Room tone + crickets (JaapMitra night palette)'))

post(SPIRIT, 'motion', 'hi', 'Kabir: turn the bead of the mind', 'kabir_man_ka_manka',
     'माला फेरत जुग भया, फिरा न मन का फेर।',
     'कबीर कहते हैं: हाथ का मनका छोड़ो, मन का मनका फेरो। गिनती फ़ोन संभाल ले, मन नाम में डूबे।',
     '#कबीर #दोहा #संतवाणी ' + TAGS_HI,
     [H('500 साल पहले\n*कबीर ने कहा था…*', vis='hanging'),
      Q('माला फेरत जुग भया, फिरा न मन का फेर।\nकर का मनका डार दे, मन का मनका फेर॥', 'संत कबीर',
        'हाथ की माला नहीं,\n*मन की माला फेरो।*', dur=6.4),
      Ln('गिनती हाथ पर छोड़ें,\n*मन नाम में डुबोएँ।*', vis='lotus'),
      A('कहीं भी टैप करें,\n*मन भीतर रखें।*', dur=5.0),
      C('मन का मनका\n*फेरें।*')],
     sound='om', bg='dark')

# ================================================================ Week 6 · 16–22 Nov

post(HABIT, 'motion', 'en', 'Habit stacking: chai + mala', 'chai_plus_mala',
     "You already have a habit you never miss. Attach jaap to it.",
     'Habit stacking: after the first sip of chai, one mala. What will you stack it with?',
     '#habitstacking #chai ' + TAGS_EN,
     [H("You never miss\n*your morning chai.*", vis='sun'),
      Ln('So attach\n*one mala to it.*', vis='hanging'),
      LI('Stack it', ['After chai → 1 mala', 'After bath → 1 mala', 'Before sleep → 1 mala']),
      A('Same time,\n*every day.*', 'progress', dur=5.0),
      C('What will you\n*stack it with?*')],
     sound='bowl', bg='sage')

post(HOOK, 'motion', 'hi', 'Why 108, not 100?', 'kyun_108_100_nahi',
     '108 ही क्यों? 100 क्यों नहीं?',
     'परंपरा में 108 के कई अर्थ बताए जाते हैं। आपने घर में क्या सुना है?',
     '#108 #रहस्य ' + TAGS_HI,
     [H('108 ही क्यों?\n*100 क्यों नहीं?*', vis='hanging'),
      LI('परंपरा में कहा जाता है', ['27 नक्षत्र × 4 चरण', 'सूर्य की दूरी ≈ 108 × व्यास', '1¹ × 2² × 3³ = 108']),
      B('108', sub='एक पूरा चक्र'),
      A('एक टैप, एक मनका।', mantra='राम राम', dur=5.0),
      C('आपने घर में\n*क्या सुना है?*')],
     sound='bowl', notes='Sun distance ≈ 107.6 sun diameters: keep "≈".')

post(SPIRIT, 'ugc', 'hi', "Chanting my mother's mantra", 'maa_ka_mantra',
     'यह मंत्र माँ रोज़ गाती थीं। अब मैं गाती हूँ।',
     'कुछ आवाज़ें चली जाती हैं, पर नाम रह जाता है। आपके घर का मंत्र कौन-सा है?',
     '#माँ #यादें ' + TAGS_HI,
     ugc=UGC(CREATORS['meenakshi'] + ' (or any 40s woman, Hindi)', 'Kitchen at dawn, mother’s photo with a garland', '25–35s',
             ['CU: माँ की फ़ोटो पर माला (हुक)', 'MS: वही बर्तन, वही रसोई, धीरे से गुनगुनाना',
              'CU: माँ की हस्तलिखित डायरी में मंत्र', 'CU: फ़ोन पर वही मंत्र जोड़ना (अपना मंत्र)', 'WS: आँखें बंद, जप'],
             'यह मंत्र माँ रोज़ सुबह रसोई में गाती थीं। अब वो नहीं हैं, पर मंत्र है। मैंने उनकी डायरी से इसे अपने फ़ोन में लिखा। अब हर सुबह 108 बार, उनके लिए।',
             ['यह मंत्र माँ रोज़ गाती थीं।', 'अब मैं गाती हूँ।', 'हर सुबह 108, उनके लिए।'],
             'डायरी से फ़ोन में मंत्र टाइप करना: "अपना मंत्र जोड़ें" का भावुक डेमो।',
             notes='Sensitive theme: creator’s own story only, with consent.'))

post(APP, 'motion', 'hi', 'Blackout mode (Hindi)', 'andhkar_mode',
     'रात को जप करते समय फ़ोन की रोशनी चुभती है?',
     'अंधकार मोड: पूरी काली स्क्रीन, हर मनके पर हल्का कंपन। आँखें बंद, गिनती चालू।',
     '#अंधकारमोड #रात ' + TAGS_HI,
     [H('रात में फ़ोन की\n*रोशनी चुभती है?*', vis='moon', vis_y=1400),
      A('अंधकार मोड।\n*पूरी काली स्क्रीन।*', 'blackout', dur=6.0),
      Ln('हर मनके पर\n*हल्का कंपन।*', vis='moon'),
      C('आँखें बंद,\n*गिनती चालू।*')],
     sound='night', bg='night')

post(FAMILY, 'ugc', 'en', '72-year-old Nani tries a jaap app', 'nani_tries_app',
     'My 72-year-old Nani tried a jaap app for the first time.',
     'Big text, tap anywhere, and the first thing she said was…',
     '#nani #grandparents ' + TAGS_EN,
     ugc=UGC(CREATORS['kamla'] + ' (filmed by grandchild, English captions)', 'Nani’s bed with a quilt, reading glasses', '25–40s',
             ['CU: Nani squinting at phone (hook)', 'Grandchild: "Just tap anywhere, Nani"',
              'CU: first tap, bead fills, Nani laughs', 'MS: chanting confidently, phone on lap',
              'End: Nani to camera, one line in Hindi with subtitles'],
             'Nani (Hindi, subtitled): "Isme toh galti hi nahi hoti… ab main 11 mala karungi." ("You can’t make a mistake on this… now I’ll do 11 malas.")',
             ['My 72-year-old Nani tried a jaap app…', 'First tap 👇', 'Her verdict:'],
             'Her first tap and laugh: unscripted is key.',
             sound='Natural audio'))

post(SPIRIT, 'ugc', 'en', 'A day of chanting in Vrindavan', 'vrindavan_day',
     '24 hours in Vrindavan, counting every Radhe Radhe.',
     'Every street says Radhe Radhe. I tried to count mine for a day.',
     '#vrindavan #radheradhe ' + TAGS_EN,
     ugc=UGC(CREATORS['vrindavan'], 'Vrindavan lanes, Yamuna ghat, temple aarti (no filming inside sanctums)', '30–45s',
             ['Hook text over lane with "Radhe Radhe" painted walls', 'Greeting shopkeepers "Radhe Radhe"',
              'Ghat at sunset, phone counting', 'Evening aarti outside temple', 'End: total count on progress screen'],
             'In Vrindavan, every hello is "Radhe Radhe". So I counted mine for a day. Morning chanting, the parikrama, every greeting. Final count 👇',
             ['24 hrs in Vrindavan', 'counting every Radhe Radhe', 'Final count:'],
             'Final reveal of the day’s total on the progress screen.',
             sound='Street kirtan/ambient + ghanti',
             notes='Respect temple photography rules; ask before filming people.'))

post(HABIT, 'motion', 'en', 'Your first 7 days', 'first_7_days',
     'The first 7 days are the hardest. Then it becomes yours.',
     'Day 1 feels like effort, day 7 feels like home. Tick off your first week.',
     '#7days #habit ' + TAGS_EN,
     [H('The first 7 days\n*are the hardest.*', vis='flame'),
      G('Your first week', 7, label='Day {}'),
      Ln('After that,\n*it becomes yours.*', vis='sun'),
      A('Watch the streak\n*grow.*', 'progress', dur=5.0),
      C('Start your\n*Day 1 today.*')],
     sound='chimes', bg='dawn')

# ================================================================ Week 7 · 23–29 Nov · Guru Nanak Jayanti

post(HOOK, 'motion', 'en', 'Japa vs meditation', 'japa_vs_meditation',
     'Japa vs meditation: what is the difference?',
     'Meditation steadies the mind on its own; japa gives it a sacred word to hold. Which one do you practise?',
     '#meditation #japa ' + TAGS_EN,
     [H('Japa vs meditation:\n*what is the difference?*', vis='lotus'),
      LI('Japa', ['A sacred name or mantra', 'Repeated with a mala', 'Counting keeps you anchored']),
      Ln('Japa gives the mind\n*something sacred to hold.*', vis='hanging'),
      A('Let the counting\n*hold itself.*', dur=5.0),
      C('Which do\n*you practise?*')],
     sound='bowl', bg='lotus')

post(MANTRA, 'motion', 'hi', 'Guru Nanak Jayanti: Waheguru', 'guru_nanak_waheguru',
     'नाम जपो, किरत करो, वंड छको।',
     'गुरु नानक देव जी के प्रकाश पर्व की लख-लख बधाइयाँ। नाम जपो, किरत करो, वंड छको। वाहेगुरु।',
     '#गुरुनानकजयंती #वाहेगुरु #gurpurab ' + TAGS_HI,
     [H('गुरु नानक देव जी की\n*तीन सीख*', vis='rays', chip='प्रकाश पर्व · 24 नवंबर'),
      LI('नाम जपो · किरत करो · वंड छको', ['नाम जपो: प्रभु का नाम', 'किरत करो: ईमानदारी से कमाओ', 'वंड छको: बाँटकर खाओ']),
      M('ਵਾਹਿਗੁਰੂ', 'Waheguru · वाहेगुरु', 'अद्भुत गुरु: नाम सिमरन'),
      A('नाम सिमरन,\n*हर सांस के साथ।*', mantra='वाहेगुरु', dur=5.0),
      C('वाहेगुरु जी का खालसा,\n*वाहेगुरु जी की फ़तेह।*', size=70)],
     sound='chimes', bg='dawn', occasion='Guru Nanak Jayanti 24 Nov',
     notes='Sikh content: no temple bell/conch; chimes palette only. Have a Sikh reviewer check the copy.')

post(SPIRIT, 'ugc', 'en', 'A saint’s line before exams', 'kabir_before_exams',
     'One line from Kabir I read before every exam.',
     '"Dukh mein sumiran sab kare…" Chant when it is easy, and the hard days get lighter.',
     '#exams #kabir #studentlife ' + TAGS_EN,
     ugc=UGC(CREATORS['arjun'], 'Study desk at night, notes everywhere, exam timetable on wall', '25–35s',
             ['CU: exam timetable (hook text)', 'CU: sticky note with Kabir doha on the monitor',
              'Talking head: reads the doha, explains in one line', 'Top shot: one mala before opening books', 'End: closes eyes, opens book'],
             '"Dukh mein sumiran sab kare, sukh mein kare na koy. Jo sukh mein sumiran kare, dukh kahe ko hoy." Everyone prays when things go wrong. Kabir says pray when they’re fine too. So: one mala before I study. Every day, not just exam week.',
             ['One line from Kabir', 'I read before every exam', 'One mala before I study, every day.'],
             'Top shot of one mala completing before the books open.',
             sound='Soft lo-fi bhajan, or JaapMitra bowl palette'))

post(APP, 'motion', 'en', 'Make it yours: themes', 'themes_falling_mantra',
     'Your mala, your colours.',
     '13 themes, bead mala or progress ring, and the falling mantra: your mantra drifts down with every bead.',
     '#themes ' + TAGS_EN,
     [H('Your mala,\n*your colours.*', vis='mala', mala_to=36),
      A('13 themes.\n*Falling mantra.*', 'themes', mantra='Radhe Radhe', dur=6.6),
      C('Make your sadhana\n*feel like yours.*')],
     sound='chimes', bg='dawn')

post(MANTRA, 'motion', 'en', 'The Maha Mantra: 16 words', 'maha_mantra_16',
     '16 words. 32 syllables. One Maha Mantra.',
     'The Hare Krishna Maha Mantra, from the Kali-Santarana Upanishad, as Chaitanya Mahaprabhu taught: chant humbly, always.',
     '#harekrishna #mahamantra #chaitanya ' + TAGS_EN,
     [H('16 words.\n*32 syllables.*', vis='hanging'),
      M('हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे\nहरे राम हरे राम राम राम हरे हरे', 'Hare Krishna Maha Mantra',
        'Kali-Santarana Upanishad', size=60, dur=5.6),
      Q('Humbler than a blade of grass,\nmore tolerant than a tree:\nchant the holy name always.',
        'Sri Chaitanya Mahaprabhu, Shikshashtakam 3', dur=5.4),
      A('16 rounds?\n*We count them all.*', mantra='हरे कृष्ण', dur=5.0),
      C('Hare Krishna.')],
     sound='temple', bg='temple')

post(SPIRIT, 'ugc', 'hi', 'My puja corner tour', 'pooja_kona_tour',
     '1BHK में भी मंदिर बन सकता है। मेरा पूजा कोना देखिए।',
     'जगह छोटी, भाव बड़ा। आपका पूजा कोना कैसा है? फ़ोटो कमेंट करें।',
     '#पूजाघर #मंदिर ' + TAGS_HI,
     ugc=UGC(CREATORS['priya'], '1BHK flat, small shelf temple, fairy lights', '20–30s',
             ['WS: छोटा फ़्लैट (हुक)', 'CU: लकड़ी का शेल्फ़-मंदिर, मूर्तियाँ', 'CU: आसन, माला, दीया',
              'CU: स्टैंड पर फ़ोन, जापमित्र खुला', 'WS: दीया जलाकर बैठना'],
             'घर छोटा है, पर यह कोना मेरा सबसे बड़ा कमरा है। आसन, दीया, ठाकुर जी, और मेरी गिनती वाला फ़ोन।',
             ['1BHK में भी मंदिर बन सकता है।', 'मेरा पूजा कोना ✨'],
             'स्टैंड पर रखा फ़ोन, सेटअप का हिस्सा।',
             sound='Trending aesthetic bhajan, or JaapMitra chimes'))

post(HOOK, 'motion', 'hi', 'Lost in counting, where is the jaap?', 'ginti_me_ulajhe',
     'गिनती में उलझे रहे, तो जप कहाँ गया?',
     'कबीर कहते हैं, दुख में सब याद करते हैं, सुख में कोई नहीं। आज, बिना वजह, एक माला।',
     '#कबीर #संतवाणी ' + TAGS_HI,
     [H('गिनती में उलझे,\n*तो जप कहाँ गया?*', vis='mala', mala_to=67),
      Q('दुख में सुमिरन सब करे, सुख में करे न कोय।\nजो सुख में सुमिरन करे, दुख काहे को होय॥', 'संत कबीर', dur=6.0),
      Ln('आज, बिना किसी वजह,\n*एक माला।*', vis='lotus'),
      A('गिनती हम करेंगे।', dur=4.6),
      C('सुख में भी\n*सुमिरन।*')],
     sound='om', bg='dark')

# ================================================================ Week 8 · 30 Nov–6 Dec

post(HABIT, 'motion', 'hi', 'Why the same time every day?', 'roz_ek_samay',
     'रोज़ एक ही समय पर जप क्यों?',
     'ब्रह्म मुहूर्त, सूर्योदय से लगभग डेढ़ घंटा पहले। पर सबसे अच्छा समय वो है जो रोज़ निभे।',
     '#ब्रह्ममुहूर्त ' + TAGS_HI,
     [H('रोज़ एक ही समय\n*पर जप क्यों?*', vis='sun'),
      LI('परंपरा कहती है', ['ब्रह्म मुहूर्त: भोर से पहले', 'संध्या: सूर्यास्त के समय', 'या वो समय जो रोज़ निभे']),
      Ln('मन को समय की\n*आदत पड़ जाती है।*', vis='hanging'),
      A('रोज़ की याद,\n*रोज़ की लय।*', 'progress', dur=5.0),
      C('आपका समय\n*कौन-सा है?*')],
     sound='temple', bg='sage')

post(HOOK, 'motion', 'en', 'Say it once, then chant 108', 'say_it_once',
     'Say your intention once. Then chant 108 times.',
     'A Sankalp is not wishing, it is intention plus practice. Say it once, then let the mantra carry it.',
     '#manifest #intention #sankalp ' + TAGS_EN,
     [H('Say your intention once.\n*Then chant 108 times.*', vis='flame'),
      Ln("Don't repeat the wish.\n*Repeat the Name.*", vis='mala'),
      B('21', sub='days to settle an intention'),
      A('Take a Sankalp.', 'sankalp', day_to=6, dur=5.6),
      C('Say it once.\n*Chant it daily.*')],
     sound='bowl', bg='lotus', notes='Manifestation framing: focus/intention only.')

post(HABIT, 'ugc', 'en', 'Day 1 vs Day 40 of my sankalp', 'day1_vs_day40',
     'Day 1 vs Day 40 of my Sankalp.',
     'Day 1: fidgeting, checking the count. Day 40: I forgot the phone was there.',
     '#40days #sankalp ' + TAGS_EN,
     ugc=UGC(CREATORS['swati'], 'Same spot, same outfit colour for both days (split screen)', '20–30s',
             ['Split screen: Day 1 left, Day 40 right (hook)', 'Day 1: fidgety, peeking at the count',
              'Day 40: still, eyes closed, steady taps', 'CU: Sankalp screen Day 40/40 complete', 'End: one line to camera'],
             'Day 1, I kept checking the count. Day 40, I forgot the phone was even there. That’s the whole point.',
             ['Day 1 vs Day 40', 'of my Sankalp', 'Day 40: forgot the phone was there.'],
             'The Sankalp "Day 40 / 40, complete" screen as the reveal.',
             sound='Trending "before/after" audio, or JaapMitra bowl'))

post(APP, 'motion', 'hi', 'Chant with calming music', 'sangeet_ke_saath',
     'संगीत के साथ जप, और अपनी आवाज़ में भी।',
     'शांत ध्वनियाँ चलाएँ, या अपनी रिकॉर्डिंग। संगीत बजते समय स्क्रीन चालू रहती है।',
     '#संगीत #शांति ' + TAGS_HI,
     [H('संगीत के साथ\n*जप करें।*', vis='bowl'),
      A('शांत ध्वनियाँ,\n*या अपनी रिकॉर्डिंग।*', 'music', dur=6.0),
      Ln('जाप करें, साँस लें,\n*शांत रहें।*', vis='bowl'),
      C('हर मनके में\n*शांति।*')],
     sound='bowl', bg='navy')

post(FAMILY, 'ugc', 'hi', "Mum's 10 minutes before everyone wakes", 'maa_ke_10_minute',
     'घर जागने से पहले, माँ के 10 मिनट।',
     'माँ सबसे पहले उठती हैं, और ये 10 मिनट सिर्फ़ उनके हैं।',
     '#माँ #सुबह ' + TAGS_HI,
     ugc=UGC(CREATORS['sharma'] + ' (mother, 40s, filmed by her child)', 'Kitchen + balcony, 5:45am', '20–30s',
             ['सोते हुए घर का WS (हुक)', 'माँ चुपचाप बालकनी में आसन बिछाती हैं', 'CU: फ़ोन पर टैप, तुलसी के पास',
              'चाय चढ़ाने से पहले 108 पूरा', 'बच्चे की आवाज़: "मम्मी, चाय!" माँ मुस्कुराती हैं'],
             '(टेक्स्ट) सबके उठने से पहले, माँ के 10 मिनट। (अंत में बच्चे की आवाज़) "मम्मी, चाय!"',
             ['घर जागने से पहले…', '…माँ के 10 मिनट।', 'ये 10 मिनट सिर्फ़ उनके हैं।'],
             'तुलसी के पास फ़ोन पर 108 पूरा होना।',
             sound='Morning birds + tanpura'))

post(HOOK, 'ugc', 'hi', 'Choosing a mala: rudraksha, tulsi, sandalwood', 'mala_kaise_chune',
     'रुद्राक्ष, तुलसी या चंदन, आपके लिए कौन-सी माला?',
     'परंपरा में अलग देवताओं के लिए अलग मालाएँ बताई जाती हैं। आपकी कौन-सी है?',
     '#रुद्राक्ष #तुलसीमाला #चंदन ' + TAGS_HI,
     ugc=UGC(CREATORS['vrindavan'], 'Table with three malas on a cloth, natural light', '30–40s',
             ['तीनों मालाएँ फ्रेम में (हुक)', 'CU: रुद्राक्ष, "शिव भक्त अक्सर…"', 'CU: तुलसी, "विष्णु/कृष्ण भक्त…"',
              'CU: चंदन, "शीतलता, किसी भी देवता…"', 'End: "और यात्रा में? फ़ोन।" (फ़ोन पर टैप)'],
             'रुद्राक्ष, अक्सर शिव भक्त। तुलसी, विष्णु और कृष्ण भक्त। चंदन, शीतल, सबके लिए। और जब माला साथ न हो? ये।',
             ['रुद्राक्ष, तुलसी या चंदन?', 'आपके लिए कौन-सी माला?', 'और यात्रा में? 📱'],
             'अंतिम पंचलाइन में फ़ोन, हल्का-फुल्का।',
             notes='Say "परंपरा में" (by tradition); practices differ by sampradaya.'))

post(SPIRIT, 'motion', 'en', 'Gita 6.35: practice', 'gita_abhyasa',
     'Krishna admits the mind is restless. Then he gives the fix.',
     'Bhagavad Gita 6.35: the mind is restless, but it is steadied by practice (abhyasa) and detachment.',
     '#bhagavadgita #krishna #abhyasa ' + TAGS_EN,
     [H('Even Krishna said\n*the mind is restless.*', vis='rays'),
      Q('Undoubtedly the mind is restless\nand hard to control, but by practice\nand detachment it is held.',
        'Bhagavad Gita 6.35', dur=6.0),
      B('Abhyasa', sub='practice: one mala, every day', size=200),
      A('Practice, counted.', 'progress', dur=5.0),
      C('Every day,\n*a little steadier.*')],
     sound='om', bg='dark')

# ================================================================ Week 9 · 7–13 Dec

post(HABIT, 'motion', 'en', "Missed a day? Don't restart", 'missed_a_day',
     'Missed a day? Do not restart from zero.',
     'Every 7 days in a row earns a grace day (up to 2). Miss one, and your streak stays.',
     '#streak #gracedays ' + TAGS_EN,
     [H('Missed a day?\n*Don’t restart from zero.*', vis='flame'),
      Ln('Guilt breaks more habits\n*than missed days do.*', vis='lotus'),
      A('Grace days keep\n*your streak alive.*', 'progress', dur=5.6),
      C('Just come back\n*today.*')],
     sound='bowl', bg='sage')

post(HOOK, 'motion', 'en', 'POV: lost count at 67', 'pov_lost_at_67',
     'POV: you lost count at 67. Again.',
     'Was it 67 or 76? We have all been there. Tap anywhere and let the count take care of itself.',
     '#pov #relatable ' + TAGS_EN,
     [H('POV: you lost count\n*at 67. Again.*', vis='hand', vis_y=1400, chip='POV'),
      Ln('Was it 67…\n*or 76?*', vis='hanging'),
      A('Tap anywhere.\n*It remembers.*', **{'from': 60}),
      C('Never start over\n*again.*')],
     sound='temple')

post(SPIRIT, 'ugc', 'en', 'Chanting under the stars', 'terrace_stars',
     'Winter night. Terrace. 108 names under the stars.',
     'The city sleeps, the stars are out, and it is just you and the Name.',
     '#winter #nightsky ' + TAGS_EN,
     ugc=UGC(CREATORS['ananya'], 'Rooftop at night, shawl, string lights off', '15–20s',
             ['Wide: night sky, city lights (hook)', 'CU: shawl, breath visible', 'CU: Blackout phone in lap',
              'Timelapse stars (if possible)', 'End: "108 · done" text'],
             '(Text only.)',
             ['Winter night.', 'Terrace.', '108 names under the stars.'],
             'Blackout screen: the dim count is the only light.',
             sound='JaapMitra night palette (crickets + low bell)'))

post(APP, 'motion', 'en', 'Any mala size', 'mala_size_108_54_27',
     '108, 54, 27, or your own number.',
     'Set any mala size: 108, 54, 27, or a custom count for your practice.',
     '#malasize ' + TAGS_EN,
     [H('108? 54? 27?\n*Your number.*', vis='mala', mala_to=54),
      A('Set any\n*mala size.*', 'add', typed='हरे राम', size_sel=1, dur=6.0),
      Ln('Short on time?\n*A half mala still counts.*', vis='hanging'),
      C('Your practice,\n*your count.*')],
     sound='chimes')

post(MANTRA, 'motion', 'hi', 'Mahamrityunjaya mantra', 'mahamrityunjaya',
     'महामृत्युंजय मंत्र: अर्थ के साथ।',
     'ऋग्वेद का महामृत्युंजय मंत्र, शिव से मंगल और रक्षा की प्रार्थना। अर्थ समझकर जप करें।',
     '#महामृत्युंजय #शिव #हरहरमहादेव ' + TAGS_HI,
     [H('महामृत्युंजय मंत्र,\n*अर्थ के साथ।*', vis='om'),
      M('ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्।\nउर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय मामृतात्॥',
        'Om Tryambakam Yajamahe…', 'त्रिनेत्र शिव को नमन:\n*बंधनों से मुक्ति की प्रार्थना*', size=46, dur=6.6),
      A('अर्थ समझें,\n*फिर 108 बार।*', mantra='महामृत्युंजय', dur=5.0),
      C('हर हर महादेव।')],
     sound='om', bg='dark', notes='No health claims; "मंगल और रक्षा की प्रार्थना" only.')

post(HABIT, 'ugc', 'hi', 'Five minutes on an office break', 'office_break_jap',
     'ऑफ़िस ब्रेक में सब फ़ोन चलाते हैं। मैं भी… पर ऐसे।',
     'चाय ब्रेक = जप ब्रेक। 5 मिनट, आधी माला, पूरा फ़र्क।',
     '#ऑफिसलाइफ #worklife ' + TAGS_HI,
     ugc=UGC(CREATORS['rohit'], 'Office pantry / stairwell, lanyard, laptop bag', '15–25s',
             ['दोस्त सोशल मीडिया स्क्रॉल कर रहे (हुक)', 'CU: मेरे फ़ोन पर भी… जापमित्र', 'सीढ़ी पर बैठकर 54 मनके',
              'बॉस का मैसेज आता है, शांति से उठना', 'End text'],
             '(टेक्स्ट) सब ब्रेक में फ़ोन चलाते हैं। मैं भी। बस थोड़ा अलग।',
             ['ऑफ़िस ब्रेक में सब फ़ोन चलाते हैं…', 'मैं भी 👀', '5 मिनट = आधी माला (54)'],
             'स्क्रॉल बनाम टैप का कंट्रास्ट ही हुक है।',
             sound='Trending comedic-to-calm transition audio'))

post(HABIT, 'motion', 'hi', '40-day sankalp: Day 1', 'sankalp_40_din_1',
     '40 दिन का संकल्प, आज दिन 1।',
     '40 दिन, रोज़ 10 माला। आज पहला दिन। कौन साथ है? कमेंट में "दिन 1" लिखें।',
     '#40दिन #संकल्प ' + TAGS_HI,
     [H('40 दिन का संकल्प।\n*आज दिन 1।*', vis='diya'),
      G('रोज़ 10 माला', 40, upto=1, label='दिन {}', dur=3.6),
      A('हर दिन की\n*गिनती साथ।*', 'sankalp', day_to=2, dur=5.4),
      C('कौन साथ है?\n*"दिन 1" लिखें।*')],
     sound='temple', bg='temple')

# ================================================================ Week 10 · 14–20 Dec · Gita Jayanti

post(HOOK, 'motion', 'hi', 'Sleepy during jaap? 3 kinds of japa', 'jap_me_neend',
     'जप करते समय नींद आती है?',
     'परंपरा में जप के तीन प्रकार बताए गए हैं: वाचिक, उपांशु, मानसिक। नींद आए तो वाचिक से शुरू करें।',
     '#जप #वाचिक #मानसिक ' + TAGS_HI,
     [H('जप करते समय\n*नींद आती है?*', vis='moon', vis_y=1420),
      LI('जप के तीन प्रकार', ['वाचिक: धीमी आवाज़ में', 'उपांशु: केवल होंठ हिलें', 'मानसिक: मन ही मन']),
      Ln('नींद आए तो\n*वाचिक से शुरू करें।*', vis='sun'),
      A('बैठें सीधे,\n*टैप करते रहें।*', dur=4.8),
      C('आप कौन-सा\n*जप करते हैं?*')],
     sound='bowl', bg='sage')

post(FAMILY, 'ugc', 'en', "Teaching my 6-year-old her first mantra", 'first_mantra_kid',
     "Teaching my 6-year-old her first mantra.",
     'She thinks it is a game. I think it is a blessing. Both are true.',
     '#parenting #kids ' + TAGS_EN,
     ugc=UGC(CREATORS['meenakshi'] + ' + daughter (6)', 'Floor seating, small idol, crayons nearby', '25–35s',
             ['CU: little hands folded (hook)', 'Mother says "Om Namah Shivaya", child repeats',
              'CU: child taps phone, beads light up, giggles', 'Child: "Amma, 10 more!"', 'End: both bow'],
             'She thinks it’s a game. Every tap lights a bead. I think it’s a blessing. Maybe it’s both.',
             ['Teaching my 6-year-old', 'her first mantra', '"Amma, 10 more!"'],
             'Child’s reaction to beads lighting up.',
             sound='Natural audio + chimes',
             notes='Child safety: no name, school or location details on screen.'))

post(SPIRIT, 'ugc', 'en', "My grandmother's 50-year habit", 'nani_50_saal',
     'My grandmother has chanted every single morning for 50 years.',
     '50 years, every morning. I asked her what kept her going. Her answer stayed with me.',
     '#grandmother #wisdom ' + TAGS_EN,
     ugc=UGC(CREATORS['kamla'], 'Grandmother on a charpai in winter sun, old rudraksha', '30–45s',
             ['CU: wrinkled hands with mala (hook text)', 'Grandchild off-camera: "Nani, why every day?"',
              'Talking head (Hindi, subtitled): her answer', 'B-roll: her chanting', 'End: grandchild chanting beside her with phone'],
             'Nani (subtitled): "Jis din nahi karti, us din kuch adhoora lagta hai. Naam se din poora hota hai." ("The day I skip feels incomplete. The Name completes the day.")',
             ['50 years. Every morning.', 'I asked her why.', 'Her answer:'],
             'Final shot: two generations, mala and phone side by side.',
             sound='Natural audio + tanpura'))

post(APP, 'motion', 'hi', 'Home-screen widget', 'home_widget',
     'ऐप खोले बिना आज का जाप देखें।',
     'होम स्क्रीन विजेट: आज की गिनती और आपकी लय, एक नज़र में।',
     '#विजेट ' + TAGS_HI,
     [H('ऐप खोले बिना\n*आज का जाप?*', vis='mala', mala_to=62),
      A('होम स्क्रीन विजेट।\n*एक नज़र में लय।*', 'widget', dur=5.6),
      C('हर बार फ़ोन देखें,\n*नाम याद आए।*')],
     sound='chimes')

post(MANTRA, 'motion', 'en', "Dhruva's mantra", 'dhruva_mantra',
     'The mantra a 5-year-old chanted until God appeared.',
     'In the Bhagavata, sage Narada gives young Dhruva the twelve-syllable mantra: Om Namo Bhagavate Vasudevaya.',
     '#dhruva #vishnu #bhagavatam ' + TAGS_EN,
     [H('The mantra a 5-year-old\n*chanted until God appeared.*', vis='rays'),
      Ln('Dhruva, from the\n*Bhagavata Purana.*', vis='sun'),
      M('ॐ नमो भगवते वासुदेवाय', 'Om Namo Bhagavate Vasudevaya', 'The 12-syllable mantra\n*(Dvadashakshari)*'),
      A('12 syllables,\n*108 times.*', mantra='ॐ नमो भगवते वासुदेवाय', dur=5.0),
      C('Devotion has\n*no age.*')],
     sound='conch', bg='temple')

post(SPIRIT, 'motion', 'hi', 'Gita Jayanti: karma, not fruit', 'gita_jayanti_2_47',
     'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।',
     'गीता जयंती की शुभकामनाएँ। कर्म पर अधिकार है, फल पर नहीं। जप करें, गिनती और फल छोड़ दें।',
     '#गीताजयंती #भगवद्गीता #कृष्ण ' + TAGS_HI,
     [H('गीता जयंती पर\n*एक श्लोक।*', vis='rays', chip='गीता जयंती'),
      Q('कर्मण्येवाधिकारस्ते\nमा फलेषु कदाचन।', 'भगवद्गीता 2.47', 'कर्म पर अधिकार है,\n*फल पर नहीं।*', dur=6.0),
      Ln('जप करें।\n*गिनती और फल छोड़ दें।*', vis='lotus'),
      A('गिनती हम पर।', mantra='हरे कृष्ण', dur=4.8),
      C('जय श्री कृष्ण।')],
     sound='conch', bg='temple', occasion='Gita Jayanti (19 or 20 Dec: confirm with Panchang)')

post(SPIRIT, 'ugc', 'hi', '18 malas for 18 chapters', 'gita_18_mala',
     'गीता के 18 अध्याय, 18 माला।',
     'गीता जयंती पर मेरा छोटा-सा संकल्प: हर अध्याय के लिए एक माला।',
     '#गीताजयंती #18अध्याय ' + TAGS_HI,
     ugc=UGC(CREATORS['vrindavan'], 'Gita on a stand, morning, temple courtyard or home', '25–35s',
             ['गीता खोलना (हुक)', 'हर अध्याय का नाम तेज़ कट्स में', 'फ़ोन पर माला गिनती 1/18… 18/18',
              'प्रगति स्क्रीन', 'प्रणाम'],
             'गीता जयंती पर मेरा संकल्प: 18 अध्याय, 18 माला। अध्याय पढ़ा, फिर एक माला।',
             ['गीता के 18 अध्याय…', '…18 माला।', 'आज का संकल्प।'],
             'माला की गिनती 18 तक पहुँचना।',
             sound='Gita path audio (licensed) or JaapMitra conch'),
     occasion='Gita Jayanti weekend')

# ================================================================ Week 11 · 21–27 Dec

post(HABIT, 'motion', 'en', 'Longest night, longest chant', 'longest_night',
     "Tonight is the longest night of the year.",
     'Winter solstice: the longest night. Try 3 malas tonight instead of 1.',
     '#wintersolstice #night ' + TAGS_EN,
     [H('Tonight is the\n*longest night of the year.*', vis='moon', vis_y=1420),
      Ln('More darkness,\n*more room for the Name.*', vis='moon'),
      B('3', sub='malas tonight, not 1'),
      A('Blackout mode\n*for the long night.*', 'blackout', dur=5.4),
      C('Let the night\n*be long.*')],
     sound='night', bg='night', occasion='Winter solstice 21 Dec')

post(HOOK, 'motion', 'en', 'You unlock your phone dozens of times a day', 'unlock_phone',
     'You unlock your phone dozens of times a day. Let it help once.',
     'Same phone, different purpose. One unlock a day, for the Name.',
     '#screentime #digitaldetox ' + TAGS_EN,
     [H('You unlock your phone\n*dozens of times a day.*', vis='none'),
      Ln('Let one of those\n*be for the Name.*', vis='hanging'),
      A('Same phone.\n*Different purpose.*', dur=5.0),
      C('One unlock\n*for God.*')],
     sound='bowl', bg='dark')

post(SPIRIT, 'ugc', 'en', 'Sunrise jaap by the river', 'sunrise_river',
     'Sunrise, a river, and 108 names.',
     'If you can, take your jaap outside once. It changes everything.',
     '#sunrise #ghats ' + TAGS_EN,
     ugc=UGC(CREATORS['swati'] + ' (or Varanasi/Rishikesh creator)', 'Ghat or lake at sunrise, mist', '15–20s',
             ['Wide sunrise over water (hook)', 'Walking down ghat steps', 'Sitting, phone on cloth, tapping',
              'Bell from a nearby temple', 'End text over sun'],
             '(Text only.)',
             ['Sunrise.', 'A river.', '108 names.'],
             'Phone on folded cloth, counter visible.',
             sound='Ghat ambience + temple bell'))

post(APP, 'motion', 'en', 'Take a Sankalp', 'take_a_sankalp_demo',
     'An 11, 21 or 40-day vow, tracked day by day.',
     'Pick a Sankalp, set a daily goal, and watch each day fill in.',
     '#sankalp ' + TAGS_EN,
     [H('A vow is easier\n*when you can see it.*', vis='diya'),
      A('11, 21 or 40 days.\n*Every day tracked.*', 'sankalp', day_to=40, dur=8.0),
      C('Take a Sankalp.\n*Keep it.*')],
     sound='temple')

post(FAMILY, 'ugc', 'hi', 'The whole family chants together', 'parivar_ek_saath',
     'छुट्टियों में पूरा परिवार, एक साथ 108।',
     'तीन पीढ़ियाँ, एक कमरा, एक मंत्र। आपके परिवार में सबसे ज़्यादा जप कौन करता है?',
     '#परिवार #सर्दीकीछुट्टियाँ ' + TAGS_HI,
     ugc=UGC(CREATORS['sharma'], 'Drawing room, everyone on the floor in a circle, winter evening', '25–35s',
             ['ऊपर से सर्कल का शॉट (हुक)', 'दादा माला पर, बच्चे फ़ोन पर, माँ ताली के साथ', 'तेज़ कट्स: हर व्यक्ति का चेहरा',
              'सब एक साथ "राधे राधे" पर ख़त्म', 'हँसी, प्रसाद'],
             '(टेक्स्ट + प्राकृतिक आवाज़)',
             ['छुट्टियों में पूरा परिवार…', '…एक साथ 108।', 'तीन पीढ़ियाँ, एक मंत्र।'],
             'बच्चों के फ़ोन पर गिनती, दादा की माला के साथ।',
             sound='Family chanting audio'))

post(APP, 'ugc', 'en', 'How many malas I chanted in 2026', 'my_2026_in_malas',
     'I counted every mala I chanted in 2026. Here is the number.',
     'Year-end reflection: the yearly chart does not lie. What would your number be?',
     '#yearinreview #2026 ' + TAGS_EN,
     ugc=UGC(CREATORS['ananya'], 'Cosy desk, fairy lights, journal', '20–30s',
             ['Hook text + hand covering phone screen', 'Reveal yearly chart on progress screen', 'Talking head: best month, hardest month',
              'One lesson learned', 'End: "Next year: ___" written in journal'],
             'I counted every mala I chanted this year. Best month: Kartik. Hardest: June. One lesson: consistency beats intensity.',
             ['I counted every mala in 2026', 'The number 👇', 'Next year:'],
             'Yearly chart reveal is the hook payoff.',
             sound='Trending year-in-review audio'))

post(APP, 'motion', 'hi', 'Radhe Radhe: falling mantra', 'radhe_radhe_falling',
     'वृंदावन में हर अभिवादन "राधे राधे" क्यों?',
     'वृंदावन में "राधे राधे" ही नमस्ते है। आपके हर टैप के साथ "राधे राधे" धीरे से गिरता है।',
     '#राधेराधे #वृंदावन #radheradhe ' + TAGS_HI,
     [H('वृंदावन में हर अभिवादन\n*"राधे राधे" क्यों?*', vis='lotus'),
      Ln('क्योंकि वहाँ हर बात\n*राधा जी से शुरू होती है।*', vis='lotus'),
      A('हर टैप के साथ\n*राधे राधे।*', 'falling', mantra='राधे राधे', dur=6.0),
      C('राधे राधे।')],
     sound='chimes', bg='lotus')

# ================================================================ Week 12 · 28 Dec–3 Jan · New Year

post(HABIT, 'motion', 'hi', "New Year resolution: jaap, not gym", 'naye_saal_jap',
     'नए साल का संकल्प: जिम नहीं, जप।',
     'जिम की मेंबरशिप फ़रवरी तक चलती है। जप की लय साल भर चल सकती है।',
     '#नयासाल #संकल्प #2027 ' + TAGS_HI,
     [H('नए साल का संकल्प:\n*जिम नहीं, जप।*', vis='flame'),
      Ln('जिम फ़रवरी तक,\n*जप साल भर।*', vis='hanging'),
      G('बस रोज़ एक माला', 21, upto=21, label='{} दिन', dur=4.2),
      A('1 जनवरी से\n*दिन 1।*', 'sankalp', day_to=3, dur=5.2),
      C('जिम भी करें,\n*जप भी करें।*')],
     sound='temple')

post(HOOK, 'motion', 'en', 'Manifesting 2027?', 'manifesting_2027',
     'Manifesting 2027? Start with one Sankalp.',
     'Before the vision board: one intention, one mantra, every day. Write your 2027 Sankalp below.',
     '#2027 #manifestation #newyear ' + TAGS_EN,
     [H('Manifesting 2027?\n*Start with one Sankalp.*', vis='sun'),
      LI('Your 2027 Sankalp', ['One clear intention', 'One mantra', 'Every single day']),
      Ln('A focused mind\n*moves mountains.*', vis='mala'),
      A('40 days to begin.', 'sankalp', day_to=8, dur=5.6),
      C('Write your Sankalp\n*below.*')],
     sound='bowl', bg='lotus', notes='Intention/focus framing; no guaranteed outcomes.')

post(SPIRIT, 'ugc', 'hi', 'What jaap taught me in 2026', 'jap_ne_sikhaya',
     '2026 में नाम जप ने मुझे क्या सिखाया।',
     'साल के अंत में, तीन सीखें। आपकी सबसे बड़ी सीख क्या रही?',
     '#2026 #सीख ' + TAGS_HI,
     ugc=UGC(CREATORS['ananya'], 'Window seat, diary, warm light', '25–35s',
             ['डायरी में "2026" (हुक)', 'टॉकिंग हेड: तीन सीखें', 'B-roll: साल भर के जप के छोटे क्लिप', 'प्रगति स्क्रीन (वार्षिक)', 'अंत: मुस्कान'],
             'पहली सीख: कम ही सही, रोज़। दूसरी: मन भटके, तो लौट आओ। तीसरी: गिनती की चिंता छोड़ो, नाम पकड़ो।',
             ['2026 में नाम जप ने', 'मुझे क्या सिखाया', '1. कम सही, पर रोज़'],
             'वार्षिक चार्ट, 2 सेकंड।',
             sound='Soft piano/flute bhajan'))

post(APP, 'motion', 'en', 'Your year in malas', 'year_in_malas',
     'Your 2026, counted in malas.',
     'Daily, weekly, monthly, yearly: every mala you chanted, in one place.',
     '#yearinreview ' + TAGS_EN,
     [H('Your 2026,\n*counted in malas.*', vis='mala', mala_to=108),
      A('Every mala,\n*every day.*', 'progress', dur=6.0),
      C('See you in 2027.\n*Same time, same Naam.*', size=72)],
     sound='chimes', bg='dawn')

post(SPIRIT, 'motion', 'en', 'First mala of 2027', 'first_mala_2027',
     'The first mala of the year.',
     'Begin the year the way you want to live it. First mala of 2027. Ram Ram.',
     '#newyear2027 #firstmala ' + TAGS_EN,
     [H('The first mala\n*of the year.*', vis='sun', chip='1 Jan 2027'),
      Ln('Begin the year\n*the way you want to live it.*', vis='sun'),
      A('108 to begin.', mantra='Ram Ram', dur=5.0),
      C('Happy New Year.\n*Ram Ram.*')],
     sound='temple', bg='dawn', occasion='New Year 1 Jan')

post(FAMILY, 'ugc', 'en', "Dad's first Sankalp", 'dad_first_sankalp',
     'My dad has never kept a New Year resolution. This year he took a Sankalp.',
     'Day 2 of Papa’s 40-day Sankalp. We are all watching (and cheering).',
     '#dad #newyear ' + TAGS_EN,
     ugc=UGC(CREATORS['sharma'] + ' (father 50s–60s, filmed by son/daughter)', 'Dining table, morning newspaper', '25–35s',
             ['Hook text over Dad reading paper', 'Child sets up Sankalp on his phone', 'Dad picks 40 days, a bit unsure',
              'Day 2: Dad shows the screen proudly', 'End: family cheering'],
             'Child: "Papa, 40 days?" Dad: "Arre, 40 kya, 41 karunga." (Day 2) Dad: "Dekho, Day 2!"',
             ["My dad has never kept a resolution…", "…this year he took a Sankalp.", 'Day 2 👇'],
             'The Sankalp "Day 2 / 40" screen in Dad’s hands.',
             sound='Natural audio + ghanti'))

post(HOOK, 'motion', 'hi', 'Counting on your fingers (kar-mala)', 'kar_mala',
     'माला न हो, तो उँगलियों पर कैसे गिनें?',
     'परंपरा में उँगलियों के पोरों पर गिनने की विधि "कर-माला" कहलाती है। और फ़ोन हो, तो बस टैप।',
     '#करमाला #जपविधि ' + TAGS_HI,
     [H('माला न हो,\n*तो कैसे गिनें?*', vis='hand', vis_y=1420),
      Ln('परंपरा में इसे\n*"कर-माला" कहते हैं।*', vis='hand'),
      LI('कर-माला', ['उँगलियों के पोरों पर', 'अंगूठे से गिनती', 'हर चक्र में 10 या 12']),
      A('या बस, कहीं भी टैप।', dur=4.8),
      C('आप कैसे\n*गिनते हैं?*')],
     sound='temple', notes='Kar-mala methods differ by tradition; keep it general.')

# ================================================================ Week 13 · 4–10 Jan

post(HABIT, 'motion', 'en', 'Week 1 of your 2027 Sankalp', 'week1_2027',
     'Week 1 of your 2027 Sankalp. Still going?',
     'Seven days in. This is where most resolutions fade, and where Sankalps take root.',
     '#2027 #sankalp #week1 ' + TAGS_EN,
     [H('Week 1 of 2027.\n*Still going?*', vis='flame'),
      G('Your 40-day Sankalp', 40, upto=7, label='Day {} / 40', dur=4.6),
      Ln('This is where resolutions fade,\n*and Sankalps take root.*', vis='lotus', size=66),
      A('33 days to go.', 'sadhana', day_from=7, day_to=8, dur=4.8),
      C('Keep going.')],
     sound='bowl', bg='sage')

post(HOOK, 'motion', 'en', 'Manasik japa', 'manasik_japa',
     'The quietest japa is said to be the most powerful.',
     'Tradition ranks japa: spoken (vachika), whispered (upamshu), mental (manasika). The silent one is said to go deepest.',
     '#manasikjapa #silence ' + TAGS_EN,
     [H('The quietest japa\n*is said to be the most powerful.*', vis='lotus'),
      LI('Tradition ranks them', ['Vachika: spoken aloud', 'Upamshu: whispered', 'Manasika: in the mind']),
      Ln('No sound.\n*No movement. Only Naam.*', vis='moon'),
      A('Silent screen,\n*silent japa.*', 'blackout', dur=5.0),
      C('Try 1 mala\n*in silence today.*')],
     sound='night', bg='night')

post(SPIRIT, 'ugc', 'en', 'Cold morning, warm chai, one mala', 'chai_mala_asmr',
     'Cold morning. Warm chai. One mala.',
     'Winter sadhana ASMR. No talking, just the sounds.',
     '#asmr #winter #chai ' + TAGS_EN,
     ugc=UGC(CREATORS['priya'], 'Kitchen/balcony in winter, steel glass of chai, shawl', '15–20s',
             ['CU: chai boiling (hook text)', 'CU: pouring, steam', 'CU: wrapped hands around glass',
              'Top: phone tapping beside chai', 'End: sip, eyes closed'],
             '(No VO. ASMR only.)',
             ['Cold morning.', 'Warm chai.', 'One mala.'],
             'Tap sounds + haptics are part of the ASMR.',
             sound='ASMR natural + soft bowl at end'))

post(APP, 'motion', 'hi', '21 mantras, or your own (Hindi)', '21_mantra_hindi',
     '21 पवित्र मंत्र, या अपना।',
     'राम, राधा, शिव, हनुमान, कृष्ण, गायत्री, वाहेगुरु… या अपना मंत्र, किसी भी लिपि में।',
     '#मंत्र ' + TAGS_HI,
     [H('21 पवित्र मंत्र,\n*या अपना।*', vis='om'),
      A('राम से वाहेगुरु तक,\n*सब एक जगह।*', 'list', dur=4.8),
      A('या अपना मंत्र,\n*किसी भी लिपि में।*', 'add', typed='जय श्री राम', dur=5.8),
      C('आपका मंत्र,\n*आपका तरीका।*')],
     sound='chimes', bg='dawn')

post(MANTRA, 'motion', 'en', 'Gayatri Mantra', 'gayatri_mantra',
     'The Gayatri Mantra, with meaning.',
     'From the Rig Veda (3.62.10), traditionally chanted at sunrise and sunset: a prayer for an illumined mind.',
     '#gayatrimantra #rigveda #sunrise ' + TAGS_EN,
     [H('The Gayatri Mantra,\n*with meaning.*', vis='sun'),
      M('ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं\nभर्गो देवस्य धीमहि धियो यो नः प्रचोदयात्॥', 'Rig Veda 3.62.10',
        'May the radiant light\n*illumine our minds.*', size=46, dur=6.4),
      Ln('Traditionally chanted\n*at sunrise and sunset.*', vis='sun'),
      A('108 at sunrise.', mantra='गायत्री मंत्र', dur=5.0),
      C('Om Shanti.')],
     sound='om', bg='dawn')

post(HABIT, 'ugc', 'hi', '40 days complete', '40_din_pure',
     '40 दिन पूरे हुए। सच में।',
     '40 दिन, 400 माला, एक भी दिन नहीं छूटा (एक छूट का दिन लगा 😅)। आपका अगला संकल्प?',
     '#40दिन #संकल्पपूर्ण ' + TAGS_HI,
     ugc=UGC(CREATORS['rohit'], 'Same spot as Day 1 video, mithai box', '20–30s',
             ['संकल्प स्क्रीन "40/40 पूर्ण" (हुक)', 'दिन 1 का पुराना क्लिप', 'तेज़ मोंटाज: अलग-अलग जगहें, एक टैप',
              'मिठाई बाँटना', 'कैमरे से: "अगला संकल्प: 21 दिन, परिवार के साथ"'],
             '40 दिन पूरे हुए। सच में। ट्रेन में, ऑफ़िस में, बीमारी में भी। एक दिन छूटा, पर लय नहीं टूटी। अगला संकल्प: परिवार के साथ।',
             ['40 दिन पूरे हुए।', 'सच में।', 'अगला संकल्प 👇'],
             'संकल्प पूर्ण स्क्रीन ही ओपनिंग शॉट।',
             sound='Celebratory dhol into ghanti'))

post(SPIRIT, 'motion', 'hi', '90 days later: Meera', '90_din_baad_meera',
     '90 दिन पहले आपने क्या सोचा था?',
     'मीरा कहती हैं: पायो जी मैंने राम रतन धन पायो। 90 दिन बाद, आपने क्या पाया?',
     '#मीराबाई #संतवाणी #90दिन ' + TAGS_HI,
     [H('90 दिन पहले\n*आपने क्या सोचा था?*', vis='none'),
      G('90 दिन', 90, upto=90, label='{} दिन', dur=4.6),
      Q('पायो जी मैंने\nराम रतन धन पायो।', 'मीराबाई', 'नाम ही असली धन है', dur=5.4),
      C('आपने क्या\n*पाया?*', vis='lotus')],
     sound='temple', bg='temple')

POSTS = P
assert len(POSTS) == 91, len(POSTS)
