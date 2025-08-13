import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'LEADERBOARD',
          style: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: const LeaderboardContent(),
    );
  }
}

class LeaderboardContent extends StatelessWidget {
  const LeaderboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for the leaderboard
    final List<Map<String, dynamic>> leaderboardData = [
      {'rank': 1, 'name': 'Alex Johnson', 'score': 9875},
      {'rank': 2, 'name': 'Emma Williams', 'score': 9742},
      {'rank': 3, 'name': 'Michael Brown', 'score': 9568},
      {'rank': 4, 'name': 'Sophia Davis', 'score': 8954},
      {'rank': 5, 'name': 'James Wilson', 'score': 8732},
      {'rank': 6, 'name': 'Olivia Taylor', 'score': 8521},
      {'rank': 7, 'name': 'William Miller', 'score': 8347},
      {'rank': 8, 'name': 'Ava Anderson', 'score': 8125},
      {'rank': 9, 'name': 'Ethan Thomas', 'score': 7986},
      {'rank': 10, 'name': 'Isabella Jackson', 'score': 7854},
      {'rank': 11, 'name': 'Noah White', 'score': 7632},
      {'rank': 12, 'name': 'Charlotte Harris', 'score': 7521},
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF1E293B).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Top 3 winners section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2nd place
                TopPlayerWidget(
                  rank: 2,
                  name: leaderboardData[1]['name'],
                  score: leaderboardData[1]['score'],
                  color: const Color(0xFFE0E0E0), // Silver
                  size: 90,
                  textSize: 16,
                ),
                
                // 1st place
                TopPlayerWidget(
                  rank: 1,
                  name: leaderboardData[0]['name'],
                  score: leaderboardData[0]['score'],
                  color: const Color(0xFFFFD700), // Gold
                  size: 110,
                  textSize: 18,
                ),
                
                // 3rd place
                TopPlayerWidget(
                  rank: 3,
                  name: leaderboardData[2]['name'],
                  score: leaderboardData[2]['score'],
                  color: const Color(0xFFCD7F32), // Bronze
                  size: 80,
                  textSize: 14,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Rest of the leaderboard
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16),
                itemCount: leaderboardData.length - 3, // Skip the top 3
                itemBuilder: (context, index) {
                  final playerData = leaderboardData[index + 3]; // +3 to skip top 3
                  return LeaderboardTile(
                    rank: playerData['rank'],
                    name: playerData['name'],
                    score: playerData['score'],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopPlayerWidget extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final Color color;
  final double size;
  final double textSize;

  const TopPlayerWidget({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.color,
    required this.size,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: GoogleFonts.plusJakartaSans(
                textStyle: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF0F67FE),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.split(' ').map((part) => part[0]).join(''),
              style: GoogleFonts.plusJakartaSans(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: textSize,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: GoogleFonts.plusJakartaSans(
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: textSize - 2,
            ),
          ),
        ),
      ],
    );
  }
}

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int score;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: GoogleFonts.plusJakartaSans(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            textStyle: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F67FE).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            score.toString(),
            style: GoogleFonts.plusJakartaSans(
              textStyle: const TextStyle(
                color: Color(0xFF0F67FE),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}