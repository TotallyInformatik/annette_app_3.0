import 'package:http/http.dart' as http;
class GroupsQ1 {
  List<List<String>> groupsQ1List = [];
  Future<bool> initialize () async{
    Future<String?> _getTimetable() async {
      try {
        var response = await http.get(
            Uri.https('www.annettegymnasium.de', 'SP/stundenplan_oL/c/P9/c00027.htm'));
        if (response.statusCode == 200) {
          return response.body;
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    if(await _getTimetable() != null) {
      String htmlCode = (await _getTimetable())!;
      htmlCode = htmlCode.replaceAll('Gk', 'GK');
      htmlCode = htmlCode.replaceAll('Lk', 'LK');

      for(int i=1; i<3; i++) {
        List<String> tempList = [];
        String tempCode = htmlCode;
        int tempIndex = tempCode.indexOf('LK-Schiene $i');
        if(tempIndex == -1) {
          tempIndex = tempCode.indexOf('LK Schiene $i');
        }
        tempIndex++;
        tempCode = tempCode.substring(0, tempCode.indexOf('</TABLE', tempIndex));
        tempCode = tempCode.substring(tempCode.lastIndexOf('TABLE'));
        tempCode = tempCode.substring(tempCode.indexOf('<TR>', tempCode.indexOf('<TR>') + 4));

        while(tempCode.indexOf('<B>') != -1) {
          tempCode = tempCode.substring(tempCode.indexOf('<B>') + 3);
          String s = tempCode.substring(0, tempCode.indexOf('</B'));
          s = s.replaceAll('.', ' ');
          s = s.trim();
          tempList.add(s);
          tempCode = tempCode.substring(tempCode.indexOf('</B'));
        }
        groupsQ1List.add(tempList);
      }

      for(int i=1; i<10; i++) {
        List<String> tempList = [];
        String tempCode = htmlCode;
        int tempIndex = tempCode.indexOf('GK-Schiene $i');
        if(tempIndex == -1) {
          tempIndex = tempCode.indexOf('GK Schiene $i');
        }
        tempCode = tempCode.substring(0, tempCode.indexOf('</TABLE', tempIndex));
        tempCode = tempCode.substring(tempCode.lastIndexOf('TABLE'));
        tempCode = tempCode.substring(tempCode.indexOf('<TR>', tempCode.indexOf('<TR>') + 4));

        while(tempCode.indexOf('<B>') != -1) {
          tempCode = tempCode.substring(tempCode.indexOf('<B>') + 3);
          String s = tempCode.substring(0, tempCode.indexOf('</B'));
          s = s.replaceAll('.', ' ');
          s = s.trim();
          tempList.add(s);
          tempCode = tempCode.substring(tempCode.indexOf('</B'));
        }
        groupsQ1List.add(tempList);
      }

      groupsQ1List.add(['SP GK1','SP GK2','SP GK3','SP GK4','SP GK5',]);
      groupsQ1List.add([]);
      groupsQ1List.add([]);
      groupsQ1List.add([]);
      groupsQ1List.add([]);
      groupsQ1List.add([]);

      return true;
    } else {
      return false;
    }
  }

  List<List<String>> getGroupsQ1 () {
    return groupsQ1List;
  }
}