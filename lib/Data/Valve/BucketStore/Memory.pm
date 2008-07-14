# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/BucketStore/Memory.pm 65685 2008-07-14T21:35:24.074501Z daisuke  $

package Data::Valve::BucketStore::Memory;
use Moose;

with 'Data::Valve::BucketStore';

has 'store' => (
    is => 'rw',
    isa => 'HashRef',
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub BUILD { 
    my $self = shift;
    $self->store( {
        __default => $self->create_bucket()
    } );
}

sub create_bucket
{
    my $self = shift;
    return Data::Valve::Bucket->new(
        max_items => $self->max_items,
        interval  => $self->interval
    );
}

sub try_push {
    my ($self, %args) = @_;

    my $bucket = $self->store()->{ $args{key} };
    if (! $bucket) {
        $bucket = $self->create_bucket;
        $self->store()->{ $args{key} } = $bucket;
    }

    return $bucket->try_push();
}

1;

__END__

=head1 NAME

Data::Valve::BucketStore::Memory - An In-Memory Bucket Store

=head1 METHODS

=head2 create_bucket

=head2 try_push

=cut
