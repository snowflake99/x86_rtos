#include <string.h>
#include <types.h>

/* memccpy - copy bytes in memory */
void *memccpy(void *s1, const void *s2, int c, size_t n)
{
  size_t i;
  uint8_t ch = (uint8_t)c;
  uint8_t *str1 = s1;
  const uint8_t *str2 = s2;

  for(i = 0; i < n; ++i)
    if( (*str1++ = *str2++) == ch)
      return str1;

  return 0;
}

void *memset(void * s, int c, size_t n)
{
  size_t i;
  uint8_t ch = (uint8_t)c;
  uint8_t* d = s;

  for(i = 0; i < n; ++i)
    *d++ = ch;

  return s;
}

size_t strlen(const char *s)
{
  const char * tmp;

  for(tmp = s; *tmp; ++tmp)
    ;

  return tmp - s;
}
