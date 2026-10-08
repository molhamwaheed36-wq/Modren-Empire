extends RefCounted
class_name MEId
static func make(prefix:String)->String:
    return "%s-%d-%d" % [prefix, Time.get_ticks_msec(), randi()]
