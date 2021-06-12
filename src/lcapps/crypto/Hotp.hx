package lcapps.crypto;

import haxe.crypto.Hmac;
import haxe.io.Bytes;

class Hotp{
	
	/**
	 * Verify a one-time password against a secret key
	 * @param secret The base32 encoded secret key
	 * @param code The six digit password provided by the authenticating user
	 * @param range The range of 30 second increments to check
	 * @param passwordSize The length of the password (defaults to 6)
	 * @return Bool true if the password is valid for the secret at this time
	 */
	public static function verify(secret:String, password:Int, passwordSize:Int = 6, range:Int = 3, hashMethod:HashMethod = HashMethod.SHA1):Bool{
		var key:Bytes = Base32.decode(secret);
		var timestamp = Date.now().getTime() / 30000;

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
	 * @param key 
	 * @param counter 
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
	 * @return String
	 */
	public static function createAuthenticatorUri(username:String, domain:String, secret:String, issuer:String):String{
		var encodedIssuer = StringTools.urlEncode(issuer);
		var encodedUsername = StringTools.urlEncode(username);
		return 'otpauth://totop/$encodedIssuer:$encodedUsername@$domain?secret=$secret&issuer=$encodedIssuer';
	}

	/**
	 * Create a random base32 encoded secret
	 * @param length 
	 * @return String
	 */
	public static function createSecret(length:Int=32):String{
		var res = "";

		for(i in 0...length){
			var idx = Math.round(Math.random() * Base32.CHARS.length);
			res += Base32.CHARS.charAt(idx);
		}
		
		return res;
	}
}