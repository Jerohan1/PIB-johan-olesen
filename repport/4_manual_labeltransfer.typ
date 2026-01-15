#import "@preview/subpar:0.2.2"

= Stage 3: Celltype annotation of scATAC-seq data with label transfer

After annotating the scRNA-seq data we can use that to annotate the scATAC-seq data. Firstly, each sample was processed similar to the scRNA-seq data of quality control, filtering, normalised and LSI transformation instead of PCA. A gene activity matrix was created from the filtered cells and features from _refdata-cellranger-arc-GRCh38-2024-A_.

The gene activity matrix is a proxy for gene expression. This works as the ATAC data consist of the open chromatin regions. Active transcription and therefore expression of RNA happens in these open chromatin regions. It is not a perfect comparison as the open chromatin regions also contain many other elements and not only genes.

Next, the combined RNA matrix and gene activity matrix are normalised, scaled and PCA transformed, before being concatenated together. This ensures best possible label transfer between the two sets. `harmony` was used to integrate the two sets, followed by `bbknn` to remove batch effects between the RNA set and ATAC set.

Finally, doing the label transfer of celltype from scRNA-seq to scATAC-seq. The label transfer was done by finding the RNA neighbours of each ATAC cell and assigning the consensus cell. If the distance was too big from an ATAC cell to its neighbours, the cell was not assigned during the first pass. On the second pass the already assigned ATAC cells was included as neighbours. Passes were repeated until all cells had been annotated.

Looking at individual results using the NOA1 sample as an example in @NOA1_integration. It looks like we get well defined results for each of the samples. A common theme through the samples is that the majority of the cells are germline cells. Plots are misleading in the amount of cells. The OA samples included a factor of 5 times more cells than the NOA samples. The reason for this is the fact that OA patients have normal spermatogenesis with obstruction of sperm entering semen in some way, while NOA patient may have problems with the spermatogenesis by itself. @zhouConstructionExternalValidation2021 @modgilUpdateDiagnosisManagement2016

The complete set of all samples can be found in @integration_complete. For each sample we once again capture a continuous cluster for the germline cells.

#subpar.grid(
  figure(
    image("figs/NOA1_atac_files/NOA1_atac_36_0.png"),
    caption: [UMAP plot of NOA1 scATAC-seq integrated with combined RNA.],
  ), <NOA1_tech>,

  figure(
    image("figs/NOA1_atac_files/NOA1_atac_41_0.png"),
    caption: [NOA1 celltype assignment after label transfer.],
  ), <NOA1_celltype>,
  label: <NOA1_integration>,
  columns: 2,
  caption: [UMAP plot of NOA1 integration.],
)

By concatenating each ATAC sample into one object and integrating them collectively with combined scRNA-seq using `harmony`, and batch correcting with `bbknn` results in @integrated. It is hard to tell the germline cells from the somatic lineages except macrophages and endothelial, so by only looking at the subset of cell marked as one of the germline cell and doing the integration and batch correction yields @integrated_seperate.

#figure(
  image("figs/scRNA_ATAC_integration_files/scRNA_ATAC_integration_9_0.png"),
  caption: [UMAP plot of integrated scATAC-seq on scRNA-seq],
) <integrated>

This time the spermatids, early round, round and elongated, are in a separate cluster from the spermatogonia and spermatocytes. Intersestingly, the ATAC_OA1 sample produces these long arm clusters of various spermatocytes on @integrated_germ and of macrophages and endothelial cells on @integrated_somatic.

#subpar.grid(
  figure(
    image("figs/scRNA_ATAC_integration_files/scRNA_ATAC_integration_15_0.png"),
    caption: [Germline subset.],
  ), <integrated_germ>,

  figure(
    image("figs/scRNA_ATAC_integration_files/scRNA_ATAC_integration_16_0.png"),
    caption: [Somatic cells subset],
  ), <integrated_somatic>,
  caption: [UMAP plot of the integrated scATAC-seq on scRNA-seq subsets for easier visualisation with sample and cell type.],
  columns: 2,
  label: <integrated_seperate>
)

In conclusion, the scATAC-seq data has been successfully annotated using label transfer from scRNA-seq data producing an expected continuous flow of germline cells through the different developmental stages.