part of 'nutrition.dart';

enum NutritionLanguage {
  /// English
  ENGLISH(stringValue: 'en'),

  /// Dzongkha
  DZONGKHA_LANGUAGE(stringValue: 'dz'),

  /// Japanese
  JAPANESE(stringValue: 'ja'),

  /// Malay
  MALAY(stringValue: 'ms'),

  /// Tagalog
  TAGALOG(stringValue: 'tl'),

  /// Moldovan
  MOLDOVAN(stringValue: 'mo'),

  /// Mongolian
  MONGOLIAN(stringValue: 'mn'),

  /// Korean
  KOREAN(stringValue: 'ko'),

  /// Luba-Katanga
  LUBA_KATANGA_LANGUAGE(stringValue: 'lu'),

  /// Kazakh
  KAZAKH(stringValue: 'kk'),

  /// Quechua
  QUECHUA_LANGUAGES(stringValue: 'qu'),

  /// Ukrainian
  UKRAINIAN(stringValue: 'uk'),

  /// Occitan
  OCCITAN(stringValue: 'oc'),

  /// Bihari
  BIHARI_LANGUAGES(stringValue: 'bh'),

  /// South Ndebele
  SOUTHERN_NDEBELE(stringValue: 'nr'),

  /// Bokmal
  BOKMAL(stringValue: 'nb'),

  /// Komi
  KOMI(stringValue: 'kv'),

  /// Modern Greek
  MODERN_GREEK(stringValue: 'el'),

  /// Fijian
  FIJIAN_LANGUAGE(stringValue: 'fj'),

  /// Zulu
  ZULU(stringValue: 'zu'),

  /// Ido
  IDO(stringValue: 'io'),

  /// Khmer
  KHMER(stringValue: 'km'),

  /// Sanskrit
  SANSKRIT(stringValue: 'sa'),

  /// Macedonian
  MACEDONIAN(stringValue: 'mk'),

  /// Sotho
  SOTHO(stringValue: 'st'),

  /// Scottish Gaelic
  SCOTTISH_GAELIC(stringValue: 'gd'),

  /// Marathi
  MARATHI(stringValue: 'mr'),

  /// Nauruan
  NAURUAN(stringValue: 'na'),

  /// Oromo
  OROMO(stringValue: 'om'),

  /// Welsh
  WELSH(stringValue: 'cy'),

  /// Vietnamese
  VIETNAMESE(stringValue: 'vi'),

  /// Bislama
  BISLAMA(stringValue: 'bi'),

  /// Somali
  SOMALI(stringValue: 'so'),

  /// Lithuanian
  LITHUANIAN(stringValue: 'lt'),

  /// Haitian Creole
  HAITIAN_CREOLE(stringValue: 'ht'),

  /// Malagasy
  MALAGASY(stringValue: 'mg'),

  /// Spanish
  SPANISH(stringValue: 'es'),

  /// Danish
  DANISH(stringValue: 'da'),

  /// Slovenian
  SLOVENE(stringValue: 'sl'),

  /// Icelandic
  ICELANDIC(stringValue: 'is'),

  /// Estonian
  ESTONIAN(stringValue: 'et'),

  /// Wolof
  WOLOF(stringValue: 'wo'),

  /// Hiri Motu
  HIRI_MOTU(stringValue: 'ho'),

  /// Tamil
  TAMIL(stringValue: 'ta'),

  /// Slovak
  SLOVAK(stringValue: 'sk'),

  /// Herero
  HERERO(stringValue: 'hz'),

  /// Italian
  ITALIAN(stringValue: 'it'),

  /// Irish
  IRISH(stringValue: 'ga'),

  /// Shona
  SHONA(stringValue: 'sn'),

  /// Marshallese
  MARSHALLESE(stringValue: 'mh'),

  /// French
  FRENCH(stringValue: 'fr'),

  /// Aymara
  AYMARA(stringValue: 'ay'),

  /// Hebrew
  HEBREW(stringValue: 'he'),

  /// Northern Sami
  NORTHERN_SAMI(stringValue: 'se'),

  /// Bengali
  BENGALI(stringValue: 'bn'),

  /// Odia
  ODIA(stringValue: 'or'),

  /// Malayalam
  MALAYALAM(stringValue: 'ml'),

  /// Dutch
  DUTCH(stringValue: 'nl'),

  /// Uyghur
  UYGHUR(stringValue: 'ug'),

  /// Serbian
  SERBIAN(stringValue: 'sr'),

  /// Tibetan
  TIBETAN_LANGUAGE(stringValue: 'bo'),

  /// Belarusian
  BELARUSIAN(stringValue: 'be'),

  /// Samoan
  SAMOAN(stringValue: 'sm'),

  /// Punjabi
  PUNJABI(stringValue: 'pa'),

  /// Russian
  RUSSIAN(stringValue: 'ru'),

  /// Tahitian
  TAHITIAN(stringValue: 'ty'),

  /// Interlingua
  INTERLINGUA(stringValue: 'ia'),

  /// Afar
  AFAR(stringValue: 'aa'),

  /// Greenlandic
  GREENLANDIC(stringValue: 'kl'),

  /// Latin
  LATIN(stringValue: 'la'),

  /// Chinese
  CHINESE(stringValue: 'zh'),

  /// Turkmen
  TURKMEN(stringValue: 'tk'),

  /// West Frisian
  WEST_FRISIAN(stringValue: 'fy'),

  /// Tsonga
  TSONGA(stringValue: 'ts'),

  /// Romansh
  ROMANSH(stringValue: 'rm'),

  /// Inupiaq
  INUPIAT_LANGUAGE(stringValue: 'ik'),

  /// Tajik
  TAJIK(stringValue: 'tg'),

  /// Burmese
  BURMESE(stringValue: 'my'),

  /// Javanese
  JAVANESE(stringValue: 'jv'),

  /// Chechen
  CHECHEN(stringValue: 'ce'),

  /// Assamese
  ASSAMESE(stringValue: 'as'),

  /// Unknown language
  UNKNOWN_LANGUAGE(stringValue: 'xx'),

  /// Arabic
  ARABIC(stringValue: 'ar'),

  /// Kinyarmanda
  KINYARWANDA(stringValue: 'rw'),

  /// Tonga
  TONGAN_LANGUAGE(stringValue: 'to'),

  /// Church Slavonic
  // same as OLD_CHURCH_SLAVONIC
  CHURCH_SLAVONIC(stringValue: 'cu'),

  /// Sinhala
  SINHALA(stringValue: 'si'),

  /// Armenian
  ARMENIAN(stringValue: 'hy'),

  /// Kurdish
  KURDISH(stringValue: 'ku'),

  /// Thai
  THAI(stringValue: 'th'),

  /// Cree
  CREE(stringValue: 'cr'),

  /// Swahili
  SWAHILI(stringValue: 'sw'),

  /// Gujarati
  GUJARATI(stringValue: 'gu'),

  /// Persian
  PERSIAN(stringValue: 'fa'),

  /// Bosnian
  BOSNIAN(stringValue: 'bs'),

  /// Amharic
  AMHARIC(stringValue: 'am'),

  /// Aragonese
  ARAGONESE(stringValue: 'an'),

  /// Croatian
  CROATIAN(stringValue: 'hr'),

  /// Chewa
  CHEWA(stringValue: 'ny'),

  /// Zhuang
  ZHUANG_LANGUAGES(stringValue: 'za'),

  /// Lingala
  LINGALA_LANGUAGE(stringValue: 'ln'),

  /// Bambara
  BAMBARA(stringValue: 'bm'),

  /// Limburgan
  LIMBURGISH_LANGUAGE(stringValue: 'li'),

  /// Nuosu
  NUOSU_LANGUAGE(stringValue: 'ii'),

  /// Kwanyama
  KWANYAMA(stringValue: 'kj'),

  /// Kirundi
  KIRUNDI(stringValue: 'rn'),

  /// Ewe
  EWE(stringValue: 'ee'),

  /// Faorese
  FAROESE(stringValue: 'fo'),

  /// Sindhi
  SINDHI(stringValue: 'sd'),

  /// Corsican
  CORSICAN(stringValue: 'co'),

  /// Kannada
  KANNADA(stringValue: 'kn'),

  /// Norwegian
  NORWEGIAN(stringValue: 'no'),

  /// Sundanese
  SUNDANESE_LANGUAGE(stringValue: 'su'),

  /// Georgian
  GEORGIAN(stringValue: 'ka'),

  /// Hausa
  HAUSA(stringValue: 'ha'),

  /// Tswana
  TSWANA(stringValue: 'tn'),

  /// Catalan
  CATALAN(stringValue: 'ca'),

  /// Ndonga
  NDONGA_DIALECT(stringValue: 'ng'),

  /// Igbo
  IGBO_LANGUAGE(stringValue: 'ig'),

  /// Afrikaans
  AFRIKAANS(stringValue: 'af'),

  /// Polish
  POLISH(stringValue: 'pl'),

  /// Kashmiri
  KASHMIRI(stringValue: 'ks'),

  /// Maori
  MAORI(stringValue: 'mi'),

  /// Hungarian
  HUNGARIAN(stringValue: 'hu'),

  /// Breton
  BRETON(stringValue: 'br'),

  /// Portuguese
  PORTUGUESE(stringValue: 'pt'),

  /// Bulgarian
  BULGARIAN(stringValue: 'bg'),

  /// Avestan
  AVESTAN(stringValue: 'ae'),

  /// Nepali
  NEPALI(stringValue: 'ne'),

  /// Twi
  TWI(stringValue: 'tw'),

  /// Uzbek
  UZBEK(stringValue: 'uz'),

  /// Chamorro
  CHAMORRO(stringValue: 'ch'),

  /// Guarani
  GUARANI(stringValue: 'gn'),

  /// Nynorsk
  NYNORSK(stringValue: 'nn'),

  /// Azerbaijani
  AZERBAIJANI(stringValue: 'az'),

  /// Czech
  CZECH(stringValue: 'cs'),

  /// Navajo
  NAVAJO(stringValue: 'nv'),

  /// Finnish
  FINNISH(stringValue: 'fi'),

  /// Luxembourgish
  LUXEMBOURGISH(stringValue: 'lb'),

  /// Swedish
  SWEDISH(stringValue: 'sv'),

  /// Yiddish
  YIDDISH(stringValue: 'yi'),

  /// Inuktitut
  INUKTITUT(stringValue: 'iu'),

  /// Lao
  LAO(stringValue: 'lo'),

  /// Chuvash
  CHUVASH(stringValue: 'cv'),

  /// Maltese
  MALTESE(stringValue: 'mt'),

  /// Maldivian
  MALDIVIAN_LANGUAGE(stringValue: 'dv'),

  /// Interlingue
  INTERLINGUE(stringValue: 'ie'),

  /// Ossetian
  OSSETIAN(stringValue: 'os'),

  /// Bashkir
  BASHKIR(stringValue: 'ba'),

  /// Ojibwe
  OJIBWE(stringValue: 'oj'),

  /// Kanuri
  KANURI(stringValue: 'kr'),

  /// Indonesian
  INDONESIAN(stringValue: 'id'),

  /// Sardinian
  SARDINIAN_LANGUAGE(stringValue: 'sc'),

  /// Akan
  AKAN(stringValue: 'ak'),

  /// Manx
  MANX(stringValue: 'gv'),

  /// Turkish
  TURKISH(stringValue: 'tr'),

  /// Esperanto
  ESPERANTO(stringValue: 'eo'),

  /// Pashto
  PASHTO(stringValue: 'ps'),

  /// Kyrgyz
  KYRGYZ(stringValue: 'ky'),

  /// Volapuk
  VOLAPUK(stringValue: 'vo'),

  /// Avar
  AVAR(stringValue: 'av'),

  /// Sango
  SANGO(stringValue: 'sg'),

  /// Venda
  VENDA(stringValue: 've'),

  /// Albanian
  ALBANIAN(stringValue: 'sq'),

  /// Basque
  BASQUE(stringValue: 'eu'),

  /// Fulah
  FULA_LANGUAGE(stringValue: 'ff'),

  /// German
  GERMAN(stringValue: 'de'),

  /// Latvian
  LATVIAN(stringValue: 'lv'),

  /// Cornish
  CORNISH(stringValue: 'kw'),

  /// Pali
  PALI(stringValue: 'pi'),

  /// Tatar
  TATAR(stringValue: 'tt'),

  /// Romanian
  ROMANIAN(stringValue: 'ro'),

  /// Gikuyu
  GIKUYU(stringValue: 'ki'),

  /// Tigrinya
  TIGRINYA(stringValue: 'ti'),

  /// Galician
  GALICIAN(stringValue: 'gl'),

  /// Telugu
  TELUGU(stringValue: 'te'),

  /// Hindi
  HINDI(stringValue: 'hi'),

  /// Kongo
  KONGO_LANGUAGE(stringValue: 'kg'),

  /// Xhosa
  XHOSA(stringValue: 'xh'),

  /// Swazi
  SWAZI(stringValue: 'ss'),

  /// Luganda
  LUGANDA(stringValue: 'lg'),

  /// Urdu
  URDU(stringValue: 'ur'),

  /// North Ndbele
  NORTHERN_NDEBELE_LANGUAGE(stringValue: 'nd'),

  /// Yoruba
  YORUBA(stringValue: 'yo'),

  /// World, as pseudo language
  WORLD(stringValue: 'world'),

  /// Undefined language
  UNDEFINED(stringValue: '-');

  const NutritionLanguage({
    required this.stringValue,
  });

  /// ISO 639-1
  final String stringValue;

  static NutritionLanguage? fromString(final String? stringValue) =>
      NutritionLanguage.values.firstWhereOrNull(
        (final NutritionLanguage language) =>
            language.stringValue == stringValue,
      );

  static List<NutritionLanguage> get sortedValues =>
      NutritionLanguage.values.toList()..sort((a, b) => a.t.compareTo(b.t));

  OpenFoodFactsLanguage get offApiLanguage =>
      OpenFoodFactsLanguage.fromOffTag(stringValue)!;

  String get t => 'food.languages.${stringValue.toLowerCase()}'.t;
}

enum NutritionCountry {
  /// Andorra
  ANDORRA(stringValue: 'ad'),

  /// United Arab Emirates
  UNITED_ARAB_EMIRATES(stringValue: 'ae'),

  /// Afghanistan
  AFGHANISTAN(stringValue: 'af'),

  /// Antigua and Barbuda
  ANTIGUA_AND_BARBUDA(stringValue: 'ag'),

  /// Anguilla
  ANGUILLA(stringValue: 'ai'),

  /// Albania
  ALBANIA(stringValue: 'al'),

  /// Armenia
  ARMENIA(stringValue: 'am'),

  /// Angola
  ANGOLA(stringValue: 'ao'),

  /// Antarctica
  ANTARCTICA(stringValue: 'aq'),

  /// Argentina
  ARGENTINA(stringValue: 'ar'),

  /// American Samoa
  AMERICAN_SAMOA(stringValue: 'as'),

  /// Austria
  AUSTRIA(stringValue: 'at'),

  /// Australia
  AUSTRALIA(stringValue: 'au'),

  /// Aruba
  ARUBA(stringValue: 'aw'),

  /// Åland Islands
  ALAND_ISLANDS(stringValue: 'ax'),

  /// Azerbaijan
  AZERBAIJAN(stringValue: 'az'),

  /// Bosnia and Herzegovina
  BOSNIA_AND_HERZEGOVINA(stringValue: 'ba'),

  /// Barbados
  BARBADOS(stringValue: 'bb'),

  /// Bangladesh
  BANGLADESH(stringValue: 'bd'),

  /// Belgium
  BELGIUM(stringValue: 'be'),

  /// Burkina Faso
  BURKINA_FASO(stringValue: 'bf'),

  /// Bulgaria
  BULGARIA(stringValue: 'bg'),

  /// Bahrain
  BAHRAIN(stringValue: 'bh'),

  /// Burundi
  BURUNDI(stringValue: 'bi'),

  /// Benin
  BENIN(stringValue: 'bj'),

  /// Saint Barthélemy
  SAINT_BARTHELEMY(stringValue: 'bl'),

  /// Bermuda
  BERMUDA(stringValue: 'bm'),

  /// Brunei Darussalam
  BRUNEI_DARUSSALAM(stringValue: 'bn'),

  /// Bolivia (Plurinational State of)
  BOLIVIA(stringValue: 'bo'),

  /// Bonaire, Sint Eustatius and Saba
  BONAIRE(stringValue: 'bq'),

  /// Brazil
  BRAZIL(stringValue: 'br'),

  /// Bahamas
  BAHAMAS(stringValue: 'bs'),

  /// Bhutan
  BHUTAN(stringValue: 'bt'),

  /// Bouvet Island
  BOUVET_ISLAND(stringValue: 'bv'),

  /// Botswana
  BOTSWANA(stringValue: 'bw'),

  /// Belarus
  BELARUS(stringValue: 'by'),

  /// Belize
  BELIZE(stringValue: 'bz'),

  /// Canada
  CANADA(stringValue: 'ca'),

  /// Cocos (Keeling) Islands
  COCOS_ISLANDS(stringValue: 'cc'),

  /// Congo, Democratic Republic of the
  DEMOCRATIC_REPUBLIC_OF_THE_CONGO(stringValue: 'cd'),

  /// Central African Republic
  CENTRAL_AFRICAN_REPUBLIC(stringValue: 'cf'),

  /// Congo
  CONGO(stringValue: 'cg'),

  /// Switzerland
  SWITZERLAND(stringValue: 'ch'),

  /// Côte d'Ivoire
  COTE_D_IVOIRE(stringValue: 'ci'),

  /// Cook Islands
  COOK_ISLANDS(stringValue: 'ck'),

  /// Chile
  CHILE(stringValue: 'cl'),

  /// Cameroon
  CAMEROON(stringValue: 'cm'),

  /// China
  CHINA(stringValue: 'cn'),

  /// Colombia
  COLOMBIA(stringValue: 'co'),

  /// Costa Rica
  COSTA_RICA(stringValue: 'cr'),

  /// Cuba
  CUBA(stringValue: 'cu'),

  /// Cabo Verde
  CABO_VERDE(stringValue: 'cv'),

  /// Curaçao
  CURACAO(stringValue: 'cw'),

  /// Christmas Island
  CHRISTMAS_ISLAND(stringValue: 'cx'),

  ///Cyprus
  CYPRUS(stringValue: 'cy'),

  /// Czechia
  CZECHIA(stringValue: 'cz'),

  /// Germany
  GERMANY(stringValue: 'de'),

  /// Djibouti
  DJIBOUTI(stringValue: 'dj'),

  /// Denmark
  DENMARK(stringValue: 'dk'),

  /// Dominica
  DOMINICA(stringValue: 'dm'),

  /// Dominican Republic
  DOMINICAN_REPUBLIC(stringValue: 'do'),

  /// Algeria
  ALGERIA(stringValue: 'dz'),

  /// Ecuador
  ECUADOR(stringValue: 'ec'),

  /// Estonia
  ESTONIA(stringValue: 'ee'),

  /// Egypt
  EGYPT(stringValue: 'eg'),

  /// Western Sahara
  WESTERN_SAHARA(stringValue: 'eh'),

  /// Eritrea
  ERITREA(stringValue: 'er'),

  /// Spain
  SPAIN(stringValue: 'es'),

  /// Ethiopia
  ETHIOPIA(stringValue: 'et'),

  /// Finland
  FINLAND(stringValue: 'fi'),

  /// Fiji
  FIJI(stringValue: 'fj'),

  /// Falkland Islands (Malvinas)
  FALKLAND_ISLANDS(stringValue: 'fk'),

  /// Micronesia (Federated States of)
  MICRONESIA(stringValue: 'fm'),

  /// Faroe Islands
  FAROE_ISLANDS(stringValue: 'fo'),

  /// France
  FRANCE(stringValue: 'fr'),

  /// Gabon
  GABON(stringValue: 'ga'),

  /// United Kingdom of Great Britain and Northern Ireland
  // in OFF this is not 'gb'
  UNITED_KINGDOM(stringValue: 'uk'),

  /// Grenada
  GRENADA(stringValue: 'gd'),

  /// Georgia
  GEORGIA(stringValue: 'ge'),

  /// French Guiana
  FRENCH_GUIANA(stringValue: 'gf'),

  /// Guernsey
  GUERNSEY(stringValue: 'gg'),

  /// Ghana
  GHANA(stringValue: 'gh'),

  /// Gibraltar
  GIBRALTAR(stringValue: 'gi'),

  /// Greenland
  GREENLAND(stringValue: 'gl'),

  /// Gambia
  GAMBIA(stringValue: 'gm'),

  /// Guinea
  GUINEA(stringValue: 'gn'),

  /// Guadeloupe
  GUADELOUPE(stringValue: 'gp'),

  /// Equatorial Guinea
  EQUATORIAL_GUINEA(stringValue: 'gq'),

  /// Greece
  GREECE(stringValue: 'gr'),

  /// South Georgia and the South Sandwich Islands
  SOUTH_GEORGIA(stringValue: 'gs'),

  /// Guatemala
  GUATEMALA(stringValue: 'gt'),

  /// Guam
  GUAM(stringValue: 'gu'),

  /// Guinea-Bissau
  GUINEA_BISSAU(stringValue: 'gw'),

  /// Guyana
  GUYANA(stringValue: 'gy'),

  /// Hong Kong
  HONG_KONG(stringValue: 'hk'),

  /// Heard Island and McDonald Islands
  HEARD_ISLAND(stringValue: 'hm'),

  /// Honduras
  HONDURAS(stringValue: 'hn'),

  /// Croatia
  CROATIA(stringValue: 'hr'),

  /// Haiti
  HAITI(stringValue: 'ht'),

  /// Hungary
  HUNGARY(stringValue: 'hu'),

  /// Indonesia
  INDONESIA(stringValue: 'id'),

  /// Ireland
  IRELAND(stringValue: 'ie'),

  /// Israel
  ISRAEL(stringValue: 'il'),

  /// Isle of Man
  ISLE_OF_MAN(stringValue: 'im'),

  /// India
  INDIA(stringValue: 'in'),

  /// British Indian Ocean Territory
  BRITISH_INDIAN_OCEAN_TERRITORY(stringValue: 'io'),

  /// Iraq
  IRAQ(stringValue: 'iq'),

  /// Iran (Islamic Republic of)
  IRAN(stringValue: 'ir'),

  /// Iceland
  ICELAND(stringValue: 'is'),

  /// Italy
  ITALY(stringValue: 'it'),

  /// Jersey
  JERSEY(stringValue: 'je'),

  /// Jamaica
  JAMAICA(stringValue: 'jm'),

  /// Jordan
  JORDAN(stringValue: 'jo'),

  /// Japan
  JAPAN(stringValue: 'jp'),

  /// Kenya
  KENYA(stringValue: 'ke'),

  /// Kyrgyzstan
  KYRGYZSTAN(stringValue: 'kg'),

  /// Cambodia
  CAMBODIA(stringValue: 'kh'),

  /// Kiribati
  KIRIBATI(stringValue: 'ki'),

  /// Comoros
  COMOROS(stringValue: 'km'),

  /// Saint Kitts and Nevis
  SAINT_KITTS_AND_NEVIS(stringValue: 'kn'),

  /// Korea (Democratic People's Republic of)
  NORTH_KOREA(stringValue: 'kp'),

  /// Korea, Republic of
  SOUTH_KOREA(stringValue: 'kr'),

  /// Kuwait
  KUWAIT(stringValue: 'kw'),

  /// Cayman Islands
  CAYMAN_ISLANDS(stringValue: 'ky'),

  /// Kazakhstan
  KAZAKHSTAN(stringValue: 'kz'),

  /// Lao People's Democratic Republic
  LAOS(stringValue: 'la'),

  /// Lebanon
  LEBANON(stringValue: 'lb'),

  /// Saint Lucia
  SAINT_LUCIA(stringValue: 'lc'),

  /// Liechtenstein
  LIECHTENSTEIN(stringValue: 'li'),

  /// Sri Lanka
  SRI_LANKA(stringValue: 'lk'),

  /// Liberia
  LIBERIA(stringValue: 'lr'),

  /// Lesotho
  LESOTHO(stringValue: 'ls'),

  /// Lithuania
  LITHUANIA(stringValue: 'lt'),

  /// Luxembourg
  LUXEMBOURG(stringValue: 'lu'),

  /// Latvia
  LATVIA(stringValue: 'lv'),

  /// Libya
  LIBYA(stringValue: 'ly'),

  /// Morocco
  MOROCCO(stringValue: 'ma'),

  /// Monaco
  MONACO(stringValue: 'mc'),

  /// Moldova, Republic of
  MOLDOVA(stringValue: 'md'),

  /// Montenegro
  MONTENEGRO(stringValue: 'me'),

  /// Saint Martin (French part)
  SAINT_MARTIN(stringValue: 'mf'),

  /// Madagascar
  MADAGASCAR(stringValue: 'mg'),

  /// Marshall Islands
  MARSHALL_ISLANDS(stringValue: 'mh'),

  /// North Macedonia
  NORTH_MACEDONIA(stringValue: 'mk'),

  /// Mali
  MALI(stringValue: 'ml'),

  /// Myanmar
  MYANMAR(stringValue: 'mm'),

  /// Mongolia
  MONGOLIA(stringValue: 'mn'),

  /// Macao
  MACAO(stringValue: 'mo'),

  /// Northern Mariana Islands
  NORTHERN_MARIANA_ISLANDS(stringValue: 'mp'),

  /// Martinique
  MARTINIQUE(stringValue: 'mq'),

  /// Mauritania
  MAURITANIA(stringValue: 'mr'),

  /// Montserrat
  MONTSERRAT(stringValue: 'ms'),

  /// Malta
  MALTA(stringValue: 'mt'),

  /// Mauritius
  MAURITIUS(stringValue: 'mu'),

  /// Maldives
  MALDIVES(stringValue: 'mv'),

  /// Malawi
  MALAWI(stringValue: 'mw'),

  /// Mexico
  MEXICO(stringValue: 'mx'),

  /// Malaysia
  MALAYSIA(stringValue: 'my'),

  /// Mozambique
  MOZAMBIQUE(stringValue: 'mz'),

  /// Namibia
  NAMIBIA(stringValue: 'na'),

  /// New Caledonia
  NEW_CALEDONIA(stringValue: 'nc'),

  /// Niger
  NIGER(stringValue: 'ne'),

  /// Norfolk Island
  NORFOLK_ISLAND(stringValue: 'nf'),

  /// Nigeria
  NIGERIA(stringValue: 'ng'),

  /// Nicaragua
  NICARAGUA(stringValue: 'ni'),

  /// Netherlands
  NETHERLANDS(stringValue: 'nl'),

  /// Norway
  NORWAY(stringValue: 'no'),

  /// Nepal
  NEPAL(stringValue: 'np'),

  /// Nauru
  NAURU(stringValue: 'nr'),

  /// Niue
  NIUE(stringValue: 'nu'),

  /// New Zealand
  NEW_ZEALAND(stringValue: 'nz'),

  /// Oman
  OMAN(stringValue: 'om'),

  /// Panama
  PANAMA(stringValue: 'pa'),

  /// Peru
  PERU(stringValue: 'pe'),

  /// French Polynesia
  FRENCH_POLYNESIA(stringValue: 'pf'),

  /// Papua New Guinea
  PAPUA_NEW_GUINEA(stringValue: 'pg'),

  /// Philippines
  PHILIPPINES(stringValue: 'ph'),

  /// Pakistan
  PAKISTAN(stringValue: 'pk'),

  /// Poland
  POLAND(stringValue: 'pl'),

  /// Saint Pierre and Miquelon
  SAINT_PIERRE_AND_MIQUELON(stringValue: 'pm'),

  /// Pitcairn
  PITCAIRN(stringValue: 'pn'),

  /// Puerto Rico
  PUERTO_RICO(stringValue: 'pr'),

  /// Palestine, State of
  PALESTINE(stringValue: 'ps'),

  /// Portugal
  PORTUGAL(stringValue: 'pt'),

  /// Palau
  PALAU(stringValue: 'pw'),

  /// Paraguay
  PARAGUAY(stringValue: 'py'),

  /// Qatar
  QATAR(stringValue: 'qa'),

  /// Réunion
  REUNION(stringValue: 're'),

  /// Romania
  ROMANIA(stringValue: 'ro'),

  /// Serbia
  SERBIA(stringValue: 'rs'),

  /// Russian Federation
  RUSSIA(stringValue: 'ru'),

  /// Rwanda
  RWANDA(stringValue: 'rw'),

  /// Saudi Arabia
  SAUDI_ARABIA(stringValue: 'sa'),

  /// Solomon Islands
  SOLOMON_ISLANDS(stringValue: 'sb'),

  /// Seychelles
  SEYCHELLES(stringValue: 'sc'),

  /// Sudan
  SUDAN(stringValue: 'sd'),

  /// Sweden
  SWEDEN(stringValue: 'se'),

  /// Singapore
  SINGAPORE(stringValue: 'sg'),

  /// Saint Helena, Ascension and Tristan da Cunha
  SAINT_HELENA(stringValue: 'sh'),

  /// Slovenia
  SLOVENIA(stringValue: 'si'),

  /// Svalbard and Jan Mayen
  SVALBARD_AND_JAN_MAYEN(stringValue: 'sj'),

  /// Slovakia
  SLOVAKIA(stringValue: 'sk'),

  /// Sierra Leone
  SIERRA_LEONE(stringValue: 'sl'),

  /// San Marino
  SAN_MARINO(stringValue: 'sm'),

  /// Senegal
  SENEGAL(stringValue: 'sn'),

  /// Somalia
  SOMALIA(stringValue: 'so'),

  /// Suriname
  SURINAME(stringValue: 'sr'),

  /// South Sudan
  SOUTH_SUDAN(stringValue: 'ss'),

  /// Sao Tome and Principe
  SAO_TOME_AND_PRINCIPE(stringValue: 'st'),

  /// El Salvador
  EL_SALVADOR(stringValue: 'sv'),

  /// Sint Maarten (Dutch part)
  SINT_MAARTEN(stringValue: 'sx'),

  /// Syrian Arab Republic
  SYRIA(stringValue: 'sy'),

  /// Eswatini
  ESWATINI(stringValue: 'sz'),

  /// Turks and Caicos Islands
  TURKS_AND_CAICOS_ISLANDS(stringValue: 'tc'),

  /// Chad
  CHAD(stringValue: 'td'),

  /// French Southern Territories
  FRENCH_SOUTHERN_TERRITORIES(stringValue: 'tf'),

  /// Togo
  TOGO(stringValue: 'tg'),

  /// Thailand
  THAILAND(stringValue: 'th'),

  /// Tajikistan
  TAJIKISTAN(stringValue: 'tj'),

  /// Tokelau
  TOKELAU(stringValue: 'tk'),

  /// Timor-Leste
  TIMOR_LESTE(stringValue: 'tl'),

  /// Turkmenistan
  TURKMENISTAN(stringValue: 'tm'),

  /// Tunisia
  TUNISIA(stringValue: 'tn'),

  /// Tonga
  TONGA(stringValue: 'to'),

  /// Turkey
  TURKEY(stringValue: 'tr'),

  /// Trinidad and Tobago
  TRINIDAD_AND_TOBAGO(stringValue: 'tt'),

  /// Tuvalu
  TUVALU(stringValue: 'tv'),

  /// Taiwan, Province of China
  TAIWAN(stringValue: 'tw'),

  /// Tanzania, United Republic of
  TANZANIA(stringValue: 'tz'),

  /// Ukraine
  UKRAINE(stringValue: 'ua'),

  /// Uganda
  UGANDA(stringValue: 'ug'),

  /// United States Minor Outlying Islands
  UNITED_STATES_MINOR_OUTLYING_ISLANDS(stringValue: 'um'),

  /// United States of America
  USA(stringValue: 'us'),

  /// Uruguay
  URUGUAY(stringValue: 'uy'),

  /// Uzbekistan
  UZBEKISTAN(stringValue: 'uz'),

  /// Holy See
  HOLY_SEE(stringValue: 'va'),

  /// Saint Vincent and the Grenadines
  SAINT_VINCENT_AND_THE_GRENADINES(stringValue: 'vc'),

  /// Venezuela (Bolivarian Republic of)
  VENEZUELA(stringValue: 've'),

  /// Virgin Islands (British)
  BRITISH_VIRGIN_ISLANDS(stringValue: 'vg'),

  /// Virgin Islands (U.S.)
  US_VIRGIN_ISLANDS(stringValue: 'vi'),

  /// Viet Nam
  VIET_NAM(stringValue: 'vn'),

  /// Vanuatu
  VANUATU(stringValue: 'vu'),

  /// Wallis and Futuna
  WALLIS_AND_FUTUNA(stringValue: 'wf'),

  /// Samoa
  SAMOA(stringValue: 'ws'),

  /// Yemen
  YEMEN(stringValue: 'ye'),

  /// Mayotte
  MAYOTTE(stringValue: 'yt'),

  /// South Africa
  SOUTH_AFRICA(stringValue: 'za'),

  /// Zambia
  ZAMBIA(stringValue: 'zm'),

  /// Zimbabwe
  ZIMBABWE(stringValue: 'zw'),

  /// World
  WORLD(stringValue: 'world');

  const NutritionCountry({
    required this.stringValue,
  });

  /// Lowercase ISO 639-1, except for [UNITED_KINGDOM].
  final String stringValue;

  static NutritionCountry? fromString(final String? stringValue) =>
      NutritionCountry.values.firstWhereOrNull(
        (final NutritionCountry country) => country.stringValue == stringValue,
      );

  static List<NutritionCountry> get sortedValues =>
      NutritionCountry.values.toList()..sort((a, b) => a.t.compareTo(b.t));

  OpenFoodFactsCountry? get offApiCountry =>
      OpenFoodFactsCountry.fromOffTag(stringValue);

  String get t => 'food.countries.${stringValue.toLowerCase()}'.t;
}
