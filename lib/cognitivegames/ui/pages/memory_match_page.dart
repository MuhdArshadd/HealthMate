import 'package:flutter/material.dart';

import '../widgets/game_board.dart';

class MemoryMatchPage extends StatelessWidget {
  const MemoryMatchPage({
    required this.gameLevel,
    super.key,
  });

  final int gameLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GameBoardMobile(
              gameLevel: gameLevel,
            );
          },
        ),
      ),
    );
  }
}
