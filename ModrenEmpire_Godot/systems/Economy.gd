extends Node

func price_elasticity(price: float, reference: float = 699.0) -> float:
    return clamp(pow(reference/max(price,1.0),0.65),0.25,2.2)

func company_value() -> float:
    var s=Game.state
    return max(0.0,float(s.company.cash)-float(s.company.debt)) + float(s.product.quality)*2500.0 + float(s.company.reputation)*10000.0 + float(s.factory.capacity)*20.0
