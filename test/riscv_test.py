import logging
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Edge, Timer
from cocotb.binary import BinaryValue


from helper_lib import read_file_to_list,Instruction, rotate_right, shift_helper, ByteAddressableMemory, reverse_hex_string_endiannes, sign_extend, zero_extend
from helper_student import Log_Datapath,Log_Controller,Log_UART


class TB:
    def __init__(self, Instruction_list, dut, dut_PC, dut_regfile):
        self.dut = dut
        self.dut_PC = dut_PC
        self.dut_regfile = dut_regfile
        self.Instruction_list = Instruction_list
    
        self.logger = logging.getLogger("Performance Model")
        self.logger.setLevel(logging.DEBUG)

        self.PC = 0
        self.Z_flag = 0
        self.Register_File =[]
        for i in range(32):
            self.Register_File.append(0)
    
        self.memory = ByteAddressableMemory(1024)

        self.clock_cycle_count = 0        
             
    def log_dut(self):
        Log_Datapath(self.dut,self.logger)
        Log_Controller(self.dut,self.logger)
        Log_UART(self.dut,self.logger)

    #Compares and lgos the PC and register file of Python module and HDL design
    def compare_result(self):
        self.logger.debug("************* Performance Model / DUT Data  **************")
        self.logger.debug("PC:%d \t PC:%d",self.PC,self.dut_PC.value.integer)
        for i in range(32):
            self.logger.debug("Register%d: %d \t %d",i,self.Register_File[i], self.dut_regfile.Reg_Out[i].value.integer)
        assert self.PC == self.dut_PC.value
        for i in range(32):
           assert self.Register_File[i] == self.dut_regfile.Reg_Out[i].value

    def write_to_register_file(self,register_no, data):
        if(data <0):
            data = data + (1 << 32) 
        self.Register_File[register_no] = data
        

    def performance_model (self):
        self.logger.debug("\n\n**************** Clock cycle: %d **********************",self.clock_cycle_count)
        self.clock_cycle_count = self.clock_cycle_count+1
        self.logger.debug("**************** Instruction No: %d **********************",int((self.PC)/4))
        current_instruction = self.Instruction_list[int((self.PC)/4)].replace(" ", "")
        
        current_instruction = reverse_hex_string_endiannes(current_instruction)
        self.PC = self.PC + 4
        
        self.inst_fields = Instruction(current_instruction)
        self.inst_fields.log(self.logger)

        match self.inst_fields.op:
            case 3:
                self.execute_load_type()
            case 19:
                self.execute_register_imm_type()
            case 23:
                self.execute_auipc()
            case 35:
                self.execute_store_type()
            case 51:
                self.execute_register_type()
            case 55:
                self.execute_lui()
            case 99:
                self.execute_branch_type()
            case 103:
                self.execute_jalr_type()
            case 111:
                self.execute_jal_type()
            case _:
                raise TypeError("Terry the Horrible @performance_model!")


    def execute_load_type(self):
        match self.inst_fields.funct3:
            case 0: self.write_to_register_file(self.inst_fields.rd, sign_extend(int.from_bytes(self.memory.read(self.Register_File[self.inst_fields.rs1] + self.inst_fields.imm11_0)), 8))
            case 1: self.write_to_register_file(self.inst_fields.rd, sign_extend( int.from_bytes(self.memory.read(self.Register_File[self.inst_fields.rs1] + self.inst_fields.imm11_0)), 16))
            case 2: self.write_to_register_file(self.inst_fields.rd, int.from_bytes(self.memory.read(self.Register_File[self.inst_fields.rs1] + self.inst_fields.imm11_0)))
            case 4: self.write_to_register_file(self.inst_fields.rd, zero_extend(int.from_bytes(self.memory.read(self.Register_File[self.inst_fields.rs1] + self.inst_fields.imm11_0)), 8))
            case 5: self.write_to_register_file(self.inst_fields.rd, zero_extend(int.from_bytes(self.memory.read(self.Register_File[self.inst_fields.rs1] + self.inst_fields.imm11_0)), 16))
            case _: raise TypeError("Something terrible @execute_load_type!")

    def execute_register_imm_type(self):
        match self.inst_fields.funct3:
            case 0: self.write_to_register_file(self.inst_fields.rd, self.Register_File[self.inst_fields.rs1] + sign_extend(self.inst_fields.imm11_0, 12))
            case 1: self.write_to_register_file(self.inst_fields.rd, (self.Register_File[self.inst_fields.rs1] << (self.inst_fields.imm11_0 & 0x1F)) & 0xFFFFFFFF )
            case 2: self.write_to_register_file(self.inst_fields.rd, int(self.Register_File[self.inst_fields.rs1] < sign_extend(self.inst_fields.imm11_0, 12)))
            case 3: self.write_to_register_file(self.inst_fields.rd, int((self.Register_File[self.inst_fields.rs1] & 0xFFFFFFFF) < (sign_extend(self.inst_fields.imm11_0, 12) & 0xFFFFFFFF)))
            case 4: self.write_to_register_file(self.inst_fields.rd, self.Register_File[self.inst_fields.rs1] ^ sign_extend(self.inst_fields.imm11_0, 12))
            case 5: 
                if self.inst_fields.funct7 == 0:
                    self.write_to_register_file(self.inst_fields.rd, ((self.Register_File[self.inst_fields.rs1]) >> zero_extend(self.inst_fields.imm11_0 & 0x1F, 12)) & 0xFFFFFFFF)
                else:
                    self.write_to_register_file(self.inst_fields.rd, self.arith_right_shift(self.Register_File[self.inst_fields.rs1], self.inst_fields.imm11_0 & 0x1F))

            case 6: self.write_to_register_file(self.inst_fields.rd, self.Register_File[self.inst_fields.rs1] | sign_extend(self.inst_fields.imm11_0, 12))
            case 7: self.write_to_register_file(self.inst_fields.rd, self.Register_File[self.inst_fields.rs1] & sign_extend(self.inst_fields.imm11_0, 12))
            case _: raise TypeError("Something terrible @execute_register_imm_type!")

    def execute_auipc(self):

        self.write_to_register_file(self.inst_fields.rd, self.PC - 4 + (self.inst_fields.imm31_12 << 12))

    def execute_store_type(self):
        target_address = self.Register_File[self.inst_fields.rs1] + (self.inst_fields.imm11_5 << 5 | self.inst_fields.imm4_0)
        match self.inst_fields.funct3:    
            case 0: self.memory.write_byte(target_address, self.Register_File[self.inst_fields.rs2] & 0xFF)
            case 1: self.memory.write_half_word(target_address, self.Register_File[self.inst_fields.rs2] & 0xFFFF)
            case 2: self.memory.write(target_address,  self.Register_File[self.inst_fields.rs2]& 0xFFFFFFFF)
            case _: raise TypeError("Something terrible @execute_store_type!")
        

    def execute_register_type(self):
        match self.inst_fields.funct3:
            case 0: 
                if self.inst_fields.funct7 == 0:
                    self.write_to_register_file(self.inst_fields.rd, self.Register_File[self.inst_fields.rs1] + self.Register_File[self.inst_fields.rs2])
                else:
                    self.write_to_register_file(self.inst_fields.rd, self.Register_File[self.inst_fields.rs1] - self.Register_File[self.inst_fields.rs2])

            case 1: self.write_to_register_file(self.inst_fields.rd, (self.Register_File[self.inst_fields.rs1] << (self.Register_File[self.inst_fields.rs2] & 0x1F)) &  0xFFFFFFFF)
            case 2: self.write_to_register_file(self.inst_fields.rd, int(self.Register_File[self.inst_fields.rs1] < self.Register_File[self.inst_fields.rs2]))
            case 3:  self.write_to_register_file(self.inst_fields.rd, int(self.Register_File[self.inst_fields.rs1] & 0xFFFFFFFF < self.Register_File[self.inst_fields.rs2] & 0xFFFFFFFF ))
            case 4: self.write_to_register_file(self.inst_fields.rd, self.Register_File[self.inst_fields.rs1] ^ self.Register_File[self.inst_fields.rs2])
            case 5:
                if self.inst_fields.funct7 == 0:
                    self.write_to_register_file(self.inst_fields.rd, (self.Register_File[self.inst_fields.rs1] >> (self.Register_File[self.inst_fields.rs2] & 0x1F)) & 0xFFFFFFFF )
                else:
                    self.write_to_register_file(self.inst_fields.rd, self.arith_right_shift(self.Register_File[self.inst_fields.rs1], self.Register_File[self.inst_fields.rs2] & 0x1F))

            case 6: self.write_to_register_file(self.inst_fields.rd, self.Register_File[self.inst_fields.rs1] | self.Register_File[self.inst_fields.rs2])
            case 7: self.write_to_register_file(self.inst_fields.rd, self.Register_File[self.inst_fields.rs1] & self.Register_File[self.inst_fields.rs2])
            case _: raise TypeError("Something terrible @execute_register_type!")


    def execute_lui(self):
        self.write_to_register_file(self.inst_fields.rd, self.inst_fields.imm31_12 << 12)


    def execute_branch_type(self):
        match self.inst_fields.funct3:
            case 0: self.PC = (self.PC + (self.inst_fields.imm12 << 12 | self.inst_fields.imm11B << 11 | self.inst_fields.imm10_5 << 5 | self.inst_fields.imm4_1 << 1)) if self.Register_File[self.inst_fields.rs1] == self.Register_File[self.inst_fields.rs2] else self.PC
            case 1: self.PC = (self.PC + (self.inst_fields.imm12 << 12 | self.inst_fields.imm11B << 11 | self.inst_fields.imm10_5 << 5 | self.inst_fields.imm4_1 << 1)) if self.Register_File[self.inst_fields.rs1] != self.Register_File[self.inst_fields.rs2] else self.PC
            case 2: self.PC = (self.PC + (self.inst_fields.imm12 << 12 | self.inst_fields.imm11B << 11 | self.inst_fields.imm10_5 << 5 | self.inst_fields.imm4_1 << 1)) if self.Register_File[self.inst_fields.rs1] < self.Register_File[self.inst_fields.rs2] else self.PC
            case 3: self.PC = (self.PC + (self.inst_fields.imm12 << 12 | self.inst_fields.imm11B << 11 | self.inst_fields.imm10_5 << 5 | self.inst_fields.imm4_1 << 1)) if self.Register_File[self.inst_fields.rs1] >= self.Register_File[self.inst_fields.rs2] else self.PC
            case 4: self.PC = (self.PC + (self.inst_fields.imm12 << 12 | self.inst_fields.imm11B << 11 | self.inst_fields.imm10_5 << 5 | self.inst_fields.imm4_1 << 1)) if (self.Register_File[self.inst_fields.rs1] & 0xFFFFFFFF)  <  (self.Register_File[self.inst_fields.rs2] & 0xFFFFFFFF) else self.PC
            case 5: self.PC = (self.PC + (self.inst_fields.imm12 << 12 | self.inst_fields.imm11B << 11 | self.inst_fields.imm10_5 << 5 | self.inst_fields.imm4_1 << 1)) if (self.Register_File[self.inst_fields.rs1] & 0xFFFFFFFF)  >= (self.Register_File[self.inst_fields.rs2] & 0xFFFFFFFF) else self.PC
            case _: raise TypeError("Something terrible @execute_register_imm_type!")

    def execute_jalr_type(self):
        self.PC = (self.Register_File[self.inst_fields.rs1] + sign_extend(self.inst_fields.imm11_0, 12))  & ~1
        self.write_to_register_file(self.inst_fields.rd, self.PC + 4)
    
    def execute_jal_type(self):
        imm = self.inst_fields.imm20 << 20 | self.inst_fields.imm19_12 << 12 | self.inst_fields.imm11J << 11 | self.inst_fields.imm10_1 << 1
        self.PC = self.PC + sign_extend(imm, 21)

    def print_whole_memory(self):
        self.logger.debug("******** WHOLE MEMORY CONTENT ***********")        
        for i in range(256):
            self.logger.debug("loc %d  ; content %d", i, self.memory.read_byte(i))

    def arith_right_shift(self, reg_value, shamt):
        if reg_value & (1 << 31):
            return (reg_value >> shamt) | (0xFFFFFFFF << (32 - shamt))
        else:
            return reg_value >> shamt


    async def run_test(self):
        self.performance_model()
        
        await Timer(1, units="us")
        self.log_dut()
        await RisingEdge(self.dut.clk)
        await FallingEdge(self.dut.clk)
        self.compare_result()

        counter = 0

        while(int(self.Instruction_list[int((self.PC)/4)].replace(" ", ""),16)!=0):
            self.performance_model()
           
            self.log_dut()
            await RisingEdge(self.dut.clk)
            await FallingEdge(self.dut.clk)
            self.compare_result()
        
            
            counter = counter + 1
            if(counter == 2):
                break
                
                   
@cocotb.test()
async def riscv_test(dut):
    
    await cocotb.start(Clock(dut.clk, 10, 'us').start(start_high=False))
    dut.reset.value=1
    await RisingEdge(dut.clk)
    dut.reset.value=0
    await FallingEdge(dut.clk)
    instruction_lines = read_file_to_list('Instructions.hex')
    
    tb = TB(instruction_lines,dut, dut.my_datapath.PC, dut.my_datapath.r_file)
    await tb.run_test()