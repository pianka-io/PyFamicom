from common.addressing import argument_size, Addressing
from common.constants import RESET_VECTOR, CPU_STATUS_INTERRUPT
from cpu.memory import Memory
from cpu.op import ops_by_code, Op
from cpu.registers import Registers


class CPU:
    def __init__(self, prg_rom: bytes):
        self.registers = Registers()
        self.memory = Memory(prg_rom)
        self.entry = self.memory.read_word(RESET_VECTOR)

    def start(self):
        self.registers.PC = self.entry
        while True:
            opcode = self.memory.read_byte(self.registers.PC)
            if opcode not in ops_by_code:
                print(f"unsupported opcode: ${opcode:x}")
                break
            op = ops_by_code[opcode]
            arg = self._read_arg(op)
            self._print_instruction(op, arg)
            jump = self._handle_instruction(op, arg)
            if not jump:
                self.registers.PC += op.size

    def _print_instruction(self, op: Op, arg: int):
        rom_address = self.memory.translate_cpu_address_to_rom(self.registers.PC)
        print(f"[${self.registers.PC:x}:${rom_address:x}] {op.mnemonic} ${arg:x}")

    def _read_arg(self, op: Op) -> int:
        begin = self.registers.PC + 1
        size = argument_size(op.addressing)
        if size == 0:
            return 0
        if size == 1:
            return self.memory.read_byte(begin)
        if size == 2:
            return self.memory.read_word(begin)
        raise ValueError(f"unsupported argument size: {size}")

    def _handle_instruction(self, op: Op, arg: int) -> bool:
        match op.mnemonic:
            case "jsr":
                return self.jsr(op, arg)
            case "sei":
                return self.sei()
            case "sta":
                return self.sta(op, arg)
            case "lda":
                return self.lda(op, arg)
        raise ValueError(f"unsupported instruction: {op.mnemonic}")

    def jsr(self, op: Op, arg: int) -> bool:
        match op.addressing:
            case Addressing.ABSOLUTE:
                self.registers.PC = arg
        return True

    def sei(self) -> bool:
        self.registers.set_p(CPU_STATUS_INTERRUPT)
        return False

    def sta(self, op: Op, arg: int) -> bool:
        match op.addressing:
            case Addressing.ABSOLUTE:
                self.memory.write_byte(arg, self.registers.A)
        return False

    def lda(self, op: Op, arg: int) -> bool:
        match op.addressing:
            case Addressing.IMMEDIATE:
                self.registers.A = arg
            case _:
                raise ValueError(f"unsupported addressing mode: {op.addressing.name}")
        return False
