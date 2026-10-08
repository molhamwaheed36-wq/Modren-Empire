# Bank / Currency Integration Contract

Future adapter methods: create_account, get_balance, deposit, withdraw, transfer, transaction_history, register_currency, lock_funds, unlock_funds.

Game currencies are abstract. MECR and MECOIN can be mapped to a future provider without changing the game economy API. External services must authenticate independently and must never receive game-director credentials.
