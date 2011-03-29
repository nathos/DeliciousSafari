#!/usr/bin/ruby

# Ruby example code to generate a license key. This is based on make_license_key.sh. The contents of
# make_license_key.sh are:

#BEGIN make_license_key.sh
# Usage: ./make_license_key.sh <name or email address>
# echo -n "$1" | openssl dgst -sha1 -binary | openssl rsautl -sign -inkey private.pem | openssl enc -base64
#END make_licenseKey.sh

# To sum up, this file creates a binary SHA1 digest of message, encrypts it with the private key,
# and base 64 encodes it.

# To show the inverse, the license key is then base 64 decoded, and the public key is used to decrypt
# the data to the original SHA-1 digest.


require 'openssl'
require 'base64'
require 'digest/sha1'

# Create the license key
message = "Testing 1 2 3"

sha1_binary = Digest::SHA1.digest(message)

private_key = OpenSSL::PKey::RSA.new(File.read("./private.pem"))
cipher_text = private_key.private_encrypt(sha1_binary)

cipher_text64 = Base64.encode64(cipher_text)


# Decode the license key.
cipher_text64_decoded = Base64.decode64(cipher_text64)

public_key = OpenSSL::PKey::RSA.new(File.read("./public.pem"))
sha1_binary_plain_text = public_key.public_decrypt(cipher_text64_decoded)

puts "Message: #{message}"
puts "SHA-1 Message: #{sha1_binary}"
puts "Cipher Text: #{cipher_text}"
puts "Cipher Text 64: #{cipher_text64}"
puts "Plain Text: #{sha1_binary_plain_text}"
