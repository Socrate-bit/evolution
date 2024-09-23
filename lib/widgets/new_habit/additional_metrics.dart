import 'package:flutter/material.dart';
import 'package:tracker_v1/widgets/recaps/big_text_form_field.dart';

class AdditionalMetrics extends StatefulWidget {
  const AdditionalMetrics(this.enteredAdditionalMetrics, {super.key});

  final List<String> enteredAdditionalMetrics;

  @override
  State<AdditionalMetrics> createState() => _AdditionalMetricsState();
}

class _AdditionalMetricsState extends State<AdditionalMetrics> {
  String? _additionalMetrics;
  final formKey = GlobalKey<FormState>();

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
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      formKey.currentState!.save();
      widget.enteredAdditionalMetrics.add(_additionalMetrics!);
      _additionalMetrics = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: BigTextFormField(
                  maxLenght: 100,
                  maxLine: 1,
                  controlledValue: _additionalMetrics ?? '',
                  onSaved: (value) {
                    _additionalMetrics = value;
                  },
                  toolTipTitle: 'Additional tracking (Optional)',
                  tooltipContent: 'Provide Additional tracking (Optional)',
                ),
              ),
              IconButton(
                  onPressed: () {
                    _addAdditionalMetrics(context);
                  },
                  icon: const Icon(Icons.add))
            ],
          ),
          if (widget.enteredAdditionalMetrics.isNotEmpty)
            SizedBox(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.enteredAdditionalMetrics.length,
                  itemBuilder: (ctx, item) {
                    return Center(
                      child: Text(
                        widget.enteredAdditionalMetrics[item],
                        style: const TextStyle(color: Colors.white),
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
            )
        ],
      ),
    );
  }
}
