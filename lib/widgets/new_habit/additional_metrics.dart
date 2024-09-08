import 'package:flutter/material.dart';
import 'package:tracker_v1/widgets/new_habit/text_form_field.dart';

class AdditionalMetrics extends StatefulWidget {
  const AdditionalMetrics(this.enteredAdditionalMetrics, {super.key});

  final List<String> enteredAdditionalMetrics;

  @override
  State<AdditionalMetrics> createState() => _AdditionalMetricsState();
}

class _AdditionalMetricsState extends State<AdditionalMetrics> {
  final _additionalInputController = TextEditingController();

  void _addAdditionalMetrics(context) {
    if (widget.enteredAdditionalMetrics.length > 4) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: const Text('Maximum additional fields reached'),
                backgroundColor: Theme.of(context).colorScheme.surfaceBright,
              ));
      return;
    }
    setState(() {
      widget.enteredAdditionalMetrics.add(_additionalInputController.text);
      _additionalInputController.clear();
    });
  }

  @override
  void dispose() {
    _additionalInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BasicTextFormField(
            maxLength: 100,
            controller: _additionalInputController,
            label: 'Additional tracking (Optional)',
            passValue: (value) {},
          ),
        ),
        IconButton(
            onPressed: () {
              _addAdditionalMetrics(context);
            },
            icon: const Icon(Icons.add)),
        SizedBox(
          height: 60,
          width: 70,
          child: widget.enteredAdditionalMetrics.isNotEmpty
              ? ListView.builder(
                  itemCount: widget.enteredAdditionalMetrics.length,
                  itemBuilder: (ctx, item) {
                    return Text(
                      widget.enteredAdditionalMetrics[item],
                      style: const TextStyle(color: Colors.white),
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  })
              : null,
        ),
      ],
    );
  }
}
