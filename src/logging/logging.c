#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <time.h>
#include "logging.h"

char *get_time_now()
{
	char *buffer = malloc(20);

	if (buffer == NULL) {
		return NULL;
	}

	time_t rawtime;
	struct tm *timeinfo;

	time(&rawtime);
	timeinfo = localtime(&rawtime);

	strftime(buffer, 20, "%Y-%m-%d %H:%M:%S", timeinfo);

	return buffer;
}

void info(const char *format, ...)
{
	va_list args;
	va_start(args, format);

	char *time_now = get_time_now();
	if (time_now == NULL) {
		fputs("Something went wrong when formatting the time\n", stderr);
		exit(1);
	}
	printf("[%s] [INFO]: ", time_now);
	free(time_now);

	vprintf(format, args);
	printf("\n");
	va_end(args);
}

void warning(const char *format, ...)
{
	va_list args;
	va_start(args, format);

	char *time_now = get_time_now();
	if (time_now == NULL) {
		fputs("Something went wrong when formatting the time\n", stderr);
		exit(1);
	}
	printf("[%s] [WARNING]: ", time_now);
	free(time_now);

	vprintf(format, args);
	printf("\n");
	va_end(args);
}

void error(const char *format, ...)
{
	va_list args;
	va_start(args, format);

	char *time_now = get_time_now();
	if (time_now == NULL) {
		fputs("Something went wrong when formatting the time\n", stderr);
		exit(1);
	}
	fprintf(stderr, "[%s] [ERROR]: ", get_time_now());
	free(time_now);

	vprintf(format, args);
	printf("\n");
	va_end(args);
}

void fatal_error(const char *format, ...)
{
	va_list args;
	va_start(args, format);

	char *time_now = get_time_now();
	if (time_now == NULL) {
		fputs("Something went wrong when formatting the time\n", stderr);
		exit(1);
	}
	fprintf(stderr, "[%s] [FATAL ERROR]: ", get_time_now());
	free(time_now);

	vprintf(format, args);
	printf("\n");
	va_end(args);
}
