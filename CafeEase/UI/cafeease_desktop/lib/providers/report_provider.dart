import '../models/report_data.dart';
import 'base_provider.dart';

class ReportProvider extends BaseProvider<dynamic> {
  ReportProvider() : super('api/Reports');

  @override
  dynamic fromJson(dynamic data) => data;

  Future<ReportData> getReportData() async {
    final data = await getCustom('api/Reports/data');
    return ReportData.fromJson(data);
  }
}
