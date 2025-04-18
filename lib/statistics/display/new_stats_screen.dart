import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Color? _color;
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
      color: _color!,
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
              Navigator.pop(context);
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

  void _showDialogMessage() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                actions: [
                  CustomElevatedButton(
                      submit: () {
                        Navigator.of(ctx).pop();
                      },
                      text: 'Ok')
                ],
                contentPadding: EdgeInsets.all(16),
                content: Text(
                  '''You can add a created stat on your home screen! \n\n1. Click and hold 3 seconds on your home screen \n2. Click on the edit on the top left of the screen \n3. Select add widget \n4. Click on PeakYou and choose the widget you wanna add !
                ''',
                )));
  }

  List<(dynamic, String)> _generateSuggestions(ref, type) {
    final List<(dynamic, String)> suggestions = [];
    final List<Habit> habits = ref.read(habitProvider);

    switch (type) {
      case StatType.habit:
        suggestions
            .addAll(habits.map((e) => (e.habitId, e.name.capitalizeString())));
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

  Widget _typeField() {
    return _buildRowWithToolTip(
      title: 'Type:',
      content: 'Select the type of stat',
      child: _DropDownMenu(
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
    );
  }

  Widget _searchBarField() {
    return CustomSearchBar(
        selectValue: (item) => _onSelectSearchBarValue(item),
        generateSuggestion: () {
          return _generateSuggestions(ref, _type);
        });
  }

  Widget _formulaField() {
    return _buildRowWithToolTip(
      title: 'Formula:',
      content: 'Select the sub type of stat',
      child: _DropDownMenu(
        value: _subType,
        onChanged: (selectedSubType) {
          if (selectedSubType == null) return;
          setState(() {
            _subType = selectedSubType;
          });
        },
        options: _generateSubTypeOptions(),
      ),
    );
  }

  Widget _colorField() {
    return _buildRowWithToolTip(
      title: 'Color:',
      content: 'Select the color of the stat',
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _showColorPicker();
        },
        child: CircleAvatar(
          backgroundColor: _color,
          radius: 24,
        ),
      ),
    );
  }

  Widget _submitButton() {
    return CustomElevatedButton(
      color: _color,
      submit: () {
        _submit(ref);
      },
      text: widget.stat != null ? 'Edit Stat' : 'Create Stat',
    );
  }

  Widget _addToHomeScreenButton() {
    return TextButton(
      onPressed: () {
        _showDialogMessage();
      },
      child: Text('Add On Home Screen',
          maxLines: 2,
          style:
              Theme.of(context).textTheme.titleMedium!.copyWith(color: _color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    _color ??= _color = Theme.of(context).colorScheme.primary;
    _subType ??= _initializeDefaultSubType(_type);

    return CustomModalBottomSheet(
      title: widget.stat != null ? 'Edit Stat' : 'New Stat',
      formKey: _formKey,
      content: Column(
        children: [
          _typeField(),
          const SizedBox(height: 16),
          _searchBarField(),
          const SizedBox(height: 16),
          if (_type != StatType.emotion && _type != StatType.basic)
            _formulaField(),
          const SizedBox(height: 16),
          _colorField(),
          const SizedBox(height: 32),
          _submitButton(),
          SizedBox(height: 8),
          _addToHomeScreenButton(),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}

class _DropDownMenu extends StatelessWidget {
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final Map<dynamic, String> options;

  const _DropDownMenu({
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
  final void Function(dynamic selected) selectValue;
  final List<(dynamic, String)> Function() generateSuggestion;

  const CustomSearchBar(
      {required this.selectValue, required this.generateSuggestion, super.key});

  @override
  ConsumerState<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<CustomSearchBar> {
  late List<(dynamic, String)> _suggestions;

  @override
  void initState() {
    super.initState();
    _suggestions = widget.generateSuggestion();
  }

  @override
  void didUpdateWidget(covariant CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _suggestions = widget.generateSuggestion();
  }

  Widget _buildMaterial(
      List<(dynamic, String)> suggestions, Function onSelected) {
    return Material(
      color: Colors.black,
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final option = suggestions.toList()[index];
          return ListTile(
            title: Text(option.$2),
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(option);
              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
    );
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
      displayStringForOption: (suggestion) => suggestion.$2,
      optionsViewBuilder: (context, onSelected, suggestions) {
        if (!_suggestions.contains(suggestions.first)) {
          suggestions = _suggestions;
        }
        return _buildMaterial(suggestions.toList(), onSelected);
      },
      onSelected: (suggestion) {
        setState(() {
          widget.selectValue(suggestion);
        });
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          focusNode: focusNode,
          controller: textEditingController,
          decoration: const InputDecoration(
            hintStyle: TextStyle(color: Colors.grey),
            hintText: 'Search for a stat',
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}
