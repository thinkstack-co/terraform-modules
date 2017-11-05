output "key_name" {
    value = "${aws_key_pair.deployer_key.key_name}"
}

output "fingerprint" {
    value = "${aws_key_pair.deployer_key.fingerprint}"
}
