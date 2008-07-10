#ifndef __DV_BUCKET_C__
#define __DV_BUCKET_C__

#include "dv_bucket.h"
#include <stdio.h>

#define DV_1E6 1000000
struct timezone tzp_not_used;

static inline
unsigned long long
dv_bucket_timeval2long(struct timeval *tp)
{
    return ((long long) tp->tv_sec) * DV_1E6 + tp->tv_usec;
}

dv_bucket_item *
dv_bucket_item_create(struct timeval *tp)
{
    dv_bucket_item *item;

    item = (dv_bucket_item *) malloc( sizeof(dv_bucket_item) );
    item->next = NULL;
    item->time = dv_bucket_timeval2long(tp);
    return item;
}

void
dv_bucket_item_destroy(dv_bucket_item *item)
{
    free(item);
}

dv_bucket*
dv_bucket_create(float interval, unsigned long max)
{
    dv_bucket *bucket;

    bucket = (dv_bucket *) malloc( sizeof(dv_bucket));
    bucket->max = max;
    bucket->interval = (long) interval * DV_1E6;
    bucket->count = 0;
    bucket->head = NULL;
    bucket->tail = NULL;
    return bucket;
}

void
dv_bucket_reset(dv_bucket *bucket)
{
    dv_bucket_item *item = bucket->head;

    while (item) {
        dv_bucket_item *tmp = item->next;
        dv_bucket_item_destroy(item);
        item = tmp;
    }

    bucket->head = NULL;
    bucket->tail = NULL;
    bucket->count = 0;
}

void
dv_bucket_destroy(dv_bucket *bucket)
{
    dv_bucket_item *item = bucket->head;
    dv_bucket_item *tmp;

    while (item != NULL) {
        tmp = item->next;
        free(item);
        item = tmp;
    }

    free(bucket);
}

unsigned long
dv_bucket_count(dv_bucket *bucket)
{
    return bucket->count;
}

inline static
long long
dv_bucket_timediff(struct timeval *tp1, struct timeval *tp2) 
{
    unsigned long long tp1_as_long, tp2_as_long, diff;

    tp1_as_long = dv_bucket_timeval2long(tp1);
    tp2_as_long = dv_bucket_timeval2long(tp2);

    diff = tp2_as_long - tp1_as_long;
    return diff;
}

size_t
dv_bucket_expire( dv_bucket *bucket, struct timeval *tp )
{
    /* get the difference from the head of the list and the
     * time we're currently trying to insert. 
     * if the difference is bigger than the interval specified,
     * we can safely drop the oldest bucket.
     * we repeat until bucket->head is within the given interval
     */
    size_t expired = 0;

    while ( 
        bucket->head != NULL &&
        bucket->interval < dv_bucket_timeval2long(tp) - bucket->head->time
    ) {
        dv_bucket_item *tmp = bucket->head;
        bucket->head = bucket->head->next;
        if (bucket->head == NULL) {
            bucket->tail = NULL;
        }
        dv_bucket_item_destroy(tmp);
        bucket->count--;
        expired++;
    }

    return expired;
}

int
dv_bucket_is_full(dv_bucket *bucket)
{
    return bucket->max <= bucket->count;
}

void
dv_bucket_push(dv_bucket *bucket, struct timeval *tp)
{
    dv_bucket_item *item = dv_bucket_item_create(tp);
    if (bucket->count == 0) {
        bucket->head = item;
        bucket->tail = item;
    } else {
        bucket->tail->next = item;
        bucket->tail = item;
    }

    bucket->count++;
}

int
dv_bucket_try_push(dv_bucket *bucket)
{
    struct timeval t;

    gettimeofday(&t, &tzp_not_used);

    dv_bucket_expire( bucket, &t );

    if ( dv_bucket_count( bucket ) == 0 ) {
        dv_bucket_push( bucket, &t );
        return 1;
    }

    if ( dv_bucket_is_full(bucket) ) {
        return 0;
    }

    dv_bucket_push( bucket, &t );
    return 1;
}

void
dv_bucket_dump(dv_bucket *bucket)
{
    int count = 1;
    dv_bucket_item *item = bucket->head;

    PerlIO_printf(PerlIO_stderr(),
        "bucket %p, count = %d\n", bucket, bucket->count);

    while (item != NULL) {
        PerlIO_printf(PerlIO_stderr(), " + %02d. %lld.%lld (%lld)\n", count++, item->time / DV_1E6, item->time % DV_1E6, item->time);
        item = item->next;
    }
}


#include <stdio.h>
int
main(int argc, char **argv)
{
    dv_bucket *bucket = dv_bucket_create( 10, 5 );

    while (1) {
        if (dv_bucket_try_push( bucket ) ) {
            printf("push ok\n");
        } else {
            printf("push NOT ok\n" );
        }

        dv_bucket_dump(bucket);

        if (bucket->count == 5) {
            dv_bucket_reset(bucket);
        }

        sleep(1);
    }
}

#endif /* __DV_BUCKET_C__ */