class DailyRecord {
  String date;
  int faceScale;
  int steps;
  bool toothBrushed;
  int gargleCount;
  bool bodyCare;
  bool shower;
  bool medicationTaken;

  DailyRecord({
    required this.date,
    required this.faceScale,
    required this.steps,
    required this.toothBrushed,
    required this.gargleCount,
    required this.bodyCare,
    required this.shower,
    required this.medicationTaken,
  });
}