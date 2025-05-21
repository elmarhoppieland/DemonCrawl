extends StaticClass
class_name RomanNumeral

# ==============================================================================

static func convert_to_roman(n: int) -> String:
	match n:
		0:
			return ""
		1:
			return "I"
		2:
			return "II"
		3:
			return "III"
		4:
			return "IV"
		5:
			return "V"
		_:
			Debug.log_error("Attempt to convert %d to a roman numeral. This behaviour is not implemented." % n)
			return ""


static func convert_from_roman(roman: String) -> int:
	match roman:
		"":
			return 0
		"I":
			return 1
		"II":
			return 2
		"III":
			return 3
		"IV":
			return 4
		"V":
			return 5
		_:
			Debug.log_error("Attempt to convert '%s' from a roman numeral. This behaviour is not implemented." % roman)
			return -1
