#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "dv_bucket.h"

MODULE = Data::Valve     PACKAGE = Data::Valve::Bucket   PREFIX = dv_bucket_

dv_bucket *
dv_bucket_create(float interval, unsigned long max)

void
dv_bucket_destroy(dv_bucket *bucket)
    ALIAS:
        DESTROY = 1

void
dv_bucket_expire(dv_bucket *bucket)

int
dv_bucket_try_push(dv_bucket *bucket)
