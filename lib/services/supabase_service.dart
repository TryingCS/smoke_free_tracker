import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final supabase = Supabase.instance.client;

  // User Profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .limit(1);
      return response.isNotEmpty ? response[0] : null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> updateNickname(String userId, String nickname) async {
    try {
      // Since we know the profile exists (user is logged in), we can use update
      await supabase.from('profiles').update({
        'nickname': nickname,
      }).eq('user_id', userId);
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
          .limit(1);
      return response.isNotEmpty ? response[0] : null;
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
}
