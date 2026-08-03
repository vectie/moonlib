#include "moonbit.h"
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

MOONBIT_FFI_EXPORT
int32_t
moonbit_moonlib_fs_mkdtemp(moonbit_bytes_t template) {
  int32_t len = Moonbit_array_length(template);
  char *buffer = (char *)malloc((size_t)len + 1);
  if (buffer == NULL) {
    return ENOMEM;
  }

  memcpy(buffer, template, (size_t)len);
  buffer[len] = '\0';
  errno = 0;
  if (mkdtemp(buffer)) {
    memcpy(template, buffer, (size_t)len);
    free(buffer);
    return 0;
  } else {
    int32_t error = errno;
    free(buffer);
    return error;
  }
}
