def convert_big_to_little(hex_str):
    
    hex_str = hex_str.strip().lower().replace("0x", "").zfill(8)
    
    bytes_list = [hex_str[i:i+2] for i in range(0, 8, 2)]
    little_endian = ' '.join(reversed(bytes_list)).upper()
    return little_endian

def process_file(input_path='normal_inst.txt', output_path='Instructions.hex'):
    with open(input_path, 'r') as infile, open(output_path, 'w') as outfile:
        for line in infile:
            if line.strip():  # Skip empty lines
                little = convert_big_to_little(line)
                outfile.write(little + '\n')

process_file()
