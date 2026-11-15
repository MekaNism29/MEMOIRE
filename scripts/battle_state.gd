class_name BattleState
extends RefCounted
## Pure battle logic (no UI): deck/hand/discard, energy, Emotional Balance
## pendulum, Bounce Back, card effects and boss AI. battle.gd is the UI layer.

signal state_changed
signal message(text: String)
signal balance_changed(old_value: int, new_value: int)
signal bounce_back_fired(damage: int)
signal card_played(card: Dictionary)

const MIN_BALANCE := -10
const MAX_BALANCE := 10
const BOUNCE_ZONE_MIN := -9
const BOUNCE_ZONE_MAX := -7
const BOUNCE_LANDING := 1
const BASE_ENERGY := 3
const HAND_SIZE := 3

var boss: Dictionary = {}
var boss_hp := 0
var boss_max_hp := 0
var balance := 0
var shield := 0
var energy := 0
var turn := 0
var boss_turn := 0
var phase := "player"   # "player" | "enemy" | "over"
var finished := false
var won := false

var draw_pile: Array = []
var discard_pile: Array = []
var hand: Array = []    # entries: {"card": Dictionary, "cost": int, "locked": bool}

# temporary modifiers
var boss_attack_reduction := 0
var double_next := false
var balance_locked := false
var no_extra_draw := false
var energy_penalty_next := 0
var echo_energy := 0
var last_card_damage := 0


func start(boss_data: Dictionary, deck: Array, echo: int = 0) -> void:
    boss = boss_data
    boss_hp = int(boss["hp"])
    boss_max_hp = boss_hp
    draw_pile = deck.duplicate()
    draw_pile.shuffle()
    discard_pile.clear()
    hand.clear()
    echo_energy = echo
    message.emit("%s muncul. Bertahanlah di antara dua kutub emosi." % boss["name"])
    start_player_turn()


# ------------------------------------------------------------ turn flow
func start_player_turn() -> void:
    if finished:
        return
    turn += 1
    shield = 0
    balance_locked = false
    no_extra_draw = false
    energy = maxi(0, BASE_ENERGY + echo_energy - energy_penalty_next)
    if echo_energy > 0:
        message.emit("Resilience Echo: +%d Energi." % echo_energy)
    if energy_penalty_next > 0:
        message.emit("Harga Bangga: Energi -%d giliran ini." % energy_penalty_next)
    echo_energy = 0
    energy_penalty_next = 0
    phase = "player"
    draw_cards(HAND_SIZE)
    message.emit("Giliran %d." % turn)
    state_changed.emit()


func end_player_turn() -> void:
    if phase != "player" or finished:
        return
    for e in hand:
        discard_pile.append(e["card"])
    hand.clear()
    phase = "enemy"
    state_changed.emit()


func enemy_turn() -> void:
    if finished:
        return
    boss_turn += 1
    var shift := _boss_shift_for_turn(boss_turn)
    message.emit("%s menyerang batinmu." % boss["name"])
    _boss_shift(shift)
    boss_attack_reduction = 0
    # Lose condition: the pendulum is still at -10 / +10 when the enemy turn ends.
    if balance <= MIN_BALANCE or balance >= MAX_BALANCE:
        finished = true
        won = false
        phase = "over"
        message.emit("Pendulum bertahan di %+d. Batinmu runtuh." % balance)
    state_changed.emit()


# ------------------------------------------------------------ cards
func draw_cards(n: int, extra: bool = false) -> void:
    if extra and no_extra_draw:
        message.emit("Hampa: tidak bisa menarik kartu tambahan.")
        return
    for i in range(n):
        if draw_pile.is_empty():
            if discard_pile.is_empty():
                break
            draw_pile = discard_pile.duplicate()
            discard_pile.clear()
            draw_pile.shuffle()
            message.emit("Dek dikocok ulang.")
        var card: Dictionary = draw_pile.pop_back()
        hand.append({"card": card, "cost": int(card["cost"]), "locked": false})


func play_block_reason(i: int) -> String:
    if finished or phase != "player":
        return "Bukan giliranmu."
    if i < 0 or i >= hand.size():
        return "Kartu tidak ada."
    var e: Dictionary = hand[i]
    if int(e["cost"]) > energy:
        return "Energi tidak cukup."
    var card: Dictionary = e["card"]
    if card.has("requires_balance_max") and balance > int(card["requires_balance_max"]):
        return "%s hanya bisa dimainkan saat Balance %d atau lebih rendah." % [card["name"], int(card["requires_balance_max"])]
    return ""


func play_card(i: int) -> bool:
    if play_block_reason(i) != "":
        return false
    var entry: Dictionary = hand[i]
    var card: Dictionary = entry["card"]
    energy -= int(entry["cost"])
    hand.remove_at(i)
    var mult := 2 if double_next else 1
    if double_next:
        message.emit("Harapan menggandakan %s!" % card["name"])
    double_next = false
    var balance_before := balance
    message.emit("Memainkan %s." % card["name"])
    _apply_card(card, mult, balance_before)
    card_played.emit(card)
    # Rindu-style bounce: returns to hand for free if played while Balance < 0.
    if card.get("returns_if_negative", false) and balance_before < 0:
        hand.append({"card": card, "cost": 0, "locked": false})
        message.emit("%s memantul kembali ke tanganmu (Cost 0)." % card["name"])
    else:
        discard_pile.append(card)
    state_changed.emit()
    return true


func _apply_card(card: Dictionary, mult: int, balance_before: int) -> void:
    var dmg: int = int(card.get("damage", 0))
    if card.has("damage_if_negative") and balance_before < 0:
        dmg = int(card["damage_if_negative"])
    dmg *= mult
    last_card_damage = dmg
    if dmg > 0:
        deal_damage(dmg)

    var sh: int = int(card.get("shield", 0)) * mult
    if card.get("shield_from_negative", false) and balance_before < 0:
        sh += (-balance_before) * mult
    if sh > 0:
        shield += sh
        message.emit("+%d Shield." % sh)

    var gain: int = int(card.get("energy_gain", 0)) * mult
    if gain > 0:
        energy += gain
        message.emit("+%d Energi." % gain)

    var reduce: int = int(card.get("boss_attack_reduction", 0)) * mult
    if reduce > 0:
        boss_attack_reduction += reduce
        message.emit("Serangan bos berikutnya -%d." % reduce)

    if card.get("double_next", false):
        double_next = true
        message.emit("Efek kartu berikutnya akan digandakan.")
    if card.get("lock_balance", false):
        balance_locked = true
        message.emit("Balance terkunci sampai giliran depan.")
    if card.get("no_extra_draw", false):
        no_extra_draw = true

    var pen: int = int(card.get("next_turn_energy_penalty", 0))
    if pen > 0:
        energy_penalty_next += pen

    if card.get("clear_debuffs", false):
        _clear_debuffs()

    if card.get("set_balance_zero", false):
        set_balance(0)
        message.emit("Balance dipulihkan ke 0.")

    var shift: int = int(card.get("balance_shift", 0)) * mult
    if shift != 0:
        shift_balance(shift)
    var pull: int = int(card.get("balance_pull", 0)) * mult
    if pull > 0:
        pull_toward_zero(pull)

    var draw_n: int = int(card.get("draw", 0)) * mult
    if draw_n > 0:
        draw_cards(draw_n, true)

    var disc: int = int(card.get("discard_random", 0))
    if disc > 0:
        _discard_random(disc)


func _discard_random(n: int) -> void:
    for i in range(n):
        if hand.is_empty():
            break
        var idx: int = randi() % hand.size()
        var card: Dictionary = hand[idx]["card"]
        discard_pile.append(card)
        hand.remove_at(idx)
        message.emit("%s terbuang dari tanganmu." % card["name"])


func _clear_debuffs() -> void:
    var cleared := false
    for e in hand:
        if e["locked"]:
            e["locked"] = false
            cleared = true
    if energy_penalty_next > 0:
        energy_penalty_next = 0
        cleared = true
    if no_extra_draw:
        no_extra_draw = false
        cleared = true
    message.emit("Lega: efek negatif dihapus." if cleared else "Lega: tidak ada efek negatif.")


# ------------------------------------------------------------ balance
func shift_balance(amount: int, force: bool = false) -> void:
    if amount == 0:
        return
    if balance_locked and not force:
        message.emit("Balance terkunci (Hampa) - tidak bergeser.")
        return
    var amt := amount
    if amt < 0:
        var resist := _left_resist()
        if resist > 0:
            amt = mini(0, amt + resist)
            message.emit("Kepingan Tekad menahan jatuhmu %d poin." % resist)
        if amt == 0:
            return
    set_balance(balance + amt)


func pull_toward_zero(points: int) -> void:
    if balance_locked:
        message.emit("Balance terkunci (Hampa) - tidak bergeser.")
        return
    if balance > 0:
        set_balance(maxi(0, balance - points))
    elif balance < 0:
        set_balance(mini(0, balance + points))


func set_balance(v: int) -> void:
    var old := balance
    balance = clampi(v, MIN_BALANCE, MAX_BALANCE)
    if old != balance:
        balance_changed.emit(old, balance)


func _left_resist() -> int:
    var total := 0
    for e in hand:
        var c: Dictionary = e["card"]
        total += int(c.get("passive_resist_left", 0))
    return total


func zone_name() -> String:
    if balance < 0:
        return "Terpuruk"
    if balance > 0:
        return "Meledak"
    return "Seimbang"


# ------------------------------------------------------------ bounce back
func bounce_available() -> bool:
    return phase == "player" and not finished \
        and balance >= BOUNCE_ZONE_MIN and balance <= BOUNCE_ZONE_MAX \
        and not hand.is_empty()


## Sacrifice one card: the pendulum rebounds to +1 and releases Recoil Damage
## equal to the distance travelled (e.g. -8 -> +1 = 9 damage).
func bounce_back(sacrifice_index: int) -> bool:
    if not bounce_available():
        return false
    if sacrifice_index < 0 or sacrifice_index >= hand.size():
        return false
    var card: Dictionary = hand[sacrifice_index]["card"]
    var old := balance
    var dmg := BOUNCE_LANDING - old
    discard_pile.append(card)
    hand.remove_at(sacrifice_index)
    message.emit("BOUNCE BACK! %s dikorbankan. Balance %d -> %+d." % [card["name"], old, BOUNCE_LANDING])
    set_balance(BOUNCE_LANDING)
    bounce_back_fired.emit(dmg)
    deal_damage(dmg)
    state_changed.emit()
    return true


# ------------------------------------------------------------ damage
func deal_damage(amount: int) -> void:
    if amount <= 0 or finished:
        return
    boss_hp = maxi(0, boss_hp - amount)
    message.emit("%d Damage ke %s." % [amount, boss["name"]])
    if boss_hp <= 0:
        finished = true
        won = true
        phase = "over"
        message.emit("%s melebur. Kenangan itu kini bagian darimu." % boss["name"])


# ------------------------------------------------------------ boss AI
func _boss_shift_for_turn(n: int) -> int:
    var p: Dictionary = boss.get("params", {})
    match String(boss.get("pattern", "")):
        "constant_shift":
            return int(p.get("shift", -3))
        "alternating_shift":
            if n % 2 == 1:
                return int(p.get("shift_a", -1))
            return int(p.get("shift_b", 1))
        "mirror_push":
            var div: int = maxi(1, int(p.get("mirror_divisor", 6)))
            return int(p.get("push", 2)) + floori(last_card_damage / float(div))
    return 0


# Boss attacks push the pendulum. Shield absorbs points of that push.
func _boss_shift(amount: int) -> void:
    var mag := absi(amount)
    if boss_attack_reduction > 0:
        message.emit("Kekecewaanmu meredam serangan (-%d)." % boss_attack_reduction)
        mag = maxi(0, mag - boss_attack_reduction)
    var absorbed := mini(shield, mag)
    if absorbed > 0:
        shield -= absorbed
        mag -= absorbed
        message.emit("Shield menyerap %d poin." % absorbed)
    if mag <= 0:
        message.emit("Serangan tertahan sepenuhnya.")
        return
    shift_balance(signi(amount) * mag)


func intent_text() -> String:
    var n := boss_turn + 1
    var shift := _boss_shift_for_turn(n)
    var txt := ""
    match String(boss.get("pattern", "")):
        "constant_shift":
            txt = "Menekan batinmu ke jurang: Balance %+d" % shift
        "alternating_shift":
            txt = "Menekan Balance %+d" % shift
        "mirror_push":
            txt = "Meniru kartu terakhirmu, mendorong Balance %+d" % shift
        _:
            txt = "Balance %+d" % shift
    if boss_attack_reduction > 0:
        txt += "  (diredam -%d)" % boss_attack_reduction
    return txt
