<?php

function generateLicense($name, $private_key_filename)
{
        echo "This is a test\n";

        $test = true;
        $sha1_text = sha1($name);
        #echo "Sha of $name is $sha1_text\n";
        $sha1_binary = pack("H*", $sha1_text);

        #echo "Private key file data: $privateKeyData\n";

        $privateKeyResource = openssl_pkey_get_private("file://" . $private_key_filename) or die("Error parsing private key");

        openssl_private_encrypt($sha1_binary, $cipher_text, $privateKeyResource) or die("Error encrypting.");

        $cipher_text64 = base64_encode($cipher_text) or die("Error base64 encoding");
        return chunk_split($cipher_text64, 65);
}

function runLicenseGenerationTest($licensedTo)
{
        $licenseKey = generatelicense($licensedTo, "private.pem");

        echo "Licensed To:\n$licensedTo\n";
        echo "License Key:\n$licenseKey\n";
}

runLicenseGenerationTest($argv[1]);

?>
