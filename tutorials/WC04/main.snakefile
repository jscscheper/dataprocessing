# -*- python -*-
from os.path import join

configfile: "config/config.yaml"
workdir: config["workdir"]

rule all:
    input:
        config["resultdir"] + "out.vcf"

rule bwa_index:
    input:
        config["inputdir"] + 'reference.fa'
    output:
        touch(config["indexdir"] + 'bwa_index.done')
    message: "Creating bwa index; {input} being created."
    shell:
        "bwa index {input}"

rule bwa_align1:
    input:
        check = config["indexdir"] + "bwa_index.done",
        gen = config["inputdir"] + 'reference.fa',
        reads = expand(config["inputdir"] + "{sample}.txt", sample=config["samples"])
    output:
        config["tempdir"] + "out.sai"
    message: "BWA alignment on {input.gen} and {input.reads}; creating {output}."
    shell:
        "bwa aln -I -t 8 {input.gen} {input.reads} > {output}"

rule bwa_align2:
    input:
        reference = config["inputdir"] + 'reference.fa',
	sai = config["tempdir"] + 'out.sai',
        reads = expand(config["inputdir"] + "{sample}.txt", sample=config["samples"])
    output:
        config["aligndir"] + "out.sam"
    message: "Alignment on {input.reference}, {input.sai}, and {input.reads}; creating {output}."
    shell:
        "bwa samse {input.reference} {input.sai} {input.reads} > {output}"

rule sam_view:
    input:
        config["aligndir"] + "out.sam"
    output:
        config["tempdir"] + "out.bam"
    message: "Converting {input} to {output}."
    shell:
        "samtools view -S -b {input} > {output}"

rule sam_sort:
    input:
        config["tempdir"] + "out.bam"
    output:
        config["sorteddir"] + "out.sorted.bam"
    message: "Sorting {input} to {output}."
    shell:
         "samtools sort {input} -o {output}"

rule remove_duplicates:
    input:
        sorted = config["sorteddir"] + "out.sorted.bam",
        picard = config["picarddir"]
    output:
        config["filtereddir"] + "out.dedupe.bam"
    message: "Removing duplicates from {input.sorted}; writing the result to {output}."
    shell:
         "java -jar {input.picard}/build/libs/picard.jar MarkDuplicates \
                            MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000\
                            METRICS_FILE=out.metrics \
                            REMOVE_DUPLICATES=true \
                            ASSUME_SORTED=true  \
                            VALIDATION_STRINGENCY=LENIENT \
                            INPUT={input.sorted} \
                            OUTPUT={output}"

rule sam_index:
    input:
         config["filtereddir"] + "out.dedupe.bam"
    output:
          touch(config["indexdir"] + "sam.index.done")
    message: "Indexing {input} and writing {output} for control."
    shell:
         "samtools index {input}"

rule sam_pileup:
    input:
         reference = config["inputdir"] + "reference.fa",
         filtered = config["filtereddir"] + "out.dedupe.bam"
    output:
          config["resultdir"] + "out.vcf"
    message: "Pileup of {input.reference} and {input.filtered}; converting it to {output}."
    shell:
         "samtools mpileup -uf {input.reference} {input.filtered} | bcftools view -> {output}"