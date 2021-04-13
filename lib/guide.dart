
import 'package:annette_app/setClass.dart';
/**
 * Diese Datei beinhaltet den Leitfaden, welcher beim ersten Start der App den Benutzer durch die Einstellungen führt.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GuideDialog extends StatefulWidget {
  final VoidCallback? onCompleted;
  const GuideDialog({Key? key, this.onCompleted}) : super(key: key);

  @override
  _GuideDialogState createState() => _GuideDialogState();
}

class _GuideDialogState extends State<GuideDialog> {
  final controller = PageController(initialPage: 0);
  bool page1 = true;


  /**
   * Erstellen des PageViews, welcher den Leitfanden mit dessen einzelnen Seiten anzeigt
   */
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 700, maxWidth: 350),
        //padding: EdgeInsets.all(15),
        child: (page1) ?
        WelcomeScreen(onCompleted: () {
          setState(() {
            page1 = false;
          });
        },) :
        Center(
          child: SetClass(
            onButtonPressed: () {
              widget.onCompleted!();
            }, isInGuide: true,
          ),
        ),
      ),
    );
  }
}

/**
 * Dieses Widget beinhaltet die 1. Seite des Leitfadens.
 * Hier findet sich eine Erklärung der Funktionen der App.
 */
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onCompleted;
  WelcomeScreen({required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        child: SingleChildScrollView(
            controller: ScrollController(initialScrollOffset: 0),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image(
                        height: 150,
                        width: 150,
                        image: AssetImage('images/icon.png'),
                        fit: BoxFit.fill)),
                Container(
                  margin: EdgeInsets.only(bottom: 10, top: 10),
                  child: Text(
                    'Annette App 3.0',textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                SingleChildScrollView(
                    controller: ScrollController(initialScrollOffset: 0),
                    scrollDirection: Axis.vertical,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: (Theme.of(context).brightness == Brightness.light) ? Colors.grey[200] : Colors.grey[600],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(children: [
                        Text('Herzlich Willkommen!',style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center),
                        Text(
                          'Verwalte und erstelle ganz unkompliziert neue Hausaufgaben. Das Fach, die Erledigungs-Frist und sogar der Zeitpunkt der Benachrichtigung werden dabei automatisch ermittelt. Neben dem Hinzufügen von Notizen kannst du selbsverständlich auch manuell alle Parameter beim Erstellen einer neuen Aufgabe bestimmen, und du hast zusätzlich die Möglichkeit, unter der Kategorie "Sonstiges" fach-unspezifische Aufgaben anzulegen.',
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center),
                      ]),
                    )),



        Container(
            margin: EdgeInsets.all(15),
            child: TextButton(
              onPressed: () {
                onCompleted();
              },
              child: Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  //height: 50,
                  constraints: BoxConstraints(
                    minWidth: 150,
                    minHeight: 50,
                  ),
                  //width: 150,
                  decoration: BoxDecoration(
                    color: (Theme.of(context).brightness == Brightness.dark) ? Theme.of(context).accentColor : Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    'Weiter',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18,
                        color: (Theme.of(context).brightness == Brightness.dark) ? Colors.black : Colors.white,

              ),
                  )),))
              ],
            )));
  }
}