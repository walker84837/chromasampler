#include <stdio.h>
#include <stdarg.h>
#include "logging.h"

void info(const char *format, ...)
{
	va_list args;
	va_start(args, format);
	printf("[INFO]: ");
	vprintf(format, args);
	printf("\n");
	va_end(args);
}

void warning(const char *format, ...)
{
	va_list args;
	va_start(args, format);
	fprintf(stderr, "[WARNING]: ");
	vprintf(format, args);
	printf("\n");
	va_end(args);
}

void error(const char *format, ...)
{
	va_list args;
	va_start(args, format);
	fprintf(stderr, "[ERROR]: ");
	vprintf(format, args);
	printf("\n");
	va_end(args);
}

void fatal_error(const char *format, ...)
{
	va_list args;
	va_start(args, format);
	fprintf(stderr, "[FATAL ERROR]: ");
	vprintf(format, args);
	printf("\n");
	va_end(args);
}
