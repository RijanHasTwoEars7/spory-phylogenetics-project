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
    parser.add_argument('-i', '--input', required=True, help='Input fasta file')
    parser.add_argument('-o', '--output', help='Output fasta file')

    args = parser.parse_args()

    input_file = args.input
    if args.output:
        output_file = args.output
    else:
        base_name = os.path.splitext(input_file)[0]
        output_file = f"{base_name}.no_duplicates.fa"

    remove_duplicates(input_file, output_file)

if __name__ == "__main__":
    main()
