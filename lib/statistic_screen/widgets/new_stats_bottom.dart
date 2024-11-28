import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_launcher/cli_commands.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/statistic_screen/statistics_model.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/statistic_screen/statistics_data.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/widgets/recaps/custom_tool_tip_title.dart';

class NewStatFrame extends ConsumerStatefulWidget {
  const NewStatFrame({Key? key, this.stat}) : super(key: key);

  final Stat? stat;

  @override
  ConsumerState<NewStatFrame> createState() => _NewStatFrameState();
}

class _NewStatFrameState extends ConsumerState<NewStatFrame> {
  final _formKey = GlobalKey<FormState>();
  StatType _type = StatType.habit;
  dynamic _ref;
  String? _name;
  Color _color = Colors.grey;
  dynamic _subType;

  @override
  void initState() {
    super.initState();
    if (widget.stat != null) {
      _type = widget.stat!.type;
      _ref = widget.stat!.ref;
      _name = widget.stat!.name;
      _color = widget.stat!.color;
      _subType = widget.stat!.formulaType;
    }
  }

  void _submit(WidgetRef ref) {
    if (!_formKey.currentState!.validate()) return;
    if (_ref == null && _type != StatType.basic) return;

    _formKey.currentState!.save();

    final newStat = Stat(
      users: FirebaseAuth.instance.currentUser!.uid,
      statId: widget.stat?.statId,
      type: _type,
      formulaType: _subType,
      ref: _ref,
      name: _type == StatType.additionalMetrics ? _ref.$2 : _name,
      color: _color,
      maxY: getMaxY(_type, _subType),
      index: widget.stat?.index ?? ref.read(statNotiferProvider).length,
    );

    if (widget.stat != null) {
      ref.read(statNotiferProvider.notifier).updateStat(newStat);
    } else {
      ref.read(statNotiferProvider.notifier).addStat(newStat);
    }


    Navigator.of(context).pop(newStat);
  }

  double? getMaxY(StatType type, dynamic subType) {
    if (type == StatType.emotion) {
      return 5;
    }
    if (subType == HabitVisualisationType.rating) {
      return 10;
    }
    if (subType == HabitVisualisationType.percentCompletion) {
      return 100;
    }

    return null;
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        content: BlockPicker(
          pickerColor: _color,
          onColorChanged: (selectedColor) {
            setState(() {
              _color = selectedColor;
            });
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<dynamic>> _getSubTypeItems() {
    switch (_type) {
      case StatType.habit:
        return HabitVisualisationType.values
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(habitVisualisationTypeNames[type]!),
                ))
            .toList();
      case StatType.additionalMetrics:
        return AdditionalMetricsSubType.values
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(additionalMetricsSubTypeNames[type]!),
                ))
            .toList();
      default:
        return [];
    }
  }

  dynamic _getDefaultSubType(StatType type) {
    switch (type) {
      case StatType.habit:
        return HabitVisualisationType.rating;
      case StatType.additionalMetrics:
        return AdditionalMetricsSubType.average;
      case StatType.basic:
        return BasicHabitSubtype.score;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _subType ??= _getDefaultSubType(_type);

    return CustomModalBottomSheet(
      title: widget.stat != null ? 'Edit Stat' : 'New Stat Visualization',
      formKey: _formKey,
      content: Column(
        children: [
          Row(
            children: [
              const CustomToolTipTitle(
                  title: 'Type:', content: 'Select the type of stat'),
              Expanded(
                child: Center(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(5)),
                      child: DropdownButton<StatType>(
                        value: _type,
                        icon: const Icon(Icons.arrow_drop_down),
                        isDense: true,
                        dropdownColor:
                            Theme.of(context).colorScheme.surfaceBright,
                        items: StatType.values
                            .where((StatType e) => e != StatType.custom)
                            .toList()
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(statTypeNames[type]!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _type = value;
                            _subType = null;
                          });
                        },
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomSearchBar(_type, (item) {
            setState(() {
              _name = item.$2;
              _ref = item.$1;
            });
          }),
          const SizedBox(height: 16),
          if (_type != StatType.emotion && _type != StatType.basic)
            Row(
              children: [
                const CustomToolTipTitle(
                    title: 'Formula:', content: 'Select the sub type of stat'),
                Expanded(
                  child: Center(
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceBright,
                            borderRadius: BorderRadius.circular(5)),
                        child: DropdownButton<dynamic>(
                          value: _subType,
                          icon: const Icon(Icons.arrow_drop_down),
                          isDense: true,
                          dropdownColor:
                              Theme.of(context).colorScheme.surfaceBright,
                          items: _getSubTypeItems(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _subType = value;
                            });
                          },
                        )),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const CustomToolTipTitle(
                  title: 'Color:', content: 'Select the color of the stat'),
              Spacer(),
              Center(
                child: InkWell(
                  onTap: _showColorPicker,
                  child: CircleAvatar(
                    backgroundColor: _color,
                    radius: 24,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
          const SizedBox(height: 32),
          CustomElevatedButton(
            submit: () {
              _submit(ref);
            },
            text: widget.stat != null ? 'Edit Stat' : 'Create Stat',
          ),
        ],
      ),
    );
  }
}

class CustomSearchBar extends ConsumerStatefulWidget {
  final StatType type;
  final Function selectValue;

  const CustomSearchBar(this.type, this.selectValue, {super.key});

  @override
  ConsumerState<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<CustomSearchBar> {
  late List<(dynamic, String)> _suggestions;

  @override
  void initState() {
    super.initState();
    _suggestions = _createSuggestion(ref);
  }

  @override
  void didUpdateWidget(covariant CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.type != oldWidget.type) {
      setState(() {
        _suggestions = _createSuggestion(ref);
      });
    }
  }

  List<(dynamic, String)> _createSuggestion(ref) {
    final List<(dynamic, String)> suggestions = [];
    final List<Habit> habits = ref.read(habitProvider);

    switch (widget.type) {
      case StatType.habit:
        suggestions.addAll(habits.map((e) => (e.habitId, e.name.capitalize())));
        break;
      case StatType.additionalMetrics:
        final List<(Habit, String)> additionalMetrics =
            ref.read(habitProvider.notifier).getAllAdditionalMetrics();
        final List<(String, String)> additionalMetricsHabitId =
            additionalMetrics.map((e) => (e.$1.habitId, e.$2)).toList();

        suggestions.addAll(additionalMetricsHabitId.asMap().entries.map(
            (entry) => (
                  entry.value,
                  '${additionalMetrics[entry.key].$1.name}/${entry.value.$2}'
                )));
        break;
      case StatType.emotion:
        final List<Emotion> emotions = Emotion.values;
        suggestions.addAll(emotions.map((e) => (
              e.name,
              emotionDescriptions[e]!.capitalize(),
            )));
        break;
      case StatType.basic:
        suggestions.addAll(BasicHabitSubtype.values.map((e) => (
              e,
              basicHabitSubtypeNames[e]!,
            )));
        break;
      default:
        break;
    }

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete(
      optionsMaxHeight: double.infinity,
      optionsBuilder: (textEditingValue) {
        return _suggestions.where((item) {
          return item.$2
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        }).toList();
      },
      displayStringForOption: (option) => option.$2,
      optionsViewBuilder: (context, onSelected, options) {
        if (!_suggestions.contains(options.first)) {
          options = _suggestions;
        }
        return Material(
          color: Colors.black,
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options.toList()[index];
              return ListTile(
                title: Text(option.$2),
                onTap: () {
                  onSelected(option);
                  FocusScope.of(context).unfocus();
                },
              );
            },
          ),
        );
      },
      onSelected: (option) {
        setState(() {
          widget.selectValue(option);
        });
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          focusNode: focusNode,
          controller: textEditingController,
          decoration: const InputDecoration(
            hintText: 'Search for a stat',
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}
