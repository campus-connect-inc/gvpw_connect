import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import '../providers/route_provider.dart';
import 'package:provider/provider.dart';
import '../styles/styles.dart';

class DrawerOptionTile extends StatefulWidget {
  const DrawerOptionTile(
      {Key? key,
        required this.optionName,
        required this.icon,
        required this.action,
        this.listenForRoute})
      : super(key: key);
  final String optionName;
  final IconData icon;
  final void Function() action;
  final String? listenForRoute;

  @override
  State<DrawerOptionTile> createState() => _DrawerOptionTileState();
}

class _DrawerOptionTileState extends State<DrawerOptionTile> {
  bool isRoute = false;
  void onTapHandler() {
    if (isRoute) {
      Navigator.pop(context);
    } else {
      widget.action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteNameProvider>(
      builder: (context, routeNameProvider, child) {
        if (routeNameProvider.currentRouteName == widget.listenForRoute) {
          isRoute = true;
        } else {
          isRoute = false;
        }
        return Material(
          color: !isRoute ? Colors.transparent : Colors.white.withOpacity(0.2),
          child: InkWell(
            onTap:onTapHandler,
            child: Row(
              children: [
                if (isRoute)
                  Container(
                    width: 10,
                    height: 50,
                    decoration: BoxDecoration(
                      color: ThemeProvider.secondary,
                    ),
                  ),
                Padding(
                  padding: isRoute
                      ? const EdgeInsets.all(0)
                      : const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      isRoute
                          ? const SizedBox(
                        width: 10,
                      )
                          : const SizedBox(
                        width: 20,
                      ),
                      Icon(
                        widget.icon,
                        color: ThemeProvider.accent,
                        size: 25,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        widget.optionName,
                        style: Styles.textStyle(
                            color: ThemeProvider.fontPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: FontSize.textLg),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}