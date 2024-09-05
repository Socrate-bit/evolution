// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tracker_v1/models/habit.dart';
// import 'package:tracker_v1/models/tracked_day.dart';

// class HabitRecapScreen extends StatefulWidget {
//   const HabitRecapScreen({super.key});

//   @override
//   State<HabitRecapScreen> createState() => _HabitRecapScreenState();
// }

// class _HabitRecapScreenState extends State<HabitRecapScreen> {
//   double _showUpRating = 0;
//   double _investmentRating = 0;
//   double _methodRating = 0;
//   double _resultRating = 0;
//   bool _extra = false;
//   String? _enteredRecap;
//   String? _enteredImprovement;

//   @override
//   Widget build(BuildContext context) {
//     Map<double, String> _ratingText = {
//       0: 'Awful',
//       1.25: "Poor",
//       2.5: "Okay",
//       3.75: "Perfect",
//       5: "Outstanding"
//     };

//     Color? getRatingColorMap(value) {
//       if (_methodRating == 5.0 &&
//           _resultRating == 5.0 &&
//           _investmentRating == 5.0 &&
//           _showUpRating == 5.0) {
//         return Colors.purple;
//       }
//       if (value < 1) return Colors.red;
//       if (value < 1.25) return Colors.orange;
//       if (value < 2.5) return Theme.of(context).colorScheme.primary;
//       if (value < 3.75) return Colors.green;
//       if (value == 5) return Colors.purple;
//       if (value >= 3.75) return Colors.blue;
//     }

//     return SingleChildScrollView(
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
//         child: Form(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Align(
//                 alignment: const Alignment(1, 1),
//                 child: IconButton(
//                   iconSize: 30,
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   icon: const Icon(
//                     Icons.close,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               const ToolTipTittle("Show-up", "Message1"),
//               Slider(
//                 label: _ratingText[_showUpRating],
//                 activeColor: getRatingColorMap(_showUpRating),
//                 inactiveColor: Theme.of(context).colorScheme.surfaceBright,
//                 value: _showUpRating,
//                 onChanged: (value) {
//                   setState(() {
//                     _showUpRating = value;
//                   });
//                 },
//                 min: 0,
//                 max: 5,
//                 divisions: 4,
//               ),
//               const ToolTipTittle("Invesment", "Message1"),
//               Slider(
//                 label: _ratingText[_investmentRating],
//                 activeColor: getRatingColorMap(_investmentRating),
//                 inactiveColor: Theme.of(context).colorScheme.surfaceBright,
//                 value: _investmentRating,
//                 onChanged: (value) {
//                   setState(() {
//                     _investmentRating = value;
//                   });
//                 },
//                 min: 0,
//                 max: 5,
//                 divisions: 4,
//               ),
//               const ToolTipTittle("Method", "Message1"),
//               Slider(
//                 label: _ratingText[_methodRating],
//                 activeColor: getRatingColorMap(_methodRating),
//                 inactiveColor: Theme.of(context).colorScheme.surfaceBright,
//                 value: _methodRating,
//                 onChanged: (value) {
//                   setState(() {
//                     _methodRating = value;
//                   });
//                 },
//                 min: 0,
//                 max: 5,
//                 divisions: 4,
//               ),
//               const ToolTipTittle("Result", "Message1"),
//               Slider(
//                 label: _ratingText[_resultRating],
//                 activeColor: getRatingColorMap(_resultRating),
//                 inactiveColor: Theme.of(context).colorScheme.surfaceBright,
//                 value: _resultRating,
//                 onChanged: (value) {
//                   setState(() {
//                     _resultRating = value;
//                   });
//                 },
//                 min: 0,
//                 max: 5,
//                 divisions: 4,
//               ),
//               Row(
//                 children: [
//                   const ToolTipTittle("Extra", "Message1"),
//                   const SizedBox(width: 16),
//                   Transform.scale(
//                     scale: 1.25,
//                     child: Checkbox(
//                         value: _extra,
//                         semanticLabel: "Bonjour",
//                         onChanged: (value) {
//                           setState(() {
//                             _extra = value!;
//                           });
//                         }),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 32),
//               const ToolTipTittle("Recap", "Message1"),
//               TextFormField(
//                 minLines: 3,
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.trim().length < 5) {
//                     return "No entries";
//                   }
//                 },
//                 onSaved: (value) {
//                   _enteredRecap = value;
//                 },
//                 maxLength: 1000,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Theme.of(context)
//                       .colorScheme
//                       .surfaceBright
//                       .withOpacity(0.5),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const ToolTipTittle("Improvements", "Message1"),
//               TextFormField(
//                 minLines: 3,
//                 maxLines: 3,
//                 validator: (value) {
//                   if (value == null || value.trim().length < 5) {
//                     return "No entries";
//                   }
//                 },
//                 onSaved: (value) {
//                   _enteredImprovement = value;
//                 },
//                 maxLength: 1000,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Theme.of(context)
//                       .colorScheme
//                       .surfaceBright
//                       .withOpacity(0.5),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Center(
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 60,
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Theme.of(context).colorScheme.primary),
//                     child: Text(
//                       'Submit',
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleMedium!
//                           .copyWith(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ToolTipTittle extends StatelessWidget {
//   const ToolTipTittle(this._title, this._message, {super.key});

//   final String _title;
//   final String _message;

//   @override
//   Widget build(BuildContext context) {
//     return Row(children: [
//       Text(_title,
//           style: Theme.of(context)
//               .textTheme
//               .titleMedium!
//               .copyWith(color: Colors.white)),
//       const SizedBox(
//         width: 10,
//       ),

//     ]);
//   }
// }
