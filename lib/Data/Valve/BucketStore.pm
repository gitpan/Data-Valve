# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/BucketStore.pm 66548 2008-07-22T00:38:42.978696Z daisuke  $

package Data::Valve::BucketStore;
use Moose::Role;

requires 'try_push';

has 'context' => (
    is       => 'rw',
    isa      => 'Data::Valve',
    handles  => [ qw(max_items interval strict_interval) ],
);

no Moose;

1;

__END__

=head1 NAME

Data::Valve::BucketStore - Manage Buckets

=head1 METHODS

=head2 setup

=cut