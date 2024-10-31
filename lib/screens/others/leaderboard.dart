import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/user.dart';
import 'package:tracker_v1/models/datas/user_stats.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/users_stats_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.invalidate(allUserStatsProvider);
    AsyncValue usersStat = ref.read(allUserStatsProvider);

    return usersStat.when(
        data: (data) => Container(
              color: Theme.of(context).colorScheme.surface,
              child: SingleChildScrollView(
                  child: Container(
                alignment: Alignment.topCenter,
                height: MediaQuery.of(context).size.height * 1.25,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 120,
                    ),
                    LeaderboardPodium(data),
                    const SizedBox(
                      height: 32,
                    ),
                    Expanded(child: LeaderboardList(data.$1, data.$2))
                  ],
                ),
              )),
            ),
        error: (error, stackTrace) => const Center(
              child: CircularProgressIndicator(),
            ),
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
  }
}

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium(this.data, {super.key});
  final (List<UserStats>, List<UserData>) data;

  // Colors for the podium
  final List<Color> podiumColor = const [
    Color.fromARGB(255, 32, 116, 35),
    Colors.greenAccent,
    Color.fromARGB(255, 11, 96, 165),
    Color.fromARGB(255, 86, 200, 253),
    Color.fromARGB(255, 132, 24, 151),
    Colors.purpleAccent
  ];

  @override
  Widget build(BuildContext context) {
    List<UserStats> usersStats = data.$1;
    List<UserData> usersData = data.$2;

    // Get the top 3 user stats and data
    if (usersStats.length < 4) {
      usersStats.addAll(
          List.generate(4 - usersStats.length, (index) => usersStats[0]));
    }
    final UserStats? firstStats = usersStats.isNotEmpty ? usersStats[0] : null;
    final UserStats? secondStats =
        usersStats.length > 1 ? usersStats[1] : usersStats[0];
    final UserStats? thirdStats =
        usersStats.length > 2 ? usersStats[2] : usersStats[0];
    final UserData? firstData =
        usersData.firstWhereOrNull((data) => data.userId == firstStats?.userId);
    final UserData? secondData = usersData
        .firstWhereOrNull((data) => data.userId == secondStats?.userId);
    final UserData? thirdData =
        usersData.firstWhereOrNull((data) => data.userId == thirdStats?.userId);

    double ratioFirstOther = 0.75;
    double firstContainerHeight = 160;
    double firstAvatarRadius = 100;
    double otherContainerHeight = firstContainerHeight * ratioFirstOther;
    double otherAvatarRadius = firstAvatarRadius * ratioFirstOther;
    double shiftCircle = 0.25;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Second place Podium
          Expanded(
            flex: 1,
            child: PodiumColumn(
              containerHeight: otherContainerHeight,
              shiftCircle: shiftCircle,
              userData: secondData!,
              userStats: secondStats!,
              avatarRadius: otherAvatarRadius,
              podiumColor: [podiumColor[2], podiumColor[3]],
              number: 2,
            ),
          ),
          // First place Podium
          Expanded(
            flex: 1,
            child: PodiumColumn(
              containerHeight: firstContainerHeight,
              shiftCircle: shiftCircle,
              userData: firstData!,
              userStats: firstStats!,
              avatarRadius: firstAvatarRadius,
              podiumColor: [podiumColor[4], podiumColor[5]],
              number: 1,
            ),
          ),
          // Third place Podium
          Expanded(
            flex: 1,
            child: PodiumColumn(
              containerHeight: otherContainerHeight - 24, // Slightly smaller
              shiftCircle: shiftCircle,
              userData: thirdData!,
              userStats: thirdStats!,
              avatarRadius: otherAvatarRadius,
              podiumColor: [podiumColor[0], podiumColor[1]],
              number: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class PodiumColumn extends StatelessWidget {
  final double containerHeight;
  final double shiftCircle;
  final UserData userData;
  final UserStats userStats;
  final double avatarRadius;
  final List<Color> podiumColor;
  final int number;
  final Radius radius = const Radius.circular(20);

  const PodiumColumn(
      {super.key,
      required this.containerHeight,
      required this.shiftCircle,
      required this.userData,
      required this.userStats,
      required this.avatarRadius,
      required this.podiumColor,
      required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: number == 1
            ? Theme.of(context).colorScheme.surfaceBright
            : Theme.of(context).colorScheme.surfaceBright.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topRight: number != 2 ? radius : Radius.zero,
          bottomLeft: number == 2 ? radius : Radius.zero,
          bottomRight: number == 3 ? radius : Radius.zero,
          topLeft: number != 3 ? radius : Radius.zero,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(userData.name,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: avatarRadius / 6, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                userStats.streaks.toString(),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: podiumColor[1],
                      fontSize: avatarRadius / 5,
                    ),
              ),
            ],
          ),
          if (number == 1)
            Positioned(
              top: -(containerHeight + avatarRadius + 8) * shiftCircle - 40,
              child: const Icon(
                Icons.emoji_events,
                size: 40,
                color: Color.fromARGB(255, 252, 191, 44),
              ),
            ),
          Positioned(
            top: -(containerHeight + avatarRadius + 8) * shiftCircle,
            child: PodiumPictureAvatar(
              podiumColor[0],
              podiumColor[1],
              userData.profilPicture,
              avatarRadius,
              first: true,
            ),
          ),
          Positioned(
              top: -(containerHeight - avatarRadius * 2 + 8) * shiftCircle +
                  avatarRadius / 4.5 / 2,
              child: Transform.rotate(
                  angle: math.pi / 4, // Rotate by 45 degrees (π/4 radians)
                  child: Container(
                    width: avatarRadius / 4.5,
                    height: avatarRadius / 4.5,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [podiumColor[0], podiumColor[1]],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
                  ))),
          Positioned(
            top: -(containerHeight - avatarRadius * 2 + 8) * shiftCircle +
                avatarRadius / 4.5 / 2,
            child: Text(
              '$number',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontSize: avatarRadius / 6),
            ),
          )
        ],
      ),
    );
  }
}

class PodiumPictureAvatar extends StatelessWidget {
  const PodiumPictureAvatar(
      this.borderColor, this.borderColor2, this.pictureUrl, this.radius,
      {super.key, this.first = false});
  final Color borderColor;
  final Color borderColor2;
  final String pictureUrl;
  final double radius;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius,
      width: radius,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [borderColor2, borderColor],
            begin: first ? Alignment.bottomCenter : Alignment.topCenter,
            end: first ? Alignment.topCenter : Alignment.bottomCenter),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundImage: NetworkImage(pictureUrl),
      ),
    );
  }
}

class LeaderboardList extends StatelessWidget {
  const LeaderboardList(this.usersStats, this.usersData, {super.key});
  final List<UserStats> usersStats;
  final List<UserData> usersData;

  @override
  Widget build(BuildContext context) {
    final UserStats currentUserStats = usersStats.firstWhereOrNull(
        (item) => item.userId == FirebaseAuth.instance.currentUser!.uid);
    final UserData currentUserData = usersData.firstWhereOrNull(
        (item) => item.userId == FirebaseAuth.instance.currentUser!.uid);

    final style =
        Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.grey);

    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceBright,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      child: Column(
        children: [
          const SizedBox(
            height: 12,
          ),
          SizedBox(
              width: double.infinity,
              height: 30,
              child: ListTile(
                  leading: Text('#', style: style),
                  title: Text('NAME', style: style),
                  trailing: Text('STREAKS', style: style))),
          const SizedBox(
            height: 20,
          ),
          LeaderboardCard(
            currentUserStats,
            currentUserData,
            usersStats.indexOf(currentUserStats) + 1,
            gradient: true,
            currentUser: true,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(color: Colors.grey),
            height: 1,
            width: double.infinity,
          ),
          Expanded(
              child: ListView.builder(
            itemCount: usersStats.length - 3,
            itemBuilder: (context, index) {
              final UserStats userStats = usersStats[index + 2];
              final UserData userData = usersData
                  .firstWhereOrNull((item) => item.userId == userStats.userId);
              return LeaderboardCard(userStats, userData, index + 4);
            },
          )),
        ],
      ),
    );
  }
}

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard(this.userStats, this.userData, this.number,
      {super.key, this.gradient = false, this.currentUser = false});

  final UserStats userStats;
  final UserData userData;
  final bool gradient;
  final int number;
  final bool currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: gradient ? null : Theme.of(context).colorScheme.surface,
          gradient: gradient
              ? const LinearGradient(
                  colors: [Colors.purple, Color.fromARGB(255, 83, 13, 95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(currentUser ? 'You' : userData.name,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: currentUser ? FontWeight.bold : null)),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('#$number', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(
                width: 32,
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(userData.profilPicture),
                radius: 20,
              ),
            ],
          ),
          trailing: Text(
            userStats.streaks.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ));
  }
}
