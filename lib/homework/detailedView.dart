import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:annette_app/database/taskDbInteraction.dart';
import '../miscellaneous-files/manageNotifications.dart';
import 'package:annette_app/fundamentals/task.dart';
import '../miscellaneous-files/parseTime.dart';
import 'addDialog.dart';

// TODO: implement subject-changing

/// Diese Datei beinhaltet die Detailansicht einer Hausaufgabe,
/// bei der alle Informationen bezüglich der Aufgabe angezeigt werden können.
class DetailedView extends StatefulWidget {
  final Task? task;
  final Function(int?)? onReload;
  final Function(int?)? onRemove;
  final bool? isParallelDetail;

  DetailedView(
      {Key? key,
      this.task,
      this.onReload,
      this.onRemove,
      this.isParallelDetail})
      : super(key: key);

  @override
  DetailedViewState createState() => DetailedViewState();
}

class DetailedViewState extends State<DetailedView> {

  Task? task;
  String? updateNotes;
  DateTime? updateNotificationTime;
  DateTime? updateDeadlineTime;
  late bool errorNotificationTime;
  late bool errorDeadlineTime;
  late bool errorNotes;
  bool? checked = false;

  final TextEditingController _textEditingController = TextEditingController();

  static double timePickerHeight = 150;
  static double timePickerWidth = 280;
  static BoxDecoration timePickerBorder = BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
          width: 1
      )
  );


  void editDialog(String title, StatefulBuilder childWidgets, Function confirmFunction) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Builder(builder: (context) {
            return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 450,
                    ),
                    padding: EdgeInsets.only(
                        top: 30, left: 30, right: 30, bottom: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                          ),
                          IntrinsicHeight(
                            child: childWidgets
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    size: 30,
                                  )),
                              IconButton(
                                  onPressed: confirmFunction(),
                                  icon: Icon(
                                    Icons.check_rounded,
                                    size: 30,
                                  )),
                            ],
                          )
                        ],
                      ),
                    )));
          });
        });
  }


  confirmDeadlineTime() async {
    if (!errorDeadlineTime) {
      Task newTask = new Task(
          id: task!.id,
          subject: task!.subject,
          isChecked: task!.isChecked,
          deadlineTime:
          updateDeadlineTime.toString(),
          notificationTime:
          task!.notificationTime,
          notes: task!.notes);
      databaseUpdateTask(newTask);

      setState(() {
        task = newTask;
      });
      widget.onReload!(task!.id);
      Navigator.pop(context);
      if (DateTime.parse(
          task!.notificationTime!)
          .isAfter(DateTime.now())) {
        cancelNotification(task!.id);
        await Future.delayed(Duration(seconds: 1), () {});

        scheduleNotification(
            newTask.id!,
            newTask.subject!,
            newTask.notes,
            newTask.deadlineTime.toString(),
            DateTime.parse(
                newTask.notificationTime!));
      }
    }
  }

  void editDeadlineTime() {

    editDialog(
      "Zu erledigen bis",
      StatefulBuilder(builder: (context, setState) {
        return Column(
          children: [
            Container(
              decoration: timePickerBorder,
              child: SizedBox(
                height: timePickerHeight,
                width: timePickerWidth,
                child: CupertinoDatePicker(
                  use24hFormat: true,
                  initialDateTime: updateDeadlineTime,
                  mode: CupertinoDatePickerMode
                      .dateAndTime,
                  onDateTimeChanged: (value) {
                    updateDeadlineTime = value;
                  },
                ),
              )
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: (errorDeadlineTime) ?
                  Text('Fehler: Frist vor Erinnerung', style: TextStyle(color: Colors.red)) : Text(''),
            )
          ]
        );
      }),
      () => confirmDeadlineTime
    );
  }

  void editNotificationTime() {

    editDialog(
        "Erinnerungs-Zeit",
        StatefulBuilder(builder: (context, setState) {
          return Column(
              children: [
                Container(
                  decoration: timePickerBorder,
                  child: SizedBox(
                      height: timePickerHeight,
                      width: timePickerWidth,
                      child: CupertinoDatePicker(
                        use24hFormat: true,
                        initialDateTime: updateNotificationTime,
                        mode:
                        CupertinoDatePickerMode.dateAndTime,
                        onDateTimeChanged: (value) {
                          updateNotificationTime = value;
                          setState(() {
                            if (updateNotificationTime!
                                .add(Duration(minutes: 1))
                                .isBefore(DateTime.now())) {
                              errorNotificationTime = true;
                            } else {
                              errorNotificationTime = false;
                            }
                          });
                        },
                      ),
                    )
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: (errorNotificationTime) ?
                    Text('Ungültige Zeit', style: TextStyle(color: Colors.red),) : Text('')
                )
              ]
          );
        }),
        () => confirmDeadlineTime
    );

  }

  void confirmNotes() async {
    if (!errorNotes) {
      if (updateNotes == '' ||
          updateNotes == null) {
        updateNotes = null;
      }
      Task newTask = new Task(
          id: task!.id,
          subject: task!.subject,
          isChecked: task!.isChecked,
          deadlineTime: task!.deadlineTime,
          notificationTime:
          task!.notificationTime,
          notes: updateNotes);
      databaseUpdateTask(newTask);
      setState(() {
        task = newTask;
      });
      widget.onReload!(task!.id);
      Navigator.pop(context);

      if (DateTime.parse(task!.notificationTime!)
          .isAfter(DateTime.now())) {
        cancelNotification(task!.id);
        await Future.delayed(
            Duration(seconds: 1), () {});

        scheduleNotification(
            newTask.id!,
            newTask.subject!,
            newTask.notes,
            newTask.deadlineTime.toString(),
            DateTime.parse(
                newTask.notificationTime!));
      }
    }
  }

  void onNotesChanged(String text, Function setError) {
    updateNotes = text;
    _textEditingController.text = updateNotes!;
    _textEditingController.selection =
        TextSelection.fromPosition(TextPosition(
            offset: _textEditingController
                .text.length));
    setState(() {});

    if (updateNotes == '' || updateNotes == null) {
      updateNotes = null;
    }
    if (updateNotes == null &&
        task!.subject == 'Sonstiges') {
      setError(() {
        errorNotes = true;
      });
    } else {
      setError(() {
        errorNotes = false;
      });
    }
  }


  void editNotes() {

    editDialog(
      "Notizen",
      StatefulBuilder(builder: (context, setError) {
        return Column(children: [
          TextField(
            maxLines: AddDialog.notesLines,
            dragStartBehavior: DragStartBehavior.down,
            controller: _textEditingController,
            decoration: InputDecoration(hintText: 'Notizen'),
            onChanged: (text) => onNotesChanged(text, setError),
          ),
          (errorNotes)
              ? Text(
            'Notiz erforderlich',
            style: TextStyle(color: Colors.red),
          )
              : Text(''),
        ]);
      }),
        () => confirmNotes
    );

  }

  /// Diese Methode dient dazu, im Querformat eine andere Aufgabe in der Detailansicht anzuzeigen
  /// und die Detailansicht so zu aktualisieren.
  update(Task? pTask) {
    setState(() {
      task = pTask;
      if (task != null) {
        updateNotes = task!.notes;
        updateNotificationTime = DateTime.parse(task!.notificationTime!);
        if (task!.isChecked == 1) {
          checked = true;
        } else {
          checked = false;
        }
      }
    });
  }

  void remove() async {
    Future.delayed(Duration(seconds: 2), () {
      if (checked == true) {
        databaseDeleteTask(task!.id);
        cancelNotification(task!.id);
        widget.onRemove!(task!.id);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    task = widget.task;
    if (task != null) {
      updateNotes = task!.notes;
      updateNotificationTime = DateTime.parse(task!.notificationTime!);
      if (task!.isChecked == 1) {
        checked = true;
      } else {
        checked = false;
      }
    }
  }

  /// Rückgabe eines Containers mit der gesamten Detailansicht.
  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return Center(child: Text('Keine Aufgabe ausgewählt.'));
    } else {
      return ListView(children: <Widget>[
        Container(
            decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.light)
                    ? Colors.white
                    : Colors.grey[800],
                border: Border.all(color: Colors.black45, width: 1.0),
                borderRadius: BorderRadius.circular(5)),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.all(10),
            child: Center(
                child: Column(
              children: <Widget>[
                subjectWidget(task!.subject!),
                if (task!.notes != null) notesWidget(task!.notes!, context),
                deadlinetimeWidget(task!.deadlineTime!, context),
                notificationtimeWidget(task!.notificationTime!, context),
                quickNotifications(),
              ],
            ))),
        Center(
          child: Flex(
            direction:
                (MediaQuery.of(context).orientation == Orientation.landscape &&
                        widget.isParallelDetail == true)
                    ? ((MediaQuery.of(context).size.width / 2) < 407)
                        ? Axis.vertical
                        : Axis.horizontal
                    : (MediaQuery.of(context).size.width < 350)
                        ? Axis.vertical
                        : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: ,
            children: [
              if (task!.notes == null)
                Container(
                    width: 170,
                    decoration: BoxDecoration(
                        color:
                            (Theme.of(context).brightness == Brightness.light)
                                ? Colors.white
                                : Colors.grey[800],
                        border: Border.all(color: Colors.black45, width: 1.0),
                        borderRadius: BorderRadius.circular(5)),
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          errorNotes = false;
                          editNotes();
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            CupertinoIcons.add,
                            color: (Theme.of(context).brightness ==
                                    Brightness.light)
                                ? Colors.blue
                                : Theme.of(context).accentColor,
                            size: 28,
                          ),
                          Text(
                            'Notizen',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    )),
              Container(
                  width: 170,
                  decoration: BoxDecoration(
                      color: (Theme.of(context).brightness == Brightness.light)
                          ? Colors.white
                          : Colors.grey[800],
                      border: Border.all(color: Colors.black45, width: 1.0),
                      borderRadius: BorderRadius.circular(5)),
                  padding: EdgeInsets.all(5.0),
                  margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        checked = !checked!;
                        remove();
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        checked!
                            ? Icon(
                                CupertinoIcons.check_mark_circled_solid,
                                color: Colors.green,
                                size: 28,
                              )
                            : Icon(
                                CupertinoIcons.circle,
                                size: 28,
                                color: Theme.of(context).accentColor,
                              ),
                        checked!
                            ? Text(
                                'Erledigt',
                                style: TextStyle(fontSize: 17),
                              )
                            : Text('Erledigen', style: TextStyle(fontSize: 17)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ]);
    }
  }

  void remindMeLater(String time) {
    DateTime tempTime;

    if (time == 'afternoon') {
      tempTime = new DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 16);
    } else if (time == 'evening') {
      tempTime = new DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 20);
    } else if (time == 'tomorrowMorning') {
      tempTime = new DateTime(DateTime.now().year, DateTime.now().month,
          (DateTime.now().day + 1), 9);
    } else {
      tempTime = DateTime.now().add(Duration(hours: 1));
    }

    task!.notificationTime = tempTime.toString();
    cancelNotification(task!.id!);
    scheduleNotification(
        task!.id!, task!.subject!, task!.notes, task!.deadlineTime!, tempTime);
    databaseUpdateTask(task!);
    setState(() {});
  }

  Widget quickNotifications() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          OutlinedButton(
            onPressed: () {
              remindMeLater('oneHour');
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.timer,
                    color: Colors.orange,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      'In 1 Stunde erinnern',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              remindMeLater((DateTime.now().hour < 16)
                  ? 'afternoon'
                  : (DateTime.now().hour < 20)
                      ? 'evening'
                      : 'tomorrowMorning');
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.timer,
                    color: (Theme.of(context).brightness == Brightness.dark)
                        ? Theme.of(context).accentColor
                        : Colors.blueGrey,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      (DateTime.now().hour < 16)
                          ? 'Am Nachmittag erinnern'
                          : (DateTime.now().hour < 20)
                              ? 'Am Abend erinnern'
                              : 'Am Morgen erinnern',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget deadlinetimeWidget(String pTime, BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0, top: 20),
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Zu erledigen bis:', style: TextStyle(fontSize: 17)),
                  Text(
                    parseTimeToUserOutput(pTime),
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: (!DateTime.parse(pTime).isAfter(DateTime.now()))
                            ? Colors.red
                            : null),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_rounded,
                  color: Theme.of(context).accentColor),
              onPressed: () {
                errorDeadlineTime = false;
                updateDeadlineTime = DateTime.parse(task!.deadlineTime!);
                editDeadlineTime();
              },
            )
          ],
        ));
  }

  Widget notesWidget(String pNotes, BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(bottom: 10.0, top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Notizen:', style: TextStyle(fontSize: 17)),
                SelectableText(
                  pNotes,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.edit_rounded, color: Theme.of(context).accentColor),
            onPressed: () {
              errorNotes = false;
              _textEditingController.text = task!.notes!;
              _textEditingController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _textEditingController.text.length));
              editNotes();
            },
          )
        ],
      ),
    );
  }

  Widget notificationtimeWidget(String pTime, BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(bottom: 10.0, top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Zeitpunkt der Erinnerung:',
                    style: TextStyle(fontSize: 17)),
                Text(parseTimeToUserOutput(pTime),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.edit_rounded, color: Theme.of(context).accentColor),
            onPressed: () {
              errorNotificationTime = false;
              updateNotificationTime = DateTime.parse(task!.notificationTime!);
              editNotificationTime();
            },
          )
        ],
      ),
    );
  }
}

/// Dieses Widget gibt einen Container zurück, welche in die Detailanscht eingebunden wird.
/// Dieses Widget beinhaltet das Fach der Hausaufgabe.
Widget subjectWidget(String pSubject) {
  return Container(
    margin: EdgeInsets.only(bottom: 10.0),
    alignment: Alignment.topLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Fach:', style: TextStyle(fontSize: 17)),
        Text(pSubject,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            )),
      ],
    ),
  );
}