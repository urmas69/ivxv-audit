# Storage, administration, configuration and logging audit

The storage service invokes `/usr/bin/etcd` directly (`storage/service/storage/main.go:295`), creating a deployment portability/reproducibility dependency (IVXV-SRC-001). Admin command parsing uses signed BDOC metadata and YAML; `yaml.Loader` is a security lead requiring a reachable attacker-controlled payload (IVXV-SRC-002). Logs include service state and ballot/report identifiers by design; retention and access controls are deployment assumptions.
