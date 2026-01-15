= Stage 1: Data aquisition and preparation

For the first stage of the project, the focus was on acquiring and preparing data for analysis. This included downloading and organizing the necessary datasets, as well as preprocessing the data to ensure it was ready for downstream analysis. The workflow is illustrated on @stage1.

For the real dataset set out in the goals, Wang et al @wangScRNAseqScATACseqReveal2025 have made their scRNA-seq and scATAC-seq data available.

The dataset consists of scRNA-seq of 5 donors; NOA1, NOA2, NOA3, OA1 and OA2. NOA stands for non-obstructive azoospermia, OA for obstructive azoospermia. In the study the OA patient was used as a control group as OA is not a problem with spermatogenesis, .

The scRNA-seq data was available under NCBI Gene Expression Omnibus ID *GSE202647* from 2022, and was already ready for analysis.

The scATAC-seq data was available under NCBI BioProject ID *PRJNA1177103* from 2024. This was only the raw read data, so the Cellranger ATAC @satpathyMassivelyParallelSinglecell2019 pipeline was run for each of the five samples. For Cellranger to be able to run the data had to be structured and named in a specific way. Using the guidelines available from the offical 10X Cellranger documentation and matching the read length of each of the four files per sample was renamed accordingly.

Identifying each file to do correct renaming was done by looking at the read length. This was needed as the original files were just named numerically. The naming scheme for Cellranger ATAC count @SpecifyingInputFASTQ: `[Sample Name]S1_L00[Lane Number][Read Type]_001.fastq.gz`, where `Read type`:
  - `I1`: Dual index i7 read (optional)
  - `R1`: Read 1
  - `I2`: Dual index i5 read
  - `R3`: Read 2

`Lane Number` does not matter. `Sample Name` can be anything.

In the case of the NOA3 donor the read length was R1; `50`, R2; `49`, I1; `8`, I2; `16`. Thereby producing these four files:
- `SRR31097965_S1_L001_I1_001.fastq`
- `SRR31097965_S1_L001_I2_001.fastq`
- `SRR31097965_S1_L001_R1_001.fastq`
- `SRR31097965_S1_L001_R2_001.fastq`

The `count` function was run with Cellranger ATAC version 2.2.0 on each sample with reference data _refdata-cellranger-arc-GRCh38-2024-A_ using SLURM. This resulted in the `filtered_peak_bc_matrix.h5`, `fragments.tsv` and `peak_annotation.tsv` for each sample ready for analysis.

Ideally, the data from scRNA-seq and scATAC-seq should be cell matched from their barcodes, but finding public datasets for testis with that criteria was difficult. Instead, we will be matching cells by celltype instead from donor matched scRNA-seq and scATAC-seq. The data in Wang et al's study comes from the same five donors, three NOA and two OA, but sequenced at different time points, so the cell barcodes do not match.