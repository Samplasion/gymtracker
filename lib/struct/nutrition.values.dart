part of 'nutrition.dart';

enum NutritionUnit {
  KCAL,
  KJ,
  G,
  MILLI_G,
  MICRO_G,
  MILLI_L,
  L,
  PERCENT,
  UNKNOWN;

  String toCamelCase() {
    final parts = name.split('_');
    return parts.first.toLowerCase() +
        parts
            .skip(1)
            .map((part) => part[0].toUpperCase() + part.substring(1))
            .join('');
  }
}

NutritionUnit deserializeUnit(String camelCase) => switch (camelCase) {
      'kcal' => NutritionUnit.KCAL,
      'kj' => NutritionUnit.KJ,
      'g' => NutritionUnit.G,
      'mg' => NutritionUnit.MILLI_G,
      'µg' => NutritionUnit.MICRO_G,
      'ml' => NutritionUnit.MILLI_L,
      'l' => NutritionUnit.L,
      '%' => NutritionUnit.PERCENT,
      _ => NutritionUnit.UNKNOWN,
    };

String serializeUnit(NutritionUnit unit) => switch (unit) {
      NutritionUnit.KCAL => 'kcal',
      NutritionUnit.KJ => 'kj',
      NutritionUnit.G => 'g',
      NutritionUnit.MILLI_G => 'mg',
      NutritionUnit.MICRO_G => 'µg',
      NutritionUnit.MILLI_L => 'ml',
      NutritionUnit.L => 'l',
      NutritionUnit.PERCENT => '%',
      NutritionUnit.UNKNOWN => '',
    };

const kNutritionValueToUnit = {
  "calories": NutritionUnit.KCAL,
  "fat": NutritionUnit.G,
  "saturatedFat": NutritionUnit.G,
  "carbs": NutritionUnit.G,
  "sugar": NutritionUnit.G,
  "protein": NutritionUnit.G,
  "salt": NutritionUnit.G,
  "sodium": NutritionUnit.G,
  "fiber": NutritionUnit.G,
  "addedSugars": NutritionUnit.G,
  "caffeine": NutritionUnit.G,
  "calcium": NutritionUnit.MILLI_G,
  "iron": NutritionUnit.MILLI_G,
  "vitaminC": NutritionUnit.MILLI_G,
  "magnesium": NutritionUnit.MILLI_G,
  "phosphorus": NutritionUnit.MILLI_G,
  "potassium": NutritionUnit.MILLI_G,
  "zinc": NutritionUnit.MILLI_G,
  "copper": NutritionUnit.MILLI_G,
  "selenium": NutritionUnit.MICRO_G,
  "vitaminA": NutritionUnit.MICRO_G,
  "vitaminE": NutritionUnit.MILLI_G,
  "vitaminD": NutritionUnit.MICRO_G,
  "vitaminB1": NutritionUnit.MILLI_G,
  "vitaminB2": NutritionUnit.MILLI_G,
  "vitaminPP": NutritionUnit.MILLI_G,
  "vitaminB6": NutritionUnit.MILLI_G,
  "vitaminB12": NutritionUnit.MICRO_G,
  "vitaminB9": NutritionUnit.MICRO_G,
  "vitaminK": NutritionUnit.MICRO_G,
  "cholesterol": NutritionUnit.MILLI_G,
  "butyricAcid": NutritionUnit.G,
  "caproicAcid": NutritionUnit.G,
  "caprylicAcid": NutritionUnit.G,
  "capricAcid": NutritionUnit.G,
  "lauricAcid": NutritionUnit.G,
  "myristicAcid": NutritionUnit.G,
  "palmiticAcid": NutritionUnit.G,
  "stearicAcid": NutritionUnit.G,
  "oleicAcid": NutritionUnit.G,
  "linoleicAcid": NutritionUnit.G,
  "docosahexaenoicAcid": NutritionUnit.G,
  "eicosapentaenoicAcid": NutritionUnit.G,
  "erucicAcid": NutritionUnit.G,
  "monounsaturatedFat": NutritionUnit.G,
  "polyunsaturatedFat": NutritionUnit.G,
  "alcohol": NutritionUnit.PERCENT,
  "pantothenicAcid": NutritionUnit.MILLI_G,
  "biotin": NutritionUnit.MICRO_G,
  "chloride": NutritionUnit.MILLI_G,
  "chromium": NutritionUnit.MICRO_G,
  "fluoride": NutritionUnit.MILLI_G,
  "iodine": NutritionUnit.MICRO_G,
  "manganese": NutritionUnit.MILLI_G,
  "molybdenum": NutritionUnit.MICRO_G,
  "omega3": NutritionUnit.MILLI_G,
  "omega6": NutritionUnit.MILLI_G,
  "omega9": NutritionUnit.MILLI_G,
  "betaCarotene": NutritionUnit.G,
  "bicarbonate": NutritionUnit.MILLI_G,
  "sugarAlcohol": NutritionUnit.G,
  "alphaLinolenicAcid": NutritionUnit.G,
  "arachidicAcid": NutritionUnit.G,
  "arachidonicAcid": NutritionUnit.G,
  "behenicAcid": NutritionUnit.G,
  "ceroticAcid": NutritionUnit.G,
  "dihomoGammaLinolenicAcid": NutritionUnit.G,
  "elaidicAcid": NutritionUnit.G,
  "gammaLinolenicAcid": NutritionUnit.G,
  "gondoicAcid": NutritionUnit.G,
  "lignocericAcid": NutritionUnit.G,
  "meadAcid": NutritionUnit.G,
  "melissicAcid": NutritionUnit.G,
  "montanicAcid": NutritionUnit.G,
  "nervonicAcid": NutritionUnit.G,
  "transFat": NutritionUnit.G,
};

typedef NutritionValuesWithAmount = (double, NutritionValues);

class NutritionValues {
  final double calories;
  final double fat;
  final double saturatedFat;
  final double carbs;
  final double sugar;
  final double protein;

  // Optional fields

  /// Salt (unit: G)
  final double? salt;

  /// Sodium (unit: G)
  final double? sodium;

  /// Fibers (unit: G)
  final double? fiber;

  /// Added Sugars (unit: G)
  final double? addedSugars;

  /// Caffeine (unit: G)
  final double? caffeine;

  /// Calcium (unit: MILLI_G)
  final double? calcium;

  /// Iron (unit: MILLI_G)
  final double? iron;

  /// Vitamin C (unit: MILLI_G)
  final double? vitaminC;

  /// Magnesium (unit: MILLI_G)
  final double? magnesium;

  /// Phosphorus (unit: MILLI_G)
  final double? phosphorus;

  /// Potassium (unit: MILLI_G)
  final double? potassium;

  /// Zinc (unit: MILLI_G)
  final double? zinc;

  /// Copper (unit: MILLI_G)
  final double? copper;

  /// Selenium (unit: MICRO_G)
  final double? selenium;

  /// Vitamin A (unit: MICRO_G)
  final double? vitaminA;

  /// Vitamin E (unit: MILLI_G)
  final double? vitaminE;

  /// Vitamin D (unit: MICRO_G)
  final double? vitaminD;

  /// Vitamin B1 (unit: MILLI_G)
  final double? vitaminB1;

  /// Vitamin B2 (unit: MILLI_G)
  final double? vitaminB2;

  /// Vitamin PP (unit: MILLI_G)
  final double? vitaminPP;

  /// Vitamin B6 (unit: MILLI_G)
  final double? vitaminB6;

  /// Vitamin B12 (unit: MICRO_G)
  final double? vitaminB12;

  /// Vitamin B9 (unit: MICRO_G)
  final double? vitaminB9;

  /// Vitamin K (unit: MICRO_G)
  final double? vitaminK;

  /// Cholesterol (unit: MILLI_G)
  final double? cholesterol;

  /// Butyric Acid (unit: G)
  final double? butyricAcid;

  /// Caproic Acid (unit: G)
  final double? caproicAcid;

  /// Caprylic Acid (unit: G)
  final double? caprylicAcid;

  /// Capric Acid (unit: G)
  final double? capricAcid;

  /// Lauric Acid (unit: G)
  final double? lauricAcid;

  /// Myristic Acid (unit: G)
  final double? myristicAcid;

  /// Palmitic Acid (unit: G)
  final double? palmiticAcid;

  /// Stearic Acid (unit: G)
  final double? stearicAcid;

  /// Oleic Acid (unit: G)
  final double? oleicAcid;

  /// Linoleic Acid (unit: G)
  final double? linoleicAcid;

  /// Docosahexaenoic Acid (unit: G)
  final double? docosahexaenoicAcid;

  /// Eicosapentaenoic Acid (unit: G)
  final double? eicosapentaenoicAcid;

  /// Erucic Acid (unit: G)
  final double? erucicAcid;

  /// Monounsaturated Fats (unit: G)
  final double? monounsaturatedFat;

  /// Polyunsaturated Fats (unit: G)
  final double? polyunsaturatedFat;

  /// Alcohol (unit: PERCENT)
  final double? alcohol;

  /// Pantothenic Acid (unit: MILLI_G)
  final double? pantothenicAcid;

  /// Biotin (unit: MICRO_G)
  final double? biotin;

  /// Chloride (unit: MILLI_G)
  final double? chloride;

  /// Chromium (unit: MICRO_G)
  final double? chromium;

  /// Fluoride (unit: MILLI_G)
  final double? fluoride;

  /// Iodine (unit: MICRO_G)
  final double? iodine;

  /// Manganese (unit: MILLI_G)
  final double? manganese;

  /// Molybdenum (unit: MICRO_G)
  final double? molybdenum;

  /// Omega 3 (unit: MILLI_G)
  final double? omega3;

  /// Omega 6 (unit: MILLI_G)
  final double? omega6;

  /// Omega 9 (unit: MILLI_G)
  final double? omega9;

  /// ß-Carotene (unit: G)
  final double? betaCarotene;

  /// Bicarbonate (unit: MILLI_G)
  final double? bicarbonate;

  /// Sugar Alcohol (polyol) (unit: G)
  final double? sugarAlcohol;

  /// Alpha Linolenic Acid (unit: G)
  final double? alphaLinolenicAcid;

  /// Arachidic Acid (unit: G)
  final double? arachidicAcid;

  /// Arachidonic Acid (unit: G)
  final double? arachidonicAcid;

  /// Behenic Acid (unit: G)
  final double? behenicAcid;

  /// Cerotic Acid (unit: G)
  final double? ceroticAcid;

  /// Dihomo-Gamma-Linolenic Acid (unit: G)
  final double? dihomoGammaLinolenicAcid;

  /// Elaidic Acid (unit: G)
  final double? elaidicAcid;

  /// Gamma-Linolenic Acid (unit: G)
  final double? gammaLinolenicAcid;

  /// Gondoic Acid (11-Eicosenoic acid) (unit: G)
  final double? gondoicAcid;

  /// Lignoceric Acid (unit: G)
  final double? lignocericAcid;

  /// Mead Acid (unit: G)
  final double? meadAcid;

  /// Melissic Acid (unit: G)
  final double? melissicAcid;

  /// Montanic Acid (unit: G)
  final double? montanicAcid;

  /// Nervonic Acid (unit: G)
  final double? nervonicAcid;

  /// Trans Fats (unit: G)
  final double? transFat;

  const NutritionValues({
    required this.calories,
    required this.fat,
    required this.saturatedFat,
    required this.carbs,
    required this.sugar,
    required this.protein,
    this.salt,
    this.sodium,
    this.fiber,
    this.addedSugars,
    this.caffeine,
    this.calcium,
    this.iron,
    this.vitaminC,
    this.magnesium,
    this.phosphorus,
    this.potassium,
    this.zinc,
    this.copper,
    this.selenium,
    this.vitaminA,
    this.vitaminE,
    this.vitaminD,
    this.vitaminB1,
    this.vitaminB2,
    this.vitaminPP,
    this.vitaminB6,
    this.vitaminB12,
    this.vitaminB9,
    this.vitaminK,
    this.cholesterol,
    this.butyricAcid,
    this.caproicAcid,
    this.caprylicAcid,
    this.capricAcid,
    this.lauricAcid,
    this.myristicAcid,
    this.palmiticAcid,
    this.stearicAcid,
    this.oleicAcid,
    this.linoleicAcid,
    this.docosahexaenoicAcid,
    this.eicosapentaenoicAcid,
    this.erucicAcid,
    this.monounsaturatedFat,
    this.polyunsaturatedFat,
    this.alcohol,
    this.pantothenicAcid,
    this.biotin,
    this.chloride,
    this.chromium,
    this.fluoride,
    this.iodine,
    this.manganese,
    this.molybdenum,
    this.omega3,
    this.omega6,
    this.omega9,
    this.betaCarotene,
    this.bicarbonate,
    this.sugarAlcohol,
    this.alphaLinolenicAcid,
    this.arachidicAcid,
    this.arachidonicAcid,
    this.behenicAcid,
    this.ceroticAcid,
    this.dihomoGammaLinolenicAcid,
    this.elaidicAcid,
    this.gammaLinolenicAcid,
    this.gondoicAcid,
    this.lignocericAcid,
    this.meadAcid,
    this.melissicAcid,
    this.montanicAcid,
    this.nervonicAcid,
    this.transFat,
  });

  static const zero = NutritionValues(
    calories: 0,
    fat: 0,
    saturatedFat: 0,
    carbs: 0,
    sugar: 0,
    protein: 0,
    // Other fields are null so they default to 0 in calculations
  );

  factory NutritionValues.fromJson(Map<String, dynamic> json) {
    return NutritionValues(
      calories: (json['calories'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      saturatedFat: (json['saturatedFat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      salt: (json['salt'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      addedSugars: (json['addedSugars'] as num?)?.toDouble(),
      caffeine: (json['caffeine'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      iron: (json['iron'] as num?)?.toDouble(),
      vitaminC: (json['vitaminC'] as num?)?.toDouble(),
      magnesium: (json['magnesium'] as num?)?.toDouble(),
      phosphorus: (json['phosphorus'] as num?)?.toDouble(),
      potassium: (json['potassium'] as num?)?.toDouble(),
      zinc: (json['zinc'] as num?)?.toDouble(),
      copper: (json['copper'] as num?)?.toDouble(),
      selenium: (json['selenium'] as num?)?.toDouble(),
      vitaminA: (json['vitaminA'] as num?)?.toDouble(),
      vitaminE: (json['vitaminE'] as num?)?.toDouble(),
      vitaminD: (json['vitaminD'] as num?)?.toDouble(),
      vitaminB1: (json['vitaminB1'] as num?)?.toDouble(),
      vitaminB2: (json['vitaminB2'] as num?)?.toDouble(),
      vitaminPP: (json['vitaminPP'] as num?)?.toDouble(),
      vitaminB6: (json['vitaminB6'] as num?)?.toDouble(),
      vitaminB12: (json['vitaminB12'] as num?)?.toDouble(),
      vitaminB9: (json['vitaminB9'] as num?)?.toDouble(),
      vitaminK: (json['vitaminK'] as num?)?.toDouble(),
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
      butyricAcid: (json['butyricAcid'] as num?)?.toDouble(),
      caproicAcid: (json['caproicAcid'] as num?)?.toDouble(),
      caprylicAcid: (json['caprylicAcid'] as num?)?.toDouble(),
      capricAcid: (json['capricAcid'] as num?)?.toDouble(),
      lauricAcid: (json['lauricAcid'] as num?)?.toDouble(),
      myristicAcid: (json['myristicAcid'] as num?)?.toDouble(),
      palmiticAcid: (json['palmiticAcid'] as num?)?.toDouble(),
      stearicAcid: (json['stearicAcid'] as num?)?.toDouble(),
      oleicAcid: (json['oleicAcid'] as num?)?.toDouble(),
      linoleicAcid: (json['linoleicAcid'] as num?)?.toDouble(),
      docosahexaenoicAcid: (json['docosahexaenoicAcid'] as num?)?.toDouble(),
      eicosapentaenoicAcid: (json['eicosapentaenoicAcid'] as num?)?.toDouble(),
      erucicAcid: (json['erucicAcid'] as num?)?.toDouble(),
      monounsaturatedFat: (json['monounsaturatedFat'] as num?)?.toDouble(),
      polyunsaturatedFat: (json['polyunsaturatedFat'] as num?)?.toDouble(),
      alcohol: (json['alcohol'] as num?)?.toDouble(),
      pantothenicAcid: (json['pantothenicAcid'] as num?)?.toDouble(),
      biotin: (json['biotin'] as num?)?.toDouble(),
      chloride: (json['chloride'] as num?)?.toDouble(),
      chromium: (json['chromium'] as num?)?.toDouble(),
      fluoride: (json['fluoride'] as num?)?.toDouble(),
      iodine: (json['iodine'] as num?)?.toDouble(),
      manganese: (json['manganese'] as num?)?.toDouble(),
      molybdenum: (json['molybdenum'] as num?)?.toDouble(),
      omega3: (json['omega3'] as num?)?.toDouble(),
      omega6: (json['omega6'] as num?)?.toDouble(),
      omega9: (json['omega9'] as num?)?.toDouble(),
      betaCarotene: (json['betaCarotene'] as num?)?.toDouble(),
      bicarbonate: (json['bicarbonate'] as num?)?.toDouble(),
      sugarAlcohol: (json['sugarAlcohol'] as num?)?.toDouble(),
      alphaLinolenicAcid: (json['alphaLinolenicAcid'] as num?)?.toDouble(),
      arachidicAcid: (json['arachidicAcid'] as num?)?.toDouble(),
      arachidonicAcid: (json['arachidonicAcid'] as num?)?.toDouble(),
      behenicAcid: (json['behenicAcid'] as num?)?.toDouble(),
      ceroticAcid: (json['ceroticAcid'] as num?)?.toDouble(),
      dihomoGammaLinolenicAcid:
          (json['dihomoGammaLinolenicAcid'] as num?)?.toDouble(),
      elaidicAcid: (json['elaidicAcid'] as num?)?.toDouble(),
      gammaLinolenicAcid: (json['gammaLinolenicAcid'] as num?)?.toDouble(),
      gondoicAcid: (json['gondoicAcid'] as num?)?.toDouble(),
      lignocericAcid: (json['lignocericAcid'] as num?)?.toDouble(),
      meadAcid: (json['meadAcid'] as num?)?.toDouble(),
      melissicAcid: (json['melissicAcid'] as num?)?.toDouble(),
      montanicAcid: (json['montanicAcid'] as num?)?.toDouble(),
      nervonicAcid: (json['nervonicAcid'] as num?)?.toDouble(),
      transFat: (json['transFat'] as num?)?.toDouble(),
    );
  }

  factory NutritionValues.fromOFFNutrimentsPer100g(Nutriments nutriments) {
    return NutritionValues(
      calories:
          nutriments.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ??
              0,
      fat: nutriments.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0,
      saturatedFat:
          nutriments.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams) ??
              0,
      carbs: nutriments.getValue(
              Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
          0,
      sugar: nutriments.getValue(Nutrient.sugars, PerSize.oneHundredGrams) ?? 0,
      protein:
          nutriments.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0,
      salt: nutriments.getValue(Nutrient.salt, PerSize.oneHundredGrams),
      sodium: nutriments.getValue(Nutrient.sodium, PerSize.oneHundredGrams),
      fiber: nutriments.getValue(Nutrient.fiber, PerSize.oneHundredGrams),
      addedSugars:
          nutriments.getValue(Nutrient.addedSugars, PerSize.oneHundredGrams),
      caffeine: nutriments.getValue(Nutrient.caffeine, PerSize.oneHundredGrams),
      calcium: nutriments.getValue(Nutrient.calcium, PerSize.oneHundredGrams),
      iron: nutriments.getValue(Nutrient.iron, PerSize.oneHundredGrams),
      vitaminC: nutriments.getValue(Nutrient.vitaminC, PerSize.oneHundredGrams),
      magnesium:
          nutriments.getValue(Nutrient.magnesium, PerSize.oneHundredGrams),
      phosphorus:
          nutriments.getValue(Nutrient.phosphorus, PerSize.oneHundredGrams),
      potassium:
          nutriments.getValue(Nutrient.potassium, PerSize.oneHundredGrams),
      zinc: nutriments.getValue(Nutrient.zinc, PerSize.oneHundredGrams),
      copper: nutriments.getValue(Nutrient.copper, PerSize.oneHundredGrams),
      selenium: nutriments.getValue(Nutrient.selenium, PerSize.oneHundredGrams),
      vitaminA: nutriments.getValue(Nutrient.vitaminA, PerSize.oneHundredGrams),
      vitaminE: nutriments.getValue(Nutrient.vitaminE, PerSize.oneHundredGrams),
      vitaminD: nutriments.getValue(Nutrient.vitaminD, PerSize.oneHundredGrams),
      vitaminB1:
          nutriments.getValue(Nutrient.vitaminB1, PerSize.oneHundredGrams),
      vitaminB2:
          nutriments.getValue(Nutrient.vitaminB2, PerSize.oneHundredGrams),
      vitaminPP:
          nutriments.getValue(Nutrient.vitaminPP, PerSize.oneHundredGrams),
      vitaminB6:
          nutriments.getValue(Nutrient.vitaminB6, PerSize.oneHundredGrams),
      vitaminB12:
          nutriments.getValue(Nutrient.vitaminB12, PerSize.oneHundredGrams),
      vitaminB9:
          nutriments.getValue(Nutrient.vitaminB9, PerSize.oneHundredGrams),
      vitaminK: nutriments.getValue(Nutrient.vitaminK, PerSize.oneHundredGrams),
      cholesterol:
          nutriments.getValue(Nutrient.cholesterol, PerSize.oneHundredGrams),
      butyricAcid:
          nutriments.getValue(Nutrient.butyricAcid, PerSize.oneHundredGrams),
      caproicAcid:
          nutriments.getValue(Nutrient.caproicAcid, PerSize.oneHundredGrams),
      caprylicAcid:
          nutriments.getValue(Nutrient.caprylicAcid, PerSize.oneHundredGrams),
      capricAcid:
          nutriments.getValue(Nutrient.capricAcid, PerSize.oneHundredGrams),
      lauricAcid:
          nutriments.getValue(Nutrient.lauricAcid, PerSize.oneHundredGrams),
      myristicAcid:
          nutriments.getValue(Nutrient.myristicAcid, PerSize.oneHundredGrams),
      palmiticAcid:
          nutriments.getValue(Nutrient.palmiticAcid, PerSize.oneHundredGrams),
      stearicAcid:
          nutriments.getValue(Nutrient.stearicAcid, PerSize.oneHundredGrams),
      oleicAcid:
          nutriments.getValue(Nutrient.oleicAcid, PerSize.oneHundredGrams),
      linoleicAcid:
          nutriments.getValue(Nutrient.linoleicAcid, PerSize.oneHundredGrams),
      docosahexaenoicAcid: nutriments.getValue(
          Nutrient.docosahexaenoicAcid, PerSize.oneHundredGrams),
      eicosapentaenoicAcid: nutriments.getValue(
          Nutrient.eicosapentaenoicAcid, PerSize.oneHundredGrams),
      erucicAcid:
          nutriments.getValue(Nutrient.erucicAcid, PerSize.oneHundredGrams),
      monounsaturatedFat: nutriments.getValue(
          Nutrient.monounsaturatedFat, PerSize.oneHundredGrams),
      polyunsaturatedFat: nutriments.getValue(
          Nutrient.polyunsaturatedFat, PerSize.oneHundredGrams),
      alcohol: nutriments.getValue(Nutrient.alcohol, PerSize.oneHundredGrams),
      pantothenicAcid: nutriments.getValue(
          Nutrient.pantothenicAcid, PerSize.oneHundredGrams),
      biotin: nutriments.getValue(Nutrient.biotin, PerSize.oneHundredGrams),
      chloride: nutriments.getValue(Nutrient.chloride, PerSize.oneHundredGrams),
      chromium: nutriments.getValue(Nutrient.chromium, PerSize.oneHundredGrams),
      fluoride: nutriments.getValue(Nutrient.fluoride, PerSize.oneHundredGrams),
      iodine: nutriments.getValue(Nutrient.iodine, PerSize.oneHundredGrams),
      manganese:
          nutriments.getValue(Nutrient.manganese, PerSize.oneHundredGrams),
      molybdenum:
          nutriments.getValue(Nutrient.molybdenum, PerSize.oneHundredGrams),
      omega3: nutriments.getValue(Nutrient.omega3, PerSize.oneHundredGrams),
      omega6: nutriments.getValue(Nutrient.omega6, PerSize.oneHundredGrams),
      omega9: nutriments.getValue(Nutrient.omega9, PerSize.oneHundredGrams),
      betaCarotene:
          nutriments.getValue(Nutrient.betaCarotene, PerSize.oneHundredGrams),
      bicarbonate:
          nutriments.getValue(Nutrient.bicarbonate, PerSize.oneHundredGrams),
      sugarAlcohol:
          nutriments.getValue(Nutrient.sugarAlcohol, PerSize.oneHundredGrams),
      alphaLinolenicAcid: nutriments.getValue(
          Nutrient.alphaLinolenicAcid, PerSize.oneHundredGrams),
      arachidicAcid:
          nutriments.getValue(Nutrient.arachidicAcid, PerSize.oneHundredGrams),
      arachidonicAcid: nutriments.getValue(
          Nutrient.arachidonicAcid, PerSize.oneHundredGrams),
      behenicAcid:
          nutriments.getValue(Nutrient.behenicAcid, PerSize.oneHundredGrams),
      ceroticAcid:
          nutriments.getValue(Nutrient.ceroticAcid, PerSize.oneHundredGrams),
      dihomoGammaLinolenicAcid: nutriments.getValue(
          Nutrient.dihomoGammaLinolenicAcid, PerSize.oneHundredGrams),
      elaidicAcid:
          nutriments.getValue(Nutrient.elaidicAcid, PerSize.oneHundredGrams),
      gammaLinolenicAcid: nutriments.getValue(
          Nutrient.gammaLinolenicAcid, PerSize.oneHundredGrams),
      gondoicAcid:
          nutriments.getValue(Nutrient.gondoicAcid, PerSize.oneHundredGrams),
      lignocericAcid:
          nutriments.getValue(Nutrient.lignocericAcid, PerSize.oneHundredGrams),
      meadAcid: nutriments.getValue(Nutrient.meadAcid, PerSize.oneHundredGrams),
      melissicAcid:
          nutriments.getValue(Nutrient.melissicAcid, PerSize.oneHundredGrams),
      montanicAcid:
          nutriments.getValue(Nutrient.montanicAcid, PerSize.oneHundredGrams),
      nervonicAcid:
          nutriments.getValue(Nutrient.nervonicAcid, PerSize.oneHundredGrams),
      transFat: nutriments.getValue(Nutrient.transFat, PerSize.oneHundredGrams),
    );
  }

  /// Returns the combined nutrition values of the given [values], rescaled to
  /// 100g.
  static NutritionValues sum(Iterable<NutritionValuesWithAmount> values) {
    var sum = NutritionValues.zero;
    var totalAmount = 0.0;
    for (final value in values) {
      // (totalAmount, sum) += value;
      totalAmount += value.$1;
      sum += value.$2;
    }
    return sum.rescaled(from: totalAmount, to: 100);
  }

  NutritionValues operator +(NutritionValues other) {
    return NutritionValues(
      calories: calories + other.calories,
      fat: fat + other.fat,
      saturatedFat: saturatedFat + other.saturatedFat,
      carbs: carbs + other.carbs,
      sugar: sugar + other.sugar,
      protein: protein + other.protein,
      salt: _nullIfZero((salt ?? 0.0) + (other.salt ?? 0.0)),
      sodium: _nullIfZero((sodium ?? 0.0) + (other.sodium ?? 0.0)),
      fiber: _nullIfZero((fiber ?? 0.0) + (other.fiber ?? 0.0)),
      addedSugars:
          _nullIfZero((addedSugars ?? 0.0) + (other.addedSugars ?? 0.0)),
      caffeine: _nullIfZero((caffeine ?? 0.0) + (other.caffeine ?? 0.0)),
      calcium: _nullIfZero((calcium ?? 0.0) + (other.calcium ?? 0.0)),
      iron: _nullIfZero((iron ?? 0.0) + (other.iron ?? 0.0)),
      vitaminC: _nullIfZero((vitaminC ?? 0.0) + (other.vitaminC ?? 0.0)),
      magnesium: _nullIfZero((magnesium ?? 0.0) + (other.magnesium ?? 0.0)),
      phosphorus: _nullIfZero((phosphorus ?? 0.0) + (other.phosphorus ?? 0.0)),
      potassium: _nullIfZero((potassium ?? 0.0) + (other.potassium ?? 0.0)),
      zinc: _nullIfZero((zinc ?? 0.0) + (other.zinc ?? 0.0)),
      copper: _nullIfZero((copper ?? 0.0) + (other.copper ?? 0.0)),
      selenium: _nullIfZero((selenium ?? 0.0) + (other.selenium ?? 0.0)),
      vitaminA: _nullIfZero((vitaminA ?? 0.0) + (other.vitaminA ?? 0.0)),
      vitaminE: _nullIfZero((vitaminE ?? 0.0) + (other.vitaminE ?? 0.0)),
      vitaminD: _nullIfZero((vitaminD ?? 0.0) + (other.vitaminD ?? 0.0)),
      vitaminB1: _nullIfZero((vitaminB1 ?? 0.0) + (other.vitaminB1 ?? 0.0)),
      vitaminB2: _nullIfZero((vitaminB2 ?? 0.0) + (other.vitaminB2 ?? 0.0)),
      vitaminPP: _nullIfZero((vitaminPP ?? 0.0) + (other.vitaminPP ?? 0.0)),
      vitaminB6: _nullIfZero((vitaminB6 ?? 0.0) + (other.vitaminB6 ?? 0.0)),
      vitaminB12: _nullIfZero((vitaminB12 ?? 0.0) + (other.vitaminB12 ?? 0.0)),
      vitaminB9: _nullIfZero((vitaminB9 ?? 0.0) + (other.vitaminB9 ?? 0.0)),
      vitaminK: _nullIfZero((vitaminK ?? 0.0) + (other.vitaminK ?? 0.0)),
      cholesterol:
          _nullIfZero((cholesterol ?? 0.0) + (other.cholesterol ?? 0.0)),
      butyricAcid:
          _nullIfZero((butyricAcid ?? 0.0) + (other.butyricAcid ?? 0.0)),
      caproicAcid:
          _nullIfZero((caproicAcid ?? 0.0) + (other.caproicAcid ?? 0.0)),
      caprylicAcid:
          _nullIfZero((caprylicAcid ?? 0.0) + (other.caprylicAcid ?? 0.0)),
      capricAcid: _nullIfZero((capricAcid ?? 0.0) + (other.capricAcid ?? 0.0)),
      lauricAcid: _nullIfZero((lauricAcid ?? 0.0) + (other.lauricAcid ?? 0.0)),
      myristicAcid:
          _nullIfZero((myristicAcid ?? 0.0) + (other.myristicAcid ?? 0.0)),
      palmiticAcid:
          _nullIfZero((palmiticAcid ?? 0.0) + (other.palmiticAcid ?? 0.0)),
      stearicAcid:
          _nullIfZero((stearicAcid ?? 0.0) + (other.stearicAcid ?? 0.0)),
      oleicAcid: _nullIfZero((oleicAcid ?? 0.0) + (other.oleicAcid ?? 0.0)),
      linoleicAcid:
          _nullIfZero((linoleicAcid ?? 0.0) + (other.linoleicAcid ?? 0.0)),
      docosahexaenoicAcid: _nullIfZero(
          (docosahexaenoicAcid ?? 0.0) + (other.docosahexaenoicAcid ?? 0.0)),
      eicosapentaenoicAcid: _nullIfZero(
          (eicosapentaenoicAcid ?? 0.0) + (other.eicosapentaenoicAcid ?? 0.0)),
      erucicAcid: _nullIfZero((erucicAcid ?? 0.0) + (other.erucicAcid ?? 0.0)),
      monounsaturatedFat: _nullIfZero(
          (monounsaturatedFat ?? 0.0) + (other.monounsaturatedFat ?? 0.0)),
      polyunsaturatedFat: _nullIfZero(
          (polyunsaturatedFat ?? 0.0) + (other.polyunsaturatedFat ?? 0.0)),
      alcohol: _nullIfZero((alcohol ?? 0.0) + (other.alcohol ?? 0.0)),
      pantothenicAcid: _nullIfZero(
          (pantothenicAcid ?? 0.0) + (other.pantothenicAcid ?? 0.0)),
      biotin: _nullIfZero((biotin ?? 0.0) + (other.biotin ?? 0.0)),
      chloride: _nullIfZero((chloride ?? 0.0) + (other.chloride ?? 0.0)),
      chromium: _nullIfZero((chromium ?? 0.0) + (other.chromium ?? 0.0)),
      fluoride: _nullIfZero((fluoride ?? 0.0) + (other.fluoride ?? 0.0)),
      iodine: _nullIfZero((iodine ?? 0.0) + (other.iodine ?? 0.0)),
      manganese: _nullIfZero((manganese ?? 0.0) + (other.manganese ?? 0.0)),
      molybdenum: _nullIfZero((molybdenum ?? 0.0) + (other.molybdenum ?? 0.0)),
      omega3: _nullIfZero((omega3 ?? 0.0) + (other.omega3 ?? 0.0)),
      omega6: _nullIfZero((omega6 ?? 0.0) + (other.omega6 ?? 0.0)),
      omega9: _nullIfZero((omega9 ?? 0.0) + (other.omega9 ?? 0.0)),
      betaCarotene:
          _nullIfZero((betaCarotene ?? 0.0) + (other.betaCarotene ?? 0.0)),
      bicarbonate:
          _nullIfZero((bicarbonate ?? 0.0) + (other.bicarbonate ?? 0.0)),
      sugarAlcohol:
          _nullIfZero((sugarAlcohol ?? 0.0) + (other.sugarAlcohol ?? 0.0)),
      alphaLinolenicAcid: _nullIfZero(
          (alphaLinolenicAcid ?? 0.0) + (other.alphaLinolenicAcid ?? 0.0)),
      arachidicAcid:
          _nullIfZero((arachidicAcid ?? 0.0) + (other.arachidicAcid ?? 0.0)),
      arachidonicAcid: _nullIfZero(
          (arachidonicAcid ?? 0.0) + (other.arachidonicAcid ?? 0.0)),
      behenicAcid:
          _nullIfZero((behenicAcid ?? 0.0) + (other.behenicAcid ?? 0.0)),
      ceroticAcid:
          _nullIfZero((ceroticAcid ?? 0.0) + (other.ceroticAcid ?? 0.0)),
      dihomoGammaLinolenicAcid: _nullIfZero((dihomoGammaLinolenicAcid ?? 0.0) +
          (other.dihomoGammaLinolenicAcid ?? 0.0)),
      elaidicAcid:
          _nullIfZero((elaidicAcid ?? 0.0) + (other.elaidicAcid ?? 0.0)),
      gammaLinolenicAcid: _nullIfZero(
          (gammaLinolenicAcid ?? 0.0) + (other.gammaLinolenicAcid ?? 0.0)),
      gondoicAcid:
          _nullIfZero((gondoicAcid ?? 0.0) + (other.gondoicAcid ?? 0.0)),
      lignocericAcid:
          _nullIfZero((lignocericAcid ?? 0.0) + (other.lignocericAcid ?? 0.0)),
      meadAcid: _nullIfZero((meadAcid ?? 0.0) + (other.meadAcid ?? 0.0)),
      melissicAcid:
          _nullIfZero((melissicAcid ?? 0.0) + (other.melissicAcid ?? 0.0)),
      montanicAcid:
          _nullIfZero((montanicAcid ?? 0.0) + (other.montanicAcid ?? 0.0)),
      nervonicAcid:
          _nullIfZero((nervonicAcid ?? 0.0) + (other.nervonicAcid ?? 0.0)),
      transFat: _nullIfZero((transFat ?? 0.0) + (other.transFat ?? 0.0)),
    );
  }

  NutritionValues operator /(double value) {
    return NutritionValues(
      calories: calories / value,
      fat: fat / value,
      saturatedFat: saturatedFat / value,
      carbs: carbs / value,
      sugar: sugar / value,
      protein: protein / value,
      salt: salt != null ? salt! / value : null,
      sodium: sodium != null ? sodium! / value : null,
      fiber: fiber != null ? fiber! / value : null,
      addedSugars: addedSugars != null ? addedSugars! / value : null,
      caffeine: caffeine != null ? caffeine! / value : null,
      calcium: calcium != null ? calcium! / value : null,
      iron: iron != null ? iron! / value : null,
      vitaminC: vitaminC != null ? vitaminC! / value : null,
      magnesium: magnesium != null ? magnesium! / value : null,
      phosphorus: phosphorus != null ? phosphorus! / value : null,
      potassium: potassium != null ? potassium! / value : null,
      zinc: zinc != null ? zinc! / value : null,
      copper: copper != null ? copper! / value : null,
      selenium: selenium != null ? selenium! / value : null,
      vitaminA: vitaminA != null ? vitaminA! / value : null,
      vitaminE: vitaminE != null ? vitaminE! / value : null,
      vitaminD: vitaminD != null ? vitaminD! / value : null,
      vitaminB1: vitaminB1 != null ? vitaminB1! / value : null,
      vitaminB2: vitaminB2 != null ? vitaminB2! / value : null,
      vitaminPP: vitaminPP != null ? vitaminPP! / value : null,
      vitaminB6: vitaminB6 != null ? vitaminB6! / value : null,
      vitaminB12: vitaminB12 != null ? vitaminB12! / value : null,
      vitaminB9: vitaminB9 != null ? vitaminB9! / value : null,
      vitaminK: vitaminK != null ? vitaminK! / value : null,
      cholesterol: cholesterol != null ? cholesterol! / value : null,
      butyricAcid: butyricAcid != null ? butyricAcid! / value : null,
      caproicAcid: caproicAcid != null ? caproicAcid! / value : null,
      caprylicAcid: caprylicAcid != null ? caprylicAcid! / value : null,
      capricAcid: capricAcid != null ? capricAcid! / value : null,
      lauricAcid: lauricAcid != null ? lauricAcid! / value : null,
      myristicAcid: myristicAcid != null ? myristicAcid! / value : null,
      palmiticAcid: palmiticAcid != null ? palmiticAcid! / value : null,
      stearicAcid: stearicAcid != null ? stearicAcid! / value : null,
      oleicAcid: oleicAcid != null ? oleicAcid! / value : null,
      linoleicAcid: linoleicAcid != null ? linoleicAcid! / value : null,
      docosahexaenoicAcid:
          docosahexaenoicAcid != null ? docosahexaenoicAcid! / value : null,
      eicosapentaenoicAcid:
          eicosapentaenoicAcid != null ? eicosapentaenoicAcid! / value : null,
      erucicAcid: erucicAcid != null ? erucicAcid! / value : null,
      monounsaturatedFat:
          monounsaturatedFat != null ? monounsaturatedFat! / value : null,
      polyunsaturatedFat:
          polyunsaturatedFat != null ? polyunsaturatedFat! / value : null,
      alcohol: alcohol != null ? alcohol! / value : null,
      pantothenicAcid:
          pantothenicAcid != null ? pantothenicAcid! / value : null,
      biotin: biotin != null ? biotin! / value : null,
      chloride: chloride != null ? chloride! / value : null,
      chromium: chromium != null ? chromium! / value : null,
      fluoride: fluoride != null ? fluoride! / value : null,
      iodine: iodine != null ? iodine! / value : null,
      manganese: manganese != null ? manganese! / value : null,
      molybdenum: molybdenum != null ? molybdenum! / value : null,
      omega3: omega3 != null ? omega3! / value : null,
      omega6: omega6 != null ? omega6! / value : null,
      omega9: omega9 != null ? omega9! / value : null,
      betaCarotene: betaCarotene != null ? betaCarotene! / value : null,
      bicarbonate: bicarbonate != null ? bicarbonate! / value : null,
      sugarAlcohol: sugarAlcohol != null ? sugarAlcohol! / value : null,
      alphaLinolenicAcid:
          alphaLinolenicAcid != null ? alphaLinolenicAcid! / value : null,
      arachidicAcid: arachidicAcid != null ? arachidicAcid! / value : null,
      arachidonicAcid:
          arachidonicAcid != null ? arachidonicAcid! / value : null,
      behenicAcid: behenicAcid != null ? behenicAcid! / value : null,
      ceroticAcid: ceroticAcid != null ? ceroticAcid! / value : null,
      dihomoGammaLinolenicAcid: dihomoGammaLinolenicAcid != null
          ? dihomoGammaLinolenicAcid! / value
          : null,
      elaidicAcid: elaidicAcid != null ? elaidicAcid! / value : null,
      gammaLinolenicAcid:
          gammaLinolenicAcid != null ? gammaLinolenicAcid! / value : null,
      gondoicAcid: gondoicAcid != null ? gondoicAcid! / value : null,
      lignocericAcid: lignocericAcid != null ? lignocericAcid! / value : null,
      meadAcid: meadAcid != null ? meadAcid! / value : null,
      melissicAcid: melissicAcid != null ? melissicAcid! / value : null,
      montanicAcid: montanicAcid != null ? montanicAcid! / value : null,
      nervonicAcid: nervonicAcid != null ? nervonicAcid! / value : null,
      transFat: transFat != null ? transFat! / value : null,
    );
  }

  NutritionValues operator *(double value) {
    return NutritionValues(
      calories: calories * value,
      fat: fat * value,
      saturatedFat: saturatedFat * value,
      carbs: carbs * value,
      sugar: sugar * value,
      protein: protein * value,
      salt: salt != null ? salt! * value : null,
      sodium: sodium != null ? sodium! * value : null,
      fiber: fiber != null ? fiber! * value : null,
      addedSugars: addedSugars != null ? addedSugars! * value : null,
      caffeine: caffeine != null ? caffeine! * value : null,
      calcium: calcium != null ? calcium! * value : null,
      iron: iron != null ? iron! * value : null,
      vitaminC: vitaminC != null ? vitaminC! * value : null,
      magnesium: magnesium != null ? magnesium! * value : null,
      phosphorus: phosphorus != null ? phosphorus! * value : null,
      potassium: potassium != null ? potassium! * value : null,
      zinc: zinc != null ? zinc! * value : null,
      copper: copper != null ? copper! * value : null,
      selenium: selenium != null ? selenium! * value : null,
      vitaminA: vitaminA != null ? vitaminA! * value : null,
      vitaminE: vitaminE != null ? vitaminE! * value : null,
      vitaminD: vitaminD != null ? vitaminD! * value : null,
      vitaminB1: vitaminB1 != null ? vitaminB1! * value : null,
      vitaminB2: vitaminB2 != null ? vitaminB2! * value : null,
      vitaminPP: vitaminPP != null ? vitaminPP! * value : null,
      vitaminB6: vitaminB6 != null ? vitaminB6! * value : null,
      vitaminB12: vitaminB12 != null ? vitaminB12! * value : null,
      vitaminB9: vitaminB9 != null ? vitaminB9! * value : null,
      vitaminK: vitaminK != null ? vitaminK! * value : null,
      cholesterol: cholesterol != null ? cholesterol! * value : null,
      butyricAcid: butyricAcid != null ? butyricAcid! * value : null,
      caproicAcid: caproicAcid != null ? caproicAcid! * value : null,
      caprylicAcid: caprylicAcid != null ? caprylicAcid! * value : null,
      capricAcid: capricAcid != null ? capricAcid! * value : null,
      lauricAcid: lauricAcid != null ? lauricAcid! * value : null,
      myristicAcid: myristicAcid != null ? myristicAcid! * value : null,
      palmiticAcid: palmiticAcid != null ? palmiticAcid! * value : null,
      stearicAcid: stearicAcid != null ? stearicAcid! * value : null,
      oleicAcid: oleicAcid != null ? oleicAcid! * value : null,
      linoleicAcid: linoleicAcid != null ? linoleicAcid! * value : null,
      docosahexaenoicAcid:
          docosahexaenoicAcid != null ? docosahexaenoicAcid! * value : null,
      eicosapentaenoicAcid:
          eicosapentaenoicAcid != null ? eicosapentaenoicAcid! * value : null,
      erucicAcid: erucicAcid != null ? erucicAcid! * value : null,
      monounsaturatedFat:
          monounsaturatedFat != null ? monounsaturatedFat! * value : null,
      polyunsaturatedFat:
          polyunsaturatedFat != null ? polyunsaturatedFat! * value : null,
      alcohol: alcohol != null ? alcohol! * value : null,
      pantothenicAcid:
          pantothenicAcid != null ? pantothenicAcid! * value : null,
      biotin: biotin != null ? biotin! * value : null,
      chloride: chloride != null ? chloride! * value : null,
      chromium: chromium != null ? chromium! * value : null,
      fluoride: fluoride != null ? fluoride! * value : null,
      iodine: iodine != null ? iodine! * value : null,
      manganese: manganese != null ? manganese! * value : null,
      molybdenum: molybdenum != null ? molybdenum! * value : null,
      omega3: omega3 != null ? omega3! * value : null,
      omega6: omega6 != null ? omega6! * value : null,
      omega9: omega9 != null ? omega9! * value : null,
      betaCarotene: betaCarotene != null ? betaCarotene! * value : null,
      bicarbonate: bicarbonate != null ? bicarbonate! * value : null,
      sugarAlcohol: sugarAlcohol != null ? sugarAlcohol! * value : null,
      alphaLinolenicAcid:
          alphaLinolenicAcid != null ? alphaLinolenicAcid! * value : null,
      arachidicAcid: arachidicAcid != null ? arachidicAcid! * value : null,
      arachidonicAcid:
          arachidonicAcid != null ? arachidonicAcid! * value : null,
      behenicAcid: behenicAcid != null ? behenicAcid! * value : null,
      ceroticAcid: ceroticAcid != null ? ceroticAcid! * value : null,
      dihomoGammaLinolenicAcid: dihomoGammaLinolenicAcid != null
          ? dihomoGammaLinolenicAcid! * value
          : null,
      elaidicAcid: elaidicAcid != null ? elaidicAcid! * value : null,
      gammaLinolenicAcid:
          gammaLinolenicAcid != null ? gammaLinolenicAcid! * value : null,
      gondoicAcid: gondoicAcid != null ? gondoicAcid! * value : null,
      lignocericAcid: lignocericAcid != null ? lignocericAcid! * value : null,
      meadAcid: meadAcid != null ? meadAcid! * value : null,
      melissicAcid: melissicAcid != null ? melissicAcid! * value : null,
      montanicAcid: montanicAcid != null ? montanicAcid! * value : null,
      nervonicAcid: nervonicAcid != null ? nervonicAcid! * value : null,
      transFat: transFat != null ? transFat! * value : null,
    );
  }

  @override
  String toString() {
    final lines = [
      "calories: $calories",
      "fat: $fat",
      "saturatedFat: $saturatedFat",
      "carbs: $carbs",
      "sugar: $sugar",
      "protein: $protein",
      if (salt != null) "salt: $salt",
      if (sodium != null) "sodium: $sodium",
      if (fiber != null) "fiber: $fiber",
      if (addedSugars != null) "addedSugars: $addedSugars",
      if (caffeine != null) "caffeine: $caffeine",
      if (calcium != null) "calcium: $calcium",
      if (iron != null) "iron: $iron",
      if (vitaminC != null) "vitaminC: $vitaminC",
      if (magnesium != null) "magnesium: $magnesium",
      if (phosphorus != null) "phosphorus: $phosphorus",
      if (potassium != null) "potassium: $potassium",
      if (zinc != null) "zinc: $zinc",
      if (copper != null) "copper: $copper",
      if (selenium != null) "selenium: $selenium",
      if (vitaminA != null) "vitaminA: $vitaminA",
      if (vitaminE != null) "vitaminE: $vitaminE",
      if (vitaminD != null) "vitaminD: $vitaminD",
      if (vitaminB1 != null) "vitaminB1: $vitaminB1",
      if (vitaminB2 != null) "vitaminB2: $vitaminB2",
      if (vitaminPP != null) "vitaminPP: $vitaminPP",
      if (vitaminB6 != null) "vitaminB6: $vitaminB6",
      if (vitaminB12 != null) "vitaminB12: $vitaminB12",
      if (vitaminB9 != null) "vitaminB9: $vitaminB9",
      if (vitaminK != null) "vitaminK: $vitaminK",
      if (cholesterol != null) "cholesterol: $cholesterol",
      if (butyricAcid != null) "butyricAcid: $butyricAcid",
      if (caproicAcid != null) "caproicAcid: $caproicAcid",
      if (caprylicAcid != null) "caprylicAcid: $caprylicAcid",
      if (capricAcid != null) "capricAcid: $capricAcid",
      if (lauricAcid != null) "lauricAcid: $lauricAcid",
      if (myristicAcid != null) "myristicAcid: $myristicAcid",
      if (palmiticAcid != null) "palmiticAcid: $palmiticAcid",
      if (stearicAcid != null) "stearicAcid: $stearicAcid",
      if (oleicAcid != null) "oleicAcid: $oleicAcid",
      if (linoleicAcid != null) "linoleicAcid: $linoleicAcid",
      if (docosahexaenoicAcid != null)
        "docosahexaenoicAcid: $docosahexaenoicAcid",
      if (eicosapentaenoicAcid != null)
        "eicosapentaenoicAcid: $eicosapentaenoicAcid",
      if (erucicAcid != null) "erucicAcid: $erucicAcid",
      if (monounsaturatedFat != null) "monounsaturatedFat: $monounsaturatedFat",
      if (polyunsaturatedFat != null) "polyunsaturatedFat: $polyunsaturatedFat",
      if (alcohol != null) "alcohol: $alcohol",
      if (pantothenicAcid != null) "pantothenicAcid: $pantothenicAcid",
      if (biotin != null) "biotin: $biotin",
      if (chloride != null) "chloride: $chloride",
      if (chromium != null) "chromium: $chromium",
      if (fluoride != null) "fluoride: $fluoride",
      if (iodine != null) "iodine: $iodine",
      if (manganese != null) "manganese: $manganese",
      if (molybdenum != null) "molybdenum: $molybdenum",
      if (omega3 != null) "omega3: $omega3",
      if (omega6 != null) "omega6: $omega6",
      if (omega9 != null) "omega9: $omega9",
      if (betaCarotene != null) "betaCarotene: $betaCarotene",
      if (bicarbonate != null) "bicarbonate: $bicarbonate",
      if (sugarAlcohol != null) "sugarAlcohol: $sugarAlcohol",
      if (alphaLinolenicAcid != null) "alphaLinolenicAcid: $alphaLinolenicAcid",
      if (arachidicAcid != null) "arachidicAcid: $arachidicAcid",
      if (arachidonicAcid != null) "arachidonicAcid: $arachidonicAcid",
      if (behenicAcid != null) "behenicAcid: $behenicAcid",
      if (ceroticAcid != null) "ceroticAcid: $ceroticAcid",
      if (dihomoGammaLinolenicAcid != null)
        "dihomoGammaLinolenicAcid: $dihomoGammaLinolenicAcid",
      if (elaidicAcid != null) "elaidicAcid: $elaidicAcid",
      if (gammaLinolenicAcid != null) "gammaLinolenicAcid: $gammaLinolenicAcid",
      if (gondoicAcid != null) "gondoicAcid: $gondoicAcid",
      if (lignocericAcid != null) "lignocericAcid: $lignocericAcid",
      if (meadAcid != null) "meadAcid: $meadAcid",
      if (melissicAcid != null) "melissicAcid: $melissicAcid",
      if (montanicAcid != null) "montanicAcid: $montanicAcid",
      if (nervonicAcid != null) "nervonicAcid: $nervonicAcid",
      if (transFat != null) "transFat: $transFat",
    ];
    return '''NutritionalValues(
  ${lines.join(",\n  ")}
)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NutritionValues &&
        other.calories == calories &&
        other.fat == fat &&
        other.saturatedFat == saturatedFat &&
        other.carbs == carbs &&
        other.sugar == sugar &&
        other.protein == protein &&
        other.salt == salt &&
        other.sodium == sodium &&
        other.fiber == fiber &&
        other.addedSugars == addedSugars &&
        other.caffeine == caffeine &&
        other.calcium == calcium &&
        other.iron == iron &&
        other.vitaminC == vitaminC &&
        other.magnesium == magnesium &&
        other.phosphorus == phosphorus &&
        other.potassium == potassium &&
        other.zinc == zinc &&
        other.copper == copper &&
        other.selenium == selenium &&
        other.vitaminA == vitaminA &&
        other.vitaminE == vitaminE &&
        other.vitaminD == vitaminD &&
        other.vitaminB1 == vitaminB1 &&
        other.vitaminB2 == vitaminB2 &&
        other.vitaminPP == vitaminPP &&
        other.vitaminB6 == vitaminB6 &&
        other.vitaminB12 == vitaminB12 &&
        other.vitaminB9 == vitaminB9 &&
        other.vitaminK == vitaminK &&
        other.cholesterol == cholesterol &&
        other.butyricAcid == butyricAcid &&
        other.caproicAcid == caproicAcid &&
        other.caprylicAcid == caprylicAcid &&
        other.capricAcid == capricAcid &&
        other.lauricAcid == lauricAcid &&
        other.myristicAcid == myristicAcid &&
        other.palmiticAcid == palmiticAcid &&
        other.stearicAcid == stearicAcid &&
        other.oleicAcid == oleicAcid &&
        other.linoleicAcid == linoleicAcid &&
        other.docosahexaenoicAcid == docosahexaenoicAcid &&
        other.eicosapentaenoicAcid == eicosapentaenoicAcid &&
        other.erucicAcid == erucicAcid &&
        other.monounsaturatedFat == monounsaturatedFat &&
        other.polyunsaturatedFat == polyunsaturatedFat &&
        other.alcohol == alcohol &&
        other.pantothenicAcid == pantothenicAcid &&
        other.biotin == biotin &&
        other.chloride == chloride &&
        other.chromium == chromium &&
        other.fluoride == fluoride &&
        other.iodine == iodine &&
        other.manganese == manganese &&
        other.molybdenum == molybdenum &&
        other.omega3 == omega3 &&
        other.omega6 == omega6 &&
        other.omega9 == omega9 &&
        other.betaCarotene == betaCarotene &&
        other.bicarbonate == bicarbonate &&
        other.sugarAlcohol == sugarAlcohol &&
        other.alphaLinolenicAcid == alphaLinolenicAcid &&
        other.arachidicAcid == arachidicAcid &&
        other.arachidonicAcid == arachidonicAcid &&
        other.behenicAcid == behenicAcid &&
        other.ceroticAcid == ceroticAcid &&
        other.dihomoGammaLinolenicAcid == dihomoGammaLinolenicAcid &&
        other.elaidicAcid == elaidicAcid &&
        other.gammaLinolenicAcid == gammaLinolenicAcid &&
        other.gondoicAcid == gondoicAcid &&
        other.lignocericAcid == lignocericAcid &&
        other.meadAcid == meadAcid &&
        other.melissicAcid == melissicAcid &&
        other.montanicAcid == montanicAcid &&
        other.nervonicAcid == nervonicAcid &&
        other.transFat == transFat;
  }

  @override
  int get hashCode =>
      calories.hashCode ^
      fat.hashCode ^
      saturatedFat.hashCode ^
      carbs.hashCode ^
      sugar.hashCode ^
      protein.hashCode ^
      salt.hashCode ^
      sodium.hashCode ^
      fiber.hashCode ^
      addedSugars.hashCode ^
      caffeine.hashCode ^
      calcium.hashCode ^
      iron.hashCode ^
      vitaminC.hashCode ^
      magnesium.hashCode ^
      phosphorus.hashCode ^
      potassium.hashCode ^
      zinc.hashCode ^
      copper.hashCode ^
      selenium.hashCode ^
      vitaminA.hashCode ^
      vitaminE.hashCode ^
      vitaminD.hashCode ^
      vitaminB1.hashCode ^
      vitaminB2.hashCode ^
      vitaminPP.hashCode ^
      vitaminB6.hashCode ^
      vitaminB12.hashCode ^
      vitaminB9.hashCode ^
      vitaminK.hashCode ^
      cholesterol.hashCode ^
      butyricAcid.hashCode ^
      caproicAcid.hashCode ^
      caprylicAcid.hashCode ^
      capricAcid.hashCode ^
      lauricAcid.hashCode ^
      myristicAcid.hashCode ^
      palmiticAcid.hashCode ^
      stearicAcid.hashCode ^
      oleicAcid.hashCode ^
      linoleicAcid.hashCode ^
      docosahexaenoicAcid.hashCode ^
      eicosapentaenoicAcid.hashCode ^
      erucicAcid.hashCode ^
      monounsaturatedFat.hashCode ^
      polyunsaturatedFat.hashCode ^
      alcohol.hashCode ^
      pantothenicAcid.hashCode ^
      biotin.hashCode ^
      chloride.hashCode ^
      chromium.hashCode ^
      fluoride.hashCode ^
      iodine.hashCode ^
      manganese.hashCode ^
      molybdenum.hashCode ^
      omega3.hashCode ^
      omega6.hashCode ^
      omega9.hashCode ^
      betaCarotene.hashCode ^
      bicarbonate.hashCode ^
      sugarAlcohol.hashCode ^
      alphaLinolenicAcid.hashCode ^
      arachidicAcid.hashCode ^
      arachidonicAcid.hashCode ^
      behenicAcid.hashCode ^
      ceroticAcid.hashCode ^
      dihomoGammaLinolenicAcid.hashCode ^
      elaidicAcid.hashCode ^
      gammaLinolenicAcid.hashCode ^
      gondoicAcid.hashCode ^
      lignocericAcid.hashCode ^
      meadAcid.hashCode ^
      melissicAcid.hashCode ^
      montanicAcid.hashCode ^
      nervonicAcid.hashCode ^
      transFat.hashCode;

  Map<String, double?> toJson() {
    return {
      "calories": calories,
      "fat": fat,
      "saturatedFat": saturatedFat,
      "carbs": carbs,
      "sugar": sugar,
      "protein": protein,
      "salt": salt,
      "sodium": sodium,
      "fiber": fiber,
      "addedSugars": addedSugars,
      "caffeine": caffeine,
      "calcium": calcium,
      "iron": iron,
      "vitaminC": vitaminC,
      "magnesium": magnesium,
      "phosphorus": phosphorus,
      "potassium": potassium,
      "zinc": zinc,
      "copper": copper,
      "selenium": selenium,
      "vitaminA": vitaminA,
      "vitaminE": vitaminE,
      "vitaminD": vitaminD,
      "vitaminB1": vitaminB1,
      "vitaminB2": vitaminB2,
      "vitaminPP": vitaminPP,
      "vitaminB6": vitaminB6,
      "vitaminB12": vitaminB12,
      "vitaminB9": vitaminB9,
      "vitaminK": vitaminK,
      "cholesterol": cholesterol,
      "butyricAcid": butyricAcid,
      "caproicAcid": caproicAcid,
      "caprylicAcid": caprylicAcid,
      "capricAcid": capricAcid,
      "lauricAcid": lauricAcid,
      "myristicAcid": myristicAcid,
      "palmiticAcid": palmiticAcid,
      "stearicAcid": stearicAcid,
      "oleicAcid": oleicAcid,
      "linoleicAcid": linoleicAcid,
      "docosahexaenoicAcid": docosahexaenoicAcid,
      "eicosapentaenoicAcid": eicosapentaenoicAcid,
      "erucicAcid": erucicAcid,
      "monounsaturatedFat": monounsaturatedFat,
      "polyunsaturatedFat": polyunsaturatedFat,
      "alcohol": alcohol,
      "pantothenicAcid": pantothenicAcid,
      "biotin": biotin,
      "chloride": chloride,
      "chromium": chromium,
      "fluoride": fluoride,
      "iodine": iodine,
      "manganese": manganese,
      "molybdenum": molybdenum,
      "omega3": omega3,
      "omega6": omega6,
      "omega9": omega9,
      "betaCarotene": betaCarotene,
      "bicarbonate": bicarbonate,
      "sugarAlcohol": sugarAlcohol,
      "alphaLinolenicAcid": alphaLinolenicAcid,
      "arachidicAcid": arachidicAcid,
      "arachidonicAcid": arachidonicAcid,
      "behenicAcid": behenicAcid,
      "ceroticAcid": ceroticAcid,
      "dihomoGammaLinolenicAcid": dihomoGammaLinolenicAcid,
      "elaidicAcid": elaidicAcid,
      "gammaLinolenicAcid": gammaLinolenicAcid,
      "gondoicAcid": gondoicAcid,
      "lignocericAcid": lignocericAcid,
      "meadAcid": meadAcid,
      "melissicAcid": melissicAcid,
      "montanicAcid": montanicAcid,
      "nervonicAcid": nervonicAcid,
      "transFat": transFat,
    };
  }

  NutritionValues rescaled({
    required double from,
    required double to,
  }) {
    return this * (to / from);
  }
}

double? _nullIfZero(double value) {
  return value == 0.0 ? null : value;
}
