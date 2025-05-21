def ToHex(value):
    try:
        ret = hex(value.integer)
    except: #If there are 'x's in the value
        ret = "0b" + str(value)
    return ret

#Populate the below functions as in the example lines of code to print your values for debugging
def Log_Datapath(dut,logger):
    #Log whatever signal you want from the datapath, called before positive clock edge
    logger.debug("************ DUT DATAPATH Signals ***************")
    #dut._log.info("reset:%s", ToHex(dut.my_datapath.reset.value))
    # dut._log.info("ALUSrc:%s", ToHex(dut.my_datapath.ALUSrc.value))
    dut._log.info("SrcA:%s", ToHex(dut.my_datapath.SrcA.value))
    dut._log.info("SrcB:%s", ToHex(dut.my_datapath.SrcB.value))
    dut._log.info("ALUControl:%s", ToHex(dut.my_datapath.ALUControl.value))
    dut._log.info("ALUResult:%s", ToHex(dut.my_datapath.ALUResult.value))
    dut._log.info("PCTarget:%s", ToHex(dut.my_datapath.PCTarget.value))
    dut._log.info("WD3:%s", ToHex(dut.my_datapath.WD3.value))
    dut._log.info("WriteData:%s", ToHex(dut.my_datapath.WriteData.value))
    dut._log.info("RegWriteSrcSelect:%s", ToHex(dut.my_datapath.RegWriteSrcSelect.value))
    dut._log.info("WriteData:%s", ToHex(dut.my_datapath.WriteData.value))
    dut._log.info("cir_buffer:%s", ToHex(dut.my_datapath.fifo_.cir_buffer.value))
    dut._log.info("fifo => write:%s", ToHex(dut.my_datapath.fifo_.write.value))
    dut._log.info("write_ptr:%s", ToHex(dut.my_datapath.fifo_.write_ptr.value))
    dut._log.info("read_ptr:%s", ToHex(dut.my_datapath.fifo_.read_ptr.value))
    #dut._log.info("RegSrc:%s", ToHex(dut.my_datapath.RegSrc.value))
    #dut._log.info("ImmSrc:%s", ToHex(dut.my_datapath.ImmSrc.value))
    #dut._log.info("ALUControl:%s", ToHex(dut.my_datapath.ALUControl.value))
    #dut._log.info("CO:%s", ToHex(dut.my_datapath.CO.value))
    #dut._log.info("OVF:%s", ToHex(dut.my_datapath.OVF.value))
    #dut._log.info("N:%s", ToHex(dut.my_datapath.N.value))
    #dut._log.info("Z:%s", ToHex(dut.my_datapath.Z.value))
    #dut._log.info("CarryIN:%s", ToHex(dut.my_datapath.CarryIN.value))
    #dut._log.info("ShiftControl:%s", ToHex(dut.my_datapath.ShiftControl.value))
    #dut._log.info("shamt:%s", ToHex(dut.my_datapath.shamt.value))
    #dut._log.info("PC:%s", ToHex(dut.my_datapath.PC.value))
    #dut._log.info("Instruction:%s", ToHex(dut.my_datapath.Instruction.value))

def Log_Controller(dut,logger):
    #Log whatever signal you want from the controller, called before positive clock edge
    logger.debug("************ DUT Controller Signals ***************")
    #dut._log.info("Op:%s", ToHex(dut.my_controller.Op.value))
    #dut._log.info("Funct:%s", ToHex(dut.my_controller.Funct.value))
    #dut._log.info("Rd:%s", ToHex(dut.my_controller.Rd.value))
    #dut._log.info("Src2:%s", ToHex(dut.my_controller.Src2.value))
    #dut._log.info("PCSrc:%s", ToHex(dut.my_controller.PCSrc.value))
    #dut._log.info("RegWrite:%s", ToHex(dut.my_controller.RegWrite.value))
    #dut._log.info("MemWrite:%s", ToHex(dut.my_controller.MemWrite.value))
    #dut._log.info("nPCSrc:%s", ToHex(dut.my_controller.nPCSrc.value))
    #dut._log.info("nRegWrite:%s", ToHex(dut.my_controller.nRegWrite.value))
    #dut._log.info("nMemWrite:%s", ToHex(dut.my_controller.nMemWrite.value))
    #dut._log.info("ALUSrc:%s", ToHex(dut.my_controller.ALUSrc.value))
    #dut._log.info("MemtoReg:%s", ToHex(dut.my_controller.MemtoReg.value))
    #dut._log.info("ALUControl:%s", ToHex(dut.my_controller.ALUControl.value))
    #dut._log.info("FlagWrite:%s", ToHex(dut.my_controller.FlagWrite.value))
    #dut._log.info("ImmSrc:%s", ToHex(dut.my_controller.ImmSrc.value))
    #dut._log.info("RegSrc:%s", ToHex(dut.my_controller.RegSrc.value))
    #dut._log.info("ALUFlags:%s", ToHex(dut.my_controller.ALUFlags.value))
    #dut._log.info("ShiftControl:%s", ToHex(dut.my_controller.ShiftControl.value))
    #dut._log.info("shamt:%s", ToHex(dut.my_controller.shamt.value))
    #dut._log.info("CondEx:%s", ToHex(dut.my_controller.CondEx.value))




def Log_UART(dut,logger):
    #Log whatever signal you want from the controller, called before positive clock edge
    logger.debug("************ UART Signals ***************")
    dut._log.info("UARTOp:%s", ToHex(dut.my_datapath.uart_.UARTOp.value))
    dut._log.info("WriteData:%s", ToHex(dut.my_datapath.uart_.WriteData.value))
    
    