# Converting an existing pipeline into a Snakemake-based version
Dennis Scheper, 373689</br>
E: d.j.scheper@st.hanze.nl

This repository contains the Snakemake version of the artMAP pipeline. [1][artmap] artMAP is a pipeline that identifies EMS-induced mutations in _Arabidopsis thaliana_. The authors wanted to develop a pipeline that is accessible to people without bioinformatics expertise and, therefore, integrated the pipeline into a Docker environment. Docker provides an easy-to-use installation process and makes artMAP widely available to a wide audience. artMAP's laid-back approach to the identification of EMS-induced mutations is made possible by its graphical interface where a user can adjust parameters by filling them into a form. A user also needs to declare whether its input file consists of single- or paired-end reads and whether reads are "short" or "long".

When turning this pipeline into a Snakemake-based version, we automated the process of determining with which kind of input the pipeline was dealing. We accomplished this by naming samples a certain way, for example, naming the sample `single_long`. Now, this version of the artMAP pipeline is fully automated and operates via the command line. Therefore, it needs more expertise than the original pipeline required but the aspect of automation makes the pipeline more sufficient in handling big data operations. The authors did not provide enough test data, therefore, we generated our data to assess the validity of the pipeline.

## Test data and distinction of input files
This pipeline covers four distinct input file types:

* Single-end short reads
* Single-end long reads
* Paired-end short reads
* Paired-end long reads

The length average length of all reads in the input file determines whether it is long or short. We handled a distinction that when the average length is less than or equal to 90, it was labelled as a short read. Otherwise, the read is considered to be 'long'. Not every type had test data available in the original pipeline GitHub directory. Therefore, we generated our data for every based on the `seqtk` library. This solution may not have been perfect but it allows us to test every aspect of the pipeline. We used sources stated in the original paper, see the sources section for every reference to the original data. Data was first downloaded and then sampled using the `seqtk` library. Data was generated as follows:

For single-end reads of any kind:

```{bash}
seqtk sample large_single-end_reads.fq > sample_single-end_reads.fq
```

For paired-end reads of any kind:

```{bash}
seqtk sample -s{seed} large_paired-end_R{index}_reads.fq > sample_paired-end_R{index}_reads.fq
```

For paired-end reads, we executed the command shown above for `R1` and `R2`, respectfully. To keep track of which reads were chosen in the first execution, the seed parameter (`-s`) with an identical seed in both runs used to have the same pair of reads in the sampled versions of the two paired-end read FastQ files.

## Layout and Packages
Conda (installation is explained below) version ... was used as a package and environment manager. The following packages were used:
    <list>

In the root of this repository, you will find this `README.md`, a visual representation of the pipeline in the form of a DAG (`dag.png`), `env.yaml` which can be used for installation of all necessary packages as we explain below, and the `Snakefile` file, which is the entry point of the pipeline. The subdirectories are set up as follows:
    - `benchmarks`: contains the benchmarks that state e.g. how long any subprocess took.
    - `config`: contains the `config.yaml` that is used for dynamic paths and sample usage.
    - `data`: contains the input and output files of every rule.
    - `logs`: contains log files for each rule; every rule has its subdirectory.
    - `results`: contains the final output files.
    - `scripts`: contains Python (`visualize.py`) and JS (`snpsPicker.js` (artMAP)) scripts used in the pipeline.
    - `workflow`: contains every rule and is imported into the main file (`Snakemake`).

## Installation and Configuration

**Step 1: Acquiring Files**

Clone this repository and go to the source directory.

```{bash}
git clone https://github.com/djscheper/dataprocessing.git
cd dataprocessing/final-assignment
```

**Step 2: Installing Conda**

This pipeline uses Conda for its package management. Please follow the instruction for installing Conda [here][conda-install].

**Step 3: Installing Packages**

To install all necessary packages, create a conda environment and install the packages provided in `env.yaml`:

```{bash}
conda env create -f env.yml
```

**Step 4: Activation**

Next, activate the conda environment to get access to all necessary packages.

```
conda activate snake_env
```

**Step 5: Configuration**

After successfully activating the conda environment you find the configuration file `config/config.yaml` which needs to be updated to your desired parameters to ensure functionality. Not all parameters need to be adjusted but may. The config file contains the following parameters:
    * `workdir`: path to the directory holding the pipeline
    * `{name}dir`: `{name}` refers to any directory under `data/` where all input and output data is written to
    * `genome`: path holds the reference genome 
    * `result-dir`: path to the directory where the final output will be written to
    * `extensions`: parameter to be used to generate reference genome, if missing
    * `samples`: samples to be used in the pipeline
    * `type`: type of sample, can either be wild type (`wt`) or mutant (`mut`)
    * `threads`: number of threads used, the standard is 8. Please adjust this to your own specification.
    * `threshold_reads`: threshold to determine whether a read is long or short, standard is 90

**Step 6: Adding a sample**

This step is optional and gives instructions on how to add your own sample. A sample needs to be named properly so that the pipeline can recognize which input file it is dealing with. 
    1 - Make sure your input file is in the pathway specified in the `samples-dir` parameter present in `config.yaml`
    2 - Naming your input file in a certain way is essential:
            * single-end long reads: `single_long_1_{wt/mut}.fq`
            * single-end short reads: `single_short_1_{wt/mut}.fq`
            * paired-end long reads: `paired_long_{1/2}_{wt/mut}.fq`
            * paired-end short reads: `paired_short_{1/2}_{wt/mut}.fq`
    3 - Make sure you differentiate between wild (`wt`) - and mutant-type (`mut`) input files.
    4 - Make sure, if you use paired-end reads, that you have two input files per paired-end read sample.

Now you are set to use the pipeline!

## Usage
If you have activated the pipeline as described above, you can run the pipeline like so:

```{bash}
snakemake --cores <number_of_cores>
```

Please make sure that the number of cores you give up is identical to the number specified in the `threads` parameter in the `config.yaml` file.


## Contact
If any issue or question remains, please contact us at [d.j.scheper@st.hanze.nl](mailto:d.j.scheper@st.hanze.nl)

[artmap]:https://github.com/RihaLab/artMAP/tree/master
[conda-install]: https://conda.io/projects/conda/en/latest/user-guide/install/index.html