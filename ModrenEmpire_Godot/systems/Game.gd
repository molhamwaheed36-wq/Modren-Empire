extends Node

signal changed
signal log_added(message)

const SAVE_VERSION := 4
var rng := RandomNumberGenerator.new()
var state: Dictionary

func _ready() -> void:
    rng.randomize()
    new_game()

func new_game() -> void:
    state = {
        "version": SAVE_VERSION, "month": 1, "year": 1, "day": 1,
        "company": {"name":"Modren Technologies", "ceo":"MOLHAM WAHEED", "cash":100000.0, "debt":0.0, "reputation":50.0, "level":1, "xp":0.0},
        "product": {"name":"Modren One", "generation":1, "price":699.0, "quality":50.0, "appeal":50.0, "inventory":0, "sold":0, "made":0,
            "components":{"cpu":1,"gpu":1,"npu":1,"display":1,"camera":1,"battery":1,"ram":1,"storage":1,"connectivity":1,"os":1,"materials":1}},
        "research": {}, "factory":{"capacity":1000,"efficiency":0.70,"plants":1,"queue":0},
        "staff":[], "suppliers":[], "markets":{}, "competitors":{}, "marketing":[], "patents":[], "projects":[], "events":[],
        "wallet":{"MECR":0.0,"MECOIN":0.0,"locked":0.0},
        "bank":{"provider":"LOCAL_VIRTUAL_BANK","accounts":[],"transactions":[]},
        "settings":{"speed":1.0,"autosave":true,"sound":true},
        "director":{"name":"MOLHAM WAHEED","role":"GAME_DIRECTOR","permissions":["*"]},
        "lan":{"mode":"offline","host":false,"connected":false,"session":""},
        "stats":{"units_total":0,"revenue":0.0,"expenses":0.0,"profit":0.0,"market_share":0.0}
    }
    _seed_data()
    changed.emit()

func _seed_data() -> void:
    var research_names = ["cpu","gpu","npu","display","camera","battery","ram","storage","connectivity","os","manufacturing","marketing","ai","materials","network"]
    for key in research_names: state.research[key] = 0
    state.staff = [
        {"id":1,"name":"A. Engineer","role":"Engineer","skill":72,"salary":2400,"morale":85,"exp":2},
        {"id":2,"name":"R. Researcher","role":"Researcher","skill":78,"salary":2700,"morale":82,"exp":3},
        {"id":3,"name":"S. Manager","role":"Manager","skill":68,"salary":3100,"morale":88,"exp":4}
    ]
    state.suppliers = [
        {"id":1,"name":"Nova Silicon","component":"CPU/GPU/NPU","price":120,"reliability":0.94,"contract":12},
        {"id":2,"name":"VisionGlass","component":"Display","price":85,"reliability":0.91,"contract":12},
        {"id":3,"name":"PowerCell","component":"Battery","price":35,"reliability":0.96,"contract":12}
    ]
    state.markets = {
        "Syria":{"unlocked":true,"demand":1.0,"purchasing":0.65,"competition":0.45,"share":0.0},
        "Germany":{"unlocked":false,"demand":0.9,"purchasing":1.35,"competition":0.75,"share":0.0},
        "France":{"unlocked":false,"demand":0.82,"purchasing":1.25,"competition":0.72,"share":0.0},
        "USA":{"unlocked":false,"demand":1.2,"purchasing":1.5,"competition":0.92,"share":0.0}
    }
    state.competitors = {
        "Nova Mobile":{"tech":55.0,"price":649.0,"marketing":60.0,"share":34.0},
        "Vertex":{"tech":68.0,"price":799.0,"marketing":75.0,"share":28.0},
        "Orion Tech":{"tech":48.0,"price":499.0,"marketing":55.0,"share":22.0}
    }

func add_log(message: String) -> void:
    state.events.push_front({"time":"Y%d M%d D%d" % [state.year,state.month,state.day],"message":message})
    if state.events.size() > 100: state.events.pop_back()
    log_added.emit(message)
    changed.emit()

func tick_month() -> void:
    var months_passed := 1
    for i in months_passed:
        state.month += 1
        if state.month > 12: state.month = 1; state.year += 1
    var salary_cost := 0.0
    for e in state.staff:
        salary_cost += float(e.salary)
        e.morale = clamp(float(e.morale) + rng.randf_range(-2.0,2.0), 0.0, 100.0)
        e.exp += 1
    var production: int = int(min(int(state.factory.capacity * state.factory.efficiency * max(1,state.factory.plants)), 10000))
    var demand_score := _demand_score()
    var sold: int = int(min(int(state.product.inventory) + production, int(80.0 * demand_score)))
    var unit_cost := _unit_cost()
    var revenue: float = float(sold) * float(state.product.price)
    var production_cost: float = float(production) * unit_cost
    state.product.made += production
    state.product.inventory += production - sold
    state.product.sold += sold
    state.company.cash += revenue - production_cost - salary_cost
    state.stats.revenue += revenue
    state.stats.expenses += production_cost + salary_cost
    state.stats.profit += revenue - production_cost - salary_cost
    state.stats.units_total += sold
    state.stats.market_share = clamp(state.stats.market_share + sold / 1000.0, 0.0, 100.0)
    state.company.xp += sold * 0.05 + max(0.0, revenue-production_cost)*0.0001
    _level_check()
    _random_event()
    add_log("Month closed: %d units sold, revenue %.0f" % [sold,revenue])

func _demand_score() -> float:
    var quality = float(state.product.quality)
    var appeal = float(state.product.appeal)
    var reputation = float(state.company.reputation)
    var marketing = 0.0
    for m in state.marketing: marketing += float(m.get("power",0))
    var price_factor = clamp(900.0 / max(200.0,float(state.product.price)),0.45,1.5)
    return clamp((quality*0.38 + appeal*0.25 + reputation*0.20 + marketing*0.12 + float(state.research["os"])*1.0)*price_factor/55.0,0.2,5.0)

func _unit_cost() -> float:
    var c := 170.0
    for value in state.product.components.values(): c += float(value)*2.7
    c *= (1.12 - float(state.factory.efficiency)*0.20)
    return c

func research(key: String) -> bool:
    if not state.research.has(key): return false
    var lvl := int(state.research[key])
    var cost := 5000.0 + lvl * 6500.0
    if state.company.cash < cost: return false
    var researcher_power := 0.0
    for e in state.staff: if e.role == "Researcher" or e.role == "Engineer": researcher_power += float(e.skill)
    if researcher_power < 50.0 and lvl > 0: return false
    state.company.cash -= cost
    state.research[key] = lvl + 1
    state.company.xp += 100
    _level_check()
    add_log("Research advanced: %s -> level %d" % [key,lvl+1])
    return true

func apply_research(key: String) -> bool:
    if not state.research.has(key): return false
    var lvl := int(state.research[key])
    if lvl <= 0: return false
    if not state.product.components.has(key): return false
    state.product.components[key] = lvl
    state.product.quality = clamp(float(state.product.quality)+lvl*1.5,0,100)
    state.product.appeal = clamp(float(state.product.appeal)+lvl*0.8,0,100)
    add_log("Applied %s technology to current product" % key)
    return true

func develop_next_generation() -> bool:
    var cost := 25000.0 + int(state.product.generation)*15000.0
    if state.company.cash < cost: return false
    state.company.cash -= cost
    state.product.generation += 1
    state.product.name = "Modren %s" % _roman(state.product.generation)
    state.product.quality = clamp(state.product.quality+4,0,100)
    state.product.appeal = clamp(state.product.appeal+3,0,100)
    state.product.inventory = 0
    add_log("New product generation launched: %s" % state.product.name)
    return true

func manufacture(amount: int) -> bool:
    amount = clamp(amount,1,100000)
    var available := int(state.factory.capacity * state.factory.efficiency * max(1,state.factory.plants))
    if amount > available: amount = available
    var cost := amount * _unit_cost()
    if state.company.cash < cost: return false
    state.company.cash -= cost
    state.product.made += amount
    state.product.inventory += amount
    state.factory.queue += amount
    state.stats.expenses += cost
    add_log("Manufactured %d units" % amount)
    return true

func hire(name: String, role: String, skill: int) -> bool:
    var salary := 1800.0 + skill*25.0
    if state.company.cash < salary: return false
    state.company.cash -= salary
    state.staff.append({"id":Time.get_ticks_msec(),"name":name,"role":role,"skill":skill,"salary":salary,"morale":80,"exp":0})
    add_log("Hired %s as %s" % [name,role])
    return true

func upgrade_factory() -> bool:
    var cost: float = 20000.0 * (1.0 + float(state.factory.plants)*0.55)
    if state.company.cash < cost: return false
    state.company.cash -= cost
    state.factory.plants += 1
    state.factory.capacity += 700
    state.factory.efficiency = clamp(state.factory.efficiency+0.04,0.4,0.99)
    add_log("Factory upgraded: %d plants" % state.factory.plants)
    return true

func unlock_market(name: String) -> bool:
    if not state.markets.has(name) or state.markets[name].unlocked: return false
    var cost: float = float({"Germany":50000.0,"France":65000.0,"USA":100000.0}.get(name,50000.0))
    if state.company.cash < cost: return false
    state.company.cash -= cost
    state.markets[name].unlocked = true
    add_log("Market unlocked: %s" % name)
    return true

func marketing_campaign(name: String, budget: float) -> bool:
    if state.company.cash < budget or budget < 1000: return false
    state.company.cash -= budget
    var power := sqrt(budget) * 0.9
    state.marketing.append({"name":name,"budget":budget,"power":power,"months":3})
    state.company.reputation = clamp(state.company.reputation + min(8.0,power/20.0),0,100)
    add_log("Marketing campaign launched: %s" % name)
    return true

func take_loan(amount: float) -> bool:
    if amount <= 0: return false
    state.company.cash += amount
    state.company.debt += amount*1.12
    add_log("Emergency credit line: %.0f" % amount)
    return true

func patent(name: String, field: String) -> bool:
    var cost := 15000.0
    if state.company.cash < cost: return false
    state.company.cash -= cost
    state.patents.append({"name":name,"field":field,"year":state.year})
    state.company.reputation = clamp(state.company.reputation+2,0,100)
    add_log("Patent registered: %s" % name)
    return true

func _random_event() -> void:
    if rng.randf() > 0.38: return
    var events = [
        ["Component shortage", -9000.0, "Supply chain disruption increased costs."],
        ["Tech breakthrough", 12000.0, "A breakthrough improved your next cycle."],
        ["Positive review", 0.0, "A major review increased brand reputation."],
        ["Competitor price war", -6000.0, "Competitors lowered prices."],
        ["New demand wave", 15000.0, "Demand surged this month."]
    ]
    var e = events[rng.randi_range(0,events.size()-1)]
    state.company.cash += e[1]
    if e[0] == "Positive review": state.company.reputation = clamp(state.company.reputation+5,0,100)
    if e[0] == "New demand wave": state.company.reputation = clamp(state.company.reputation+2,0,100)
    add_log("Event: %s — %s" % [e[0],e[2]])

func _level_check() -> void:
    var target: float = float(state.company.level) * 250.0
    while state.company.xp >= target:
        state.company.xp -= target
        state.company.level += 1
        state.company.reputation = clamp(state.company.reputation+1,0,100)
        target = state.company.level * 250.0
        add_log("Company level increased to %d" % state.company.level)

func _roman(n:int)->String:
    var vals=[1000,900,500,400,100,90,50,40,10,9,5,4,1]
    var syms=["M","CM","D","CD","C","XC","L","XL","X","IX","V","IV","I"]
    var out=""
    for i in vals.size():
        while n >= vals[i]: out += syms[i]; n -= vals[i]
    return out
