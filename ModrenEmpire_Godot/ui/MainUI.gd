extends Control

# Modren Empire - premium management UI
# Designed for desktop preview and Android touch export.

var content: VBoxContainer
var page_title: Label
var subtitle: Label
var cash_label: Label
var debt_label: Label
var level_label: Label
var reputation_label: Label
var toast: Label
var active_tab := "Dashboard"
var nav_buttons: Dictionary = {}

const BG := Color("0A0F19")
const PANEL := Color("111A29")
const PANEL_2 := Color("162235")
const BORDER := Color("263852")
const TEXT := Color("EAF2FF")
const MUTED := Color("8EA3BD")
const ACCENT := Color("58B7FF")
const GREEN := Color("4ADE9A")
const GOLD := Color("F6C85F")
const RED := Color("FF6B7A")

func build(_owner: Node) -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_PASS
    _build_background()
    _build_shell()
    _select_tab("Dashboard")
    Game.changed.connect(_refresh)
    _refresh()

func _build_background() -> void:
    var bg := ColorRect.new()
    bg.color = BG
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)
    move_child(bg, 0)

func _build_shell() -> void:
    var root := HBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 0)
    add_child(root)

    var sidebar := PanelContainer.new()
    sidebar.custom_minimum_size = Vector2(230, 0)
    sidebar.add_theme_stylebox_override("panel", _box(Color("0D1522"), BORDER, 0, 0))
    root.add_child(sidebar)

    var side := VBoxContainer.new()
    side.add_theme_constant_override("separation", 8)
    sidebar.add_child(side)

    var brand := Label.new()
    brand.text = "  MODREN\n  EMPIRE"
    brand.add_theme_font_size_override("font_size", 25)
    brand.add_theme_color_override("font_color", TEXT)
    brand.custom_minimum_size = Vector2(0, 88)
    side.add_child(brand)

    var tag := Label.new()
    tag.text = "  TECHNOLOGY EMPIRE"
    tag.add_theme_font_size_override("font_size", 11)
    tag.add_theme_color_override("font_color", ACCENT)
    side.add_child(tag)

    side.add_child(HSeparator.new())

    for item in ["Dashboard","Company","Product Lab","R&D","Factory","Supply Chain","Staff","Markets","Competitors","Finance","Bank","Events","Game Director","LAN","Settings"]:
        var b := Button.new()
        b.text = "  " + item
        b.alignment = HORIZONTAL_ALIGNMENT_LEFT
        b.custom_minimum_size = Vector2(0, 40)
        b.add_theme_font_size_override("font_size", 14)
        b.add_theme_color_override("font_color", MUTED)
        b.add_theme_stylebox_override("normal", _box(Color("0D1522"), Color("0D1522"), 8, 0))
        b.add_theme_stylebox_override("hover", _box(Color("16263B"), ACCENT, 8, 1))
        b.pressed.connect(_select_tab.bind(item))
        side.add_child(b)
        nav_buttons[item] = b

    var spacer := Control.new()
    spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
    side.add_child(spacer)

    var admin := Label.new()
    admin.text = "  GAME DIRECTOR\n  MOLHAM WAHEED"
    admin.add_theme_color_override("font_color", GOLD)
    admin.add_theme_font_size_override("font_size", 12)
    side.add_child(admin)

    var main_margin := MarginContainer.new()
    main_margin.add_theme_constant_override("margin_left", 24)
    main_margin.add_theme_constant_override("margin_right", 24)
    main_margin.add_theme_constant_override("margin_top", 20)
    main_margin.add_theme_constant_override("margin_bottom", 18)
    main_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    root.add_child(main_margin)

    var main := VBoxContainer.new()
    main.add_theme_constant_override("separation", 14)
    main_margin.add_child(main)

    var top := HBoxContainer.new()
    top.custom_minimum_size = Vector2(0, 64)
    main.add_child(top)

    var titles := VBoxContainer.new()
    titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(titles)
    page_title = Label.new()
    page_title.add_theme_font_size_override("font_size", 27)
    page_title.add_theme_color_override("font_color", TEXT)
    titles.add_child(page_title)
    subtitle = Label.new()
    subtitle.add_theme_font_size_override("font_size", 12)
    subtitle.add_theme_color_override("font_color", MUTED)
    titles.add_child(subtitle)

    cash_label = _metric_label("CASH", "0")
    top.add_child(cash_label)
    debt_label = _metric_label("DEBT", "0")
    top.add_child(debt_label)
    level_label = _metric_label("LEVEL", "1")
    top.add_child(level_label)
    reputation_label = _metric_label("REP", "50")
    top.add_child(reputation_label)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    main.add_child(scroll)
    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 14)
    scroll.add_child(content)

    toast = Label.new()
    toast.add_theme_color_override("font_color", GREEN)
    toast.add_theme_font_size_override("font_size", 12)
    main.add_child(toast)

func _metric_label(name:String, value:String) -> Label:
    var l := Label.new()
    l.text = name + "\n" + value
    l.custom_minimum_size = Vector2(92, 54)
    l.add_theme_font_size_override("font_size", 11)
    l.add_theme_color_override("font_color", MUTED)
    return l

func _select_tab(name:String) -> void:
    active_tab = name
    if not is_instance_valid(content): return
    for c in content.get_children(): c.queue_free()
    page_title.text = name
    subtitle.text = "MODREN TECHNOLOGIES  •  Offline Simulation  •  Year %d / Month %d" % [Game.state.year, Game.state.month]
    for key in nav_buttons:
        nav_buttons[key].add_theme_color_override("font_color", ACCENT if key == name else MUTED)
    match name:
        "Dashboard": _dashboard()
        "Company": _company()
        "Product Lab": _product()
        "R&D": _research()
        "Factory": _factory()
        "Supply Chain": _supply()
        "Staff": _staff()
        "Markets": _markets()
        "Competitors": _competitors()
        "Finance": _finance()
        "Bank": _bank()
        "Events": _events()
        "Game Director": _director()
        "LAN": _lan()
        "Settings": _settings()

func _card(title:String, body:String, accent:Color=ACCENT) -> PanelContainer:
    var p := PanelContainer.new()
    p.add_theme_stylebox_override("panel", _box(PANEL, BORDER, 12, 1))
    var m := MarginContainer.new()
    m.add_theme_constant_override("margin_left", 16); m.add_theme_constant_override("margin_right", 16)
    m.add_theme_constant_override("margin_top", 13); m.add_theme_constant_override("margin_bottom", 13)
    p.add_child(m)
    var v := VBoxContainer.new(); v.add_theme_constant_override("separation", 6); m.add_child(v)
    var t := Label.new(); t.text = title.to_upper(); t.add_theme_font_size_override("font_size", 12); t.add_theme_color_override("font_color", accent); v.add_child(t)
    var b := Label.new(); b.text = body; b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; b.add_theme_font_size_override("font_size", 16); b.add_theme_color_override("font_color", TEXT); v.add_child(b)
    return p

func _button(text:String, method:Callable, accent:Color=ACCENT) -> Button:
    var b := Button.new(); b.text = text; b.custom_minimum_size = Vector2(0, 42)
    b.add_theme_font_size_override("font_size", 13); b.add_theme_color_override("font_color", TEXT)
    b.add_theme_stylebox_override("normal", _box(PANEL_2, BORDER, 9, 1))
    b.add_theme_stylebox_override("hover", _box(Color("1C3048"), accent, 9, 1))
    b.add_theme_stylebox_override("pressed", _box(Color("223A55"), accent, 9, 2))
    b.pressed.connect(method); return b

func _row() -> HBoxContainer:
    var r := HBoxContainer.new(); r.add_theme_constant_override("separation", 12); return r

func _dashboard() -> void:
    var s=Game.state; var row=_row(); content.add_child(row)
    row.add_child(_card("Company Value", "$%.0f" % s.company.cash, GREEN)); row.add_child(_card("Product", "%s  •  Gen %d" % [s.product.name,s.product.generation])); row.add_child(_card("Units Sold", "%d" % s.stats.units_total, GOLD)); row.add_child(_card("Reputation", "%.1f / 100" % s.company.reputation, ACCENT))
    content.add_child(_card("Command Center", "Manage products, research, factories, staff, markets and finance from one control surface. Your decisions change the economy.", ACCENT))
    var actions=_row(); content.add_child(actions)
    actions.add_child(_button("Advance Month", func(): Game.tick_month()))
    actions.add_child(_button("Manufacture 100", func(): Game.manufacture(100)))
    actions.add_child(_button("Develop Next Gen", func(): Game.develop_next_generation(), GOLD))
    actions.add_child(_button("Launch Marketing", func(): Game.marketing_campaign("Global Launch",10000), GREEN))
    var recent=Label.new(); recent.text="RECENT ACTIVITY"; recent.add_theme_color_override("font_color",MUTED); content.add_child(recent)
    for e in s.events.slice(0,min(6,s.events.size())): content.add_child(_card(e.time, e.message, MUTED))

func _company() -> void:
    var s=Game.state; content.add_child(_card("Company", "%s\nCEO: %s\nLevel %d  •  XP %.0f\nReputation %.1f" % [s.company.name,s.company.ceo,s.company.level,s.company.xp,s.company.reputation], ACCENT))
    content.add_child(_button("Advance One Month",func():Game.tick_month()))

func _product() -> void:
    var p=Game.state.product; content.add_child(_card("Product Studio", "%s\nGeneration %d\nPrice $%.0f  •  Quality %.1f  •  Appeal %.1f\nInventory %d" % [p.name,p.generation,p.price,p.quality,p.appeal,p.inventory], GREEN))
    for k in p.components.keys(): content.add_child(_card(k, "Technology level %d" % int(p.components[k]), ACCENT))
    content.add_child(_button("Manufacture 100",func():Game.manufacture(100)))
    content.add_child(_button("Develop Next Generation",func():Game.develop_next_generation(),GOLD))

func _research() -> void:
    for k in Game.state.research.keys():
        var row=_row(); content.add_child(row); row.add_child(_card(k,"Level %d" % Game.state.research[k],ACCENT)); row.add_child(_button("Research",func():Game.research(k))); row.add_child(_button("Apply to Product",func():Game.apply_research(k),GREEN))

func _factory() -> void:
    var f=Game.state.factory; content.add_child(_card("Factory Network","Plants %d\nCapacity %d\nEfficiency %.0f%%\nQueue %d"%[f.plants,f.capacity,f.efficiency*100,f.queue],GOLD))
    content.add_child(_button("Upgrade Factory",func():Game.upgrade_factory(),GOLD)); content.add_child(_button("Manufacture 500",func():Game.manufacture(500)))

func _supply() -> void:
    for x in Game.state.suppliers: content.add_child(_card(x.name,"Component: %s\nPrice %.0f  • Reliability %.0f%%\nContract %d months"%[x.component,x.price,x.reliability*100,x.contract],ACCENT))

func _staff() -> void:
    for e in Game.state.staff: content.add_child(_card(e.name,"%s\nSkill %d  • Morale %.0f  • Salary %.0f\nExperience %d"%[e.role,e.skill,e.morale,e.salary,e.exp],GREEN))
    content.add_child(_button("Hire Engineer",func():Game.hire("New Engineer","Engineer",70)))
    content.add_child(_button("Hire Researcher",func():Game.hire("New Researcher","Researcher",75)))

func _markets() -> void:
    for k in Game.state.markets.keys():
        var m=Game.state.markets[k]
        var row=_row()
        content.add_child(row)
        row.add_child(_card(k,"%s\nDemand %.2f  • Competition %.2f\nShare %.1f%%"%["UNLOCKED" if m.unlocked else "LOCKED",m.demand,m.competition,m.share],GREEN if m.unlocked else RED))
        if not m.unlocked:
            row.add_child(_button("Unlock",func():Game.unlock_market(k),GOLD))

func _competitors() -> void:
    for k in Game.state.competitors.keys():
        var c=Game.state.competitors[k]; content.add_child(_card(k,"Technology %.0f  • Price %.0f\nMarketing %.0f  • Market Share %.1f%%"%[c.tech,c.price,c.marketing,c.share],RED))

func _finance() -> void:
    var s=Game.state; content.add_child(_card("Financial Overview","Cash $%.0f\nDebt $%.0f\nRevenue $%.0f\nExpenses $%.0f\nLifetime Profit $%.0f"%[s.company.cash,s.company.debt,s.stats.revenue,s.stats.expenses,s.stats.profit],GREEN))
    content.add_child(_button("Emergency Credit $50,000",func():Game.take_loan(50000),RED)); content.add_child(_button("Marketing $10,000",func():Game.marketing_campaign("Launch",10000))); content.add_child(_button("Patent Technology",func():Game.patent("Modren Core","Computing"),GOLD))

func _bank() -> void:
    var s=Game.state; content.add_child(_card("Virtual Bank","Provider: %s\nMECR %.2f\nMECOIN %.8f\nExternal adapter: READY"%[s.bank.provider,s.wallet.MECR,s.wallet.MECOIN],ACCENT))
    content.add_child(_card("Integration Boundary","Virtual ledger only. External banking/real-money systems are intentionally not enabled.",GOLD))

func _events() -> void:
    for e in Game.state.events: content.add_child(_card(e.time,e.message,MUTED))

func _director() -> void:
    content.add_child(_card("GAME DIRECTOR / SUPER ADMIN","MOLHAM WAHEED\nPermissions: *\nFull simulation authority",GOLD))
    content.add_child(_button("Inject $100,000",func():Director.inject_cash(100000),GOLD)); content.add_child(_button("Max Reputation",func():Director.max_reputation(),GOLD)); content.add_child(_button("Boost All Research",func():Director.boost_research(8),GOLD)); content.add_child(_button("Unlock All Markets",func():Director.unlock_all_markets(),GOLD))

func _lan() -> void:
    content.add_child(_card("Local Co-op","Godot ENet over local Wi-Fi / phone hotspot\nHost port: 47777",ACCENT)); content.add_child(_button("Host LAN",func():Network.host())); content.add_child(_button("Broadcast State",func():Network.broadcast_state())); var ip=LineEdit.new(); ip.placeholder_text="Host IP, e.g. 192.168.43.1"; content.add_child(ip); content.add_child(_button("Join Host",func():Network.join(ip.text))); content.add_child(_button("Leave Session",func():Network.leave(),RED))

func _settings() -> void:
    content.add_child(_card("Simulation Settings","Autosave: %s\nSound: %s\nSpeed: %.1fx"%[Game.state.settings.autosave,Game.state.settings.sound,Game.state.settings.speed],ACCENT))
    content.add_child(_button("Save Game",func():SaveSystem.save_game(),GREEN)); content.add_child(_button("Load Game",func():SaveSystem.load_game()))

func _refresh() -> void:
    if not is_instance_valid(page_title): return
    var s=Game.state
    cash_label.text="CASH\n$%.0f" % s.company.cash
    debt_label.text="DEBT\n$%.0f" % s.company.debt
    level_label.text="LEVEL\n%d" % s.company.level
    reputation_label.text="REP\n%.0f" % s.company.reputation
    subtitle.text="MODREN TECHNOLOGIES  •  Offline Simulation  •  Year %d / Month %d" % [s.year,s.month]
    toast.text="Simulation updated • %s" % s.product.name

func _box(fill:Color, border:Color, radius:int, width:int) -> StyleBoxFlat:
    var b:=StyleBoxFlat.new(); b.bg_color=fill; b.border_color=border
    b.set_border_width_all(width); b.set_corner_radius_all(radius)
    return b
