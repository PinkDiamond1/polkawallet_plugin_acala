// graphql query
const transferQuery = r'''
  query ($account: String, $token: String) {
    transfers(filter: {
      isSystemCall:{equalTo:false},
      tokenId: {equalTo: $token},
      or: [
        { fromId: { equalTo: $account } },
        { toId: { equalTo: $account } }
      ]
    }, first: 20, orderBy: TIMESTAMP_DESC) {
      nodes {
        id
        fromId
        toId
        blockId
        amount
        extrinsicId
        timestamp
      }
    }
  }
''';
const loanQuery = r'''  
  query ($account: String) {
   updatePositions(first:20,orderBy: TIMESTAMP_DESC, filter: {ownerId: {equalTo: $account}}) {
          nodes{
            collateralId
            collateralAdjustment
            debitAdjustment
            timestamp
            extrinsicId
            debitExchangeRate
            extrinsic {
              method
            }
          }
        }
}
''';
const swapQuery = r'''
  query ($account: String) {
    dexActions(filter: {accountId: {equalTo: $account}},
      orderBy: TIMESTAMP_DESC, first: 20) {
      nodes {
        id
        type
        data
        timestamp
        extrinsic {
          id
          method
          isSuccess
        }
      }
    }
  }
''';
const dexStakeQuery = r'''
  query ($account: String) {
    incentiveActions(filter: {accountId: {equalTo: $account}},
      orderBy: TIMESTAMP_DESC, first: 20) {
      nodes {
        id
        type
        data
        timestamp
        extrinsic {
          id
          method
          isSuccess
        }
      }
    }
  }
''';
const homaQuery = r'''
  query ($account: String) {
    homaActions(filter: {accountId: {equalTo: $account}},
      orderBy: TIMESTAMP_DESC, first: 20) {
      nodes {
        id
        type
        data
        timestamp
        extrinsic {
          id
          method
          timestamp
          isSuccess
        }
      }
    }
  }
''';

const queryPoolDetail = r'''
  query ($pool: String) {
    pools(filter: {id: {equalTo: $pool}}) {
      nodes {
        id,
        token0 {id,decimal, name }
        token1 {id,decimal, name }
        token0Amount
        token1Amount
        tvlUSD
        dayData(orderBy:DATE_DESC,first:30) {
          nodes {
            id
            date
            tvlUSD
            volumeUSD
          }
        }
      }

    }
  }
''';

const multiplyQuery = r'''
query ($senderId: String) {
    extrinsics(filter: {
      section :{equalTo :"honzon"},
      or:[{method:{equalTo:"expandPositionCollateral"}}, {method:{equalTo:"shrinkPositionDebit"}}],
      senderId: {equalTo: $senderId}},
      first: 20,orderBy:BLOCK_ID_DESC) {
      nodes {
        id
        method
        section
        updatePositions {
          nodes{
            collateralId
            collateralAdjustment
            debitAdjustment
            timestamp
            extrinsicId
            debitExchangeRate
          }
        }
      }
    }
}
''';
