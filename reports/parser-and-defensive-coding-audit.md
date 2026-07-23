# Parser and defensive-coding audit

Reviewed ZIP, BDOC/XML, YAML, JSON, PEM/DER and command/configuration entry points by source search and targeted manual tracing. ZIP code contains explicit file-count/size checks; command-file YAML uses custom constructors with `yaml.Loader`. No isolated exploit or denial-of-service reproduction was created. Leads are retained in [unresolved-leads.tsv](../evidence/source-audit/unresolved-leads.tsv).
