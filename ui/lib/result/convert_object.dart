import 'dart:convert';

class DrugInfo {
  final String bizRno;
  final String changeDate;
  final String chart;
  final String className;
  final String classNo;
  final String colorClass1;
  final String colorClass2;
  final String drugShape;
  final String ediCode;
  final String entpName;
  final String entpSeq;
  final String etcOtcName;
  final String formCodeName;
  final String imgRegistTs;
  final String itemEngName;
  final String itemImage;
  final String itemName;
  final String itemPermitDate;
  final String itemSeq;
  final String lengLong;
  final String lengShort;
  final String lineBack;
  final String lineFront;
  final String markCodeBack;
  final String markCodeBackAnal;
  final String markCodeBackImg;

  DrugInfo({
    required this.bizRno,
    required this.changeDate,
    required this.chart,
    required this.className,
    required this.classNo,
    required this.colorClass1,
    required this.colorClass2,
    required this.drugShape,
    required this.ediCode,
    required this.entpName,
    required this.entpSeq,
    required this.etcOtcName,
    required this.formCodeName,
    required this.imgRegistTs,
    required this.itemEngName,
    required this.itemImage,
    required this.itemName,
    required this.itemPermitDate,
    required this.itemSeq,
    required this.lengLong,
    required this.lengShort,
    required this.lineBack,
    required this.lineFront,
    required this.markCodeBack,
    required this.markCodeBackAnal,
    required this.markCodeBackImg,
  });

  factory DrugInfo.fromJson(Map<String, dynamic> json) {
    return DrugInfo(
      bizRno: json['BIZRNO'] as String,
      changeDate: json['CHANGE_DATE'] as String,
      chart: json['CHART'] as String,
      className: json['CLASS_NAME'] as String,
      classNo: json['CLASS_NO'] as String,
      colorClass1: json['COLOR_CLASS1'] as String,
      colorClass2: json['COLOR_CLASS2'] as String,
      drugShape: json['DRUG_SHAPE'] as String,
      ediCode: json['EDI_CODE'] as String,
      entpName: json['ENTP_NAME'] as String,
      entpSeq: json['ENTP_SEQ'] as String,
      etcOtcName: json['ETC_OTC_NAME'] as String,
      formCodeName: json['FORM_CODE_NAME'] as String,
      imgRegistTs: json['IMG_REGIST_TS'] as String,
      itemEngName: json['ITEM_ENG_NAME'] as String,
      itemImage: json['ITEM_IMAGE'] as String,
      itemName: json['ITEM_NAME'] as String,
      itemPermitDate: json['ITEM_PERMIT_DATE'] as String,
      itemSeq: json['ITEM_SEQ'] as String,
      lengLong: json['LENG_LONG'] as String,
      lengShort: json['LENG_SHORT'] as String,
      lineBack: json['LINE_BACK'] as String,
      lineFront: json['LINE_FRONT'] as String,
      markCodeBack: json['MARK_CODE_BACK'] as String,
      markCodeBackAnal: json['MARK_CODE_BACK_ANAL'] as String,
      markCodeBackImg: json['MARK_CODE_BACK_IMG'] as String,
    );
  }
}
