if config["sortmerna"]["step"] == "yes":
    bam_type = "sortmerna"
elif config["sortmerna"]["step"] == "no":
    bam_type = "trim"
else:
    raise ValueError("Invalid value for 'sortmerna.step' in config.yaml. Must be 'yes' or 'no'.")


FINAL_OUTPUTS.extend([
    expand("06_HTseq/{srr}_{bam_type}.htseq.count", srr=SRR_IDS, bam_type=bam_type)
])

rule HTseq:
    input:
        bam = "05_align/{srr}_{bam_type}.sort.bam",
        gtf = config["HTseq"]["gtf"]
    output:
        counts = "06_HTseq/{srr}_{bam_type}.htseq.count"
    conda:
        "../envs/envs.yaml"
    log:
        "logs/06_HTseq/{srr}_{bam_type}_htseq.log"
    params:
        params = config["HTseq"]["params"]
    shell:
        """
        htseq-count -f bam {input.bam} {input.gtf} \
            {params.params} \
            > {output.counts} 2> {log}
        
        if [ -e {output.counts} ]; then
            echo "HTSeq finished!" >> {log}
        else
            echo "HTSeq failed: counts file missing!" >> {log}
            exit 1
        fi
        """