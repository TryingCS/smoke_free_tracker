import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'profile_screen.dart';
import '../widgets/streak_counter.dart';
import '../widgets/notes_list.dart';
import '../widgets/leaderboard_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _streakStart;
  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> _relapses = [];
  List<Map<String, dynamic>> _notes = [];
  String? _userNickname;
  String? _userId;
  int _personalBest = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
    _loadStreak();
    _loadRelapses();
    _loadNotes();
    _loadLeaderboard();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final session = SupabaseService.supabase.auth.currentSession;
    if (session != null) {
      _userId = session.user.id;

      // CRITICAL: Ensure profile and streak exist
      await SupabaseService.ensureUserProfileAndStreak(_userId!);

      final profile = await SupabaseService.getUserProfile(_userId!);
      if (profile != null) {
        setState(() {
          _userNickname = profile['nickname'];
          _personalBest = profile['personal_best_days'] ?? 0;
        });
      }
    }
  }

  Future<void> _loadStreak() async {
    if (_userId == null) return;

    final streak = await SupabaseService.getStreak(_userId!);
    if (streak != null && streak['current_streak_start'] != null) {
      setState(() {
        _streakStart = DateTime.parse(streak['current_streak_start']);
        _updateDuration();
      });
    }
  }

  Future<void> _loadRelapses() async {
    if (_userId == null) return;

    final relapses = await SupabaseService.getRelapses(_userId!);
    setState(() {
      _relapses = relapses;
    });
  }

  Future<void> _loadNotes() async {
    if (_userId == null) return;

    final notes = await SupabaseService.getNotes(_userId!);
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _loadLeaderboard() async {
    try {
      final response = await SupabaseService.supabase
          .from('streaks')
          .select('*, profiles!inner(nickname)')
          .not('current_streak_start', 'is', null)
          .order('current_streak_start', ascending: true);

      final leaderboard = response.map((streak) {
        final start = DateTime.parse(streak['current_streak_start']);
        return {
          'nickname': streak['profiles']['nickname'],
          'start': start,
          'user_id': streak['user_id'],
        };
      }).toList();

      // Sort by duration (calculated from start time)
      leaderboard.sort((a, b) => DateTime.now()
          .difference(b['start'])
          .compareTo(DateTime.now().difference(a['start'])));

      setState(() {
        _leaderboard = leaderboard;
      });
    } catch (e) {
      print('Error loading leaderboard: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_streakStart != null) {
        setState(() {
          _updateDuration();
        });
      }
    });
  }

  void _updateDuration() {
    if (_streakStart != null) {
      _currentDuration = DateTime.now().difference(_streakStart!);
    }
  }

  Future<void> _startStreak() async {
    if (_userId == null) return;

    await SupabaseService.startStreak(_userId!);
    final streak = await SupabaseService.getStreak(_userId!);
    if (streak != null && streak['current_streak_start'] != null) {
      setState(() {
        _streakStart = DateTime.parse(streak['current_streak_start']);
        _updateDuration();
      });
      _loadLeaderboard();
    }
  }

  Future<void> _registerRelapse(String? note) async {
    if (_userId == null) return;

    // Save the current streak duration before resetting
    final endedStreakDays = _currentDuration.inDays;

    await SupabaseService.registerRelapse(_userId!, note: note);

    // Check if this streak was a personal best
    if (endedStreakDays > _personalBest) {
      // Update in database
      await SupabaseService.updatePersonalBest(_userId!, endedStreakDays);

      // Update local state
      setState(() {
        _personalBest = endedStreakDays;
      });
    }

    setState(() {
      _streakStart = null;
      _currentDuration = Duration.zero;
    });

    _loadRelapses();
    _loadLeaderboard();
  }

  Future<void> _addNote(String content) async {
    if (_userId == null) return;

    await SupabaseService.addNote(_userId!, content);
    _loadNotes();
  }

  Future<void> _deleteNote(String noteId) async {
    await SupabaseService.deleteNote(noteId);
    _loadNotes();
  }

  void _updateNickname(String newNickname) {
    setState(() {
      _userNickname = newNickname;
    });
    _loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smoke Free Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timer), text: 'Tracker'),
            Tab(icon: Icon(Icons.note), text: 'Notes'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Leaderboard'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreakCounter(
            streakStart: _streakStart,
            currentDuration: _currentDuration,
            relapses: _relapses,
            onStartStreak: _startStreak,
            onRegisterRelapse: _registerRelapse,
          ),
          NotesList(
            notes: _notes,
            onAddNote: _addNote,
            onDeleteNote: _deleteNote,
          ),
          LeaderboardWidget(
            leaderboard: _leaderboard,
            currentUserNickname: _userNickname,
          ),
          ProfileScreen(
            userId: _userId ?? '',
            currentNickname: _userNickname ?? 'User',
            personalBest: _personalBest,
            onNicknameUpdated: _updateNickname,
          ),
        ],
      ),
    );
  }
}
