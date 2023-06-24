# Converting an existing pipeline into a Snakemake-based version
Dennis Scheper, 373689</br>
E: d.j.scheper@st.hanze.nl

<uitleg> and <steps> We first want to address some essential comments about test data.

## Test data and distiction of input files
This pipeline covers four distinct input file types:

* Single-end short reads
* Single-end long reads
* Paired-end short reads
* Paired-end long reads

The length average length of all reads in input file determines whether it is long or short. We handled a distiction that when the average length is less than or equal to 90, it was labeled as a short read. Otherwise, the read is considered to be 'long'. Not every type had test data available in the original pipeline GitHub directory. Therefore, we generated our own data for every based on the `seqtk` library. This solution may not have been perfect but it allows us to test every aspect of the pipeline. We used sources stated in the original paper, see the sources section for every reference to the original data. Data was first downloaded and then sampled using the `seqtk` library. Data was generated as follows:

For single-end reads of any kind:

```{bash}
seqtk sample large_single-end_reads.fq > sample_single-end_reads.fq
```

For paired-end reads of any kind:

```{bash}
seqtk sample -s{seed} large_paired-end_R{index}_reads.fq > sample_paired-end_R{index}_reads.fq
```

For paired-end reads, we executed the command shown above for `R1` and `R2`, respectfully. To keep track of which reads were chosen in the first execution, the seed parameter (`-s`) with an identical seed in both runs used to have the same pair of reads be in the sampled versions of the two paired-end read FastQ files.

## Prerequisites

## Installation

## Configuration

## Usage

## Layout

## Contact
