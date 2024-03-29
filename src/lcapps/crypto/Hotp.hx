package lcapps.crypto;

import haxe.crypto.Hmac;
import haxe.io.Bytes;

class Hotp{
	/**
	 * Random number function used for generating secrets. Must return a number greater than or equal to `0.0`, and less than `1.0`.
	 */
	public static var RANDOM_FUNCTION(default, default):Void->Float = Math.random;
	
	/**
	 * Verify a one-time password against a secret key
	 * @param secret The base32 encoded secret key
	 * @param password The password provided by the authenticating user
	 * @param passwordSize The length of the password (defaults to 6)
	 * @param range The range of periods to check
	 * @param hashMethod 
	 * @param period The period that each password is valid for in milliseconds
	 * @return Bool true if the password is valid for the secret at this time
	 */
	public static function verify(secret:String, password:Int, passwordSize:Int = 6, range:Int = 3, hashMethod:HashMethod = HashMethod.SHA1, period:Int = 30000):Bool{
		var key:Bytes = Base32.decode(secret);
		var timestamp = Date.now().getTime() / period;

		for(i in -range...range){
			var checkTime = Math.floor(timestamp + i);
			var code = generateCode(key, checkTime, hashMethod);

			if(password == truncateCode(code, passwordSize)){
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Generate a HOTP code
	 * @param key The secret key
	 * @param counter The counter / time block
	 * @param hashMethod 
	 * @return Bytes
	 */
	public static function generateCode(key:Bytes, counter:Int, hashMethod:HashMethod = HashMethod.SHA1):Bytes {
		var hex = StringTools.hex(counter, 16);
		var binary = Bytes.ofHex(hex);

		var hmac = new Hmac(hashMethod);
		return hmac.make(key, binary);
	}

	/**
	 * Truncate a HOTP code into a user-readable password
	 * @param code 
	 * @param length 
	 * @return Int
	 */
	public static function truncateCode(code:Bytes, length:Int = 6):Int {
		var offset = code.get(19) & 0xf;
		return Math.floor((
			((code.get(offset) & 0x7f) << 24) | 
			((code.get(offset + 1) & 0xff) << 16) | 
			((code.get(offset + 2) & 0xff) << 8) | 
			(code.get(offset + 3) & 0xff)
		) % Math.pow(10, length));
	}

	/**
	 * Creates a URI which can be encoded as a QR code to be used by an authenticator app
	 * @param username 
	 * @param domain 
	 * @param secret 
	 * @param issuer 
	 * @param algorithm 
	 * @param digits The length of each password
	 * @param period The period that each password is valid for in seconds
	 * @return String
	 */
	public static function createAuthenticatorUri(username:String, domain:String, secret:String, issuer:String, algorithm:String = null, digits:Null<Int> = null, period:Null<Int> = null):String{
		var encodedIssuer = StringTools.urlEncode(issuer);
		var encodedUsername = StringTools.urlEncode(username);

		var result = 'otpauth://totop/$encodedIssuer:$encodedUsername@$domain?secret=$secret&issuer=$encodedIssuer';

		if(algorithm != null){
			result += '&algorithm=$algorithm';
		}

		if(digits != null){
			result += '&digits=$digits';
		}

		if(period != null){
			result += '&period=$period';
		}

		return result;
	}

	/**
	 * Create a random base32 encoded secret
	 * @param length 
	 * @return String
	 */
	public static function createSecret(length:Int=32):String{
		var res = "";

		for(i in 0...length){
			var idx = Math.round(RANDOM_FUNCTION() * Base32.CHARS.length);
			res += Base32.CHARS.charAt(idx);
		}
		
		return res;
	}
}