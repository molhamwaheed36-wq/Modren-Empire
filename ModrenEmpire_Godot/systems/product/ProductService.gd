extends RefCounted
class_name ProductService
func component_score(product:Dictionary)->float:
    var total:=0.0
    for v in product.get("components",{}).values(): total += float(v)
    return total / max(1,product.get("components",{}).size())
func estimated_quality(product:Dictionary)->float:
    return clamp(component_score(product)*7.0+float(product.get("appeal",50))*0.3,0.0,100.0)
