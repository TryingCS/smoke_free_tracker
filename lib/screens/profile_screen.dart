// lib/screens/profile_screen.dart - MINIMAL FIX
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  final String currentNickname;
  final int personalBest;
  final Function(String) onNicknameUpdated;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.currentNickname,
    required this.personalBest,
    required this.onNicknameUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.currentNickname;
  }

  Future<void> _updateNickname() async {
    if (_nicknameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await SupabaseService.updateNickname(
        widget.userId,
        _nicknameController.text.trim(),
      );
      widget.onNicknameUpdated(_nicknameController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nickname updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating nickname: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await SupabaseService.supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.currentNickname,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Personal Best Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Personal Best Streak',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              '${widget.personalBest}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              widget.personalBest == 1 ? 'day' : 'days',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Your longest smoke-free streak',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Nickname Update Section
              const Text(
                'Update Nickname',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This name appears on the leaderboard',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  hintText: 'Enter your nickname',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateNickname,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update Nickname',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
