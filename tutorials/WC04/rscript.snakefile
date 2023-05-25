datadir = '/commons/Themas/Thema11/Dataprocessing/WC04/data/'

rule all:
    """ final rule """
    input: 'result/histogram.jpg',
           'result/heatmap.jpg'


rule make_histogram:
    """ rule that creates histogram from gene expression counts"""
    input:
        datadir + 'out.csv'
    output:
         'result/histogram.jpg'
    shell:
        "Rscript scripts/histogram.R {input} {output}"

rule make_heatmap:
    """ rule that creates a heatmap from gene expression counts """
    input:
        datadir + 'gene_ex.csv'
    output:
        'result/heatmap.jpg'
    shell:
        "Rscript scripts/heatmap.R {input} {output}"