import sys

def convert_big_to_little(hex_str):
    hex_str = hex_str.strip().lower().replace("0x", "").zfill(8)
    bytes_list = [hex_str[i:i+2] for i in range(0, 8, 2)]
    little_endian = ' '.join(reversed(bytes_list)).upper()
    return little_endian

def process_file(input_path, output_path):
    with open(input_path, 'r') as infile, open(output_path, 'w') as outfile:
        for line in infile:
            if line.strip():
                little = convert_big_to_little(line)
                outfile.write(little + '\n')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python converter.py <input_file> <output_file>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]
    process_file(input_path, output_path)
