import 'dart:convert';
import 'dart:math';

import 'package:polkawallet_plugin_acala/common/constants/index.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/assets.dart';
import 'package:polkawallet_ui/utils/format.dart';

class TxLoanData extends _TxLoanData {
  static const String actionTypeDeposit = 'deposit';
  static const String actionTypeWithdraw = 'withdraw';
  static const String actionTypeBorrow = 'mint';
  static const String actionTypePayback = 'payback';
  static const String actionTypeCreate = 'create';
  static const String actionLiquidate = 'liquidate';
  static TxLoanData fromJson(
      Map json, String stableCoinSymbol, PluginAcala plugin) {
    TxLoanData data = TxLoanData();
    data.event = json['extrinsic']['method'];
    data.hash = json['extrinsicId'];

    final token = AssetsUtils.tokenDataFromCurrencyId(
        plugin, {"token": json['collateralId']});
    data.token = token.symbol;

    data.collateral = Fmt.balanceInt(json['collateralAdjustment'].toString());
    data.debit = Fmt.balanceInt((json['debitAdjustment'] ?? '0').toString()) *
        Fmt.balanceInt(
            (json['debitExchangeRate'] ?? '1000000000000').toString()) ~/
        BigInt.from(pow(10, acala_price_decimals));

    data.amountCollateral =
        Fmt.priceFloorBigInt(data.collateral!.abs(), token.decimals ?? 12);

    data.amountDebit = Fmt.priceCeilBigInt(data.debit,
        plugin.store!.assets.tokenBalanceMap[acala_stable_coin]!.decimals!);
    if (data.event == 'ConfiscateCollateralAndDebit') {
      data.actionType = actionLiquidate;
    } else if (data.collateral == BigInt.zero) {
      data.actionType =
          data.debit! > BigInt.zero ? actionTypeBorrow : actionTypePayback;
    } else if (data.debit == BigInt.zero) {
      data.actionType = data.collateral! > BigInt.zero
          ? actionTypeDeposit
          : actionTypeWithdraw;
    } else if (data.debit! < BigInt.zero) {
      data.actionType = actionTypePayback;
    } else {
      data.actionType = actionTypeCreate;
    }

    data.time = (json['timestamp'] as String).replaceAll(' ', '');
    data.isSuccess = json['isSuccess'];
    return data;
  }
}

abstract class _TxLoanData {
  String? block;
  String? hash;

  String? token;
  String? event;
  String? actionType;
  BigInt? collateral;
  BigInt? debit;
  String? amountCollateral;
  String? amountDebit;

  late String time;
  bool? isSuccess = true;
}
