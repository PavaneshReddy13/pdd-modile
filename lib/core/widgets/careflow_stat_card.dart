import 'package:flutter/material.dart';
import 'careflow_metric_card.dart';

class CareFlowStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const CareFlowStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return CareFlowMetricCard(
      title: title,
      value: value,
      icon: icon,
      accentColor: color,
      subtitle: subtitle,
    );
  }
}
