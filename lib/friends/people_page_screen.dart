import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/authentification/data/userdata_model.dart';
import 'package:tracker_v1/statistics/data/user_stats.dart';
import 'package:tracker_v1/friends/data/user_stats_provider.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage(this.userStats, this.userData, this.rank, {super.key});

  final UserStats userStats;
  final UserData userData;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          ProfilCard(
            userStats: userStats,
            userData: userData,
            rank: rank,
          ),
          SizedBox(
            height: 16,
          ),
          MessageCard(userStats: userStats, userData: userData, rank: rank)
          // Additional content can be added here
        ],
      ),
    );
  }
}

class ProfilCard extends StatelessWidget {
  const ProfilCard({
    required this.userStats,
    required this.userData,
    required this.rank,
    super.key,
  });

  final UserStats userStats;
  final UserData userData;
  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceBright,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 40,
            backgroundImage: CachedNetworkImageProvider(userData.profilPicture),
          ),
          SizedBox(width: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#$rank',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              Text(
                userData.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MessageCard extends ConsumerStatefulWidget {
  const MessageCard({
    required this.userStats,
    required this.userData,
    required this.rank,
    super.key,
  });

  final UserStats userStats;
  final UserData userData;
  final int rank;

  @override
  ConsumerState<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends ConsumerState<MessageCard> {
  late bool currentUserCard;
  TextEditingController? textController;
  String? userMessage;

  @override
  void initState() {
    currentUserCard =
        FirebaseAuth.instance.currentUser!.uid == widget.userData.userId;
      if (currentUserCard)
     {userMessage = ref.read(userStatsProvider).message;
      textController = TextEditingController(text: userMessage);}
    super.initState();
  }

  @override
  void dispose() {
    textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Text(
      widget.userStats.message.isEmpty
          ? '${widget.userData.name} has no message'
          : widget.userStats.message,
      style: Theme.of(context).textTheme.bodyMedium!,
      textAlign: TextAlign.center,
    );

    if (currentUserCard) {
      content = TextField(
        controller: textController,
        minLines: 1,
        maxLines: 4,
        decoration: InputDecoration(
            hintText: 'Add a message to your friends !',
            hintStyle: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.grey)),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (currentUserCard &&
            (textController!.text != userMessage)) {
          ref
              .read(userStatsProvider.notifier)
              .updateMessage(textController!.text);
        }
      },
      child: Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surfaceBright,
          ),
          child: content),
    );
  }
}
