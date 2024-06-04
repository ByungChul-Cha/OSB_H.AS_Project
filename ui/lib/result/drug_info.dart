import 'dart:convert';
import 'convert_object.dart';

List<DrugInfo> parseDrugInfo(String responseBody) {
  final parsed = json.decode(responseBody);
  return (parsed['row_data_list'] as List)
      .map<DrugInfo>((json) => DrugInfo.fromJson(json))
      .toList();
}
