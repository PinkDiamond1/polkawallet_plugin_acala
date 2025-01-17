import 'dart:async';
import 'dart:convert';

import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/assets.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_ui/utils/format.dart';

class AcalaServiceAssets {
  AcalaServiceAssets(this.plugin);

  final PluginAcala plugin;

  Timer? _tokenPricesSubscribeTimer;

  final tokenBalanceChannel = 'tokenBalance';

  Future<List?> getAllTokenSymbols() async {
    final List? res =
        await plugin.sdk.webView!.evalJavascript('acala.getAllTokens(api)');
    return res;
  }

  Future<Map> getTokenPrices(List<String> tokens) async {
    final Map? res = await plugin.sdk.webView!
        .evalJavascript('acala.getTokenPrices(${jsonEncode(tokens)})');
    return res ?? {};
  }

  void unsubscribeTokenBalances(String? address) async {
    final tokens = await plugin.api!.assets.getAllTokenSymbols(withCache: true);
    tokens.forEach((e) {
      plugin.sdk.api.unsubscribeMessage('$tokenBalanceChannel${e.symbol}');
    });

    final dexPairs = await plugin.api!.swap.getTokenPairs();
    dexPairs.forEach((e) {
      final lpToken =
          AssetsUtils.getBalanceFromTokenNameId(plugin, e.tokenNameId)
                  .symbol
                  ?.split('-') ??
              [];
      if (lpToken.length > 0) {
        plugin.sdk.api
            .unsubscribeMessage('$tokenBalanceChannel${lpToken.join('')}');
      }
    });
  }

  Future<void> subscribeTokenBalances(String? address,
      List<TokenBalanceData> tokens, Function(Map) callback) async {
    tokens.forEach((e) {
      final channel = '$tokenBalanceChannel${e.symbol}';
      plugin.sdk.api.subscribeMessage(
        'acala.getTokenBalance',
        ['api', address, e.tokenNameId],
        channel,
        (Map data) {
          callback({
            'id': e.id,
            'symbol': e.symbol,
            'tokenNameId': e.tokenNameId,
            'currencyId': e.currencyId,
            'type': e.type,
            'minBalance': e.minBalance,
            'decimals': e.decimals,
            'balance': data
          });
        },
      );
    });
    final dexPairs = await plugin.api!.swap.getTokenPairs();
    dexPairs.forEach((e) {
      final currencyId = {'DEXShare': e.tokens};
      final lpToken = e.tokens!
          .map((e) => AssetsUtils.tokenDataFromCurrencyId(plugin, e))
          .toList();
      final tokenId = lpToken.map((e) => e.symbol).join('-');
      final channel =
          '$tokenBalanceChannel${lpToken.map((e) => e.symbol).join('')}';
      plugin.sdk.api.subscribeMessage(
        'acala.getTokenBalance',
        ['api', address, e.tokenNameId],
        channel,
        (Map data) {
          callback({
            'symbol': tokenId,
            'type': 'DexShare',
            'tokenNameId': e.tokenNameId,
            'currencyId': currencyId,
            'minBalance': lpToken[0].minBalance,
            'decimals': lpToken[0].decimals,
            'balance': data
          });
        },
      );
    });
  }

  Future<void> subscribeTokenPrices(
      Function(Map<String, BigInt>) callback) async {
    final loanTypes = plugin.store?.loan.loanTypes
        .map((e) => e.token?.tokenNameId ?? '')
        .toList();
    loanTypes?.removeWhere((e) => e == 'LDOT');

    final List? res = await plugin.sdk.webView!.evalJavascript(
        'acala.queryTokenPriceFromOracle(api, ${jsonEncode(loanTypes)})');
    if (res != null) {
      final prices = Map<String, BigInt>();
      loanTypes?.asMap().forEach((i, e) {
        prices[e] = Fmt.balanceInt(res[i]);
      });
      callback(prices);
    }

    // we may have multi-subscriptions, so we merge them into one timer.
    if (_tokenPricesSubscribeTimer == null ||
        !_tokenPricesSubscribeTimer!.isActive) {
      _tokenPricesSubscribeTimer =
          Timer(Duration(seconds: 20), () => subscribeTokenPrices(callback));
    }
  }

  void unsubscribeTokenPrices() {
    if (_tokenPricesSubscribeTimer != null) {
      _tokenPricesSubscribeTimer!.cancel();
      _tokenPricesSubscribeTimer = null;
    }
  }

  Future<List?> queryNFTs(String? address) async {
    final List? res = await plugin.sdk.webView!
        .evalJavascript('acala.queryNFTs(api, "$address")');
    return res;
  }

  Future<Map?> queryAggregatedAssets(String? address) async {
    final Map? res = await plugin.sdk.webView!
        .evalJavascript('acala.queryAggregatedAssets(api, "$address")');
    return res;
  }

  Future<bool?> checkExistentialDepositForTransfer(
    String address,
    Map currencyId,
    int decimal,
    String amount, {
    String direction = 'to',
  }) async {
    final res = await plugin.sdk.webView!.evalJavascript(
        'acala.checkExistentialDepositForTransfer(api, "$address", ${jsonEncode(currencyId)}, $decimal, $amount, "$direction")');
    return res['result'] as bool?;
  }
}
