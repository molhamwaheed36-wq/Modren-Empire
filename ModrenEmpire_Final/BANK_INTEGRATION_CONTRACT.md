# Bank Integration Contract

This project contains only a virtual in-game ledger. It does not create real money, process payments, use blockchain, or transmit financial credentials.

The local provider is `LOCAL_VIRTUAL_BANK`. It registers `MECR` (2 decimals) and `MECOIN` (8 decimals), stores local accounts, validates amounts, and creates transaction IDs. Current game operations are deposit, withdraw and record transfer.

A future provider may implement `createAccount`, `getBalance`, `deposit`, `withdraw`, `transfer`, `getTransactionHistory`, `registerCurrency`, `lockFunds`, `unlockFunds` and `validateTransaction`. It must be injected behind this boundary; the game economy must continue to use virtual transaction commands and never receive raw payment credentials.
