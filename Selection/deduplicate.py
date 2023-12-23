import os
import argparse
from Bio import SeqIO

def remove_duplicates(input_file, output_file):
    sequences = {}  # To hold the sequences
    for seq_record in SeqIO.parse(input_file, "fasta"):
        # Use the sequence as the key and just write it to the output file if it hasn't been seen yet
        if str(seq_record.seq) not in sequences:
            sequences[str(seq_record.seq)] = seq_record.description
    # Write the unique sequences to the output file
    with open(output_file, 'w') as output_handle:
        for seq, description in sequences.items():
            output_handle.write(f">{description}\n{seq}\n")

def main():
    parser = argparse.ArgumentParser(description='Remove duplicate sequences from a multi-fasta file.')
    parser.add_argument('-i', '--input', required=True, help='Input fasta file or directory')
    parser.add_argument('-o', '--output', help='Output fasta file or directory')

    args = parser.parse_args()

    input_path = args.input
    output_path = args.output

    if os.path.isdir(input_path):
        # If input is a directory, loop over all files in the directory
        for filename in os.listdir(input_path):
            if filename.endswith(".fasta"):
                input_file = os.path.join(input_path, filename)
                if output_path:
                    # If output directory is provided, use it
                    output_file = os.path.join(output_path, f"{os.path.splitext(filename)[0]}.no_duplicates.fa")
                else:
                    # If no output directory is provided, create a new one based on the input directory name
                    new_dir = f"{input_path}_no_duplicates"
                    os.makedirs(new_dir, exist_ok=True)
                    output_file = os.path.join(new_dir, f"{os.path.splitext(filename)[0]}.no_duplicates.fa")
                remove_duplicates(input_file, output_file)
    else:
        # If input is a file, process it as before
        if output_path:
            output_file = output_path
        else:
            base_name = os.path.splitext(input_path)[0]
            output_file = f"{base_name}.no_duplicates.fa"
        remove_duplicates(input_path, output_file)

if __name__ == "__main__":
    main()

