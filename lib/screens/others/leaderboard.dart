import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/user.dart';
import 'package:tracker_v1/models/datas/user_stats.dart';
import 'package:tracker_v1/models/utilities/Scores/num_extent.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/users_stats_provider.dart';
import 'package:tracker_v1/theme.dart';
import 'package:tracker_v1/widgets/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/widgets/leaderboard/people_page.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with TickerProviderStateMixin {
  static const List<String> _pageNames1 = ['Weekly', 'Monthly', 'All Time'];
  static const List<String> _pageNames2 = ['All', 'Friends'];
  late TabController tabController;
  int _selectedPage1 = 0;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {
        _selectedPage1 = tabController.index;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.invalidate(allUserStatsProvider);
    AsyncValue usersStat = ref.watch(allUserStatsProvider);

    return usersStat.when(
        data: (data) {
          // Sort users by score relative to the time period
          List<UserStats> userStats = data.$1;
          List<UserData> usersData = data.$2;
          if (_selectedPage1 == 0) {
            userStats.sort((a, b) => b.scoreWeek.compareTo(a.scoreWeek));
          } else if (_selectedPage1 == 1) {
            userStats.sort((a, b) => b.scoreMonth.compareTo(a.scoreMonth));
          } else {
            userStats.sort((a, b) => b.scoreAllTime.compareTo(a.scoreAllTime));
          }

          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                TabBar(
                  tabs: <Widget>[..._pageNames1.map((e) => Text(e))],
                  controller: tabController,
                ),
                Expanded(
                  child: SingleChildScrollView(
                      child: Container(
                    alignment: Alignment.topCenter,
                    height: MediaQuery.of(context).size.height * 1.25,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 24,
                        ),
                        LeaderboardPodium(userStats, usersData, _selectedPage1),
                        const SizedBox(
                          height: 32,
                        ),
                        Expanded(
                            child: LeaderboardList(
                                userStats, usersData, _selectedPage1))
                      ],
                    ),
                  )),
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => const Center(
              child: CircularProgressIndicator(),
            ),
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
  }
}

String getPeopleScore(selectedPage, UserStats userStats) {
  if (selectedPage == 0) {
    return userStats.scoreWeek.roundNum();
  } else if (selectedPage == 1) {
    return userStats.scoreMonth.roundNum();
  } else {
    return userStats.scoreAllTime.roundNum();
  }
}

class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium(this.usersStats, this.usersData, this._selectedPage,
      {super.key});
  final List<UserStats> usersStats;
  final List<UserData> usersData;
  final int _selectedPage;

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
    // Get the top 3 user stats and data
    if (usersStats.length < 4) {
      usersStats.addAll(
          List.generate(4 - usersStats.length, (index) => usersStats[0]));
    }
    final UserStats? firstStats = usersStats.isNotEmpty ? usersStats[0] : null;
    final UserStats secondStats =
        usersStats.length > 1 ? usersStats[1] : usersStats[0];
    final UserStats thirdStats =
        usersStats.length > 2 ? usersStats[2] : usersStats[0];
    final UserData? firstData =
        usersData.firstWhereOrNull((data) => data.userId == firstStats?.userId);
    final UserData? secondData =
        usersData.firstWhereOrNull((data) => data.userId == secondStats.userId);
    final UserData? thirdData =
        usersData.firstWhereOrNull((data) => data.userId == thirdStats.userId);

    double ratioFirstOther = 0.75;
    double firstContainerHeight = 160;
    double firstAvatarRadius = 100;
    double otherContainerHeight = firstContainerHeight * ratioFirstOther;
    double otherAvatarRadius = firstAvatarRadius * ratioFirstOther;
    double shiftCircle = 0.325;

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
              selectedPage: _selectedPage,
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
              selectedPage: _selectedPage,
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
              selectedPage: _selectedPage,
              containerHeight: otherContainerHeight - 24, // Slightly smaller
              shiftCircle: shiftCircle,
              userData: thirdData!,
              userStats: thirdStats,
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
  final int selectedPage;
  final Radius radius = const Radius.circular(20);

  const PodiumColumn(
      {super.key,
      required this.containerHeight,
      required this.shiftCircle,
      required this.userData,
      required this.userStats,
      required this.avatarRadius,
      required this.podiumColor,
      required this.number,
      required this.selectedPage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          containerHeight + (avatarRadius - (avatarRadius * shiftCircle) + 40),
      child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                  onTap: () {
                    goToPeoplePage(context, userStats, userData, number);
                  },
                  child: Container(
                      height: containerHeight,
                      decoration: BoxDecoration(
                        color: number == 1
                            ? Theme.of(context).colorScheme.surfaceBright
                            : Theme.of(context)
                                .colorScheme
                                .surfaceBright
                                .withOpacity(0.5),
                        borderRadius: BorderRadius.only(
                          topRight: number != 2 ? radius : Radius.zero,
                          bottomLeft: number == 2 ? radius : Radius.zero,
                          bottomRight: number == 3 ? radius : Radius.zero,
                          topLeft: number != 3 ? radius : Radius.zero,
                        ),
                      ))),
            ),
            if (number == 1)
              Positioned(
                bottom:
                    (containerHeight) - (avatarRadius) * (shiftCircle - 1) - 3,
                child: Image.asset(
                  'assets/crown.png',
                  width: 40,
                ),
              ),
            Positioned(
                bottom: (containerHeight) - (avatarRadius) * shiftCircle,
                child: InkWell(
                  onTap: () {
                    goToPeoplePage(context, userStats, userData, number);
                  },
                  child: PodiumPictureAvatar(
                    podiumColor[0],
                    podiumColor[1],
                    userData.profilPicture,
                    avatarRadius,
                    first: true,
                  ),
                )),
            Positioned(
                bottom: containerHeight -
                    (avatarRadius * shiftCircle) -
                    (avatarRadius / 9) +
                    1,
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
              bottom: containerHeight -
                  (avatarRadius * shiftCircle) -
                  (avatarRadius / 9) +
                  1,
              child: Text(
                '$number',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: avatarRadius / 6),
              ),
            ),
            Positioned(
              bottom:
                  number == 3 ? containerHeight * 0.1 : containerHeight * 0.2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(userData.name,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: avatarRadius / 6,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    getPeopleScore(selectedPage, userStats),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: podiumColor[1],
                          fontSize: avatarRadius / 5,
                        ),
                  ),
                ],
              ),
            ),
            if (userStats.message.isNotEmpty)
              MessageBubble(
                  avatarRadius + (number == 1 ? -8 : -5),
                  (containerHeight) -
                      (avatarRadius) * (shiftCircle - 1) -
                      30 +
                      (number == 1 ? -24 : 0),
                  userStats,
                  userData,
                  number),
          ]),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      this.left, this.bottom, this.userStats, this.userData, this.number,
      {super.key});
  final double left;
  final double bottom;
  final UserStats userStats;
  final UserData userData;
  final int number;

  @override
  Widget build(BuildContext context) {
    final Color color =
        Theme.of(context).colorScheme.surfaceBright.withOpacity(0.75);

    return Positioned(
        left: left,
        bottom: bottom,
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.bottomLeft,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -3,
                bottom: -6,
                child: Container(
                    height: 6,
                    width: 6,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: color)),
              ),
              Positioned(
                left: 4,
                bottom: -3,
                child: Container(
                    height: 14,
                    width: 14,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: color)),
              ),
              InkWell(
                  onTap: () {
                    goToPeoplePage(context, userStats, userData, number);
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 60, minWidth: 30),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: color),
                      child: Text(
                        softWrap: true,
                        textAlign: TextAlign.center,
                        userStats.message,
                        style: TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  )),
            ],
          ),
        ));
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
  const LeaderboardList(this.usersStats, this.usersData, this.selectedPage,
      {super.key});
  final List<UserStats> usersStats;
  final List<UserData> usersData;
  final int selectedPage;

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
                  trailing: Text('SCORE', style: style))),
          const SizedBox(
            height: 20,
          ),
          LeaderboardCard(
            currentUserStats,
            currentUserData,
            usersStats.indexOf(currentUserStats) + 1,
            gradient: true,
            selectedPage: selectedPage,
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
              final UserStats userStats = usersStats[index + 3];
              final UserData userData = usersData
                  .firstWhereOrNull((item) => item.userId == userStats.userId);
              return LeaderboardCard(
                userStats,
                userData,
                index + 4,
                selectedPage: selectedPage,
              );
            },
          )),
        ],
      ),
    );
  }
}

class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard(this.userStats, this.userData, this.number,
      {super.key,
      this.gradient = false,
      this.currentUser = false,
      required this.selectedPage});

  final UserStats userStats;
  final UserData userData;
  final bool gradient;
  final int number;
  final bool currentUser;
  final int selectedPage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        goToPeoplePage(context, userStats, userData, number);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: gradient ? null : Theme.of(context).colorScheme.surface,
          boxShadow: [basicShadow],
          gradient: gradient
              ? const LinearGradient(
                  colors: [Colors.purple, Color.fromARGB(255, 83, 13, 95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ListTile(
              title: Text(currentUser ? 'You' : userData.name,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: currentUser ? FontWeight.bold : null)),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('#$number',
                      style: Theme.of(context).textTheme.bodyLarge),
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
                getPeopleScore(selectedPage, userStats),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (userStats.message.isNotEmpty)
              MessageBubble(180, 40, userStats, userData, number)
          ],
        ),
      ),
    );
  }
}

void goToPeoplePage(context, UserStats userStats, UserData userData, int rank) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => CustomModalBottomSheet(
          title: '', content: PeoplePage(userStats, userData, rank)));
}
