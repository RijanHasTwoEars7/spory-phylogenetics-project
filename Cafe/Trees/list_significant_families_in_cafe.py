# dependencies
    # traverse_cafe_tree.py
    # The output generated by traverse_cafe_tree.py i.e. a table with focal node, parents, children and siblings listed per row.

# input params
    # @ tsv file -> A tsv file with focal nodes,children, parents and siblings per row. The siblings and children should be separated by commans within the table cells.
    # @ base_asr.tre -> The list of trees generated by cafe.

import pandas as pd
import argparse
import os
import re

parser = argparse.ArgumentParser(description="Take a tsv file/table and the base_asr.tre file to tabulate the list of respective families that have experienced significant change. Edit the source code to account for CSVs or any other format.")

input_group = parser.add_argument_group('Input file arguments')

input_group.add_argument('--table',nargs='?',const='bar', help='The table that contains the tsv.')

input_group.add_argument('--trees',nargs='?',const='bar',help='The file that contains the cafe generated trees.')

output_group = parser.add_argument_group('Output group arguments')

output_group.add_argument('--output',nargs='?',const='bar', help='The name for the output file. The output will be made up of two files {output}.counts, {output}.names')

args = parser.parse_args()

# make sure that the input files exist
for action in parser._action_groups:
    if action.title == 'Input file arguments':
        for arg in action._group_actions:
            arg_value = getattr(args,arg.dest)
            if os.path.exists(arg_value):
                pass
            else:
                print(f"Cannot open '{arg_value}', please make sure it exits or the path is supplied correctly.")

df = pd.read_csv(args.table, sep = '\t')

df.replace(r'>.*', ">", regex=True, inplace = True) # this removes extraneous characters past > (if any exist). This is applicable to cafe only.

trees = open(args.trees, 'r')

all_families = trees.readlines()

def query_asr(cell_data):

    cell_data = cell_data.rsplit(',')

    focal_families = []

    OG_pattern = r'OG[0-9]+'

    for node in cell_data:
        node = f"{node}\*" # the slash is there to espace the wildcard of *.
        for line in all_families:
            if re.search(node,line):
                m = re.search(OG_pattern,line)
                #print(m)
                if m:
                    focal_families.append(m[0])

    list_of_families = ",".join(focal_families)

    return(list_of_families)

df_result = df.applymap(query_asr)

families = f"{args.output}.families"

df_result.to_csv(families, sep='\t', index=False)

counts = f"{args.output}.count"

count_df = df_result.applymap(lambda x: len(str(x).split(',')))

count_df.to_csv(counts,sep='\t', index=False)
