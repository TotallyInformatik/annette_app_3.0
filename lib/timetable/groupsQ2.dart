import 'package:annette_app/data/links.dart';
import 'package:http/http.dart' as http;

import '../miscellaneous-files/timetableURL.dart';
class GroupsQ2 {
  List<List<String>> groupsQ2List = [];
  Future<bool> initialize () async{
    Future<String?> _getTimetable() async {
      try {
        String? tempUrl = await getTimetableURL();
        if (tempUrl != null) {


          var

          response = await http.get(
            Uri.https(Links.timetableUrl, '$tempUrl/c00028.htm'));
        if (response.statusCode == 200) {
          return response.body;
        }}
        return null;
      } catch (e) {
        return null;
      }
    }

    if(await _getTimetable() != null) {
      String htmlCode = (await _getTimetable())!;

      if(!htmlCode.toUpperCase().contains('LK')) {
        return false;
      }

      htmlCode = htmlCode.replaceAll('Gk', 'GK');
      htmlCode = htmlCode.replaceAll('Lk', 'LK');
      htmlCode = htmlCode.replaceAll('z1', 'Z1');
      htmlCode = htmlCode.replaceAll('z2', 'Z2');


      for(int i=1; i<3; i++) {
        List<String> tempList = [];
        String tempCode = htmlCode;
        int tempIndex = tempCode.indexOf('LK-Schiene $i');
        if(tempIndex == -1) {
          tempIndex = tempCode.indexOf('LK Schiene $i');
        }
        tempCode = tempCode.substring(0, tempCode.indexOf('</TABLE', tempIndex));
        tempCode = tempCode.substring(tempCode.lastIndexOf('TABLE'));
        tempCode = tempCode.substring(tempCode.indexOf('<TR>', tempCode.indexOf('<TR>') + 4));

        while(tempCode.indexOf('<B>') != -1) {
          tempCode = tempCode.substring(tempCode.indexOf('<B>') + 3);
          String s = tempCode.substring(0, tempCode.indexOf('</B'));
          s = s.replaceAll('.', ' ');
          s = s.trim();
if(!tempList.contains(s)) {
          tempList.add(s);
        }
          tempCode = tempCode.substring(tempCode.indexOf('</B'));
        }
        tempList.sort((a,b) {
          return a.compareTo(b);
        });
        groupsQ2List.add(tempList);
      }

      for(int i=1; i<10; i++) {
        List<String> tempList = [];
        String tempCode = htmlCode;
        String tempName = 'GK-Schiene';

        int tempIndex = tempCode.indexOf('$tempName $i<');
        if(tempIndex == -1) {
          tempName = 'GK Schiene';
          tempIndex = tempCode.indexOf('$tempName $i<');
        }

        while(tempIndex != -1) {
          tempCode =
              tempCode.substring(0, tempCode.indexOf('</TABLE', tempIndex));
          tempCode = tempCode.substring(tempCode.lastIndexOf('TABLE'));
          tempCode = tempCode.substring(
              tempCode.indexOf('<TR>', tempCode.indexOf('<TR>') + 4));

          while (tempCode.indexOf('<B>') != -1) {
            tempCode = tempCode.substring(tempCode.indexOf('<B>') + 3);
            String s = tempCode.substring(0, tempCode.indexOf('</B'));
            s = s.replaceAll('.', ' ');
            s = s.trim();
            if (!tempList.contains(s) && !s.contains('Z1') && !s.contains('Z2')) {
              tempList.add(s);
            }
            tempCode = tempCode.substring(tempCode.indexOf('</B'));
          }
          tempList.sort((a, b) {
            return a.compareTo(b);
          });


          tempCode = htmlCode;
          tempIndex = tempCode.indexOf('$tempName $i<', tempIndex + 10);

        }
        groupsQ2List.add(tempList);
      }

      groupsQ2List.add([]);
      groupsQ2List.add([]);
      groupsQ2List.add([]);
      groupsQ2List.add([]);

      groupsQ2List.add(['GE Z1', 'GE Z2', 'SW Z1', 'SW Z2']);
      groupsQ2List.add(['GE Z1', 'GE Z2', 'SW Z1', 'SW Z2']);

      return true;
    } else {
      return false;
    }
  }

  List<List<String>> getGroupsQ2 () {
    return groupsQ2List;
  }
}