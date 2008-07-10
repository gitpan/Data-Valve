# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve.pm 65481 2008-07-10T09:26:32.262379Z daisuke  $

package Data::Valve;
use Moose;
use Data::Valve::Bucket;

use XSLoader;
our $VERSION   = '0.00003';
our $AUTHORITY = 'cpan:DMAKI';

XSLoader::load __PACKAGE__, $VERSION;

has 'max_items' => (
    is => 'rw',
    isa => 'Int',
    required => 1
);

has 'interval' => (
    is => 'rw',
    isa => 'Num',
    required => 1
);

has 'bucket_store' => (
    is => 'rw',
    does => 'Data::Valve::BucketStore',
);

around 'new' => sub {
    my ($next, $class, %args) = @_;

    my $store = delete $args{bucket_store} || { module => 'Memory' };
    if (! blessed $store) {
        my $module = $store->{module};
        if ($module !~ s/^\+//) {
            $module = "Data::Valve::BucketStore::$module";
        }
        Class::MOP::load_class($module);

        $store = $module->new( %{ $store->{args} } );
    }

    my $self = $next->($class, %args, bucket_store => $store);
    $store->setup( $self );

    return $self;
};

__PACKAGE__->meta->make_immutable;

no Moose;

sub BUILD {
    my $self = shift;
    $self->bucket_store->context($self);
}

sub try_push {
    my ($self, %args) = @_;

    $args{key} ||= '__default';
    $self->bucket_store->try_push(%args);
}

1;

__END__

=head1 NAME

Data::Valve - Throttle Your Data

=head1 SYNOPSIS

  use Data::Valve;

  my $valve = Data::Valve->new(
    max_items => 10,
    interval  => 30
  );

  if ($valve->try_push()) {
    print "ok\n";
  } else {
    print "throttled\n";
  }

  if ($valve->try_push(key => "foo")) {
    print "ok\n";
  } else {
    print "throttled\n";
  }

=head1 DESCRIPTION

Data::Valve is a throttler based on Data::Throttler.

Currently only throttles within a single process. More to come soon

=head1 METHODS

=head2 try_push([key => $key_name])

=head1 AUTHOR

Daisuke Maki C<< <daisuke@endeworks.jp> >>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut