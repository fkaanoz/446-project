def read_file_to_list(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()
        lines = [line.strip() for line in lines]
    return lines

def reverse_hex_string_endiannes(hex_string):  
    reversed_string = bytes.fromhex(hex_string)
    reversed_string = reversed_string[::-1]
    reversed_string = reversed_string.hex()        
    return  reversed_string

class Instruction:
    def __init__(self, instruction):
        
        self.binary_instr = format(int(instruction, 16), '032b')

        self.op = int(self.binary_instr[25:32], 2)
        self.rd = int(self.binary_instr[20:25], 2)
        self.funct3 = int(self.binary_instr[17:20], 2)
        self.rs1 = int(self.binary_instr[12:17], 2)
        self.rs2 = int(self.binary_instr[7:12], 2)
        self.funct7 = int(self.binary_instr[0:7], 2)

        self.imm11_0 = int(self.binary_instr[0:12], 2)
        self.imm11_5 = int(self.binary_instr[0:7], 2)
        self.imm12 = int(self.binary_instr[0], 2)
        self.imm10_5 = int(self.binary_instr[1:7], 2)
        self.imm31_12 = int(self.binary_instr[0:20], 2)
        self.imm20 = int(self.binary_instr[0], 2)
        self.imm10_1 = int(self.binary_instr[1:11], 2)
        self.imm11J = int(self.binary_instr[11], 2)
        self.imm19_12 = int(self.binary_instr[12:20], 2)
        self.imm4_0 = int(self.binary_instr[20:25], 2)
        self.imm4_1 = int(self.binary_instr[20:24], 2)
        self.imm11B = int(self.binary_instr[24], 2)

        
    def log(self,logger):
        logger.debug("****** Current Instruction *********")
        logger.debug("Binary string: %s", self.binary_instr)


        logger.debug("**** FIELDS *****")
        logger.debug("imm11_0 :%d", self.imm11_0)
        logger.debug("imm11_0 :%d", self.rs1)



        if(self.op == int("0000011", 2)):
            logger.debug("\tInstruction TYPE : I (LOAD and its variants)")
            logger.debug("\top : (3)")
            logger.debug("\tfunct3 : %d",self.funct3)
            logger.debug("\trd : %d",self.rd)
            logger.debug("\trs : %d",self.rs1)
            logger.debug("\tImmediate bits (12 bits) : %d",self.imm11_0)

        elif(self.op == int("0010011", 2)):
            logger.debug("\tInstruction TYPE : I (arithmetic and logic)")
            logger.debug("\top : (19)")
            logger.debug("\tfunct3 : %d",self.funct3)
            logger.debug("\trd : %d",self.rd)
            logger.debug("\trs : %d",self.rs1)
            logger.debug("\tImmediate bits (12 bits) : %d",self.imm11_0 )

        elif(self.op == int("0010111", 2)):
            logger.debug("\tInstruction TYPE : U (auipc)")
            logger.debug("\top : (23)")
            logger.debug("\trd : %d",self.rd)
            logger.debug("\tImmediate bits (20 bits) :%d", self.imm31_12 << 12)
            

        elif(self.op == int("0100011", 2)):
            logger.debug("\tInstruction TYPE : S (STORE and its variants)")
            logger.debug("\top : (35)")
            logger.debug("\tfunct3 : %d",self.funct3)
            logger.debug("\trs1 : %d",self.rs1)
            logger.debug("\trs2 : %d",self.rs2)
            logger.debug("\tImmediate bits (concat) :%d", (self.imm11_5 << 5) | self.imm4_0)
        

        elif(self.op == int("0110011", 2)):
            logger.debug("\tInstruction TYPE : R (Register operation)")
            logger.debug("\top : (51)")
            logger.debug("\trd : %d",self.rd)
            logger.debug("\tfunct3 : %d",self.funct3)
            logger.debug("\trs1 : %d",self.rs1)
            logger.debug("\trs2 : %d",self.rs2)
            logger.debug("\tfunct7 : %d",self.funct7)


        elif(self.op == int("0110111", 2)):
            logger.debug("\tInstruction TYPE : U (lui)")
            logger.debug("\top : (55)")
            logger.debug("\trd : %d",self.rd)
            logger.debug("\tImmediate bits (20 bits) :%d", self.imm31_12 << 12)

        
        elif(self.op == int("1100011", 2)):
            logger.debug("\tInstruction TYPE : B (BRANCH and its variants)")
            logger.debug("\top : (99)")
            logger.debug("\tfunct3 : %d",self.funct3)
            logger.debug("\trs1 : %d",self.rs1)
            logger.debug("\trs2 : %d",self.rs2)
            logger.debug("\tImmediate bits (concat) :%d", self.imm12 << 12 | self.imm11B << 11 | self.imm10_5 << 5 | self.imm4_1 << 1)

        elif(self.op == int("1100111", 2)):
            logger.debug("\tInstruction TYPE : I (jalr)")
            logger.debug("\top : (103)")
            logger.debug("\tfunct3 : %d",self.funct3)
            logger.debug("\trd : %d",self.rd)
            logger.debug("\trs : %d",self.rs1)
            logger.debug("\tImmediate bits (12 bits) : %d",self.imm11_0 )

        elif(self.op == int("1101111", 2)):
            logger.debug("\tInstruction TYPE : J (jal)")
            logger.debug("\top : (111)")
            logger.debug("\trd : %d",self.rd)
            logger.debug("\tImmediate bits (concat) : %d", self.imm20 << 20 | self.imm19_12 << 12 | self.imm11J << 11 | self.imm10_1 <<1)



def sign_extend(value, width):
    value = value & ((1 << width) - 1)
    
    sign_bit = 1 << (width - 1)
    
    if value & sign_bit:
        value = value - (1 << width)

    return value


def zero_extend(value, width):
    value = value & ((1 << width) - 1)
    return value




#### WILL BE REFACTORED!!!
def rotate_right(value, shift, n_bits=32):
    """
    Rotate `value` to the right by `shift` bits.

    :param value: The integer value to rotate.
    :param shift: The number of bits to rotate by.
    :param n_bits: The bit-width of the integer (default 32 for standard integer).
    :return: The value after rotating to the right.
    """
    shift %= n_bits  # Ensure the shift is within the range of 0 to n_bits-1
    return (value >> shift) | (value << (n_bits - shift)) & ((1 << n_bits) - 1)

def shift_helper(value, shift,shift_type, n_bits=32):
    shift %= n_bits  # Ensure the shift is within the range of 0 to n_bits-1
    match shift_type:
        case 0:
            return (value  << shift)% 0x100000000
        case 1:
            return (value  >> shift) % 0x100000000
        case 2:
            if((value & 0x80000000)!=0):
                    filler = (0xFFFFFFFF >> (n_bits-shift))<<((n_bits-shift))
                    return ((value  >> shift)|filler) % 0x100000000
            else:
                return (value  >> shift) % 0x100000000
        case 3:
            return rotate_right(value,shift,n_bits)
        


class ByteAddressableMemory:
    def __init__(self, size):
        self.size = size
        self.memory = bytearray(size)  # Initialize memory as a bytearray of the given size

    def read(self, address):
        if (address < 0 or address + 4 > self.size) and address != 1028:
            raise ValueError("Invalid memory address or length")
        return_val = bytes(self.memory[address : address + 4])
        return_val = return_val[::-1]
        return return_val
    
    def read_byte(self, address):
        if (address < 0 or address > self.size) and address != 1028:
            raise ValueError("Invalid memory address or length")
        return_val = self.memory[address]
        return return_val


    def write(self, address, data):
        if (address < 0 or address + 4> self.size) and address != 1024:
            raise ValueError("Invalid memory address or data length")
        
        if address != 1024:
            data_bytes = int(data).to_bytes(4, byteorder='little')
            self.memory[address : address + 4] = data_bytes 
    

    def write_byte(self, addr, value):
        if not 0 <= value <= 0xFF:
            raise ValueError("Value must be a byte")
        if (addr < 0 or addr >= self.size) and addr != 1024:
            print("addr", addr)
            raise ValueError("Address out of range")
       
        if addr != 1024:
            self.memory[addr] = value
        

    def write_half_word(self, address, data):
        if (address < 0 or address + 2 > self.size) and address != 1024:
            raise ValueError("Invalid memory address or data length")
        
        if address != 1024:
            data_bytes = int(data).to_bytes(2, byteorder='little')
            self.memory[address : address + 2] = data_bytes