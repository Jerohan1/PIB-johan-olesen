#import "@preview/subpar:0.2.2"

#set page(numbering: "i")
#counter(page).update(1)

#show figure: set block(breakable: true)

#let appendices(body) = {
  pagebreak()
  counter(heading).update(0)
  counter("appendices").update(1)

  set heading(
    numbering: (..nums) => {
      let vals = nums.pos()
      let value = "ABCDEFGHIJ".at(vals.at(0) - 1)
      if vals.len() == 1 {
        return "Appendix " + value
      }
      else {
        return value + "." + nums.pos().slice(1).map(str).join(".")
      }
    }
  );

  [#body]
}

#show: appendices

= Cellranger

Naming scheme for Cellranger ATAC count @SpecifyingInputFASTQ: `[Sample Name]S1_L00[Lane Number][Read Type]_001.fastq.gz`, where `Read type`:
  - `I1`: Dual index i7 read (optional)
  - `R1`: Read 1
  - `I2`: Dual index i5 read
  - `R3`: Read 2

`Lane Number` does not matter. `Sample Name` can be anything.

Example of NOA1 sample:
- SRR31097965_S1_L001_I1_001.fastq
- SRR31097965_S1_L001_I2_001.fastq
- SRR31097965_S1_L001_R1_001.fastq
- SRR31097965_S1_L001_R2_001.fastq

= scRNA-seq

#figure(
  table(
    align: left,
    columns: 2,
    table.header([*Cell Type*], [*Marker Genes*]),
    [Sertoli], [SOX9, GATA1, ACSL4, WT1, GAS6, VIM, CD99, APOA1],
    [Leydig], [CFD, IGF1, IGFBP5, INSL3],
    [Myoid], [MYH11, ACTA2],
    [Macrophage], [CD68, CD163, MSR1, CD14],
    [Endothelial], [VWF, SOX17],
    [B], [CD52],
    [Mast], [TPSB2],
    [T], [CCL5],
    [Plasma], [IGLC2],
    [PMC], [DPEP1],
    [Schwann], [S100B],
    [Smooth muscle], [TAGLN],
    [SSC1.SPG], [ID4, UTF1, TWIST1, KRT18, AES, ENHO, C19orf84, SIX1, PIWIL4],
    [SSC2.SPG], [ASB9, L1TD1, NANOS3, FAM25G, CITED2],
    [Diffing.SPG], [MKI67, ACTL8, KLHL15, DMRT1, PABPC4],
    [Diffed.SPG], [SSX3, TEX19, PNMA6E, PEG10, TKTL1, BEND2],
    [PreLeptotene.SC], [DPH7, PRDM9, PRAP1, KIF1A, MAGEA9B, FAM9C, ATP6AP1, OTUD6A, CCNB3],
    [Leptotene.Zygotene.SC], [LINC00668, AP000350.6, LINC01120, AL138889.1, LINC00865, C18orf63],
    [Pachytene.SC], [PCDHB6, POM121L12, POM121L2, C9orf57, AL133279.3, AC093326.2, AL353581.1, PCDHB5, PCDHB2, AC135012.2, MNS1, CCDC42],
    [Diplotene.SC], [ART5, KLB, B3GALT4, ELMO3, RTN4RL2, AC073263.2, LINC00588, WNT6, LINC01309, AL121936.1, KRT72, LDHC],
    [Early.Round.SD], [FAM24A, SPACA1, LINC01351, ABRA, LINC00703, LINC02502, PPP1R27, H1F0, TPRG1, LRRC39, C1orf87, TMIGD3],
    [Round.SD], [TNP2, LINC02314, LINC01921, PRSS37, FBXO39, LINC02400, DHRS3, FAM205C, CXorf65, SCP2D1, LINC01548, CCDC179, AC010255.3, SPEM3],
    [Elongated.SD], [TSSK6, CABS1, SPATA3, CCDC196, TSPAN16, PHOSPHO1, SPEM2, TEX44, LRRD1, SPEM1, GLUL],
  )
) <markers>

= scATAC-seq

== UMAP plots of integration of each scATAC-seq sample <integration_complete>

#subpar.grid(
  figure(
    image("figs/NOA1_atac_files/NOA1_atac_36_0.png"),
    caption: [NOA1 batch],
  ), <NOA1_tech>,

  figure(
    image("figs/NOA1_atac_files/NOA1_atac_41_0.png"),
    caption: [NOA1 celltyp assignment],
  ), <NOA1_celltype>,

  //-----------------

  figure(
    image("figs/NOA2_atac_files/NOA2_atac_35_0.png"),
    caption: [NOA2 batch],
  ), <NOA2_tech>,

  figure(
    image("figs/NOA2_atac_files/NOA2_atac_40_0.png"),
    caption: [NOA2 celltype assignment],
  ), <NOA2_celltype>,

  //------------------

  figure(
    image("figs/NOA3_atac_files/NOA3_atac_35_0.png"),
    caption: [NOA3 batch],
  ), <NOA3_tech>,

  figure(
    image("figs/NOA3_atac_files/NOA3_atac_40_0.png"),
    caption: [NOA3 celltype assignment],
  ), <NOA3_celltype>,

  //------------------

  figure(
    image("figs/OA1_atac_files/OA1_atac_36_0.png"),
    caption: [OA1 batch],
  ), <OA1_tech>,

  figure(
    image("figs/OA1_atac_files/OA1_atac_41_0.png"),
    caption: [OA1 celltype assignment],
  ), <OA1_celltype>,

  //------------------

  figure(
    image("figs/OA2_atac_files/OA2_atac_35_0.png"),
    caption: [OA2 batch],
  ), <OA2_tech>,

  figure(
    image("figs/OA2_atac_files/OA2_atac_40_0.png"),
    caption: [OA2 celltype assignment],
  ), <OA2_celltype>,


  columns: 2,
  caption: [UMAP plots of integration of each scATAC-seq sample],
  label: <atac_integration_individual>,
)

= PyCistopic Workflow

== QC <cistopic_qc>

#subpar.grid(
  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_23_1.png"),
    caption: [],
  ),

  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_23_2.png"),
    caption: [],
  ),

  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_23_3.png"),
    caption: [],
  ),

  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_23_4.png"),
    caption: [],
  ),

  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_23_5.png"),
    caption: [],
  ),
)

#figure(
  image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_70_0.png"),
  caption: [Statistics of scATAC-seq],
) <cistopic_stats>

== Binarization plots <bin_plots>

#subpar.grid(
  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_79_0.png"),
    caption: [Otsu method.],
  ),

  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_81_0.png"),
    caption: [ntop method. Top 3000 regions chosen.],
  ),

  figure(
    image("figs/pycictopic_on_integrated_files/pycictopic_on_integrated_83_0.png"),
    caption: [Li method.],
  ),
  columns: 1,
  caption: [Binarization plots for the 3 different methods; otsu, ntop and li. x-axis showing standardised probability of region being in topic. y-axis explaining count of regions in `otsu` and `ntop`, count of cells in `li`. Selected indicating number of regions selected for a specific topic. Redline indicating automatic minimum threshold for inclusion in topic.],
)