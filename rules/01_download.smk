#FINAL_OUTPUTS.extend([
#    expand("01_rawfastq/{srr}.fastq.gz", srr=SINGLE_SRRS),
#    expand("01_rawfastq/{srr}_1.fastq.gz", srr=PAIRED_SRRS),
#    expand("01_rawfastq/{srr}_2.fastq.gz", srr=PAIRED_SRRS)
#])


rule prefetch:
    output:
        srafile = temp("01_rawfastq/{srr}/{srr}.sra")
    log:
        "logs/01_download/{srr}_prefetch.log"
    conda:
        "../envs/envs.yaml"
    params:
        srrid = "{srr}"
    threads: 1
    retries: config["download"]["retry"]
    resources:
        download_slots = 1
    shell:
        """
        if [ -e {output.srafile}.lock ]; then
            rm -f {output.srafile}.lock
            echo "{output.srafile} lock found but no output file! Deleting..." >> {log}
        fi

        prefetch --progress --output-directory 01_rawfastq {params.srrid} > {log} 2>&1
        if [ -e {output.srafile} ]; then
            echo "{output.srafile} download finished!" >> {log}
        else
            mv {output.srafile}* {output.srafile}
            echo "{output.srafile} not found! May end with .sralite. Renaming..." >> {log}
        fi
        """

rule extract_single:
    input:
        srafile = rules.prefetch.output.srafile
    output:
        fastq_files = "01_rawfastq/{srr}.fastq.gz"
    conda:
        "../envs/envs.yaml"
    log:
        "logs/01_download/{srr}_extract.log"
    params:
        srrid = "{srr}"
    threads: config["download"]["extract_threads"]
    shell:
        """
        fasterq-dump {input.srafile} --progress --details -v \
            --outdir 01_rawfastq \
            --threads {threads} \
            > {log} 2>&1
        pigz -p {threads} 01_rawfastq/{params.srrid}*.fastq

        if [ -e 01_rawfastq/{params.srrid}.fastq.gz ]; then
            echo "Single extract finished!" >> {log}
        else
            echo "Single extract failed: FASTQ file missing!" >> {log}
            exit 1
        fi
        """

rule extract_paired:
    input:
        srafile = rules.prefetch.output.srafile
    output:
        fastq_files = ["01_rawfastq/{srr}_1.fastq.gz", "01_rawfastq/{srr}_2.fastq.gz"]
    conda:
        "../envs/envs.yaml"
    log:
        "logs/01_download/{srr}_extract.log"
    params:
        srrid = "{srr}"
    threads: config["download"]["extract_threads"]
    shell:
        """
        fasterq-dump {input.srafile} --progress --details --split-files -v \
            --outdir 01_rawfastq \
            --threads {threads} \
            > {log} 2>&1
        pigz -p {threads} 01_rawfastq/{params.srrid}*.fastq

        if [ -e 01_rawfastq/{params.srrid}_1.fastq.gz ] && [ -e 01_rawfastq/{params.srrid}_2.fastq.gz ]; then
            echo "Paired extract finished!" >> {log}
        else
            echo "Paired extract failed: FASTQ files missing!" >> {log}
            exit 1
        fi
        """

