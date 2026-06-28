String formatRelativeTime(DateTime date, {required bool swahili, DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(date);

  // 30+ days => months
  if (diff.inDays >= 30) {
    final months = (diff.inDays / 30).floor();
    if (swahili) {
      return months == 1 ? 'Mwezi 1 uliopita' : 'Miezi $months iliyopita';
    }
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  }

  // 7–29 days => weeks
  if (diff.inDays >= 7) {
    final weeks = (diff.inDays / 7).floor();
    if (swahili) {
      return 'Wiki $weeks ${weeks == 1 ? 'iliyopita' : 'zilizopita'}';
    }
    return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
  }

  // 1–6 days => days
  if (diff.inDays > 0) {
    if (swahili) {
      return 'Siku ${diff.inDays} ${diff.inDays == 1 ? 'iliyopita' : 'zilizopita'}';
    }
    return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
  }

  if (diff.inHours > 0) {
    if (swahili) {
      return 'Saa ${diff.inHours} ${diff.inHours == 1 ? 'iliyopita' : 'zilizopita'}';
    }
    return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
  }

  if (diff.inMinutes > 0) {
    if (swahili) {
      return 'Dakika ${diff.inMinutes} ${diff.inMinutes == 1 ? 'iliyopita' : 'zilizopita'}';
    }
    return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  }

  return swahili ? 'Sasa hivi' : 'Just now';
}
