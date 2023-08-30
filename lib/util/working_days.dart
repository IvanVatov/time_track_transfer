List<DateTime> getWorkingDaysBetweenDates(DateTime startDate, DateTime endDate) {
  List<DateTime> workingDays = [];

  for (var date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = date.add(const Duration(days: 1))) {
    if (date.weekday >= 1 && date.weekday <= 5) {
      workingDays.add(date);
    }
  }

  return workingDays;
}



