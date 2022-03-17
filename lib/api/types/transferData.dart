import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_ui/utils/format.dart';

class TransferData extends _TransferData {
  static TransferData fromJson(Map json, TokenBalanceData token) {
    final res = TransferData();
    res.from = json['fromId'];
    res.to = json['toId'];
    res.token = token.symbol;
    res.amount = Fmt.balance(json['amount'].toString(), token.decimals!);
    res.hash = json['extrinsicId'];
    res.timestamp = (json['timestamp'] as String).replaceAll(' ', '');
    res.isSuccess = true;
    return res;
  }
}

abstract class _TransferData {
  String? block;
  String? from = "";
  String? to = "";
  String amount = "";
  String? token = "";
  String? hash = "";
  String timestamp = "";
  bool? isSuccess = true;
}
