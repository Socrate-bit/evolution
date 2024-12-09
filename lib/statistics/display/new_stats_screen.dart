import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/capitalize_string.dart';
import 'package:tracker_v1/statistics/data/statistics_model.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/statistics/data/statistics_provider.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';

class NewStatScreen extends ConsumerStatefulWidget {
  const NewStatScreen({this.stat, super.key});

  final Stat? stat;

  @override
  ConsumerState<NewStatScreen> createState() => _NewStatScreenState();
}

class _NewStatScreenState extends ConsumerState<NewStatScreen> {
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

  @override
  Widget build(BuildContext context) {
    _subType ??= _initializeDefaultSubType(_type);

    return CustomModalBottomSheet(
      title: widget.stat != null ? 'Edit Stat' : 'New Stat',
      formKey: _formKey,
      content: Column(
        children: [
          _buildRowWithToolTip(
            title: 'Type:',
            content: 'Select the type of stat',
            child: DropDownMenu(
              value: _type,
              onChanged: (selectedType) {
                if (selectedType == null) return;
                setState(() {
                  _type = selectedType;
                  _subType = null;
                });
              },
              options: Map.fromEntries(
                statTypeNames.entries
                    .where((entry) => entry.key != StatType.custom)
                    .map((entry) => MapEntry(entry.key, entry.value)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomSearchBar(_type, (item) => _onSelectSearchBarValue(item)),
          const SizedBox(height: 16),
          if (_type != StatType.emotion && _type != StatType.basic)
            _buildRowWithToolTip(
              title: 'Formula:',
              content: 'Select the sub type of stat',
              child: DropDownMenu(
                value: _subType,
                onChanged: (selectedSubType) {
                  if (selectedSubType == null) return;
                  setState(() {
                    _subType = selectedSubType;
                  });
                },
                options: _generateSubTypeOptions(),
              ),
            ),
          const SizedBox(height: 16),
          _buildRowWithToolTip(
            title: 'Color:',
            content: 'Select the color of the stat',
            child: InkWell(
              onTap: _showColorPicker,
              child: CircleAvatar(
                backgroundColor: _color,
                radius: 24,
              ),
            ),
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

  Widget _buildRowWithToolTip({
    required String title,
    required String content,
    required Widget child,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        CustomToolTipTitle(title: title, content: content),
        Expanded(child: Center(child: child)),
      ],
    );
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
      name: _name ?? '',
      color: _color,
      maxY: _determineMaxY(_type, _subType),
      index: widget.stat?.index ?? ref.read(statNotiferProvider).length,
    );

    if (widget.stat != null) {
      ref.read(statNotiferProvider.notifier).updateStat(newStat);
    } else {
      ref.read(statNotiferProvider.notifier).addStat(newStat);
    }

    Navigator.of(context).pop();
  }

  double? _determineMaxY(StatType type, dynamic subType) {
    if (type == StatType.emotion) {
      return 5;
    } else if (subType == HabitVisualisationType.rating) {
      return 10;
    } else if (subType == HabitVisualisationType.percentCompletion) {
      return 100;
    } else if (subType == BasicHabitSubtype.completion) {
      return 100;
    } else if (subType == BasicHabitSubtype.evaluation) {
      return 10;
    } else {
      return null;
    }
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

  Map<dynamic, String> _generateSubTypeOptions() {
    switch (_type) {
      case StatType.habit:
        return Map.fromEntries(
            HabitVisualisationType.values.map((type) => MapEntry(
                  type,
                  habitVisualisationTypeNames[type]!,
                )));
      case StatType.additionalMetrics:
        return Map.fromEntries(
            AdditionalMetricsSubType.values.map((type) => MapEntry(
                  type,
                  additionalMetricsSubTypeNames[type]!,
                )));
      default:
        return {};
    }
  }

  dynamic _initializeDefaultSubType(StatType type) {
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

  void _onSelectSearchBarValue(item) {
    setState(() {
      _name = _type == StatType.additionalMetrics ? item.$1.$2 : item.$2;
      _ref = _type == StatType.basic ? null : item.$1;
      _subType = _type == StatType.basic ? item.$1 : _subType;
    });
  }
}

class DropDownMenu extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final Map<dynamic, String> options;

  const DropDownMenu({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<dynamic>(
        value: value,
        icon: const Icon(Icons.arrow_drop_down),
        isDense: true,
        dropdownColor: Theme.of(context).colorScheme.surfaceBright,
        items: options.entries
            .map(
              (item) => DropdownMenuItem(
                value: item.key,
                child: Text(item.value),
              ),
            )
            .toList(),
        onChanged: onChanged,
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
        return _buildMaterial(options, onSelected);
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

  Widget _buildMaterial(options, onSelected) {
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
  }

  List<(dynamic, String)> _createSuggestion(ref) {
    final List<(dynamic, String)> suggestions = [];
    final List<Habit> habits = ref.read(habitProvider);

    switch (widget.type) {
      case StatType.habit:
        suggestions.addAll(
            habits.map((e) => (e.habitId, e.name.capitalizeString())));
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
              emotionDescriptions[e]!.capitalizeString(),
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
}
