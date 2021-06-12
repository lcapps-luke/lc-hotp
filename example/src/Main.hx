package;

import lcapps.crypto.Base32;
import lcapps.crypto.Hotp;

class Main{
	public static function main(){
		// generate a new secret & authenticator URI
		var secret = Hotp.createSecret(32);
		var uri = Hotp.createAuthenticatorUri("test", "lc-apps.co.uk", secret, "LC Apps");
		trace(uri);

		// generate the current password for the secret (this would be done by the user's authentication app)
		var secretBytes = Base32.decode(secret);
		var otp = Hotp.generateCode(secretBytes, Math.floor(Date.now().getTime() / 30000));
		var password = Hotp.truncateCode(otp);
		trace(password);

		// verify the generated password against the secret
		var result = Hotp.verify(secret, password);
		if(!result){
			throw "It's broke!";
		}
	}
}