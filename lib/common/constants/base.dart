const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

const plugin_name_acala = 'acala';
const ss58_prefix_acala = 10;

const GraphQLConfig = {
  'httpUri':
      'https://api.subquery.network/sq/AcalaNetwork/acala-transfer-history',
  'defiUri': 'https://api.subquery.network/sq/AcalaNetwork/acala',
  'loanUri': 'https://api.subquery.network/sq/AcalaNetwork/acala-loans'
};
