rule bcftools_call:
    input:
        fa="genome.fa",
        bam=expand("sorted_reads/{sample}.bam", sample=config["SAMPLES"]),
        bai=expand("sorted_reads/{sample}.bam.bai", sample=config["SAMPLES"])
    output:
        "calls/all.vcf"
    message: "executing bfctools call on the following {input} to generate the following {output}"
    shell:
        "samtools mpileup -g -f {input.fa} {input.bam} | "
        "bcftools call -mv - > {output}"