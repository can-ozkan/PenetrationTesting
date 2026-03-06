# Reverse Engineering Basics Cheat Sheet

A practical reference for **binary analysis, reverse engineering fundamentals, and program understanding**.  
Useful for **security research, malware analysis, vulnerability research, and software debugging**.

This cheat sheet focuses on:

- binary fundamentals
- assembly basics
- debugging workflow
- static vs dynamic analysis
- common reversing patterns
- practical tools

---

# 1. Reverse Engineering Overview

Reverse engineering is the process of **analyzing compiled software to understand how it works without source code**.

Typical goals:

```
Understand program behavior
Identify vulnerabilities
Analyze malware
Bypass license checks
Recover lost source logic
Analyze proprietary protocols
```

Typical workflow:

```
Identify binary format
→ Static analysis
→ Dynamic analysis
→ Code reconstruction
→ Behavior understanding
```

---

# 2. Binary File Formats

Programs are distributed as compiled binaries.

## Common Formats

| Format | Platform |
|------|---------|
| ELF | Linux |
| PE | Windows |
| Mach-O | macOS |

### Identify binary type

```
file program
```

Example output:

```
ELF 64-bit LSB executable
```

---

# 3. Binary Metadata Inspection

Useful commands:

```
file program
strings program
hexdump -C program
xxd program
```

Check architecture:

```
readelf -h program
```

Check linked libraries:

```
ldd program
```

---

# 4. Static Analysis vs Dynamic Analysis

## Static Analysis

Analyze program **without executing it**.

Examples:

```
Disassembly
Control flow analysis
String extraction
Symbol analysis
```

Tools:

```
objdump
Ghidra
IDA
radare2
Binary Ninja
```

---

## Dynamic Analysis

Analyze program **during execution**.

Examples:

```
Debugging
Memory inspection
Tracing system calls
Runtime patching
```

Tools:

```
gdb
strace
ltrace
x64dbg
WinDbg
```

---

# 5. Basic Assembly Concepts

Assembly is the **human-readable form of machine code**.

Example instruction:

```
mov eax, 1
```

Meaning:

```
Move value 1 into register eax
```

---

# 6. CPU Registers

Registers are **small fast storage locations inside the CPU**.

### Common x86 Registers

| Register | Purpose |
|--------|---------|
| EAX | accumulator |
| EBX | base |
| ECX | counter |
| EDX | data |
| ESI | source index |
| EDI | destination index |
| EBP | base pointer |
| ESP | stack pointer |
| EIP | instruction pointer |

64-bit versions:

```
RAX
RBX
RCX
RDX
RSI
RDI
RBP
RSP
RIP
```

---

# 7. The Stack

The stack stores:

```
function parameters
local variables
return addresses
saved registers
```

Stack operations:

```
push
pop
call
ret
```

Example:

```
push eax
```

Push register value onto stack.

---

# 8. Function Calls

Function call flow:

```
push arguments
call function
execute function
ret
```

Example assembly:

```
call printf
```

---

# 9. Common Assembly Instructions

### Data movement

```
mov
lea
push
pop
```

### Arithmetic

```
add
sub
mul
div
inc
dec
```

### Logic

```
and
or
xor
not
```

### Comparison

```
cmp
test
```

### Control flow

```
jmp
je
jne
jg
jl
call
ret
```

---

# 10. Conditional Jumps

Conditional jumps depend on CPU flags.

Example:

```
cmp eax, 5
je equal_label
```

Meaning:

```
Jump if eax == 5
```

Common jump instructions:

| Instruction | Meaning |
|-----------|---------|
| JE | equal |
| JNE | not equal |
| JG | greater |
| JL | less |
| JGE | greater or equal |
| JLE | less or equal |

---

# 11. Flags Register

Arithmetic operations update flags.

Common flags:

```
ZF (zero flag)
CF (carry flag)
SF (sign flag)
OF (overflow flag)
```

Example:

```
cmp eax, ebx
```

Sets flags used by conditional jumps.

---

# 12. Control Flow Graph (CFG)

A Control Flow Graph represents **program execution paths**.

Nodes:

```
basic blocks
```

Edges:

```
conditional branches
function calls
returns
```

CFG helps understand:

```
loops
conditions
program structure
```

---

# 13. Disassembly

Disassembly converts machine code to assembly.

Example:

```
objdump -d program
```

Output example:

```
400530: mov eax, 0
400535: call printf
```

---

# 14. Strings Analysis

Extract embedded strings.

```
strings program
```

Useful for finding:

```
URLs
password prompts
error messages
commands
```

---

# 15. Symbol Tables

Symbols reveal function names.

Check symbols:

```
nm program
```

Example output:

```
printf
main
malloc
```

Stripped binaries remove symbol names.

---

# 16. Debugging Basics

Debugging allows **runtime inspection**.

Start debugger:

```
gdb program
```

Run program:

```
run
```

Set breakpoint:

```
break main
```

Step instruction:

```
stepi
```

Continue execution:

```
continue
```

---

# 17. Inspect Registers

View registers:

```
info registers
```

Example:

```
rax = 0x1
rbx = 0x0
```

---

# 18. Inspect Memory

Examine memory:

```
x/16x $rsp
```

Example:

```
x/10i $rip
```

Shows next instructions.

---

# 19. System Call Tracing

Trace system calls:

```
strace program
```

Example output:

```
open("/etc/passwd", O_RDONLY)
read(3, ...)
```

---

# 20. Library Call Tracing

Trace library calls:

```
ltrace program
```

Example:

```
printf("Hello")
malloc(64)
```

---

# 21. Identify Imported Functions

Check imported functions:

```
objdump -T program
```

Or:

```
readelf -s program
```

---

# 22. Packed Binaries

Some binaries are packed to hide code.

Signs of packing:

```
small code section
few imports
large entropy
self-modifying code
```

Common packers:

```
UPX
Themida
ASPack
```

---

# 23. Unpacking Basics

Check for UPX:

```
upx -t program
```

Unpack:

```
upx -d program
```

---

# 24. Anti-Debugging Techniques

Programs sometimes detect debuggers.

Common checks:

```
ptrace
timing checks
debugger flags
```

Symptoms:

```
program exits under debugger
```

---

# 25. Control Flow Obfuscation

Obfuscation techniques:

```
opaque predicates
junk instructions
indirect jumps
control flow flattening
```

Purpose:

```
make analysis harder
```

---

# 26. Function Identification

Functions usually follow patterns:

```
push rbp
mov rbp, rsp
sub rsp, X
```

Function end:

```
leave
ret
```

---

# 27. Stack Variables

Local variables stored on stack.

Example:

```
mov eax, [rbp-0x4]
```

Access variable located at offset from base pointer.

---

# 28. Global Variables

Stored in:

```
.data
.bss
```

Example access:

```
mov eax, [0x601040]
```

---

# 29. Loops in Assembly

Typical loop pattern:

```
cmp ecx, 10
jl loop_start
```

Loop variable often stored in register.

---

# 30. Switch Statements

Compiled as:

```
jump tables
multiple cmp/jmp instructions
```

Example pattern:

```
jmp [table + eax*4]
```

---

# 31. Reverse Engineering Workflow

Typical workflow:

```
Identify architecture
Extract strings
Load in disassembler
Locate main function
Identify key functions
Analyze control flow
Rename variables
Reconstruct logic
```

---

# 32. Malware Analysis Basics

Key analysis goals:

```
identify C2 communication
understand persistence
extract encryption keys
identify dropped files
```

Common techniques:

```
string analysis
network monitoring
API tracing
sandbox execution
```

---

# 33. Patching Binaries

Binary patching modifies instructions.

Example:

```
change conditional jump
remove license check
skip validation
```

Patch tools:

```
radare2
IDA
Ghidra
hex editors
```

---

# 34. Useful Reverse Engineering Tools

### Static analysis

```
Ghidra
IDA Pro
radare2
Binary Ninja
objdump
```

### Debuggers

```
gdb
x64dbg
WinDbg
```

### Dynamic tracing

```
strace
ltrace
Frida
```

---

# 35. Reverse Engineering Study Strategy

Recommended learning order:

```
1. Assembly basics
2. C to assembly mapping
3. Stack and calling conventions
4. Disassembly tools
5. Debugging
6. Control flow reconstruction
7. Binary patching
8. Malware analysis
```

---

# 36. Quick Reverse Engineering Checklist

```
[ ] Identify binary type
[ ] Extract strings
[ ] Inspect imports
[ ] Locate main function
[ ] Identify program logic
[ ] Trace key functions
[ ] Observe runtime behavior
[ ] Document findings
```

---

# 37. Key Concepts to Memorize

```
Registers
Stack
Calling conventions
Assembly instructions
Control flow
Memory layout
Binary formats
Debugging techniques
```

Understanding these fundamentals allows you to **analyze complex binaries and uncover hidden program behavior**.
