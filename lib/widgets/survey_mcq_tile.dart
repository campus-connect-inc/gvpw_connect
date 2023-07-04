import 'package:gvpw_connect/pages/fill_survey_page.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import '../styles/styles.dart';

class Question {
  final String question;
  final String questionId;
  final List<Option> options;
  Option? selectedOption;

  Question(
      {required this.question,
        required this.options,
        required this.questionId});
}

class Option {
  final String id;
  final String text;

  Option({required this.id, required this.text});
}

class SurveyMcqTile extends StatefulWidget {
  const SurveyMcqTile({Key? key, required this.question})
      : super(key: key);
  final Question question;
  @override
  State<SurveyMcqTile> createState() => _SurveyMcqTileState();
}

class _SurveyMcqTileState extends State<SurveyMcqTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.question,
          style: Styles.textStyle(
              color: ThemeProvider.fontPrimary,
              fontWeight: FontWeight.w600,
              fontSize: FontSize.textXl),
        ),
        const SizedBox(
          height: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.question.options.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: OptionTile(
                  question: widget.question,
                  option: option,
                  onChanged: (selected) {
                    FillSurveyPage.updateResponse(
                        widget.question.questionId, option.id);
                    setState(() {
                      widget.question.selectedOption = selected;
                    });
                  }),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class OptionTile extends StatefulWidget {
  const OptionTile({
    Key? key,
    required this.option,
    required this.onChanged,
    required this.question,
  }) : super(key: key);
  final Question question;
  final Option option;
  final void Function(Option?) onChanged;

  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: ThemeProvider.tertiary, // Set the desired color for the idle circle
      ),
      child: RadioListTile(
        selected: widget.question.selectedOption == widget.option,
        selectedTileColor: widget.question.selectedOption == widget.option
            ? ThemeProvider.tertiary
            : null,
        activeColor: ThemeProvider.accent,
        tileColor: ThemeProvider.secondary,
        dense: true,
        //by enabling toggleable the user can deselect chosen option.This causes interference as while parsing during submission,
        //the response map retains previous chosen option sending wrong information.can be fixed in future.
        toggleable: false,
        enableFeedback: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
        title: Text(
          widget.option.text,
          style: Styles.textStyle(
              color: ThemeProvider.fontPrimary,
              fontWeight: FontWeight.w500,
              fontSize: FontSize.textBase),
        ),
        value: widget.option,
        groupValue: widget.question.selectedOption,
        onChanged: widget.onChanged,
      ),
    );
  }
}