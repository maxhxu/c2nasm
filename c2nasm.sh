#!/bin/sh
set -e

C_FILE="$1"
O_FILE="$C_FILE.o"
NASM_FILE="$C_FILE.nasm"
NASM_O_FILE="$NASM_FILE.o"
EXEC_FILE="$C_FILE.run"

gcc -m64 -c -o "$O_FILE" "$C_FILE"

objconv -fnasm "$O_FILE" "$NASM_FILE"

if ! grep -q "default rel" "$NASM_FILE"; then
    sed -i '1i default rel' "$NASM_FILE"
fi

sed -i 's|st(0)|st0  |g' "$NASM_FILE"
sed -i 's|noexecute||g' "$NASM_FILE"
sed -i 's|execute||g' "$NASM_FILE"
sed -i 's|: function||g' "$NASM_FILE"
sed -i 's|?_|L_|g' "$NASM_FILE"
sed -i -n '/SECTION .eh_frame/q;p' "$NASM_FILE"
sed -i 's|;.*||g' "$NASM_FILE"
sed -i 's|\s\+$||g' "$NASM_FILE"
sed -i 's|align=1||g' "$NASM_FILE"

sed -i '/^$/N;/^\n$/D' "$NASM_FILE"
sed -i '/./,$!d' "$NASM_FILE"

echo 'NASM file generated in '"$NASM_FILE"

OS_TYPE=$(uname -s)

if [ "$OS_TYPE" == "Darwin" ]; then
    FORMAT="macho64"
    LDFLAGS="-framework OpenGL -Wl,-no_pie"
elif [[ "$OS_TYPE" == "MSYS"* ]] || [[ "$OS_TYPE" == "MINGW"* ]]; then
    FORMAT="win64"
    LDFLAGS="-lopengl32 -lm"
else
    FORMAT="elf64"
    LDFLAGS="-no-pie -lGL -lm"
fi

nasm -f "$FORMAT" -o "$NASM_O_FILE" "$NASM_FILE"
gcc -m64 $LDFLAGS -o "$EXEC_FILE" "$NASM_O_FILE"

echo 'Successfully compiled to '"$EXEC_FILE"

