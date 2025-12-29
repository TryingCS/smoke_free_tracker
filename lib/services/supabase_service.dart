import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  // User Profile - FIXED VERSION
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle()
          .onError((_, __) => null);

      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> updateNickname(String userId, String nickname) async {
    try {
      await supabase
          .from('profiles')
          .update({'nickname': nickname}).eq('user_id', userId);
    } catch (e) {
      print('Error updating nickname: $e');
      rethrow;
    }
  }

  // Streaks
  static Future<Map<String, dynamic>?> getStreak(String userId) async {
    try {
      final response = await supabase
          .from('streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle()
          .onError((_, __) => null);

      return response;
    } catch (e) {
      print('Error getting streak: $e');
      return null;
    }
  }

  static Future<void> startStreak(String userId) async {
    try {
      await supabase.from('streaks').upsert({
        'user_id': userId,
        'current_streak_start': DateTime.now().toIso8601String(),
        'last_relapse': null,
      }, onConflict: 'user_id');
    } catch (e) {
      print('Error starting streak: $e');
      rethrow;
    }
  }

  static Future<void> registerRelapse(String userId, {String? note}) async {
    try {
      // Save relapse
      await supabase.from('relapses').insert({
        'user_id': userId,
        'note': note,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Reset streak
      await supabase.from('streaks').upsert({
        'user_id': userId,
        'current_streak_start': null,
        'last_relapse': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e) {
      print('Error registering relapse: $e');
      rethrow;
    }
  }

  // Relapses
  static Future<List<Map<String, dynamic>>> getRelapses(String userId) async {
    try {
      final response = await supabase
          .from('relapses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      print('Error getting relapses: $e');
      return [];
    }
  }

  // Notes
  static Future<List<Map<String, dynamic>>> getNotes(String userId) async {
    try {
      final response = await supabase
          .from('notes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      print('Error getting notes: $e');
      return [];
    }
  }

  static Future<void> addNote(String userId, String content) async {
    try {
      await supabase.from('notes').insert({
        'user_id': userId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  static Future<void> deleteNote(String noteId) async {
    try {
      await supabase.from('notes').delete().eq('id', noteId);
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  // Leaderboard
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final response = await supabase
          .from('streaks')
          .select('*, profiles!inner(nickname)')
          .not('current_streak_start', 'is', null)
          .order('current_streak_start', ascending: true);

      return response.map((streak) {
        final start = DateTime.parse(streak['current_streak_start']);
        final duration = DateTime.now().difference(start);
        return {
          'nickname': streak['profiles']['nickname'],
          'duration': duration,
          'start': start,
          'user_id': streak['user_id'],
        };
      }).toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }

  // Personal Best - FIXED VERSION
  static Future<int> getPersonalBest(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('personal_best_days')
          .eq('user_id', userId)
          .maybeSingle()
          .onError((_, __) => null);

      return response?['personal_best_days'] ?? 0;
    } catch (e) {
      print('Error getting personal best: $e');
      return 0;
    }
  }

  // Update personal best - FIXED VERSION (removed .gt condition)
  static Future<void> updatePersonalBest(String userId, int days) async {
    try {
      await supabase
          .from('profiles')
          .update({'personal_best_days': days}).eq('user_id', userId);
    } catch (e) {
      print('Error updating personal best: $e');
    }
  }

  // CRITICAL: Create profile and streak if missing
  static Future<void> ensureUserProfileAndStreak(String userId) async {
    try {
      // Check if profile exists
      final profile = await getUserProfile(userId);
      if (profile == null) {
        // Create profile
        await supabase.from('profiles').insert({
          'user_id': userId,
          'nickname': 'User${userId.substring(0, 6)}',
          'personal_best_days': 0,
        });
        print('Created missing profile for user: $userId');
      }

      // Check if streak exists
      final streak = await getStreak(userId);
      if (streak == null) {
        // Create streak record
        await supabase.from('streaks').insert({
          'user_id': userId,
          'current_streak_start': null,
          'last_relapse': null,
        });
        print('Created missing streak for user: $userId');
      }
    } catch (e) {
      print('Error ensuring user profile/streak: $e');
    }
  }
}
