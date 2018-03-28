//
// Created by Jeremy S on 2018-03-16.
//

#pragma once

#include <stdlib.h>
#include "types.h"
#include "error_t.h"

typedef struct {
    error_t error;
    void *buf;
    size_t size;
    uint8_t *cursor;
} binary_stream;


/**
 * Opens a file with a given name and wraps a binary stream
 * object around it. The file's contents are copied into a
 * buffer before closing the source file. If there was an
 * error when opening the file, then the error attribute will
 * be set with the ERROR_FILE error code.
 */
binary_stream *open_stream(const char *filename);

/**
 * Closes a given stream by freeing it's buffer and the given
 * stream pointer. The given stream is unusable after calling
 * this function.
 */
void close_stream(binary_stream *stream);

/**
 * Creates a binary_stream object by wrapping around an existing
 * buffer of a given size. The buffer should be located on the
 * heap otherwise calling close_stream() will cause a runtime
 * error as close_stream() will attempt to free the stream's
 * buffer.
 */
binary_stream *make_stream(void *buf, size_t size);

/**
 * Returns the number of bytes left in a given stream using the
 * location of the cursor.
 */
size_t bytes_left(binary_stream const *stream);

/**
 * Returns the next integer type in the stream without consuming
 * it. Will only return nil if there are not enough bytes left
 * in the stream to construct the desired integer type.
 */
optional_integer peek(binary_stream const *stream, modifier_t type);

/**
 * Extracts a given integer type from the stream, advancing the
 * cursor by the number of bytes of the extracted type. Like with
 * peek(), this function will only return nil if there are not
 * enough bytes left in the stream to construct the desired type.
 * If such a case occurs, the cursor is not advanced and the state
 * of the stream is not altered.
 */
optional_integer extract(binary_stream *stream, modifier_t type);

/**
 * Consumes n bytes from the stream without constructing anything.
 * If n larger than the number of bytes left in the stream, the
 * cursor is advanced to the end of the stream such that
 * bytes_left(stream) == 0.
 */
void consume(binary_stream *stream, int n);
