import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polkawallet_plugin_acala/api/types/txLoanData.dart';
import 'package:polkawallet_plugin_acala/common/constants/index.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/format.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginTxDetail.dart';
import 'package:polkawallet_ui/utils/consts.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class LoanTxDetailPage extends StatelessWidget {
  LoanTxDetailPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static final String route = '/karura/loan/tx';

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic =
        I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala')!;
    final amountStyle = TextStyle(
        fontSize: UI.getTextSize(16, context),
        fontWeight: FontWeight.bold,
        color: PluginColorsDark.headline1);

    final TxLoanData tx =
        ModalRoute.of(context)!.settings.arguments as TxLoanData;

    final List<TxDetailInfoItem> items = [
      TxDetailInfoItem(
        label: 'Event',
        content: Text(tx.event!,
            style: tx.isSuccess == null
                ? TextStyle(
                    fontFamily: UI.getFontFamily('TitilliumWeb', context),
                    fontSize: UI.getTextSize(30, context),
                    fontWeight: FontWeight.w600,
                    color: PluginColorsDark.headline1)
                : amountStyle),
      ),
      TxDetailInfoItem(
        label: dic['txs.action'],
        content: Text(
            dic['loan.${tx.actionType}']! +
                (tx.actionType == TxLoanData.actionTypeBorrow ||
                        tx.actionType == TxLoanData.actionTypePayback
                    ? ' $acala_stable_coin_view'
                    : ' ${PluginFmt.tokenView(tx.token)}'),
            style: amountStyle),
      )
    ];
    if (tx.collateral != BigInt.zero) {
      items.add(TxDetailInfoItem(
        label: tx.collateral! > BigInt.zero
            ? dic['loan.deposit']
            : dic['loan.withdraw'],
        content: Text('${tx.amountCollateral} ${PluginFmt.tokenView(tx.token)}',
            style: amountStyle),
      ));
    }
    if (tx.debit != BigInt.zero) {
      items.add(TxDetailInfoItem(
        label: tx.debit! < BigInt.zero ? dic['loan.payback'] : dic['loan.mint'],
        content: Text('${tx.amountDebit} $acala_stable_coin_view',
            style: amountStyle),
      ));
    }

    String? networkName = plugin.basic.name;
    if (plugin.basic.isTestNet) {
      networkName = '${networkName!.split('-')[0]}-testnet';
    }
    return PluginTxDetail(
      success: tx.isSuccess,
      action: dic['loan.${tx.actionType}'],
      // blockNum: int.parse(tx.block),
      hash: tx.hash,
      blockTime:
          Fmt.dateTime(DateFormat("yyyy-MM-ddTHH:mm:ss").parse(tx.time, true)),
      networkName: networkName,
      infoItems: items,
      current: keyring.current,
    );
  }
}
