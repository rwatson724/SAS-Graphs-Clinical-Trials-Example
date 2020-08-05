proc template;
 define style customSapphire;
    parent = styles.sapphire;
	class Header / 
	   backgroundcolor=CXdae4f3;
	class Footer / 
	   backgroundcolor=CXdae4f3;
	class RowHeader / 
	   backgroundcolor=CXdae4f3;
	class RowFooter / 
	   backgroundcolor=CXdae4f3;
    class graph / attrpriority="none";
    
   /* These colors were changed from the default:
       'greferencelines'= cx808080
	       'ggrid'= CX797c7e
   */

   class GraphColors /
       'gtext' = black
       'gtextt' = black
       'greferencelines'= cx808080
       'gborderlines' = cx000000
       'goutlines'= cx000000
       'ggrid'= CX797c7e
       'gaxis'= cx000000;

    style body from document / 
	leftmargin=.75in
        rightmargin=.5in
        topmargin=.75in
        bottommargin=.75in;
   
	class fonts /
      'TitleFont2' = ("<MTsans-serif>, Albany",9pt,bold)
      'TitleFont' = ("<MTsans-serif>, Albany",10pt,bold)
      'StrongFont' = ("<MTsans-serif>, Albany",8pt,bold)
      'EmphasisFont' = ("<MTsans-serif>, Albany",8pt,italic)
      'FixedEmphasisFont' = ("<MTmonospace>, Courier",8pt)
      'FixedStrongFont' = ("<MTmonospace>, Courier",8pt,bold)
      'FixedHeadingFont' = ("<MTmonospace>, Courier",8pt,bold)
      'BatchFixedFont' = ("SAS Monospace, <MTmonospace>, Courier",7pt)
      'FixedFont' = ("<MTmonospace>, Courier",8pt)
      'headingEmphasisFont' = ("<MTsans-serif>, Albany",10pt,bold italic)
      'headingFont' = ("<MTsans-serif>, Albany",9pt,bold)
      'docFont' = ("<MTsans-serif>, Albany",8pt);

   /* These attributes were changed from the default:
	  borderwidth=3px
	  cellpadding=4pt
   */
   style table from table /
	   borderwidth=3px
	   cellpadding=2pt
	   borderspacing=.05pt
	   frame=box
	   bordercolor=cx919191
	   bordercollapse=collapse;

   /* 20Dec2018: Made these bold:
      'GraphLabel2Font' = ("<MTsans-serif>, Albany",10pt,bold)
      'GraphLabelFont' = ("<MTsans-serif>, Albany",10pt,bold)
      'GraphValueFont' = ("<MTsans-serif>, Albany",9pt,bold)
   */
   
   class GraphFonts /
      'NodeDetailFont' = ("<MTsans-serif>, Albany",7pt)
      'NodeInputLabelFont' = ("<MTsans-serif>, Albany",9pt)
      'NodeLabelFont' = ("<MTsans-serif>, Albany",9pt)
      'NodeTitleFont' = ("<MTsans-serif>, Albany",9pt)
      'GraphAnnoFont' = ("<MTsans-serif>, Albany",10pt)
      'GraphTitle1Font' = ("<MTsans-serif>, Albany",14pt,bold)
      'GraphTitleFont' = ("<MTsans-serif>, Albany",11pt,bold)
      'GraphFootnoteFont' = ("<MTsans-serif>, Albany",10pt)
      'GraphLabel2Font' = ("<MTsans-serif>, Albany",10pt,bold)
      'GraphLabelFont' = ("<MTsans-serif>, Albany",10pt,bold)
      'GraphValueFont' = ("<MTsans-serif>, Albany",9pt,bold)
      'GraphUnicodeFont' = ("<MTsans-serif-unicode>",9pt)
      'GraphDataFont' = ("<MTsans-serif>, Albany",7pt);

    /* The linethickness for all of these elements was increased to 2px. */
    class GraphBorderLines / lineThickness=2px color=CX000000;
    class GraphAxisLines / lineThickness=2px color=CX000000;
    class GraphOutLines / lineThickness=2px color=cx000000;
    class GraphAnnoLines / lineThickness=2px color=cx000000;
    class GraphReference / lineThickness=2px color=cx808080;
    class GraphWalls / lineThickness=2px;
    class GraphDataDefault / lineThickness=2px;
    class GraphBoxWhisker / lineThickness=2px;
    class GraphBoxMedian / lineThickness=2px;
    class GraphOther / lineThickness=2px;
    class GraphConfidence / lineThickness=2px;
    class GraphAnnoShape / lineThickness=2px;
    class GraphDataNodeDefault /
       linethickness = 2px
       linestyle = 1;
    class GraphOutliers / linethickness=2px linestyle=1;
    class GraphGridLines / lineThickness=2px linestyle = 1 color=cx000000;
end;
run;
