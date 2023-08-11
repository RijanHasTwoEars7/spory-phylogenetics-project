# This version of `make_clean_mirror.py` has the following improvements:
    # 1. Keeps all the pickles in memory, which dramatically makes the code faster. On the largest orthogroups it has gone from 900 seconds to 1.32 seconds.
    # 2. Uses a custom numpy array to keep the data for new output files or in this case mirror CDSs.
# This script does not yet have multi-threading to process multiple files at the same time. This should make things even faster but the improvement in the code is satisfactory as is now.

import argparse 

import pickle

import os

import numpy as np

import multiprocessing

# Adding command line flags to the script using argparse

# Grouping argparse flags to make them more useful and indexable

parser = argparse.ArgumentParser(description=" This script takes an orthogroup with peptide sequences and generates a corresponding orthogroup with cds sequences. Two things are absoultely necessary, first a dict to identify the species in the sequence header using the most common subscript and dictified cds fastas with similar headers.")

location_group = parser.add_argument_group('Location arguments')

location_group.add_argument('--pickle',nargs='?', const='bar',default='Default', help= "This should be the location of the the pickled file with the species identification codes.")

# TODO : see if you can use * instead of extensions

location_group.add_argument('--cds',nargs='?', const='bar',default=False, help='This should be the location of the cds fasta dicts in pickle format.')

location_group.add_argument('--orthos',nargs='?', const='bar',default=False, help='The location of the orthos in Unix format.')

location_group.add_argument('--output',nargs='?', const='bar',default=False, help='The location of the output files. Location should be in Unix format.')

args = parser.parse_args()

for action in parser._action_groups: # verfiy that all given locations exist
    if action.title == 'Location arguments':
        for argument in action._group_actions:
            arg_value = getattr(args, argument.dest)
            if os.path.exists(arg_value):
                pass
            else:
                print(f"Cannot open '{arg_value}', please make sure it exits or the path is supplied correctly.")

list_of_pickles = os.listdir(args.cds)

for i in list_of_pickles:
    pickle_base = i.rsplit('.')[0]
    name_pickle = f'{args.cds}/{i}'
    with open(name_pickle,'rb') as current_pickle:
        locals()[pickle_base] = pickle.load(current_pickle)

with open(args.pickle, 'rb') as species:
    species_codes = pickle.load(species)

def write_to_file(file_name,the_array_cds):

    file_name = file_name.split('.')[0]
    cds_base = f'{args.output}/{file_name}.cds'

    np.savetxt(cds_base, the_array_cds, delimiter='\n', fmt='%s')

def list_to_cds_sequences(file_name,file_names_list):

    cds_headers = np.empty(len(file_names_list), dtype=[('header', 'U100'), ('sequence', 'U10000')]) 
    for i,pep_header in enumerate(file_names_list):
        for code_name in species_codes:
            if code_name in pep_header:
                species_name = species_codes.get(code_name)
                sequence_cds = globals()[species_name].get(pep_header.rstrip(),"None") # what are in peps may not be in cds. So, if it is in pep but not in cds then we do not want to send NoneType to the dict 
                cds_headers[i] = (pep_header.rstrip(), sequence_cds) # rstrip() to standardize line formatting

    write_to_file(file_name,cds_headers)

def get_headers(full_path):
    filename = os.path.basename(full_path)
    with open(full_path, 'r') as current_ortho_pep:
        current_ortho_pep_headers = current_ortho_pep.readlines()

    file_names_list = []
    
    for pep_header in current_ortho_pep_headers:
            if pep_header.startswith('>'):
                file_names_list.append(pep_header)
    
    list_to_cds_sequences(filename,file_names_list)


def main():
    with multiprocessing.Pool(processes=multiprocessing.cpu_count()) as pool: # using a static number of threads is just fine but I am not sure which device I will be using this script on and as such using a dynamic thread allocator might be good idea.
        orthos_path = args.orthos
        orthos_files = [os.path.join(orthos_path, f) for f in os.listdir(orthos_path)]
        pool.map(get_headers, orthos_files)

main()
