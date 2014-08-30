#ifndef _STRING_H_
#define _STRING_H_

#include <types.h>

void    *memccpy(void *, const void *, int, size_t);
void    *memchr(const void *, int, size_t);
int      memcmp(const void *, const void *, size_t);
void    *memcpy(void *, const void *, size_t);
void    *memmove(void *, const void *, size_t);
void    *memset(void *, int, size_t);
size_t  strlen(const char *);

#endif/*_STRING_H_*/
