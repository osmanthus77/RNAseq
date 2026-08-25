#FINAL_OUTPUTS.extend([
#    expand("02_fastqc/{srr}_fastqc.html", srr=SINGLE_SRRS),
#    expand("02_fastqc/{srr}_1_fastqc.html", srr=PAIRED_SRRS),
#    expand("02_fastqc/{srr}_2_fastqc.html", srr=PAIRED_SRRS)
#])
FINAL_OUTPUTS.append("02_fastqc/multiqc/multiqc_report.html")

rule fastqc_single:
    input:
        fastq_s = rules.extract_single.output.fastq_files,
    output:
        html = "02_fastqc/{srr}_fastqc.html"
    params:
        threads = config["fastqc"]["threads"]
    conda:
        "../envs/envs.yaml"
    log:
        "logs/02_fastqc/{srr}_fastqc.log"
    shell:
        """
        fastqc {input.fastq_s} -t {params.threads} --outdir 02_fastqc > {log} 2>&1

        if [ -e 02_fastqc/{wildcards.srr}_fastqc.html ]; then
            echo "FastQC finished!" >> {log}
        else
            echo "FastQC failed: HTML report missing!" >> {log}
            exit 1
        fi
        """

rule fastqc_paired:
    input:
        fastq_1 = rules.extract_paired.output.fastq_files[0],
        fastq_2 = rules.extract_paired.output.fastq_files[1]
    output:
        html_1 = "02_fastqc/{srr}_1_fastqc.html",
        html_2 = "02_fastqc/{srr}_2_fastqc.html",
    params:
        threads = config["fastqc"]["threads"]
    log:
        "logs/02_fastqc/{srr}_fastqc.log"
    conda:
        "../envs/envs.yaml"
    shell:
        """
        fastqc {input.fastq_1} {input.fastq_2} -t {params.threads} --outdir 02_fastqc > {log} 2>&1

        if [ -e {output.html_1} ] && [ -e {output.html_2} ]; then
            echo "FastQC finished!" >> {log}
        else
            echo "FastQC failed: HTML report missing!" >> {log}
            exit 1
        fi
        """

rule multiqc:
    input:
        htmls = expand("02_fastqc/{srr}_fastqc.html", srr=SINGLE_SRRS) +
                expand("02_fastqc/{srr}_1_fastqc.html", srr=PAIRED_SRRS) +
                expand("02_fastqc/{srr}_2_fastqc.html", srr=PAIRED_SRRS)
    output:
        "02_fastqc/multiqc/multiqc_report.html"
    conda:
        "../envs/envs.yaml"
    log:
        "logs/02_fastqc/multiqc.log"
    shell:
        """
        multiqc 02_fastqc -o 02_fastqc/multiqc > {log} 2>&1
        
        if [ -e {output} ]; then
            echo "MultiQC finished!" >> {log}
        else
            echo "MultiQC failed: report missing!" >> {log}
            exit 1
        fi
        """