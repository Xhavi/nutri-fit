import 'package:flutter/widgets.dart';

import 'home_screen.dart';

@Deprecated('Use HomeScreen in home_screen.dart.')
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
