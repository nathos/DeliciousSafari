This is the Obj-C 2 version of OAuthConsumer

Details on the export:
URL: svn export http://oauth.googlecode.com/svn/code/obj-c/OAuthConsumer OAuthConsumer
REVISION: Exported revision 1141.

Modifications made:
1. Added Release 3-way Fat configuration
2. Unit tests not passing in 64-bit so I:
	a. Removed sha1.[ch]
	b. hmac.[ch] and replaced with Common Crypto CCHmac using kCCHmacAlgSHA1 algorithm