import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polkawallet_plugin_acala/common/constants/index.dart';
import 'package:polkawallet_plugin_acala/pages/swapNew/bootstrapPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/assets.dart';
import 'package:polkawallet_plugin_acala/utils/format.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputBalance.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginLoadingWidget.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';

class MintPage extends StatefulWidget {
  MintPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/homa/mint';

  @override
  _MintPageState createState() => _MintPageState();
}

class _MintPageState extends State<MintPage> {
  final TextEditingController _amountPayCtrl = new TextEditingController();

  String? _error;
  String _amountReceive = '';
  BigInt? _maxInput;
  bool isLoading = false;

  Future<void> _updateReceiveAmount(double input) async {
    if (input == 0) {
      return null;
    }
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      var data = await widget.plugin.api!.homa.calcHomaNewMintAmount(input);

      setState(() {
        isLoading = false;
        _amountReceive = "${data!['receive']}";
      });
    }
  }

  void _onSupplyAmountChange(String v, double balance, double minStake) {
    final supply = v.trim();
    setState(() {
      _maxInput = null;
    });

    final error = _validateInput(supply, balance, minStake);
    setState(() {
      _error = error;
      // if (error != null) {
      //   _amountReceive = '';
      // }
    });
    if (error != null) {
      return;
    }
    _updateReceiveAmount(double.parse(supply));
  }

  String? _validateInput(String supply, double balance, double minStake) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'common');
    final error = Fmt.validatePrice(supply, context);
    if (error != null) {
      return error;
    }
    final pay = double.parse(supply);
    if (_maxInput == null && pay > balance) {
      return dic!['amount.low'];
    }

    if (pay < minStake) {
      final minLabel = I18n.of(context)!
          .getDic(i18n_full_dic_acala, 'acala')!['homa.pool.min'];
      return '$minLabel   ${minStake.toStringAsFixed(4)}';
    }

    final homaEnv = widget.plugin.store!.homa.env!;
    if (double.tryParse(supply)! + homaEnv.totalStaking >
        homaEnv.stakingSoftCap!) {
      return I18n.of(context)!
          .getDic(i18n_full_dic_acala, 'acala')!['homa.pool.cap.error'];
    }

    return error;
  }

  void _onSetMax(BigInt max, int decimals, double balance, double minStake) {
    final homaEnv = widget.plugin.store!.homa.env!;
    final staked = Fmt.tokenInt(homaEnv.totalStaking.toString(), decimals);
    final cap = Fmt.tokenInt(homaEnv.stakingSoftCap.toString(), decimals);
    if (staked + max > cap) {
      max = cap - staked;
    }

    final amount = Fmt.bigIntToDouble(max, decimals);
    setState(() {
      _amountPayCtrl.text = amount.toStringAsFixed(6);
      _maxInput = max;
      _error = _validateInput(amount.toString(), balance, minStake);
    });

    if (_error == null) {
      _updateReceiveAmount(amount);
    }
  }

  Future<void> _onSubmit(int stakeDecimal, int liquidDecimals) async {
    final pay = _amountPayCtrl.text.trim();

    if (_error != null || pay.isEmpty) return;

    final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala')!;

    final amount = _maxInput != null
        ? _maxInput.toString()
        : Fmt.tokenInt(pay, stakeDecimal).toString();

    final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          module: 'homa',
          call: 'mint',
          txTitle: '${dic['homa.mint']} L$relay_chain_token_symbol',
          txDisplay: {},
          txDisplayBold: {
            dic['dex.pay']!: Text(
              '$pay $relay_chain_token_symbol',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(color: Colors.white),
            ),
            dic['dex.receive']!: Text(
              '≈ ${Fmt.priceFloorBigInt(Fmt.balanceInt(_amountReceive), liquidDecimals, lengthMax: 4)} L$relay_chain_token_symbol',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(color: Colors.white),
            ),
          },
          params: [amount],
          isPlugin: true,
        ))) as Map?;

    if (res != null) {
      Navigator.of(context)
          .pop('${Fmt.balanceDouble(_amountReceive, liquidDecimals)}');
    }
  }

  @override
  void dispose() {
    _amountPayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(_) {
    return Observer(
      builder: (BuildContext context) {
        final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala')!;

        final balances = AssetsUtils.getBalancePairFromTokenNameId(
            widget.plugin,
            [relay_chain_token_symbol, 'L$relay_chain_token_symbol']);
        final stakeDecimals = balances[0].decimals ?? 12;
        final liquidDecimals = balances[1].decimals ?? 12;

        final decimals = widget.plugin.networkState.tokenDecimals!;
        final karBalance = Fmt.balanceDouble(
            widget.plugin.balances.native!.availableBalance.toString(),
            decimals[0]);

        final balanceDouble = Fmt.balanceDouble(
            balances[0].amount ?? "0", balances[0].decimals ?? 12);

        final minStake = widget.plugin.store!.homa.env!.mintThreshold;

        return PluginScaffold(
          appBar: PluginAppBar(
              title: Text('${dic['homa.mint']} L$relay_chain_token_symbol'),
              centerTitle: true),
          body: SafeArea(
              child: ListView(
            padding: EdgeInsets.all(16),
            children: <Widget>[
              PluginInputBalance(
                tokenViewFunction: (value) {
                  return PluginFmt.tokenView(value);
                },
                inputCtrl: _amountPayCtrl,
                margin: EdgeInsets.only(bottom: 2),
                titleTag: dic['earn.stake'],
                onInputChange: (v) =>
                    _onSupplyAmountChange(v, balanceDouble, minStake),
                onSetMax: karBalance > 0.1
                    ? (v) =>
                        _onSetMax(v, stakeDecimals, balanceDouble, minStake)
                    : null,
                onClear: () {
                  setState(() {
                    _amountPayCtrl.text = '';
                  });
                  _onSupplyAmountChange('', balanceDouble, minStake);
                },
                balance: balances[0],
                tokenIconsMap: widget.plugin.tokenIcons,
              ),
              ErrorMessage(
                _error,
                margin: EdgeInsets.symmetric(vertical: 2),
              ),
              Visibility(visible: isLoading, child: PluginLoadingWidget()),
              Visibility(
                  visible: _amountReceive.isNotEmpty &&
                      _amountPayCtrl.text.length > 0,
                  child: PluginInputBalance(
                    tokenViewFunction: (value) {
                      return PluginFmt.tokenView(value);
                    },
                    enabled: false,
                    text: Fmt.priceFloorBigInt(
                        Fmt.balanceInt(_amountReceive), liquidDecimals,
                        lengthMax: 4),
                    margin: EdgeInsets.only(bottom: 2),
                    titleTag: dic['homa.mint'],
                    balance: widget.plugin.store!.assets
                        .tokenBalanceMap["L$relay_chain_token_symbol"],
                    tokenIconsMap: widget.plugin.tokenIcons,
                  )),
              Container(
                margin: EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dic['v3.homa.minStakingAmount']!,
                      style: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "$minStake $relay_chain_token_symbol",
                      style: Theme.of(context).textTheme.headline4?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 160, bottom: 32),
                  child: PluginButton(
                    title: dic['v3.loan.submit']!,
                    onPressed: () => _onSubmit(stakeDecimals, liquidDecimals),
                  ))
            ],
          )),
        );
      },
    );
  }
}
