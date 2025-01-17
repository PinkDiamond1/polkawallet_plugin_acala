import 'dart:async';

import 'package:polkawallet_plugin_acala/common/constants/index.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';

class AcalaServiceHoma {
  AcalaServiceHoma(this.plugin);

  final PluginAcala plugin;

  Future<List?> queryHomaLiteStakingPool() async {
    final List? res = await plugin.sdk.webView!.evalJavascript('Promise.all(['
        'api.query.homaLite.stakingCurrencyMintCap(),'
        'api.query.homaLite.totalStakingCurrency(),'
        'api.query.tokens.totalIssuance({ Token: "L$relay_chain_token_symbol" })'
        '])');
    return res;
  }

  Future<Map?> queryHomaRedeemAmount(double input, int redeemType, era) async {
    final Map? res = await plugin.sdk.webView!.evalJavascript(
        'acala.calcHomaNewRedeemAmount(api, $input, $redeemType, $era)');
    return res;
  }

  Future<Map?> calcHomaMintAmount(double input) async {
    final Map? res = await plugin.sdk.webView!
        .evalJavascript('acala.calcHomaMintAmount(api, $input)');
    return res;
  }

  Future<Map?> calcHomaRedeemAmount(
      String address, double input, bool isByDex) async {
    final Map? res = await plugin.sdk.webView!.evalJavascript(
        'acala.calcHomaRedeemAmount(api,"$address", $input,$isByDex)');
    return res;
  }

  Future<dynamic> redeemRequested(String? address) async {
    final dynamic res = await plugin.sdk.webView!
        .evalJavascript('acala.queryRedeemRequest(api,"$address")');
    return res;
  }

  Future<dynamic> queryHomaNewEnv() async {
    final dynamic res =
        await plugin.sdk.webView!.evalJavascript('acala.queryHomaNewEnv(api)');
    return res;
  }

  Future<Map?> calcHomaNewMintAmount(double input) async {
    final Map? res = await plugin.sdk.webView!
        .evalJavascript('acala.calcHomaNewMintAmount(api, $input)');
    return res;
  }

  Future<Map?> calcHomaNewRedeemAmount(double input,
      {bool isFastRedeem = false}) async {
    final Map? res = await plugin.sdk.webView!.evalJavascript(
        'acala.calcHomaNewRedeemAmount(api,$input,$isFastRedeem)');
    return res;
  }

  Future<Map?> queryHomaPendingRedeem(String? address) async {
    final Map? res = await plugin.sdk.webView!
        .evalJavascript('acala.queryHomaPendingRedeem(api,"$address")');
    return res;
  }
}
