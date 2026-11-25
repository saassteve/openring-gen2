enum HealthMetric {
  heartRate('Heart rate'),
  hrv('HRV'),
  oxygen('SpO₂'),
  respiratoryRate('Respiratory rate'),
  steps('Steps'),
  outerTemperature('Outer NTC'),
  innerTemperature('Inner NTC');

  const HealthMetric(this.label);

  final String label;
}

typedef HealthSample = ({String deviceId, int cursor, List<double> values});
typedef HealthExportReport = ({DateTime at, Map<HealthMetric, int> counts});
