package lcapps.crypto;

import haxe.crypto.BaseCode;

class Base32{
	public static var CHARS(default, null) = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
	public static var BYTES(default, null) = haxe.io.Bytes.ofString(CHARS);

	public static function encode(bytes:haxe.io.Bytes, complement = true):String {
		var str = new BaseCode(BYTES).encodeBytes(bytes).toString();
		if (complement)
			switch (bytes.length % 3) {
				case 1:
					str += "==";
				case 2:
					str += "=";
				default:
			}
		return str;
	}

	public static function decode(str:String, complement = true):haxe.io.Bytes {
		if (complement)
			while (str.charCodeAt(str.length - 1) == "=".code)
				str = str.substr(0, -1);
		return new BaseCode(BYTES).decodeBytes(haxe.io.Bytes.ofString(str));
	}
}