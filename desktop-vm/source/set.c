//
// Created by Jeremy S on 2018-03-27.
//

#include "../headers/set.h"

/* ==== Helper Functions ==== */

set_node *__make_node(void *value) {
    set_node *node = (set_node *) malloc(sizeof(set_node));
    node->value = value;
    node->left_child = nullptr;
    node->right_child = nullptr;
    return node;
}


void __delete_set_node(set_node *node) {
    if (node->right_child)
        __delete_set_node(node->right_child);
    if (node->left_child)
        __delete_set_node(node->left_child);
    free(node);
}


void __insert_rec(set *s, set_node *node, void *value) {
    if (s->comparator(value, node->value)) {
        if (node->left_child) {
            __insert_rec(s, node->left_child, value);
        } else {
            node->left_child = __make_node(value);
        }
    } else {
        if (node->right_child) {
            __insert_rec(s, node->right_child, value);
        } else {
            node->right_child = __make_node(value);
        }
    }
}


bool __search_rec(set *s, set_node *node, void *value) {
    if (node->value == value) {
        return true;
    } else if (s->comparator(value, node->value)) {
        if (node->left_child) {
            return __search_rec(s, node->left_child, value);
        } else {
            return false;
        }
    } else {
        if (node->right_child) {
            return __search_rec(s, node->right_child, value);
        } else {
            return false;
        }
    }
}


bool __remove_rec(set *s, set_node *node, set_node *parent, void *value) {
    if (node->value == value) {
        --s->count;

        set_node **edge;
        if (parent) {
            if (parent->left_child == node)
                edge = &parent->left_child;
            else
                edge = &parent->right_child;
        } else {
            edge = &s->root;
        }

        if (node->left_child) {
            set_node *pred_parent = node;
            set_node *pred = node->left_child;
            while (pred->right_child) {
                pred_parent = pred;
                pred = pred->right_child;
            }
            node->value = pred->value;
            set_node **pred_edge = pred_parent->left_child == pred ?
                                   &pred_parent->left_child : & pred_parent->right_child;
            if (pred->left_child) {
                *pred_edge = pred->left_child;
            } else {
                *pred_edge = nullptr;
            }
            return true;
        } else if (node->right_child) {
            *edge = node->right_child;
            free(node);
            return true;
        } else {
            *edge = nullptr;
            free(node);
            return true;
        }

    } else {
        if (s->comparator(value, node->value)) {
            if (node->left_child) {
                return __remove_rec(s, node->left_child, node, value);
            } else {
                return false;
            }
        } else {
            if (node->right_child) {
                return __remove_rec(s, node->right_child, node, value);
            } else {
                return false;
            }
        }
    }
}


void __in_order_traversal(set_node *node, void(*action)(void *)) {
    if (node) {
        __in_order_traversal(node->left_child, action);
        action(node->value);
        __in_order_traversal(node->right_child, action);
    }
}


/* ==== Class Functions ==== */

void *set_node_hash(void *x) {
    uint64_t maska = (uint64_t) x & 0xffff0000;
    uint64_t maskb = (uint64_t) x & 0x0000ffff;
    return (void *) (((maska >> 16) ^ maskb) ^ ((maskb & 0xff) << 8));
}


bool set_node_comparator(void *lhs, void *rhs) {
    return set_node_hash(lhs) <= set_node_hash(rhs);
}


set *make_set(bool(*comparator)(void *, void *)) {
    set *s = (set *) malloc(sizeof(set));
    s->count = 0;
    s->root = nullptr;
    s->comparator = comparator;
    return s;
}


void delete_set(set *s) {
    if (s->root)
        __delete_set_node(s->root);
    free(s);
}


void set_insert(set *s, void *x) {
    ++s->count;
    if (s->root) {
        __insert_rec(s, s->root, x);
    } else {
        s->root = __make_node(x);
    }
}

bool set_contains(set *s, void *x) {
    if (s->root) {
        return __search_rec(s, s->root, x);
    } else {
        return false;
    }
}

bool set_remove(set *s, void *x) {
    if (s->root) {
        return __remove_rec(s, s->root, nullptr, x);
    } else {
        return false;
    }
}

void set_traverse(set *s, void(*action)(void *)) {
    __in_order_traversal(s->root, action);
}
