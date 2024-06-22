// logging.h

#ifndef LOGGING_H
#define LOGGING_H

// Function to get local time as `YYYY-MM-DD HH:MM:SS`
char *get_time_now();

// Function to print log messages with INFO level
void info(const char *format, ...);

// Function to print log messages with WARNING level to stderr
void warning(const char *format, ...);

// Function to print log messages with ERROR level to stderr
void error(const char *format, ...);

// Function to print log messages with ERROR level to stderr
void fatal_error(const char *format, ...);

#endif // LOGGING_H
