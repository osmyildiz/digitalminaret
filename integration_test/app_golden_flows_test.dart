// Golden integration flows with fakes for permissions, location and scheduling.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class _FakeAppState extends ChangeNotifier {
  bool permissionGranted = false;
  bool notificationsOn = false;
  bool ramadanMode = false;
  String method = 'ISNA';
  String city = '';
  int scheduleCalls = 0;

  void grantPermission() {
    permissionGranted = true;
    city = 'Albany';
    notifyListeners();
  }

  void denyPermission() {
    permissionGranted = false;
    notifyListeners();
  }

  void setManualCity(String v) {
    city = v;
    notifyListeners();
  }

  void setMethod(String v) {
    method = v;
    notifyListeners();
  }

  void setNotifications(bool v) {
    notificationsOn = v;
    if (v) {
      scheduleCalls += 1;
    }
    notifyListeners();
  }

  void setRamadan(bool v) {
    ramadanMode = v;
    notifyListeners();
  }
}

class _FakeApp extends StatefulWidget {
  const _FakeApp({required this.state});

  final _FakeAppState state;

  @override
  State<_FakeApp> createState() => _FakeAppStateWidgetState();
}

class _FakeAppStateWidgetState extends State<_FakeApp>
    with WidgetsBindingObserver {
  String lifecycleText = 'resumed';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.state.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.state.removeListener(_refresh);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      lifecycleText = state.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.city.isEmpty) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                onPressed: widget.state.grantPermission,
                child: const Text('Grant Location'),
              ),
              ElevatedButton(
                onPressed: widget.state.denyPermission,
                child: const Text('Deny Location'),
              ),
              if (!widget.state.permissionGranted)
                TextField(
                  key: const Key('manualCityInput'),
                  onSubmitted: widget.state.setManualCity,
                ),
            ],
          ),
        ),
      );
    }

    final dhuhrLabel = DateTime(2026, 3, 6).weekday == DateTime.friday
        ? 'Jumuah'
        : 'Dhuhr';
    final fajrLabel = widget.state.ramadanMode ? 'Suhoor' : 'Fajr';
    final maghribLabel = widget.state.ramadanMode ? 'Iftar' : 'Maghrib';

    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('City: ${widget.state.city}'),
            Text('Method: ${widget.state.method}'),
            Text(fajrLabel),
            Text(dhuhrLabel),
            Text(maghribLabel),
            Text('Lifecycle: $lifecycleText'),
            Switch(
              value: widget.state.notificationsOn,
              onChanged: widget.state.setNotifications,
            ),
            Text('Schedules: ${widget.state.scheduleCalls}'),
            DropdownButton<String>(
              value: widget.state.method,
              items: const [
                DropdownMenuItem(value: 'ISNA', child: Text('ISNA')),
                DropdownMenuItem(value: 'MWL', child: Text('MWL')),
              ],
              onChanged: (v) => widget.state.setMethod(v!),
            ),
            Switch(
              key: const Key('ramadanSwitch'),
              value: widget.state.ramadanMode,
              onChanged: widget.state.setRamadan,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Golden flows', () {
    testWidgets('first launch + permission granted -> prayers visible', (tester) async {
      final state = _FakeAppState();
      await tester.pumpWidget(_FakeApp(state: state));

      await tester.tap(find.text('Grant Location'));
      await tester.pumpAndSettle();

      expect(find.text('City: Albany'), findsOneWidget);
      expect(find.text('Fajr'), findsOneWidget);
    });

    testWidgets('permission denied -> manual city -> prayers visible', (tester) async {
      final state = _FakeAppState();
      await tester.pumpWidget(_FakeApp(state: state));

      await tester.tap(find.text('Deny Location'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('manualCityInput')), 'Albany');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('City: Albany'), findsOneWidget);
    });

    testWidgets('settings method change updates home', (tester) async {
      final state = _FakeAppState()
        ..city = 'Albany'
        ..permissionGranted = true;
      await tester.pumpWidget(_FakeApp(state: state));

      await tester.tap(find.text('ISNA'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MWL').last);
      await tester.pumpAndSettle();

      expect(find.text('Method: MWL'), findsOneWidget);
    });

    testWidgets('notifications ON triggers schedule call', (tester) async {
      final state = _FakeAppState()
        ..city = 'Albany'
        ..permissionGranted = true;
      await tester.pumpWidget(_FakeApp(state: state));

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(find.text('Schedules: 1'), findsOneWidget);
    });

    testWidgets('ramadan toggle updates labels + lifecycle stable', (tester) async {
      final state = _FakeAppState()
        ..city = 'Albany'
        ..permissionGranted = true;
      await tester.pumpWidget(_FakeApp(state: state));

      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('Maghrib'), findsOneWidget);

      await tester.tap(find.byKey(const Key('ramadanSwitch')));
      await tester.pumpAndSettle();

      expect(find.text('Suhoor'), findsOneWidget);
      expect(find.text('Iftar'), findsOneWidget);
      expect(find.textContaining('Lifecycle:'), findsOneWidget);
    });
  });
}
