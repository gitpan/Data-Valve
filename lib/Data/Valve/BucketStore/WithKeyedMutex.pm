# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/BucketStore/WithKeyedMutex.pm 65651 2008-07-14T08:23:35.067533Z daisuke  $

package Data::Valve::BucketStore::WithKeyedMutex;
use Moose::Role;
use Moose::Util::TypeConstraints;

use KeyedMutex;

class_type 'KeyedMutex';

coerce 'KeyedMutex'
    => from 'HashRef'
        => via {
            my $h = $_;
            KeyedMutex->new($h->{args});
        }
;

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

sub lock {
    my ($self, $key) = @_;

    my $mutex = $self->mutex;
    return 1 unless $mutex;
    my $rv = eval { $mutex->lock($key, 1) };
    # if in case an error has been reported, we should ditch the mutex,
    # cause it will keep giving errors (or worse yet, crash)
    if ($@) {
        $self->mutex(undef);
    }
    return $rv;
}

1;

__END__

=head1 NAME

Data::Valve::BucketStore::WithKeyedMutex - Role To Add Locking Via KeyedMutex

=head1 SYNOPSIS

  package MyBucketStore;
  use Moose;

  with 'Data::Valve::BucketStore';
  with 'Data::Valve::BucketStore::WithKeyedMutex';

  no Moose;

=head1 METHODS

=head2 lock

Attempts to acquire a lock. Returns KeyedMutex::Lock on success.

If no KeyedMutex object is available (or KeyedMutex object errors out because 
of, e.g., the server is unreacheable, etc.), returns 1. This basically means
that your bucket store will run in degraded mode.

On lock failures, returns whatever KeyedMutex->lock returns (false)

=cut
