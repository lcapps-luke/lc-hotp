# Authenticating
To authenticate a user use the `Hotp.verify` method, passing the password that the user provided along with the user's base32 encoded secret key.
```haxe
var secret = "NSPUNKGGGVFK7DNXZV5BPBZJ7AQ5TTIK"; // Secret for the user's account
var password = 548056; // Password provided by the user

var valid = lcapps.crypto.Hotp.verify(secret, password);
```
The example above should cover most use cases. There are additional arguments for different password lengths, time-range leniency, and hashing methods if needed.

It is recommended to not accept the same password for a user multiple times.

# Enrolling Users
In order to set up multi-factor authentication for a user, the application must generate a base32 encoded secret key. This key will be used by both the user's authentication app and the application the user is logging in to. A simple secret generation method is available as `Hotp.createSecret`.

The secret is typically registered in the user's authentication app using a QR code. This library doesn't provide tools for generating QR code graphics but it can create the URI that may be used to generate a QR code.
```haxe
var userName = "test";
var domain = "lc-apps.co.uk";
var secret = lcapps.crypto.Hotp.createSecret();
var issuer = "LC Apps";

lcapps.crypto.Hotp.createAuthenticatorUri(userName, domain, secret, issuer);
```
The above example would create the URI `otpauth://totop/LC%20Apps:test@lc-apps.co.uk?secret=NSPUNKGGGVFK7DNXZV5BPBZJ7AQ5TTIK&issuer=LC%20Apps`. This URI would then be encoded as a QR code for the user to register the key into their authentication app.

# Generating Passwords
Passwords can be generated from a secret & counter. The counter is derived from the current time & password period.
```haxe
var secret = "NSPUNKGGGVFK7DNXZV5BPBZJ7AQ5TTIK"; // Secret for the user's account
var counter = Math.floor(Date.now().getTime() / 60000);
var otp = Hotp.generateCode(secretBytes, counter);
var password = Hotp.truncateCode(otp);
```

# Configuration
The `Hotp.createSecret` method uses `Math.random()` so may not be strong enough so some purposes. 
You can change the random number generator for this method by setting `Hotp.RANDOM_FUNCTION`.