import 'dart:math' as math;

/// Estimates the postprandial blood sugar spike after consuming a food item.
/// This advanced version incorporates research insights on glycemic index/load,
/// effective carbohydrate load (carbs - fiber), protein effects, and personal metabolic factors.
///
/// Factors considered:
///  - Glycemic Index (GI) and Glycemic Load (GL)
///  - Carbohydrates, Fiber, and Protein content of the meal
///  - Basal Metabolic Rate (BMR)
///  - Recent Activity Score (0-100)
///  - Hours since last physical activity
///  - Sleep duration (hours)
///
/// @param {number} GI - Glycemic Index of the food (0-100)
/// @param {number} GL - Glycemic Load of the food
/// @param {number} carbs - Total carbohydrates in grams
/// @param {number} fiber - Fiber content in grams
/// @param {number} protein - Protein content in grams
/// @param {number} BMR - Basal Metabolic Rate (kcal/day)
/// @param {number} activityScore - Recent Activity Score (0-100)
/// @param {number} lastActivityHours - Hours since the last physical activity
/// @param {number} sleepHours - Sleep duration in hours (last night)
/// @returns {number} - Estimated blood sugar spike in mmol/L
double estimateSugarSpikeAdvanced(
    double GI,
    double GL,
    double carbs,
    double fiber,
    double protein,
    double BMR,
    double activityScore,
    double lastActivityHours,
    double sleepHours) {
  // 1️⃣ Baseline response using GI & GL (a rough estimation)
  double baseSpike = (GI * GL) / 100;

  // 2️⃣ Effective carbohydrate load:
  //    (net carbs = total carbs - fiber) with a slight adjustment for protein (protein slows absorption)
  double netCarbs = (carbs - fiber) > 0 ? (carbs - fiber) : 0;
  // Here we assume that protein may slightly attenuate the spike.
  // The factor 0.005 per gram protein is an empirical value (tune as needed).
  double proteinAdjustment = 1 - (protein * 0.005);
  proteinAdjustment = proteinAdjustment > 0.8 ? proteinAdjustment : 0.8; // cap the reduction to 20%

  // Empirical constant: each gram of effective net carb increases blood glucose by 0.05 mmol/L baseline.
  double carbResponse = netCarbs * 0.05 * proteinAdjustment;

  // 3️⃣ BMR Factor: Lower BMR (compared to an average 1500 kcal/day) implies slower clearance → higher spike.
  double BMRFactor = 1500 / BMR;

  // 4️⃣ Activity Factor: Higher activity improves glucose uptake (activityScore 0-100).
  // Normalized so that a high activity score reduces the spike.
  double activityFactor = 1 - (activityScore / 200); // e.g., activityScore of 80 gives a factor of 0.6

  // 5️⃣ Time Factor: Benefit of exercise decays over time (exponential decay).
  // Fixed: Using math.exp instead of .exp()
  double timeFactor = math.exp(-lastActivityHours / 3);

  // 6️⃣ Sleep Factor: Poor sleep (<7 hours) increases insulin resistance.
  // For each hour below 7, we increase the spike by 10%.
  double sleepFactor = sleepHours < 7 ? 1 + ((7 - sleepHours) * 0.1) : 1;

  // 7️⃣ Combine the factors:
  // The final estimated spike combines the baseline (GI/GL) with the carb response and all adjustments.
  double estimatedSpike = (baseSpike + carbResponse) * BMRFactor * activityFactor * timeFactor * sleepFactor;

  // Return a non-negative spike value.
  return estimatedSpike > 0 ? estimatedSpike : 0;
}
