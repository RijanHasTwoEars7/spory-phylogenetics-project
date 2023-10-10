#!/usr/bin/env Rscript

#the_tree <- read.tree("Base_tree.txt")
#d <- read.table("highlight_scheme.tsv", header=TRUE, sep=",")
#ggtree(the_tree, branch.length = "none") + geom_tiplab(aes(label=node), size = 3,parse=TRUE, hjust=-0.1) + xlim(0,25)
#ggsave("Highligted_tree_with_labelled_nodes.pdf", width = 60, height = 60, units = "cm", limitsize = FALSE) 

library(optparse)
library(ggtree)
library(data.table)

option_list = list(
  make_option("--table", type="character", default=NULL, help="The table that contains the data for the nodes to be highlighted. Supply tsv or change delimiter when df is being read in. The two columns should be 'Node' for nodes to be labelled and 'Name' for their names."),
  make_option("--tree", type="character", default=NULL, help="The name of the file that contains the tree in newick format."),
  make_option("--plot", type="character", default=NULL, help="The full name for the output file."),
  make_option("--label", type="character", default=FALSE, help="Should the label provided in the newick files be used instead of the label generated from parsing?")
)

opt_parser = OptionParser(option_list=option_list)

args = commandArgs(trailingOnly = TRUE)
opt = parse_args(opt_parser, args=args)

if (!file.exists(opt$tree)) {
  stop(opt$tree, "could not be found. Please check that this file exists or if the correct locaiton was supplied.")
}

the_tree <- read.tree(opt$tree)


if(is.null(opt$table)){

  if(opt$label) { # if false use the labels as provided by parsing
    ggtree(the_tree, branch.length = "none") + geom_tiplab(align=TRUE, linesize=.5) + geom_text2(aes(label = ifelse(!isTip, node, "")), size = 3,parse=TRUE, hjust=-0.1) + xlim(0,25)
  } else{ # if true then use the labels in the newick
    ggtree(the_tree, branch.length = "none") + geom_text2(aes(label = label), size = 3, hjust=-0.1) + xlim(0,25)
  }
} else{

  if (!file.exists(opt$table)) {
  stop(opt$table, "could not be found. Please check that this file exists or if the correct locaiton was supplied.")
  }

  df <- fread(opt$table, header=TRUE)

  if(opt$label) { # if false use the labels as provided by parsing
    ggtree(the_tree, branch.length = "none") + geom_hilight(data=df, aes(node=Node, fill=Name)) + geom_tiplab(align=TRUE, linesize=.5) + geom_text2(aes(label = ifelse(!isTip, node, "")), size = 3,parse=TRUE, hjust=-0.1) + xlim(0,25)
  } else{ # if true then use the labels in the newick
    ggtree(the_tree, branch.length = "none") + geom_hilight(data=df, aes(node=Node, fill=Name)) + geom_text2(aes(label = label), size = 3, hjust=-0.1) + xlim(0,25)
  } 

}

ggsave(opt$plot, width = 60, height = 60, units = "cm", limitsize = FALSE)