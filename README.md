# c2nasm.sh

This script compiles a C file into an object, disassembles and cleans it (whitespace, fixing `objconv` quirks) into a typical x86-64 NASM file, and then reassembles that assembly into a final executable.

Run using

```bash
./c2nasm.sh <sourcefile.c>
```

## Credits

A modified version of https://github.com/diogovk/c2nasm
