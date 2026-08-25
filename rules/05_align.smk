if config["sortmerna"]["step"] == "yes":
    FINAL_OUTPUTS.extend([
        expand("05_align/{srr}_sortmerna.sort.bam", srr=SRR_IDS)
    ])
elif config["sortmerna"]["step"] == "no":
    FINAL_OUTPUTS.extend([
        expand("05_align/{srr}_trim.sort.bam", srr=SRR_IDS)
    ])
else:
    raise ValueError("Invalid value for 'sortmerna.step' in config.yaml. Must be 'yes' or 'no'.")

rule hisat2_sortmerna:
    input:
        fastq = rules.sortmerna.output.non_rRNA
    output:
        sam = temp("05_align/{srr}_sortmerna.sam"),
        bam = "05_align/{srr}_sortmerna.sort.bam"
    conda:
        "../envs/envs.yaml"
    log:
        "logs/05_align/{srr}_hisat2_sortmerna.log"
    params:
        index = config["hisat2"]["index"],
        threads = config["hisat2"]["threads"]
    shell:
        """
        hisat2 -x {params.index} \
            -U {input.fastq} \
            -S {output.sam} \
            --threads {params.threads} \
            > {log} 2>&1
        
        if [ -e {output.sam} ]; then
            echo "HISAT2 finished!" >> {log}
        else
            echo "HISAT2 failed: SAM file missing!" >> {log}
            exit 1
        fi

        samtools sort {output.sam} \
            -@ {params.threads} -O BAM -o {output.bam} \
            >> {log} 2>&1
        samtools index {output.bam} >> {log} 2>&1
        """

rule hisat2_trim:
    input:
        fastq = rules.trimmomatic_single.output.trim
    output:
        sam = temp("05_align/{srr}_trim.sam"),
        bam = "05_align/{srr}_trim.sort.bam"
    conda:
        "../envs/envs.yaml"
    log:
        "logs/05_align/{srr}_hisat2_trim.log"
    params:
        index = config["hisat2"]["index"],
        threads = config["hisat2"]["threads"]
    shell:
        """
        hisat2-build -x {params.index} \
            -U {input.fastq} \
            -S {output.sam} \
            --threads {params.threads} \
            > {log} 2>&1
        
        if [ -e {output.sam} ]; then
            echo "HISAT2 finished!" >> {log}
        else
            echo "HISAT2 failed: SAM file missing!" >> {log}
            exit 1
        fi

        samtools sort {output.sam} \
            -@ {params.threads} -O BAM -o {output.bam} \
            >> {log} 2>&1
        samtools index {output.bam} >> {log} 2>&1
        """