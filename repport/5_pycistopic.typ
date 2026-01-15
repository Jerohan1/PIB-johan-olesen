#import "@preview/subpar:0.2.2"

= Stage 4: Pycistopic workflow to get topics and differentially accesible regions

For stage 4 the goal was to do the pycistopic workflow and get the topics and differentially accesible regions to prepare for further analysis in the SCENIC+ workflow.

== Preparing for cistopic objects

First, pseudobulk peak calling was done on the scATAC-seq fragment files, using the scATAC-seq integrated data from stage 3 to annotate. This gave a bigwig and bed file for each different cell type. Peak calling was then done using MACS3 version 3.0.3 @zhangModelbasedAnalysisChIPSeq2008 on the cell type specific fragment pseudobulk bed files with default settings.

To get the consensus peaks for all the celltype, the unified blacklist for GRCh38 call set ENCFF356LFX @ENCFF356LFXENCODE was downloaded and ran the `get_consensus_peaks` function. Quality control was run on all the sample using the `qc` command and the consensus peaks using SLURM. Then using the generated QC reports, used automatic threshold values to filter out bad cells. The valid cells were then made into cistopic objects and concatenated together into one cistopic object.

The combined cistopic object of the filtered cells were annotated with the label transfered cell types. Doublets were further removed using `scrublet` @wolockScrubletComputationalIdentification2019.

== LDA Model selection

Next the actual topic modeling was performed by Latent Dirichlet Allocation, LDA, using a Collapsed Gibbs Sampler. As the optimal number of topics to use for the data was unknown, multiple different models had to be run.

The models were run using Mallet @MalletMAchineLearning with SLURM. Mallet enables the parallelisation to be done within each model. Each model was run in a separate job for speed.

Loading each model and evaluating their performance gives the optimal model to be the 30 topics model. The model selection is show in @cistopic_model_selection. The model selection was done by looking at the best performer among the four criteria implemented in pycistopic. According to pycistopic tutorial @gonzalez-blasFeaturesPycisTopicDocumentation, Minmo_2011 and Loglikelihood are the best for scATAC-seq. The model selection is not critical, as long as it is not of either extreme end.

#figure(
  image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_47_0.png"),
  caption: [LDA model selection. Most important metrics are the Minmo_2011 and Loglikelihood],
) <cistopic_model_selection>

== Clustering

Leiden clustering of the cistopic object was done with resolutions of 0.6, 1.2 and 3. Resulting clusters can be seen on @cistopic_clustering. The previous celltype annotation seemingly do not match the clustering done on the cistopic object, as the different cell types are spread all over the place. This likely indicates something has gone wrong in either previous label transfer or in the cistopic workflow. As the cell types are used for both looking at enhancers and other regulons the results from the rest of the pycistopic run are unreliable as the the model is trained on potentially badly annotated data. This rolls over into impacting the topic annotation as well.

#figure(
  image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_61_0.png"),
  caption: [Leiden clustering of scATAC-seq cistopic object. On the left is the label transferred celltypes from stage 3.],
) <cistopic_clustering>

== Topics

A topic in this context is a group of genomic regions that tend to be co-accessible across cells. In pycistopic specifically, they are regulatory topics. Cells are assigned a weight to each topic meaning cells can function in several topics at once. @gonzalez-blasFeaturesPycisTopicDocumentation

Looking at the topics in @cistopic_enrichment_UMAP, we see each topic is enriched in different cells. With cells being enriched in multiple topics.

#figure(
  image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_72_0.png"),
  caption: [Topic enrichment for all 30 topics. Note the colour scale is not comparable between topics.],
) <cistopic_enrichment_UMAP>

Next, to binarize topic-region and cell-topic distributions. Topic-region is used further downstream in the SCENIC+ workflow and cell-topic distributions is used to annotate topics.

Followed the pycistopic recommendations and used the `otsu` @otsuThresholdSelectionMethod1979 and `ntop` methods for the topic-region, and `li` method @liMinimumCrossEntropy1993 for cell-topic distribution. As an example, topic 19 is shown for all methods in @select_bin_plots. The plots of the other topics are very similar and can be found in @bin_plots. The topic 19 is an exception in the cell-topic plots, as it allow more than double the amount of cells than most other topics.

The topic-region plots, namely those undergone otsu and ntop methods, the standardised threshold is ~0.1-0.3 with most being around 0.2 for `ntop`, ~0.05-0.1 consistently smaller than ntop. This results in included upwards of 5 times as many regions in each topic.

The topic-cell plots, shows a similar story as the topic-region plots. Now instead of looking at region count, it looks at cell count. Most of the topics have low cell counts in the range of 249-4000, but also a pair of outliers with more than 8000 cells.

#subpar.grid(
  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_79_0_1.png"),
    caption: [Otsu method.],
  ), <otsu>,

  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_81_0_1.png"),
    caption: [ntop method. Top 3000 regions chosen.],
  ), <ntop>,

  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_83_0_1.png"),
    caption: [Li method.],
  ), <li>,
  columns: 3,
  caption: [Binarization plots for the 3 different methods; otsu, ntop and li. x-axis showing standardised probability of region being in topic. y-axis explaining count of regions in `otsu` and `ntop`, count of cells in `li`. Selected indicating number of regions selected for a specific topic. Redline indicating automatic minimum threshold for inclusion in topic.],
  label: <select_bin_plots>,
)

Quality control was done on the topic binarization resulting in @bin_qc for the ntop method.

#figure(
  image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_88_0.png"),
  caption: [Quality control metrics for topics. Coherence measure how high-scoring regions are co-accesible in the original data, the higher the better. Marginal topic distribution explains how much each topic contributes to the model, higher is better. Gini index describing the specificity of the topic, higher being more specific. @gonzalez-blasFeaturesPycisTopicDocumentation],
) <bin_qc>

From @bin_qc, topic 8, 16, 20 and 23 showcase high specificty to their topic as indicated by the gini index, and high cell specificity from the relatively low amount of cells. This likely indicates enhancer programs for these specific cells. Having a high coherence also indicates regulatory programs in these topics.

The topics can be annotated with celltypes using the binarized cell topics. This results in a table showing which cell types are included in each cell topic. The proportion of cells in each group that are assigned to the binarized topic and the proportion of cells in whole dataset of those cell type are used as metrics to calculate if the topic can be considered too general. If the difference between the two proportions is great, then it indicates that the topic is too broad as it means the topic is capturing both the focus cells and the background.

== Differentially accessible regions

Using the cell-topics and topic-region to impute differentially accesible regions between cell types. This is done using a Wilcoxon rank-sum test across the different celltypes. As a result this is impacted by the potentially inaccurate cell type annotations. Next, using the imputed accesible region to find differentially accesible genes, DAGs. On @cistopic_marker_enrichment a collection of DAGs of some of the marker genes used for annotation previously is shown. It highlights clearly that in comparison to @cistopic_clustering left, the celltype annotations does not match, what is seen in the data. For example; _CCL2_ a marker for T-cells is only accesible in the middle cluster. _FAM24A_ localised in the far left of the left-most cluster, while the annotation places the early round spermatids in every cluster. Generally, the big leftmost cluster corresponds to the spermatocytes and spermatids from just looking at the DAGs.

#figure(
  image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_119_0.png"),
  caption: [Enrichment of certain marker genes. Note colour scale is different for each DAG. _CD52_; B, _VWF_; endothelial, _CFD_; leydig, _CD14_; macrophage, _CCL2_; mast, _CXCR4_; plasma, _DPEP1_; PMC, _S100B_; schwann, _APOA1_; sertoli, _TAGLN_; smooth muscle, _CCL5_; T, _PIWIL4_; SSC0, _ID4_; SSC1.SPG, _DMRT1_; Diffing.SPG, _SSX3_; Diffed.SPG, _DPH7_ PreLeptotene.SC, _PIWIL1_; Pachytene.SC, _ART5_; Diplotene.SC, _FAM24A_; Early.Round.SD, _PRM2_; Elongated.SD],
) <cistopic_marker_enrichment>

== Label transfer

At this point the label transfer built in pycistopic was used to do the label transfer from the scRNA-seq to scATAC-seq, that was in the cistopic object to see if the previous label transfer was inaccurate. Using harmony, bbknn, scanorama and cca results in @cistopic_cellannotation. As can be seen, harmony, bbknn and scanorama produce similar clusters for all cell types. cca is more mixed, especially in the smaller clusters, that harmony, bbknn and scanorama clearly define. In contrast to an earlier statement about the leftmost cluster corresponding to spermatocytes and spermatids, the four methods all agree on assigning spermatocytes and spermatogonia here instead. This could be because of the limited subset of marker genes focused on in @cistopic_marker_enrichment. In general the flow of developmental stages starts at the bottom right, goes left and up, from spermatogonia to spermatocytes. Not surprisingly, all methods fail in annotating the tiny middle cluster. As seen on @cistopic_marker_enrichment this likely corresponds to the immune cells, T and B-cells, which were virtually absent in the scRNA-seq or filtered out in one of the two undefined clusters.

#figure(
  image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_144_0.png"),
  caption: [Celltype annotation using harmony, bbknn, scanorama and cca integration methods using scRNA-seq to annotate.],
) <cistopic_cellannotation>

Using the label transferred cell types instead of the previous cell type annotation the topics line up in blocks on @cistopic_enrichment_cellannotation for the corresponding celltypes as expected instead of being completely jumbled as on a previous attempt @cistopic_enrichment_prevcellannotation.

#subpar.grid(
  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_147_0.png"),
    caption: [Topic enrichment heatmap for harmony annotated cell types. Each vertical line corresponds to a single cell.],
  ), <cistopic_enrichment_cellannotation>,

  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_76_0.png"),
    caption: [Topic enrichment heatmap for the stage 3 celltype annotations in comparison to pycistopic leiden clustering with resolution 1.2. Each vertical line corresponds to a single cell. `celltype_leiden` is previous celltype annotation.],
  ), <cistopic_enrichment_prevcellannotation>
)

A late observation during the project noted that the filtering of cells during the pycistopic workflow cut the already filtered cells in half.

In conclusion, the whole pycistopic notebook should be rerun as the ATAC cells supplied at the first annotation are already filtered, so it does not make sense to do a second round of filtering and doublet removal. This means the result shown here are only of a subset of the cells annotated in stage 3. 52656 cells are in the combined processed scATAC-seq set, but only 20803 are in the cistopic object. Along with the already mentioned problem of the celltype annotations in stage 3 seemingly being inaccurate according to the LDA model and subsequent topic modeling. The pycistopic workflow should be run again adjusting corresponding sections.