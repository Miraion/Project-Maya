//
// Created by Jeremy S on 2018-03-27.
//

#pragma once

#include <stdlib.h>
#include "types.h"

struct __set_node {
    void *value;
    struct __set_node *left_child;
    struct __set_node *right_child;
};

typedef struct __set_node set_node;


typedef struct {
    set_node *root;
    size_t count;
    bool(*comparator)(void *, void *);
} set;


/**
 * Keys are run through a hash function to randomize their
 * values a bit so that the binary search tree that the set
 * uses is a bit more properly structured.
 *
 * The result of this hashing function is a 16-bit integer.
 */
void *set_node_hash(void *);


/**
 * The default comparator function for sets of raw pointers.
 */
bool set_node_comparator(void *, void *);


/**
 * Creates a new set on the heap initializing count to 0
 * and root to nullptr.
 */
set *make_set(bool(*comparator)(void *, void *));

/**
 * De-allocates all memory used by a given set then deletes
 * the set object itself.
 */
void delete_set(set *s);

/**
 * Inserts a new element `x` into a given set.
 */
void set_insert(set *s, void *x);

/**
 * Returns true if a given element `x` exists within the set.
 */
bool set_contains(set *s, void *x);

/**
 * Removes a given element `x` from a given set. Returns
 * true if removal was successful, false otherwise.
 */
bool set_remove(set *s, void *x);


/**
 * Preforms an in-order traversal of a given set, preforming
 * a given action on the value of each node.
 */
void set_traverse(set *s, void(*action)(void *));
