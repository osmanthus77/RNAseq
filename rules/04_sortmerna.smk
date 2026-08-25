# this step is optional.

FINAL_OUTPUTS.extend([
    expand("04_sortmerna/non_rRNA/{srr}_non_rRNA.fq.gz", srr=SRR_IDS)
])

rule sortmerna:
    input:
        rules.trimmomatic_single.output.trim
    output:
        rRNA = "04_sortmerna/rRNA/{srr}_rRNA.fq.gz",
        non_rRNA = "04_sortmerna/non_rRNA/{srr}_non_rRNA.fq.gz"
    conda:
        "../envs/envs.yaml"
    log:
        "logs/04_sortmerna/{srr}_sortmerna.log"
    params:
        threads = config["sortmerna"]["threads"],
        ref = config["sortmerna"]["ref"],
        rRNA_pre = "04_sortmerna/rRNA/{srr}_rRNA",
        non_rRNA_pre = "04_sortmerna/non_rRNA/{srr}_non_rRNA",
        workdir = "04_sortmerna/tmp_{srr}"
    shell:
        """
        rm -rf {params.workdir}
        
        sortmerna --ref {params.ref} \
            --reads {input} \
            --zip-out \
            --aligned {params.rRNA_pre} \
            --other {params.non_rRNA_pre} \
            --workdir {params.workdir} \
            --fastx -v \
            -a {params.threads} \
            > {log} 2>&1

        if [ -e {output.rRNA} ] && [ -e {output.non_rRNA} ]; then
            echo "SortMeRNA finished!" >> {log}
        else
            echo "SortMeRNA failed: output FASTQ files missing!" >> {log}
            exit 1
        fi

        rm -rf {params.workdir}
        """