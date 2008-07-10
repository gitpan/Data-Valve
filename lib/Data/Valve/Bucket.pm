# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/Bucket.pm 65475 2008-07-10T08:24:28.966073Z daisuke  $

package Data::Valve::Bucket;
use strict;

sub new {
    my ($class, %args) = @_;
    my $self  = bless create($args{interval}, $args{max_items}), $class;
    
    return $self;
}

sub deserialize {
    my ($class, @args) = @_;
    return bless _deserialize(@args), $class;
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

=head2 interval

=head2 max_items

=head2 count

=head2 serialize

=head2 deserialize

=head2 first

=head2 reset

=cut
