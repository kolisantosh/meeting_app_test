import '../../views.dart';

class EmployeePinWidget extends StatefulWidget {
  const EmployeePinWidget({super.key});

  @override
  State<EmployeePinWidget> createState() => _EmployeePinWidgetState();
}

class _EmployeePinWidgetState extends State<EmployeePinWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "timeLeft",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 39,
            fontWeight: FontWeight.bold,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
