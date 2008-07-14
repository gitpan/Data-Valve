# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/BucketStore.pm 65685 2008-07-14T21:35:24.074501Z daisuke  $

package Data::Valve::BucketStore;
use Moose::Role;

requires 'try_push';

has 'context' => (
    is       => 'rw',
    isa      => 'Data::Valve',
    handles  => [ qw(max_items interval) ],
);

no Moose;

1;

__END__

=head1 NAME

Data::Valve::BucketStore - Manage Buckets

=head1 METHODS

=head2 setup

=cut