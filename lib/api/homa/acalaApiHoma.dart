import 'package:polkawallet_plugin_acala/api/homa/acalaServiceHoma.dart';
import 'package:polkawallet_plugin_acala/api/types/calcHomaRedeemAmount.dart';
import 'package:polkawallet_plugin_acala/api/types/homaNewEnvData.dart';
import 'package:polkawallet_plugin_acala/api/types/homaPendingRedeemData.dart';
import 'package:polkawallet_plugin_acala/api/types/stakingPoolInfoData.dart';
import 'package:polkawallet_ui/utils/format.dart';

class AcalaApiHoma {
  AcalaApiHoma(this.service);

  final AcalaServiceHoma service;

  Future<HomaLitePoolInfoData> queryHomaLiteStakingPool() async {
    final List res =
        await (service.queryHomaLiteStakingPool() as Future<List<dynamic>>);
    return HomaLitePoolInfoData(
      cap: Fmt.balanceInt(res[0]),
      staked: Fmt.balanceInt(res[1]),
      liquidTokenIssuance: Fmt.balanceInt(res[2]),
    );
  }

  Future<Map?> calcHomaMintAmount(double input) async {
    final Map? res = await service.calcHomaMintAmount(input);
    return res;
  }

  Future<Map?> calcHomaNewMintAmount(double input) async {
    final Map? res = await service.calcHomaNewMintAmount(input);
    return res;
  }

  Future<CalcHomaRedeemAmount> calcHomaRedeemAmount(
      String address, double input, bool isByDex) async {
    final Map res = await (service.calcHomaRedeemAmount(address, input, isByDex)
        as Future<Map<dynamic, dynamic>>);
    return CalcHomaRedeemAmount.fromJson(res as Map<String, dynamic>);
  }

  Future<Map?> calcHomaNewRedeemAmount(double input, bool isFastRedeem) async {
    return service.calcHomaNewRedeemAmount(input, isFastRedeem: isFastRedeem);
  }

  Future<dynamic> redeemRequested(String? address) async {
    final dynamic res = await service.redeemRequested(address);
    return res;
  }

  Future<HomaNewEnvData> queryHomaNewEnv() async {
    final dynamic res = await service.queryHomaNewEnv();
    return HomaNewEnvData.fromJson(res);
  }

  Future<HomaPendingRedeemData> queryHomaPendingRedeem(String? address) async {
    final res = await service.queryHomaPendingRedeem(address);
    return HomaPendingRedeemData.fromJson(Map<String, dynamic>.from(res ?? {}));
  }
}
