#let conf(doc) = {

  // Page Settings //
  set page(paper: "a4")
  // header: align(right+horizon, title)
  set align(left)

  // Set numbering mode
  set page(numbering: "1")
  set math.equation(numbering: "(1)")
  set heading(numbering: "1.1")

  // Set fonts
  set text(font: "New Computer Modern")
  show raw: set text(font: "JetBrains Mono")
  show math.equation: set text(font: "New Computer Modern Math")
  set text(ligatures: true)

  // Set font size
  set text(lang: "en", size: 12pt)
  show heading.where(level: 3): set text(size: 1.05em)
  show heading.where(level: 4): set text(size: 1.0em)
  show figure: set text(size: 0.8em)
  show table: set text(size: 0.7em)

  // Set spacing
  set par(leading: 0.9em, first-line-indent: 1.5em, justify: true)
  set block(spacing: 1em)
  set table(inset: 4pt)
  show table: set par(justify: false)
  show figure: it => [#v(0.3em) #it #v(0.3em)]

  show heading.where(level: 1): set block(above: 1.95em, below: 1em)
  show heading.where(level: 2): set block(above: 1.85em, below: 1em)
  show heading.where(level: 3): set block(above: 1.75em, below: 1em)
  show heading.where(level: 4): set block(above: 1.55em, below: 1em)

  //show figure: set block(breakable: true)

  //Pagebreak after level 1 headings
  show heading.where(level: 1): it => [
   #pagebreak(weak: true)
   #it
  ]

  // Set citation style
  set cite(style: "council-of-science-editors")

  // Table settings
  set table(align: left,
            stroke: 0.5pt + black,
            fill: (_, row) => {
              if row == 0 {
                rgb(220, 220, 220)
              } else if calc.rem(row,  2) == 0 {
                rgb(242, 242, 242)
              } else {
                rgb(255, 255, 255)
              }
            },
  )

  // show reference targets
  show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      [*#it*]
    } else [#it]
  }

  // color links and references
  // show ref: set text(weight: "m")
  show link: set text(fill: blue)

  // style table-of-contents
  show outline.entry.where(
    level: 1
  ): it => {
    strong(it)
  }

  doc
}

#let title_page(title, rapporttype, authors) = {
  align(horizon, text(size: 24pt, fill: black)[*#title*])

  line(length: 100%, stroke: 2pt + rgb("#E73021"))
  linebreak()

  align(center, text(18pt)[#rapporttype])

  linebreak()

  set align(center)
  let count = authors.len()
  let ncols = calc.min(1, 3)
  grid(columns: (1fr, ) * ncols,
        row-gutter: 24pt,
        column-gutter: 12pt,
        ..authors.map(author => [
          #author.name \
          #author.role \
          #author.affiliation
        ]))

  align(right+bottom, datetime.today().display("[day].[month].[year]"))

  pagebreak()
}

#let bib(bib_path) = {
  set par(leading: 0.7em, first-line-indent: 0em, justify: true)
  bibliography(bib_path, title: [References], style: "council-of-science-editors")
}