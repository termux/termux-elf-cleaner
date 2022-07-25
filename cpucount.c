// SPDX-License-Identifier: CC0-1.0

/* Based on cpucount.c from github.com/cathugger/mkp224o */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

static int parsecpuinfo(void)
{
	unsigned char cpubitmap[128];

	memset(cpubitmap,0,sizeof(cpubitmap));

	FILE *f = fopen("/proc/cpuinfo","r");
	if (!f)
		return -1;

	char buf[8192];
	while (fgets(buf,sizeof(buf),f)) {
		// we don't like newlines
		for (char *p = buf;*p;++p) {
			if (*p == '\n') {
				*p = 0;
				break;
			}
		}
		// split ':'
		char *v = 0;
		for (char *p = buf;*p;++p) {
			if (*p == ':') {
				*p = 0;
				v = p + 1;
				break;
			}
		}
		// key padding
		size_t kl = strlen(buf);
		while (kl > 0 && (buf[kl - 1] == '\t' || buf[kl - 1] == ' ')) {
			--kl;
			buf[kl] = 0;
		}
		// space before value
		if (v) {
			while (*v && (*v == ' ' || *v == '\t'))
				++v;
		}
		// check what we need
		if (strcasecmp(buf,"processor") == 0 && v) {
			char *endp = 0;
			long n = strtol(v,&endp,10);
			if (endp && endp > v && n >= 0 && (size_t)n < sizeof(cpubitmap) * 8)
				cpubitmap[n / 8] |= 1 << (n % 8);
		}
	}

	fclose(f);

	// count bits in bitmap
	int ncpu = 0;
	for (size_t n = 0;n < sizeof(cpubitmap) * 8;++n)
		if (cpubitmap[n / 8] & (1 << (n % 8)))
			++ncpu;

	return ncpu;
}

int cpucount(void)
{
	int ncpu;
	ncpu = parsecpuinfo();
	if (ncpu > 0)
		return ncpu;
	return -1;
}
