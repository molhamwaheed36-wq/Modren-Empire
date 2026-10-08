extends Node

var provider := "LOCAL_VIRTUAL_BANK"

func create_account(player_id:String, currency:String)->Dictionary:
    var id="ACC-%s-%s" % [player_id, currency]
    Game.state.bank.accounts.append({"id":id,"player":player_id,"currency":currency,"balance":0.0})
    return {"ok":true,"account_id":id}

func deposit(account_id:String, amount:float, currency:String)->Dictionary:
    if amount <= 0: return {"ok":false,"error":"invalid_amount"}
    for a in Game.state.bank.accounts:
        if a.id == account_id and a.currency == currency:
            a.balance += amount
            Game.state.bank.transactions.append({"id":"TX-%d"%Time.get_ticks_msec(),"type":"deposit","amount":amount,"currency":currency})
            return {"ok":true,"balance":a.balance}
    return {"ok":false,"error":"account_not_found"}

func withdraw(account_id:String, amount:float, currency:String)->Dictionary:
    for a in Game.state.bank.accounts:
        if a.id == account_id and a.currency == currency and a.balance >= amount:
            a.balance -= amount
            Game.state.bank.transactions.append({"id":"TX-%d"%Time.get_ticks_msec(),"type":"withdraw","amount":amount,"currency":currency})
            return {"ok":true,"balance":a.balance}
    return {"ok":false,"error":"insufficient_or_missing"}

func transfer(from_id:String,to_id:String,amount:float,currency:String,reference:String="")->Dictionary:
    var w=withdraw(from_id,amount,currency)
    if not w.ok: return w
    var d=deposit(to_id,amount,currency)
    if not d.ok: deposit(from_id,amount,currency)
    return d
