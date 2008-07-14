# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/BucketStore/Object.pm 65651 2008-07-14T08:23:35.067533Z daisuke  $

package Data::Valve::BucketStore::Object;
use Moose;
use Moose::Util::TypeConstraints;

with 'Data::Valve::BucketStore';
with 'Data::Valve::BucketStore::WithKeyedMutex';

# this is the storage object. it must support get()/set()
subtype 'StorageObject'
    => as 'Object'
        => where { $_->can('get') && $_->can('set') }
;

has 'store' => (
    is => 'rw',
    isa => 'StorageObject',
    required => 1
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub try_push {
    my ($self, %args) = @_;

    my $key = $args{key};

    my $rv;
    my $done = 0;
    my $store = $self->store;
    while ( ! $done) {
        my $lock = $self->lock($key);
        next unless $lock;

        $done = 1;
        my $bucket_source = $store->get($key);
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
            $store->set($key, $bucket->serialize);
        }
    }

    return $rv;
}

1;

__END__

=head1 NAME

Data::Valve::BucketStore::Object - Basic Object Storage

=head1 SYNOPSIS

  my $store = Data::Valve::BucketStore::Object->new(
    store => $object,
  );

=head1 DESCRIPTION

This storage type only needs an object which supports a get()/set() methods

=head1 METHODS

=head2 try_push

=cut