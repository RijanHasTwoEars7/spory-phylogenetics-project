# Background
    # The Core Chromosomal Database (CCDB) at https://doi.org/10.3389/fpls.2022.807302 provides a comprehensive tabulation of chromosomal counts across green plants. 

    # The database contains five main sections - 'major_group', 'family', 'genus', and 'resolved_name' representing respective classification levels, and two columns for gametophytic and sporophytic chromosome counts respectively for each species listed; 

    # additionally, it contains an indication of whether the species is heterosporous or homosporous ('spory').

    # This data provides valuable insight into current understanding of plant evolution by providing detailed information on phylogenetic relationships between different taxa based on their chromosomal count patterns over time.

# Purpose
    # Take https://doi.org/10.3389/fpls.2022.807302's core data and generate various summary statistic on based on various classification levels.

# Dependencies:
    # @CCDB - The main data to be supplied to the script, with at least the above-mentioned data-fields supplied.
    # @R env - Tidyverse.

packages <- c("tidyverse","glue","optparse","hdd","dplyr")

#new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
#if(length(new.packages)) install.packages(new.packages)

for (package in packages) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package, dependencies = TRUE)
    suppressMessages(library(package, character.only = TRUE))
  } else {
    suppressMessages(library(package, character.only = TRUE))
  }
}

option_list = list(

	make_option("--ccdb", type="character", default=NULL, help="The CCDB data from https://doi.org/10.3389/fpls.2022.807302."),

	make_option("--classes", type="character", default=NULL, help="Which classification classes to tabulate. Supply comma separated with no spaces."),

	make_option("--counts",type="character",default=NULL, help="Which columns to summarize .i.e calculate inferrential statistics for. Supply comma separated with no spaces."),

    make_option("--output",type="character",default=NULL, help="The name for the output files. The name will be made as {output}_{class}_{count}.")
)

opt_parser <- OptionParser(option_list=option_list, description="")

args = commandArgs(trailingOnly = TRUE)
opt = parse_args(opt_parser, args=args)

df <- read.delim(opt$ccdb,sep=guess_delim(opt$ccdb)) # guess_delimiter for convenience

#Group the data by the class column and then computes various summary statistics for the count column within each group. The summary statistics calculated include:
#
#    highest_value: The maximum value of the count column.
#    highest_name: The corresponding resolved_name entry for the maximum value of count.
#    lowest_value: The minimum value of the count column.
#    lowest_name: The corresponding resolved_name entry for the minimum value of count.
#    mean_value: The mean (average) value of the count column.
#    resolved_mean_name: The resolved_name entry for the value in count closest to the mean value.
#    median_value: The median (middle) value of the count column.
#    resolved_median_name: The resolved_name entry for the value in count closest to the median value.
#    mode_value: The mode (most frequent) value of the count column.
#    resolved_Mode_name: The resolved_name entry for the value in count closest to the mode value.
#
#After executing the code, you would get a new data frame that contains the calculated summary statistics for each unique class in the original data frame.

insights <- function(count, class) {
  #eval(substitute(count),df)
  #eval(substitute(class,df))
  df_ph <- df %>%
  group_by(get(class)) %>%
  summarize(highest_value = max(get(count)),
  highest_name = resolved_name[which.max(get(count))],
  lowest_value = min(get(count)),
  lowest_name = resolved_name[which.min(get(count))],
  mean_value = mean(get(count)),
  resolved_mean_name = resolved_name[which.min(abs(get(count) - mean(get(count))))],
  median_value = median(get(count)),
  resolved_median_name = resolved_name[which.min(abs(get(count) - median(get(count))))],
  mode_value = names(sort(table(get(count)), decreasing = TRUE))[1],
  resolved_Mode_name = resolved_name[which.min(abs(get(count) - as.numeric(mode_value)))])

  return(df_ph)
}

if (!file.exists(opt$ccdb)) {
  stop(opt$ccdb, "could not be found. Please check that this file exists or if the correct location was supplied.")
}

# if classes have more than one item supplied
# \\p{Z} handles spaces
if (!is.null(opt$classes)) {
  c_classes <- unlist(strsplit(opt$classes, ","))
}else {
  stop("No classes provided. Please go over the help message.")
}

if (!is.null(opt$counts)) {
  c_counts <- unlist(strsplit(opt$counts, ","))
}else {
  stop("No count columns provided. Please go over the help message.")
}

for (count in c_counts) {
  for (class in c_classes) {
    df_back <- insights(count,class)
    df_name <- glue("{opt$output}_{count}_{class}.tsv")
    write.table(df_back,df_name,sep='\t')
  }
}
