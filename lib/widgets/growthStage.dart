class Growthstage {
  static String getGrowthStage(method, plantingDate) {
    final now = DateTime.now();
    int days = now.difference(plantingDate).inDays;
    if (method == 'Direct Seeding' && days >= 0 && days <= 3) {
      return 'Germination';
    } else if (method == 'Transplanting' && days == 0) {
      return 'Transplanting';
    } else if (method == 'Transplanting' && days >= 1 && days <= 4) {
      return 'Germination';
    } else if (method == 'Transplanting' && days >= 5 && days <= 7) {
      return 'Early Vegetative';
    } else if (method == 'Transplanting' && days >= 8 && days <= 24) {
      return 'Vegetative Growth';
    } else if (days >= 4 && days <= 10) {
      return 'Emergence';
    } else if (days >= 11 && days <= 14) {
      return 'Pre-AWD Transition';
    } else if (days >= 15 && days <= 24) {
      return 'Early Vegetative';
    } else if (days >= 25 && days <= 44) {
      return 'Tillering';
    } else if (days >= 45 && days <= 64) {
      return 'Panicle Initiation';
    } else if (days >= 65 && days <= 70) {
      return 'Flowering';
    } else if (days >= 71 && days <= 100) {
      return 'Grain Filling';
    } else if (days >= 101 && days <= 109) {
      return 'Ripening';
    } else if (days >= 110) {
      return 'Harvest';
    } else
      return 'Unknown Stage';
  }

}
