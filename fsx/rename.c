#include <moonbit.h>
#include <stdio.h>

MOONBIT_FFI_EXPORT
int32_t moonbit_moonlib_fsx_rename(moonbit_bytes_t source,
                                   moonbit_bytes_t destination) {
  return rename((const char *)source, (const char *)destination);
}
