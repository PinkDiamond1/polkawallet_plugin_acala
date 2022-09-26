import 'package:mobx/mobx.dart';
import 'package:polkawallet_plugin_acala/store/cache/storeCache.dart';

part 'setting.g.dart';

class SettingStore extends _SettingStore with _$SettingStore {
  SettingStore(StoreCache? cache) : super(cache);
}

abstract class _SettingStore with Store {
  _SettingStore(this.cache);

  final StoreCache? cache;

  @observable
  Map liveModules = Map();

  Map remoteConfig = {
    "modules": {
      "assets": {"visible": true, "enabled": true},
      "multiply": {"visible": true, "enabled": true},
      "loan": {"visible": true, "enabled": true},
      "swap": {"visible": true, "enabled": true},
      "earn": {"visible": true, "enabled": true},
      "homa": {"visible": true, "enabled": true},
      "nft": {"visible": true, "enabled": true}
    },
    "tokens": {
      "default": ["AUSD", "DOT", "LDOT"],
      "xcm": {
        "ACA": ["parallel", "moonbeam"],
        "DOT": ["polkadot"],
        "AUSD": ["parallel", "moonbeam"],
        "LDOT": ["parallel"],
        "fa://0": ["moonbeam"],
        "fa://1": ["parallel"]
      },
      "xcmFrom": {
        "DOT": ["polkadot"],
        "ACA": ["parallel"],
        "AUSD": ["parallel"],
        "LDOT": ["parallel"],
        "fa://1": ["parallel"]
      },
      "xcmInfo": {
        "polkadot": {
          "DOT": {
            "fee": "482771104",
            "receiveFee": "4285630",
            "existentialDeposit": "10000000000"
          }
        },
        "parallel": {
          "PARA": {
            "fee": "9600000000",
            "receiveFee": "6400000000",
            "existentialDeposit": "100000000000"
          },
          "ACA": {
            "fee": "1920000000",
            "receiveFee": "6400000000",
            "existentialDeposit": "100000000000"
          },
          "AUSD": {
            "fee": "2880000000",
            "receiveFee": "3721109059",
            "existentialDeposit": "100000000000"
          },
          "LDOT": {
            "fee": "96000000",
            "receiveFee": "24037893",
            "existentialDeposit": "500000000"
          }
        },
        "moonbeam": {
          "GLMR": {
            "fee": "8000000000000000",
            "receiveFee": "6400000000000000",
            "existentialDeposit": "100000000000000000"
          },
          "ACA": {
            "fee": "24963428577",
            "receiveFee": "6400000000",
            "existentialDeposit": "100000000000"
          },
          "AUSD": {
            "fee": "2000000000",
            "receiveFee": "3721109059",
            "existentialDeposit": "100000000000"
          }
        }
      },
      "xcmChains": {
        "acala": {"id": "2000", "nativeToken": "ACA", "ss58": 10},
        "polkadot": {"id": "0", "nativeToken": "DOT", "ss58": 0},
        "statemint": {"id": "1000", "nativeToken": "DOT", "ss58": 0},
        "parallel": {"id": "2012", "nativeToken": "PARA", "ss58": 172},
        "moonbeam": {"id": "2004", "nativeToken": "GLMR", "ss58": 1284}
      },
      "invisible": [],
      "disabled": []
    }
  };

  @action
  void setLiveModules(Map value) {
    liveModules = value;
  }

  void setRemoteConfig(Map config) {
    remoteConfig = config;
  }
}
