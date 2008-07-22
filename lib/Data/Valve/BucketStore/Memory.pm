# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/BucketStore/Memory.pm 66548 2008-07-22T00:38:42.978696Z daisuke  $

package Data::Valve::BucketStore::Memory;
use Moose;

with 'Data::Valve::BucketStore';

has 'store' => (
    is => 'rw',
    isa => 'HashRef',
    required => 1,
    default => sub { +{} }
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub create_bucket
{
    my $self = shift;
    return Data::Valve::Bucket->new(
        max_items => $self->max_items,
        interval  => $self->interval,
        strict_interval => $self->strict_interval,
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
