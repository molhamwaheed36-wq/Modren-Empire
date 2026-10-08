extends RefCounted
class_name MEValidation
static func positive(value:float)->bool: return value > 0.0
static func finite(value:float)->bool: return is_finite(value)
static func clamp_percent(value:float)->float: return clamp(value,0.0,100.0)
