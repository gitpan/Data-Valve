# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/Bucket.pm 65443 2008-07-10T02:19:14.430378Z daisuke  $

package Data::Valve::Bucket;
use strict;

sub new {
    my ($class, %args) = @_;
    my $self  = bless create($args{interval}, $args{max_items}), $class;
    
    return $self;
}

1;

__END__

=head1 NAME

Data::Valve::Bucket - A Data Bucket

=head1 METHODS

=head2 new

=head2 create

=head2 try_push

=head2 expire

=head2 destroy

=cut
