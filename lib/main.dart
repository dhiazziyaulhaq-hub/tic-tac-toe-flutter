import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const TicTacToeApp());

const navy = Color(0xFF071D31);
const panel = Color(0xFF102B43);
const blue = Color(0xFF287CF0);
const purple = Color(0xFF8860F5);
const cyan = Color(0xFF36B9FF);
const red = Color(0xFFFF5A67);

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(seedColor: blue, brightness: Brightness.dark),
        fontFamily: 'Roboto',
      ),
      home: const GameHome(),
    );
  }
}

enum AppPage { splash, menu, game, result, settings }
enum GameMode { player, ai }
enum Difficulty { easy, medium, hard }

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  AppPage page = AppPage.splash;
  GameMode mode = GameMode.player;
  Difficulty difficulty = Difficulty.medium;
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String winner = '';
  int scoreX = 0;
  int scoreO = 0;
  final Random random = Random();

  void startGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      winner = '';
      page = AppPage.game;
    });
  }

  String? findWinner(List<String> cells) {
    const lines = <List<int>>[
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (final line in lines) {
      if (cells[line[0]].isNotEmpty &&
          cells[line[0]] == cells[line[1]] &&
          cells[line[1]] == cells[line[2]]) {
        return cells[line[0]];
      }
    }
    if (cells.every((cell) => cell.isNotEmpty)) return 'draw';
    return null;
  }

  void playAt(int index) {
    if (page != AppPage.game || board[index].isNotEmpty || winner.isNotEmpty) return;
    setState(() {
      board[index] = currentPlayer;
      final result = findWinner(board);
      if (result != null) {
        finishGame(result);
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
    });

    if (page == AppPage.game && mode == GameMode.ai && currentPlayer == 'O' && winner.isEmpty) {
      Future.delayed(const Duration(milliseconds: 350), computerMove);
    }
  }

  void computerMove() {
    if (!mounted || page != AppPage.game || winner.isNotEmpty || currentPlayer != 'O') return;
    final available = <int>[];
    for (var i = 0; i < board.length; i++) {
      if (board[i].isEmpty) available.add(i);
    }
    if (available.isEmpty) return;

    int choice;
    if (difficulty == Difficulty.hard) {
      choice = _bestMove('O');
    } else if (difficulty == Difficulty.medium && random.nextBool()) {
      choice = _bestMove('O');
    } else {
      choice = available[random.nextInt(available.length)];
    }

    setState(() {
      board[choice] = 'O';
      final result = findWinner(board);
      if (result != null) {
        finishGame(result);
      } else {
        currentPlayer = 'X';
      }
    });
  }

  int _bestMove(String symbol) {
    final available = <int>[];
    for (var i = 0; i < board.length; i++) {
      if (board[i].isEmpty) available.add(i);
    }
    // Win if possible, otherwise block the opponent, then prefer the center/corners.
    for (final mark in [symbol, symbol == 'X' ? 'O' : 'X']) {
      for (final index in available) {
        final test = List<String>.from(board)..[index] = mark;
        if (findWinner(test) == mark) return index;
      }
    }
    if (board[4].isEmpty) return 4;
    final corners = [0, 2, 6, 8].where((i) => board[i].isEmpty).toList();
    if (corners.isNotEmpty) return corners.first;
    return available.first;
  }

  void finishGame(String result) {
    winner = result;
    if (result == 'X') scoreX++;
    if (result == 'O') scoreO++;
    page = AppPage.result;
  }

  void chooseMode(GameMode selected) {
    setState(() => mode = selected);
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    switch (page) {
      case AppPage.splash:
        return _splashScreen();
      case AppPage.menu:
        return _menuScreen();
      case AppPage.game:
        return _gameScreen();
      case AppPage.result:
        return _resultScreen();
      case AppPage.settings:
        return _settingsScreen();
    }
  }

  Widget _splashScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  _BigSymbol('X', color: blue), SizedBox(width: 18), _BigSymbol('O', color: red),
                ]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  _BigSymbol('O', color: red), SizedBox(width: 18), _BigSymbol('X', color: blue),
                ]),
                const SizedBox(height: 28),
                const Text('Tic Tac Toe', style: TextStyle(color: navy, fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('Simple Game, Endless Fun!', style: TextStyle(color: navy, fontSize: 14)),
                const SizedBox(height: 32),
                SizedBox(width: 230, child: _actionButton('Mulai', onPressed: () => setState(() => page = AppPage.menu))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuScreen() {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Positioned(bottom: -40, left: -20, right: -20, child: Container(height: 110, decoration: const BoxDecoration(color: blue, borderRadius: BorderRadius.vertical(top: Radius.circular(100))))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Spacer(),
              const Icon(Icons.grid_3x3, color: cyan, size: 58),
              const SizedBox(height: 16),
              const Text('Tic Tac Toe', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 38),
              _actionButton('♟  Player vs Player', onPressed: () => chooseMode(GameMode.player)),
              const SizedBox(height: 14),
              _actionButton('🤖  Player vs AI', color: purple, onPressed: () => chooseMode(GameMode.ai)),
              const SizedBox(height: 14),
              _actionButton('⚙  Pengaturan', color: const Color(0xFF526779), onPressed: () => setState(() => page = AppPage.settings)),
              const Spacer(flex: 2),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _gameScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => page = AppPage.menu)),
        title: const Text('Tic Tac Toe', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(children: [
            const SizedBox(height: 10),
            Text(mode == GameMode.player ? 'Player vs Player' : 'Player vs AI', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 22),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 9,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () => playAt(index),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: panel, border: Border.all(color: const Color(0xFF7890A3), width: 1.1), borderRadius: BorderRadius.circular(7)),
                        child: Center(child: Text(board[index], style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: board[index] == 'X' ? cyan : red))),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(winner.isEmpty ? 'Giliran: $currentPlayer' : 'Permainan selesai', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _scoreCard('Kamu (X)', scoreX, cyan)),
              const SizedBox(width: 14),
              Expanded(child: _scoreCard(mode == GameMode.ai ? 'AI (O)' : 'Pemain O', scoreO, red)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _resultScreen() {
    final isDraw = winner == 'draw';
    final won = !isDraw && (mode == GameMode.player ? winner == 'X' : winner == 'X');
    final title = isDraw ? 'Seri!' : (won ? 'Kamu Menang!' : (mode == GameMode.ai ? 'AI Menang!' : 'Pemain O Menang!'));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(isDraw ? Icons.sentiment_satisfied_alt : (won ? Icons.emoji_events : Icons.sentiment_dissatisfied), size: 88, color: isDraw ? Colors.white : (won ? const Color(0xFFFFC83D) : red)),
            const SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(isDraw ? 'Permainan berakhir dengan hasil seri.' : (won ? 'Selamat, kamu berhasil memenangkan permainan!' : 'Tetap semangat, coba lagi ya!'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 34),
            _actionButton('Main Lagi', onPressed: startGame),
            const SizedBox(height: 12),
            _actionButton('Menu Utama', color: Colors.transparent, outlined: true, onPressed: () => setState(() => page = AppPage.menu)),
          ]),
        ),
      ),
    );
  }

  Widget _settingsScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan'), backgroundColor: navy),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Mode Permainan', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _settingsPanel(Column(children: [
          RadioListTile<GameMode>(contentPadding: EdgeInsets.zero, title: const Text('Player vs Player'), value: GameMode.player, groupValue: mode, onChanged: (v) => setState(() => mode = v!)),
          RadioListTile<GameMode>(contentPadding: EdgeInsets.zero, title: const Text('Player vs AI'), value: GameMode.ai, groupValue: mode, onChanged: (v) => setState(() => mode = v!)),
        ])),
        const SizedBox(height: 24),
        const Text('Tingkat Kesulitan (AI)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _settingsPanel(Column(children: [
          RadioListTile<Difficulty>(contentPadding: EdgeInsets.zero, title: const Text('Mudah'), value: Difficulty.easy, groupValue: difficulty, onChanged: (v) => setState(() => difficulty = v!)),
          RadioListTile<Difficulty>(contentPadding: EdgeInsets.zero, title: const Text('Sedang'), value: Difficulty.medium, groupValue: difficulty, onChanged: (v) => setState(() => difficulty = v!)),
          RadioListTile<Difficulty>(contentPadding: EdgeInsets.zero, title: const Text('Sulit'), value: Difficulty.hard, groupValue: difficulty, onChanged: (v) => setState(() => difficulty = v!)),
        ])),
        const SizedBox(height: 26),
        _actionButton('Simpan Pengaturan', onPressed: () => setState(() => page = AppPage.menu)),
      ]),
    );
  }

  Widget _settingsPanel(Widget child) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14)),
    child: child,
  );

  Widget _scoreCard(String label, int score, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14)),
    child: Column(children: [Text(label, style: TextStyle(color: color, fontSize: 14)), const SizedBox(height: 6), Text('$score', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))]),
  );

  Widget _actionButton(String text, {required VoidCallback onPressed, Color color = blue, bool outlined = false}) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)))
          : FilledButton(onPressed: onPressed, style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
    );
  }
}

class _BigSymbol extends StatelessWidget {
  final String symbol;
  final Color color;
  const _BigSymbol(this.symbol, {required this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 62,
    height: 62,
    child: Center(child: Text(symbol, style: TextStyle(color: color, fontSize: 58, height: 1, fontWeight: FontWeight.w800))),
  );
}
