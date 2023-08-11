# Paul and carrol have  a workflow to generate chromosome counts for plant species. 
# This script adds the status of these species' genomes and their metadata using the [NCBI API](https://www.ncbi.nlm.nih.gov/datasets/). 
# This script adds takes the CCDB data from paul and corrol and adds the genomic metadata to the dataframe and makes a new dataset

# dependecies:
	# @call_datasets.sh -> The bash script that calls the NCBI API to generate counts for the list of species.
	# @parse_datasets_json.jl or parse_datasets_json.py -> The script that generates the second dataframe (explained below) for this script.

# params:
	# @CCDB_cleanedData_complete_genus.csv -> The data from paul and carrol. Hopefully, updateable.
	# @{seond dataframe} -> The output from @parse_datasets_json

# please note:
	# The NCBI datasets API is in beta and at this time lacks customizability when it comes to data output. Calling the API for multiple kinds of metadata values, so we have to call the NCBI API multiple times for different kinds of data. In this specific case, to receive counts of complete genomes and incomplete genomes. 
	#TODO change this in the future if possible.

library(tidyverse)
library(glue)
library(optparse)

option_list = list(
	make_option("--first_df", type="character", default=NULL, help="The CCDB data from https://doi.org/10.3389/fpls.2022.807302. Should be CSV."),

	make_option("--second_df", type="character", default=NULL, help="The data from parse_datasets_json. Should be tsv."),

	make_option("--output",type="character",default=NULL, help="The name for the output file.")
)

opt_parser <- OptionParser(option_list=option_list, description="Please make sure to supply the data in the proper format.\nAbove all else, both the dataframes should have a coulmn with bionomial names which will be used to merge the two dataframes.\nGiven that the CCDB data does not have this at this time,it is added by the script.\nMake sure that the data from parse_datasets_json is in the right format as well i.e. both the count and the species_name column should be present.")

args = commandArgs(trailingOnly = TRUE)
opt = parse_args(opt_parser, args=args)

if (!file.exists(opt$first_df)) {
    stop(opt$first_df, "could not be found. Please check that this file exists or if the correct locaiton was supplied.")
}

if (!file.exists(opt$second_df)) {
    stop(opt$second_df, "could not be found. Please check that this file exists or if the correct locaiton was supplied.")
}

ccdf <- read_csv(opt$first_df, show_col_types = FALSE)

count_df <- read_tsv(opt$second_df, show_col_types = FALSE)

binomial <- strsplit(ccdf$resolved_name, "\\s")

ccdf$binomial_resolved_names <- sapply(binomial, function(x) paste(x[1:2], collapse = " "))

merged_df <- merge(ccdf,count_df,by.x = "binomial_resolved_names", by.y = "species_name", all.x = TRUE)

write.table(merged_df,opt$output,sep='\t',row.name =FALSE)