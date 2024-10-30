// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tracker_v1/providers/user_stats_provider.dart'; // Assuming you have this provider file

// class GardenScreen extends ConsumerWidget {
//   const GardenScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Access the user stats from the provider
//     final userStats = ref.watch(userStatsProvider);

//     return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Total Gems
//             _buildScoreCard(
//               context,
//               label: 'Total Gems Earned',
//               value: userStats.totGems.toString(),
//               color: Colors.redAccent, // Color for total gems
//               icon: Icons.auto_awesome, // Gem icon
//             ),
//             const SizedBox(height: 20),
            
//             // Available Gems
//             _buildScoreCard(
//               context,
//               label: 'Available Gems',
//               value: userStats.availableGems.toString(),
//               color: Color.fromARGB(255, 248, 189, 51), // Color for available gems
//               icon: Icons.auto_awesome_mosaic, // Different gem icon
//             ),
//             const SizedBox(height: 20),
            
//             // Weekly Average
//             _buildScoreCard(
//               context,
//               label: 'Weekly Average',
//               value: userStats.averageWeek.toStringAsFixed(2),
//               color: Colors.greenAccent, // Color for weekly average
//               icon: Icons.show_chart_rounded, // Chart icon
//             ),
//             const SizedBox(height: 20),
            
//             // 3-Month Average
//             _buildScoreCard(
//               context,
//               label: '3-Month Average',
//               value: userStats.average3Months.toStringAsFixed(2),
//               color: Colors.blueAccent, // Color for 3-month average
//               icon: Icons.insights_rounded, // Another chart icon
//             ),const SizedBox(height: 20),
//             // 3-Month Average
//             _buildScoreCard(
//               context,
//               label: 'OverAll Average',
//               value: userStats.average3Months.toStringAsFixed(2),
//               color: Colors.purpleAccent, // Color for 3-month average
//               icon: Icons.align_vertical_bottom_rounded, // Another chart icon
//             ),
//           ],
//         ),
      
//     );
//   }

//   // Helper method to build styled score cards
//   Widget _buildScoreCard(BuildContext context, {required String label, required String value, required Color color, required IconData icon}) {
//     return Container(
//       width: 350,
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.surface, // Slightly lighter than background
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.5),
//             blurRadius: 5,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 30, color: color),
//               const SizedBox(width: 12),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
