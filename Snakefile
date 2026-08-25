configfile: "config/config.yaml"

wildcard_constraints:
    srr = r"[A-Za-z0-9]+"

FINAL_OUTPUTS = []

include: "rules/function.smk"

include: "rules/01_download.smk"
include: "rules/02_fastqc.smk"
include: "rules/03_trim.smk"

if config["sortmerna"]["step"] == "yes":
    include: "rules/04_sortmerna.smk"
    include: "rules/05_align.smk"
elif config["sortmerna"]["step"] == "no":
    include: "rules/05_align.smk"
else:
    raise ValueError("Invalid value for 'sortmerna.step' in config.yaml. Must be 'yes' or 'no'.")

include: "rules/06_HTseq.smk"


rule all:
    input:
        "02_fastqc/multiqc/multiqc_report.html",
        "03_trim/multiqc/multiqc_report.html",
        FINAL_OUTPUTS
