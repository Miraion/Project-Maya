//
// Created by Jeremy S on 2018-03-16.
//

#include "../headers/binary_stream.h"
#include <fcntl.h>
#include <unistd.h>

binary_stream *open_stream(const char *filename) {
    binary_stream *stream = malloc(sizeof(binary_stream));
    int fd = open(filename, O_RDONLY);
    if (fd == -1) {
        stream->error = ERROR_FILE;
        return stream;
    }
    stream->size = (size_t) lseek(fd, 0, SEEK_END);
    lseek(fd, 0, SEEK_SET);
    if (stream->size == 0) {
        stream->buf = nullptr;
        stream->cursor = nullptr;
        return stream;
    }
    stream->buf = malloc(stream->size);
    if (read(fd, stream->buf, stream->size) == -1) {
        stream->error = ERROR_FILE;
        return stream;
    }
    stream->cursor = stream->buf;
    stream->error = ERROR_NULL;
    close(fd);
    return stream;
}

void close_stream(binary_stream *stream) {
    free(stream->buf);
    free(stream);
}

binary_stream *make_stream(void *buf, size_t size) {
    binary_stream *stream = malloc(sizeof(binary_stream));
    stream->error = ERROR_NULL;
    stream->buf = buf;
    stream->size = size;
    stream->cursor = stream->buf;
    return stream;
}

size_t bytes_left(binary_stream const *stream) {
    return stream->size - (stream->cursor - (uint8_t *) stream->buf);
}

optional_integer peek(binary_stream const *stream, modifier_t type) {
    if (bytes_left(stream) < type) {
        return nil_integer();
    } else {
        switch (type) {
        case byte_m:
            return make_integer(*stream->cursor);
        case word_m:
            return make_integer(*(uint16_t *) stream->cursor);
        case long_m:
            return make_integer(*(uint32_t *) stream->cursor);
        case quad_m:
            return make_integer(*(uint64_t *) stream->cursor);
        default: return nil_integer();
        }
    }
}

optional_integer extract(binary_stream *stream, modifier_t type) {
    if (bytes_left(stream) < type) {
        return nil_integer();
    } else {
        uint64_t result = 0;
        uint8_t *ptr = (uint8_t *) &result;
        for (int i = 0; i < type; ++i) {
            ptr[i] = *stream->cursor;
            ++stream->cursor;
        }
        return make_integer(result);
    }
}

void consume(binary_stream *stream, int n) {
    while (n != 0 && bytes_left(stream) != 0) {
        ++stream->cursor;
        --n;
    }
}
