import 'package:todaybread/models/boss/boss_parsing.dart';
import 'package:todaybread/models/boss/boss_sales_response.dart';
import 'package:todaybread/services/boss/boss_sales_api.dart';
import 'package:todaybread/services/network/dio_client.dart';

class BossSalesService {
  BossSalesService._();

  static final BossSalesService instance = BossSalesService._();

  final BossSalesApi _api = BossSalesApi(DioClient.instance);

  Future<BossMonthlySalesResponse> getMonthlySales(DateTime month) async {
    final normalized = DateTime(month.year, month.month);
    final data = await _api.getMonthlySales(
      year: normalized.year,
      month: normalized.month,
    );
    return BossMonthlySalesResponse.fromDynamic(data, normalized);
  }

  Future<BossDailySalesResponse> getDailySales(DateTime date) async {
    final normalized = bossNormalizeDate(date);
    final data = await _api.getDailySales(date: bossDateKey(normalized));
    return BossDailySalesResponse.fromDynamic(data, normalized);
  }
}
