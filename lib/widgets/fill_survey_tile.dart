import 'package:gvpw_connect/pages/fill_survey_page.dart';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../styles/styles.dart';
import '../utils/util.dart';

class FillSurveyTile extends StatefulWidget {
  const FillSurveyTile({Key? key, required this.data, required this.id})
      : super(key: key);
  final Map data;
  final String id;

  @override
  State<FillSurveyTile> createState() => _FillSurveyTileState();
}

class _FillSurveyTileState extends State<FillSurveyTile> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          FillSurveyPage.surveyResponse.clear();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FillSurveyPage(surveyId: widget.id)));
        },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: ThemeProvider.secondary,
                gradient: LinearGradient(
                    begin: FractionalOffset.bottomLeft,
                    end: FractionalOffset.topRight,
                    colors: [
                      ThemeProvider.tertiary.withOpacity(0.8),
                      ThemeProvider.tertiary.withOpacity(0.7),
                      ThemeProvider.secondary.withOpacity(0.7),
                      ThemeProvider.secondary.withOpacity(0.5),
                    ],
                    stops: const [
                      0.16,
                      0.30,
                      0.64,
                      0.96,
                    ])),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                widget.data["name"].trim(),
                style: Styles.textStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: FontSize.textXl + 3,
                  color: ThemeProvider.fontPrimary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Submit before - ${Util.formatTimestamp(widget.data["endDate"])}",
                  style: Styles.textStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: FontSize.textBase,
                    color: ThemeProvider.fontPrimary.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.data["about"].trim(),
                style: Styles.textStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: FontSize.textBase,
                  color: ThemeProvider.fontPrimary,
                ),
              ),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.arrow_right_alt_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
            ])),
      ),
    );
  }
}
