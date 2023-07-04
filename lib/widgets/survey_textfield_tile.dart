import 'package:gvpw_connect/pages/fill_survey_page.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/styles.dart';


class SurveyTextfieldTile extends StatefulWidget {
  const SurveyTextfieldTile({super.key, required this.question});
  final Map<String,dynamic> question;
  @override
  State<SurveyTextfieldTile> createState() => _SurveyTextfieldTileState();
}

class _SurveyTextfieldTileState extends State<SurveyTextfieldTile> {
  final TextEditingController _controller = TextEditingController();

  void onInputChange(response){
    if(response.trim().isEmpty){
      FillSurveyPage.surveyResponse.remove(widget.question["id"]);
    }else{
      FillSurveyPage.updateResponse(widget.question["id"], response.trim());
    }
    print(FillSurveyPage.surveyResponse);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question["question"],
          style: Styles.textStyle(
              color: ThemeProvider.fontPrimary,
              fontWeight: FontWeight.w600,
              fontSize: FontSize.textXl),
        ),
        const SizedBox(
          height: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextFormField(
              cursorColor: ThemeProvider.secondary,
              controller: _controller,
              minLines: 1,
              maxLines: 8,
              style: Styles.textStyle(
                color: ThemeProvider.accent,
                fontWeight: FontWeight.w600,
                fontSize: FontSize.textLg,
              ),
              textAlign: TextAlign.start,
              inputFormatters: [
                LengthLimitingTextInputFormatter(int.parse(widget.question["charCount"])),
              ],
              onChanged: (value) {
                onInputChange(value);
                setState(() {}); // Update the character count on each change
              },
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeProvider.tertiary, width: 2.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ThemeProvider.accent, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              '${_controller.text.length}/${widget.question["charCount"]}',
              style: TextStyle(
                color: _controller.text.length >= int.parse(widget.question["charCount"]) ? Colors.yellow : ThemeProvider.fontPrimary,
                fontSize: FontSize.textBase,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }
}
