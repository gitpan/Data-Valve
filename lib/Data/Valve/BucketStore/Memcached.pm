# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/BucketStore/Memcached.pm 65480 2008-07-10T09:25:21.801513Z daisuke  $

# TODO I think we need locking!
package Data::Valve::BucketStore::Memcached;
use Moose;
use Moose::Util::TypeConstraints;

use KeyedMutex;

with 'Data::Valve::BucketStore';

subtype 'Memcached'
    => as 'Object'
        => where {
            my $h = $_;
            foreach my $class qw( Cache::Memcached Cache::Memcached::Fast Cache::Memcached::libmemcached ) {
                $h->isa($class) and return 1;
            }
            return ();
        }
;

coerce 'Memcached'
    => from 'HashRef'
        => via {
            my $h = $_;
            my $module = $h->{module} || 'Cache::Memcached';
            Class::MOP::load_class($module);
            $module->new($h->{args});
        }
;

class_type 'KeyedMutex';

coerce 'KeyedMutex'
    => from 'HashRef'
        => via {
            my $h = $_;
            KeyedMutex->new($h->{args});
        }
;

has 'memcached' => (
    is       => 'rw',
    isa      => 'Memcached',
    coerce   => 1,
    required => 1,
);

has 'mutex' => (
    is => 'rw',
    isa => 'KeyedMutex',
    coerce => 1,
);

no Moose;

sub BUILD {
    my $self = shift;

    # if no keyedmutex was provided explicitly, we attempt to create one
    # however, if the creation of this object fails, well, we can go
    # without it in degraded mode
    if ( ! $self->mutex ) {
        my $mutex = eval {KeyedMutex->new };
        if ($mutex) {
            $self->mutex($mutex);
        } else {
            warn $@;
        }
    }
}

sub try_push {
    my ($self, %args) = @_;

    my $key = $args{key};

    my $mutex = $self->mutex;

    my $rv;
    my $done = 0;
    while ( ! $done) {
        my $lock = $mutex ? $mutex->lock($key, 1) : 1;
        next unless $lock;

        $done = 1;
        my $bucket_source = $self->memcached->get($key);
        my $bucket;
        if ($bucket_source) {
            $bucket = Data::Valve::Bucket->deserialize($bucket_source, $self->interval, $self->max_items);
        } else {
            $bucket = Data::Valve::Bucket->new(
                interval  => $self->interval,
                max_items => $self->max_items,
            );
        }
        $rv = $bucket->try_push();

        # we only need to set if the value has changed, i.e., the throttle
        # was successful
        if ($rv) {
            $self->memcached->set($key, $bucket->serialize);
        }
    }

    return $rv;
}

1;

__END__

=head1 NAME

Data::Valve::BucketStore::Memcached - Memcached Backend

=head1 DESCRIPTION

Data::Valve::BucketStore::Memcached uses Memcached as its storage backend,
and allows multiple processes to work together.

This module also provides locking mechanism by means of KeyedMutex.
You should specify one at construction time:

  Data::Valve->new(
    bucket_store => {
      module => "Memcached",
      args   => {
        mutex => {
          args => {
            sock => "host:port" # <-- here
          }
        }
      }
    }
  );

This allows all coordinating processes to share the same mutex, and you will
get "correct" throttling information

=head1 METHODS

=head2 try_push

=cut
