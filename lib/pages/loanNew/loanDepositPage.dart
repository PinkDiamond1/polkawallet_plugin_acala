import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_acala/common/constants/index.dart';
import 'package:polkawallet_plugin_acala/pages/swap/bootstrapPage.dart';
import 'package:polkawallet_plugin_acala/polkawallet_plugin_acala.dart';
import 'package:polkawallet_plugin_acala/utils/assets.dart';
import 'package:polkawallet_plugin_acala/utils/format.dart';
import 'package:polkawallet_plugin_acala/utils/i18n/index.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginButton.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginInputBalance.dart';
import 'package:polkawallet_ui/components/v3/plugin/pluginScaffold.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class LoanDepositPage extends StatefulWidget {
  LoanDepositPage(this.plugin, this.keyring);
  final PluginAcala plugin;
  final Keyring keyring;

  static const String route = '/acala/loan/deposit';
  static const String actionTypeDeposit = 'deposit';
  static const String actionTypeWithdraw = 'withdraw';

  @override
  _LoanDepositPageState createState() => _LoanDepositPageState();
}

class LoanDepositPageParams {
  LoanDepositPageParams(this.actionType, this.token);
  final String actionType;
  final TokenBalanceData token;
}

class _LoanDepositPageState extends State<LoanDepositPage> {
  TokenBalanceData? _token;

  final TextEditingController _amountCtrl = new TextEditingController();

  BigInt _amountCollateral = BigInt.zero;

  String? _error1;

  void _onAmount1Change(
    String value,
    BigInt? price,
    int? stableCoinDecimals,
    int? collateralDecimals, {
    required BigInt available,
    BigInt? max,
  }) {
    String v = value.trim();
    if (v.isEmpty) return;

    BigInt collateral =
        max != null ? max : Fmt.tokenInt(v, collateralDecimals!);
    setState(() {
      _amountCollateral = collateral;
    });

    if (max == null) {
      var error = _validateAmount1(value, collateralDecimals, available);
      setState(() {
        _error1 = error;
      });
    }
  }

  String? _validateAmount1(
      String value, int? collateralDecimals, BigInt available) {
    final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'common');

    final error = Fmt.validatePrice(value, context);
    if (error != null) {
      return error;
    }
    if (Fmt.tokenInt(value, collateralDecimals!) > available) {
      return dic!['amount.low'];
    }
    return null;
  }

  Future<Map> _getTxParams(int? stableCoinDecimals) async {
    final LoanDepositPageParams params =
        ModalRoute.of(context)!.settings.arguments as LoanDepositPageParams;
    final dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala');
    switch (params.actionType) {
      case LoanDepositPage.actionTypeDeposit:
        return {
          'detail': {
            dic!['loan.deposit']: Text(
              '${_amountCtrl.text.trim()} ${PluginFmt.tokenView(params.token.symbol)}',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(color: Colors.white),
            ),
          },
          'params': [
            params.token.currencyId,
            _amountCollateral.toString(),
            0,
          ]
        };
      case LoanDepositPage.actionTypeWithdraw:
        return {
          'detail': {
            dic!['loan.withdraw']: Text(
              '${_amountCtrl.text.trim()} ${PluginFmt.tokenView(params.token.symbol)}',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(color: Colors.white),
            ),
          },
          'params': [
            params.token.currencyId,
            (BigInt.zero - _amountCollateral).toString(),
            0,
          ]
        };
      default:
        return {};
    }
  }

  Future<void> _onSubmit(String title, int? stableCoinDecimals) async {
    print("_onSubmit");
    final params = await _getTxParams(stableCoinDecimals);
    print(params);
    if (params == null) return null;

    final res = (await Navigator.of(context).pushNamed(TxConfirmPage.route,
        arguments: TxConfirmParams(
          module: 'honzon',
          call: 'adjustLoan',
          txTitle: title,
          txDisplayBold: params['detail'],
          params: params['params'],
          isPlugin: true,
        ))) as Map?;
    if (res != null) {
      Navigator.of(context).pop(res);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final LoanDepositPageParams params =
          ModalRoute.of(context)!.settings.arguments as LoanDepositPageParams;

      final loan = widget.plugin.store!.loan.loans[params.token.tokenNameId];
      setState(() {
        _amountCollateral = loan?.collaterals ?? BigInt.zero;
        _token = params.token;
      });
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'acala')!;
    var assetDic = I18n.of(context)!.getDic(i18n_full_dic_acala, 'common');

    final LoanDepositPageParams params =
        ModalRoute.of(context)!.settings.arguments as LoanDepositPageParams;
    final token = _token ?? params.token;

    final balancePair = AssetsUtils.getBalancePairFromTokenNameId(
        widget.plugin, [token.tokenNameId, acala_stable_coin]);

    final tokenOptions =
        widget.plugin.store!.loan.loanTypes.map((e) => e.token).toList();
    tokenOptions.retainWhere((e) {
      final incentive = widget.plugin.store!.earn.incentives.loans;
      return incentive != null &&
          incentive[e?.tokenNameId] != null &&
          (incentive[e?.tokenNameId]![0].amount ?? 0) > 0;
    });

    final loan = widget.plugin.store!.loan.loans[token.tokenNameId];
    final price = widget.plugin.store!.assets.prices[token.tokenNameId];

    final symbolView = PluginFmt.tokenView(token.symbol);
    String titleSuffix = ' $symbolView';

    final BigInt balance = Fmt.balanceInt(balancePair[0]!.amount);
    BigInt available = balance;

    if (params.actionType == LoanDepositPage.actionTypeWithdraw) {
      // max to withdraw
      if (loan == null) {
        available = widget.plugin.store!.loan
                .collateralRewards[token.tokenNameId]?.shares ??
            BigInt.zero;
      } else {
        available = loan.collaterals - loan.requiredCollateral > BigInt.zero
            ? loan.collaterals - loan.requiredCollateral
            : BigInt.zero;
      }
    }

    final availableView = Fmt.priceFloorBigInt(
        available, balancePair[0]!.decimals!,
        lengthMax: 8);

    final pageTitle = '${dic['loan.${params.actionType}']}$titleSuffix';

    return PluginScaffold(
      appBar: PluginAppBar(
        title: Text(pageTitle),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                  child: ListView(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                children: <Widget>[
                  PluginInputBalance(
                    tokenViewFunction: (value) {
                      return PluginFmt.tokenView(value);
                    },
                    titleTag: dic['loan.${params.actionType}'],
                    balance: TokenBalanceData(
                        symbol: balancePair[0]!.symbol,
                        decimals: balancePair[0]!.decimals!,
                        amount: available.toString()),
                    tokenIconsMap: widget.plugin.tokenIcons,
                    onSetMax: (params.actionType ==
                                LoanDepositPage.actionTypeDeposit &&
                            token.symbol ==
                                widget.plugin.networkState.tokenSymbol![0])
                        ? null
                        : (max) {
                            {
                              setState(() {
                                _amountCollateral = max;
                                _amountCtrl.text = Fmt.bigIntToDouble(
                                        max, balancePair[0]!.decimals!)
                                    .toString();
                              });
                              _onAmount1Change(
                                availableView,
                                price,
                                balancePair[1]!.decimals,
                                balancePair[0]!.decimals,
                                available: max,
                                max: max,
                              );
                            }
                          },
                    onClear: () {
                      setState(() {
                        _amountCollateral = BigInt.zero;
                        _amountCtrl.text = "0";
                      });
                      _onAmount1Change("0", price, balancePair[1]!.decimals,
                          balancePair[0]!.decimals,
                          available: available);
                    },
                    inputCtrl: _amountCtrl,
                    onInputChange: (v) => _onAmount1Change(v, price,
                        balancePair[1]!.decimals, balancePair[0]!.decimals,
                        available: available),
                  ),
                  ErrorMessage(_error1,
                      margin: EdgeInsets.symmetric(vertical: 2)),
                ],
              )),
              Padding(
                padding: EdgeInsets.all(16),
                child: PluginButton(
                  title: I18n.of(context)!
                      .getDic(i18n_full_dic_ui, 'common')!['tx.submit']!,
                  onPressed: () {
                    if (_error1 == null) {
                      _onSubmit(pageTitle, balancePair[1]!.decimals);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}