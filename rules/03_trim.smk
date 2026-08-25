#FINAL_OUTPUTS.extend([
#    expand("03_trim/{srr}_cut.fastq.gz", srr=SINGLE_SRRS),
#    expand("03_trim/{srr}_trim.fastq.gz", srr=SINGLE_SRRS)
#])


rule cutadapt_single:
    input:
        fastq_s = rules.extract_single.output.fastq_files,
    output:
        cutadapt = "03_trim/{srr}_cut.fastq.gz"
    params:
        adapter = config["cutadapt"]["adapter"],
        min_length = config["cutadapt"]["min_length"],
        overlap = config["cutadapt"]["overlap"]
    conda:
        "../envs/envs.yaml"
    log:
        "logs/03_trim/{srr}_cutadapt.log"
    shell:
        """
        cutadapt {input.fastq_s} --trim-n \
            -a {params.adapter} --minimum-length {params.min_length} --overlap {params.overlap} \
            -o {output.cutadapt} \
            > {log} 2>&1
        
        if [ -e {output.cutadapt} ]; then
            echo "Cutadapt finished!" >> {log}
        else
            echo "Cutadapt failed: trimmed FASTQ file missing!" >> {log}
            exit 1
        fi
        """


rule trimmomatic_single:
    input:
        rules.cutadapt_single.output.cutadapt
    output:
        trim = "03_trim/{srr}_trim.fastq.gz"
    conda:
        "../envs/envs.yaml"
    params:
        config["trimmomatic"]["params"]
    log:
        "logs/03_trim/{srr}_trimmomatic.log"
    shell:
        """
        trimmomatic SE {input} -phred33 {output.trim} \
            {params} \
            > {log} 2>&1
        
        if [ -e {output.trim} ]; then
            echo "Trimmomatic finished!" >> {log}
        else
            echo "Trimmomatic failed: trimmed FASTQ file missing!" >> {log}
            exit 1
        fi
        """

rule trim_fastqc:
    input:
        rules.trimmomatic_single.output.trim
    output:
        html = "03_trim/fastqc/{srr}_trim_fastqc.html"
    params:
        threads = config["fastqc"]["threads"]
    conda:
        "../envs/envs.yaml"
    log:
        "logs/03_trim/{srr}_trim_fastqc.log"
    shell:
        """
        fastqc {input} -t {params.threads} --outdir 03_trim/fastqc > {log} 2>&1
        
        if [ -e {output.html} ]; then
            echo "Trim FastQC finished!" >> {log}
        else
            echo "Trim FastQC failed: HTML report missing!" >> {log}
            exit 1
        fi
        """

rule trim_multiqc:
    input:
        htmls = expand("03_trim/fastqc/{srr}_trim_fastqc.html", srr=SINGLE_SRRS) +
                expand("03_trim/fastqc/{srr}_1_trim_fastqc.html", srr=PAIRED_SRRS) +
                expand("03_trim/fastqc/{srr}_2_trim_fastqc.html", srr=PAIRED_SRRS)
    output:
        "03_trim/multiqc/multiqc_report.html"
    conda:
        "../envs/envs.yaml"
    log:
        "logs/03_trim/multiqc.log"
    shell:
        """
        multiqc 03_trim -o 03_trim/multiqc > {log} 2>&1
        """