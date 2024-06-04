import 'package:flutter/material.dart';

import 'convert_object.dart';
import 'drug_info.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<List<DrugInfo>> futureDrugInfoList;

  @override
  void initState() {
    super.initState();
    futureDrugInfoList = fetchDrugInfoList();
  }

  Future<List<DrugInfo>> fetchDrugInfoList() async {
    final response =
        await DefaultAssetBundle.of(context).loadString('assets/data.json');
    return parseDrugInfo(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결과 화면'),
      ),
      body: FutureBuilder<List<DrugInfo>>(
        future: futureDrugInfoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final drugInfo = snapshot.data![index];
                return ListTile(
                  leading: Image.network(drugInfo.itemImage),
                  title: Text(drugInfo.itemName),
                  subtitle: Text(drugInfo.className),
                );
              },
            );
          }
        },
      ),
    );
  }
}
