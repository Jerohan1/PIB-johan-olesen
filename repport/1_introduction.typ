#import "@preview/subpar:0.2.2"

= Introduction

Spermatogenesis is a complex process that permits the differentiation of stem cells into mature spermatozoa, and is of high relevance in studying infertility conditions and cross-species differences in the biological processes.

Spermatogenesis is a continuous and highly coordinated developmental program of converting stem cells into haploid spermatozoa. The process takes place in the seminiferous tubules of the testis. The cells undergo many different stages and overlapping phases; mitotic expansion of spermatogonial stem cells (SPG) for replenishments and maturation, meiotic division of spermatocytes (SC), reshuffling the genome and reducing ploidy to 23 chromosomes from 46, and spermiogenesis of spermatids (SD) morphological and functional maturation into spermatozoa. The process starts in the walls of the tubules at the basal membrane, and after the mitotic expansion the SPGs fated for spermatozoa moves more central and attaches around supporting sertoli cells.  Each phase includes various distinct cell types. Each with their specific regulatory networks and enhancer programs. @britannicaeditorsSpermatogenesis2025 @quEditorialMammalianSpermatogenesis2024 @kubotaSpermatogonialStemCells2018

== Goals for the project

The initial goals setout during the planning stage were the following:
- Learn basics of git.
- Learn single cell workflow using scanpy, muon and SCVI-tools.
- Work with real messy data.
- Answer the following research questions:
  - Cell states & trajectories: Can we recover a clean spermatogenic trajectory (spermatogonia → spermatocytes → spermatids) and supporting somatic lineages?
  - Peak→gene linkage: Which distal elements likely regulate stage-specific genes?
  - TF programs: Which TFs show coordinated motif accessibility + target expression? (e.g., STRA8, A-MYB, TAF7L)

When the project was done the following had been done:
- Learn basics of git.
- Learn how to setup a reproducible Conda environment.
- Small shell scripts to run on SLURM.
- Learn single cell workflow with scanpy, muon and scvi-tools.
- Work with real messy data.
- Answer: Cell states & trajectories: Can we recover a clean spermatogenic trajectory (spermatogonia → spermatocytes → spermatids) and supporting somatic lineages?
- Successful celltype annotation of both scRNA-seq and scATAC-seq.
- Create LDA models to find cell topics and DARs for scATAC-seq for further analysis.

== Data availability

All environment files, notebooks and scripts as well as the repport files for this project are available on a public github repository: #link("https://github.com/SamueleSoraggi/PIB-johan-olesen")[SamueleSoraggi/PIB-johan-olesen].


== Workflow Overview

The report is divided into four stages each with individual goals highlighting the various stages of the project.

Stage 1 being the preliminary stage of acquiring data and formatting it into a format where analysis can be begun. Stage 1 is described in @stage1. The goal was to acquire data for the project and preprocess it into a format ready for the single cell analysis.

#figure(
  image("figs/stage1_schematic.svg"),
  caption: [Stage 1 schematic of data acquisition and preparation. Goal of the stage is to have the data in proper format as input for stage 2 and stage 3.]
) <stage1>

The goal of stage 2 is to annotate the scRNA-seq data with celltypes. It is described in @stage2. This was implemented in two different ways. One focuses on the using the scanpy library of functions to annotate cell types using marker genes. The other uses a SCVI-tools model to do cell type assignment based on a list of marker genes from raw expression data. End with a comparison of the two methods and pick the best one for input to stage 3 and stage 4.

#figure(
  image("figs/stage2_schematic.svg"),
  caption: [Stage 2 schematic of scRNA-seq celltype annotation. Goal of this stage is to have th scRNA-seq data annotated with celltypes. Note how the analysis branches into two. This shows the two ways of implementating the annotation workflow with a _semi-manual_ way and a SCVI-tools CellAssign model.]
) <stage2>

Stage 3 is about celltype annotation of the scATAC-seq data. Similarly, this was done in two different ways. One uses harmony to integrate and bbknn to do batch correcting to then transfer labels from scRNA-seq to scATAC-seq based on cell neighbours, similar to how Wang et al. did in the paper @wangScRNAseqScATACseqReveal2025 the data is from. The other implementation uses the pycistopic framework to do label transfer using the `label_transfer` function. This does 4 different methods of label transfer; `harmony`, `bbknn`, `cca` and `scanorama`. The second implementation was done when it made sense during stage 4 after the clustering step.

#figure(
  image("figs/stage3_fail_schematic.svg"),
  caption: [Stage 3 schematic of label transfer by integrating scRNA-seq and scATAC-seq. The yellow dots represent start and end of workflow done in parallel for all samples at the same time. Notice how the scRNA-seq data is already processed from the previous stage.]
) <stage3fail>

Flowcharts drawn with `draw.io`.

Stage 4 is the start of further work into finding, which distal elements regulate stage-specific genes and transcription factors and motifs associated with coordinated motif accessibility and target expression. Due to time constraints only the topics and differentially accesible regions was found using the pycistopic workflow. This needs further analysis using pycistarget and the SCENIC+ workflow.

#figure(
  image("figs/pycistopic_schematic.png", height: 80%),
  caption: [Stage 4 schematic of pycistopic workflow from PyCistopic documentation. @gonzalez-blasFeaturesPycisTopicDocumentation The complete pycistopic workflow was run, mainly to prepare for further work with the rest of the SCENIC+ workflow @gonzalez-blasSCENICSinglecellMultiomic2022. The pycistopic label transfer happens after the 'Clusters' step, as that was the step at which the previous annotations seemed inaccurate.]
) <stage3>


== Environment setup with Conda

First step was to get a working environment setup for the analyses. For this Conda was used to create an environment with the required packages, relying on `pip` for the most up-to-date packages, because of having to match newer hardware on GenomeDK cluster.

For the tutorial run, scRNA-seq annotation and label transfer to scATAC-seq, the environmnet `torch_env.yml` was used. This environment includes the scverse's anndata @virshupAnndataAccessStore2024, mudata @virshupScverseProjectProvides2023, scanpy @wolfSCANPYLargescaleSinglecell2018, muon @bredikhinMUONMultimodalOmics2022 and scvi-tools @gayosoPythonLibraryProbabilistic2022 packages, as well as full PyTorch @anselPyTorch2Faster2024 CUDA capabilities for accelerating SCVI-tools models. The PyTorch CUDA was needed to exploit the GPUs on the GenomeDK HPC cluster to be able to run much faster training of models.

For the stage 4 workflow with the scATAC-seq data another environment was used because of versioning requirements; `cistopic_env.yml`, consisting of the SCENIC+ @bravogonzalez-blasSCENICSinglecellMultiomic2023 suite.

All the workflows was done in Jupyter Notebooks on the GenomeDK HPC cluster in interactive jobs. SLURM was used to do work outside the notebooks when needed to exploit parallelisation capabilities or run various other cli tools like Cellranger ATAC @satpathyMassivelyParallelSinglecell2019 and MALLET @MalletMAchineLearning.

== Tutorial run

To start off before real testis data had been found. A quick run through of the tutorial run of multiome 10X PBMC @bredikhinProcessingGeneExpression by Bredikin to get a quick overview of how to work with single cell data and anndata objects, and to check Conda environment worked.

Was succesful in creating the same analysis as the tutorial.