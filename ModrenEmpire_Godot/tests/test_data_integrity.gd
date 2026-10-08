extends RefCounted
class_name TestDataIntegrity
static func run()->Dictionary:
    var result={"passed":0,"failed":0,"errors":[]}
    var dirs=["res://data/products","res://data/technology","res://data/markets","res://data/events","res://data/companies"]
    for d in dirs:
        var dir=DirAccess.open(d)
        if dir==null: result.failed+=1; result.errors.append("Missing "+d); continue
        result.passed+=1
    return result
