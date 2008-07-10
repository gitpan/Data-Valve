#ifndef __DV_BUCKET_H__
#define __DV_BUCKET_H__

#include <stdlib.h>
#include <sys/time.h>
#define MAX_DV_BUCKET_KEY 256

typedef struct dv_bucket_item
{
    unsigned long long time;
    struct dv_bucket_item *next;
} dv_bucket_item;

typedef struct dv_bucket {
    unsigned long max;
    unsigned long interval;
    unsigned long count;
    dv_bucket_item *head;
    dv_bucket_item *tail;
} dv_bucket;

/* Creates a new bucket */
dv_bucket *dv_bucket_create(float interval, unsigned long max);

#endif /* __DV_BUCKET_H__ */
