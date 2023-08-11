import json
import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("--dir", help="The directory that contains the JSONs. The current directory will be used by default.", default=".")
parser.add_argument("--o", help="The name for the output file. The default is 'counts.tsv'.", default="counts.tsv")
args = parser.parse_args()

json_files = [f for f in os.listdir(args.dir) if os.path.isfile(os.path.join(args.dir, f)) and os.path.splitext(f)[1] == ".json"]

if len(json_files) == 0:
    print("The directory you supplied has no JSON files.")
    exit()

if os.path.isfile(args.o):
    print("The file " + args.o + " already exists. Please provide a different name.")
    exit()

with open(args.o, "w") as outfile:
    init = "species_name" + "\t" + "count"
    outfile.write(init + "\n")
    for i in json_files:
        fileloc = os.path.join(args.dir, i)
        with open(fileloc) as json_file:
            json_content = json.load(json_file)
            j = i.split(".")[0].replace("_", " ")
            countomics = json_content["total_count"]
            line = j + "\t" + str(countomics)
            outfile.write(line + "\n")

