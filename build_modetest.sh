gcc -o ./modetest \
  -I. -I include/drm -I include -I tests \
  tests/modetest/modetest.c tests/modetest/buffers.c tests/modetest/cursor.c \
  tests/util/pattern.c tests/util/format.c tests/util/kms.c \
  -L/usr/lib/x86_64-linux-gnu -l:libdrm.so.2 -lm \
  -Wall \
  2>&1
