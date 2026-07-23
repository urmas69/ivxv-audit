# Auditor tool audit

`auditor` tools check ballot-box, shuffle/decryption proofs, logs and tally structures. `DecryptTool` checks that proof ciphertexts have counterparts and removes checked entries from its working copy. These checks rely on externally supplied manifests, proof files and configuration authenticity. No confirmed bypass was found; independent malformed-proof and cross-election tests remain required.
