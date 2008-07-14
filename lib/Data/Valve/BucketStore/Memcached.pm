# $Id: /mirror/coderepos/lang/perl/Data-Valve/trunk/lib/Data/Valve/BucketStore/Memcached.pm 65649 2008-07-14T06:49:12.277933Z daisuke  $

package Data::Valve::BucketStore::Memcached;
use Moose;
use Moose::Util::TypeConstraints;

extends 'Data::Valve::BucketStore::Object';

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

has '+store' => (
    isa      => 'Memcached',
    coerce   => 1,
    required => 1,
    default  => sub {
        Class::MOP::load_class('Cache::Memcached');
        Cache::Memcached->new({
            servers => [ '127.0.0.1:11211' ]
        });
    }
);

__PACKAGE__->meta->make_immutable;

no Moose;

1;

__END__

=head1 NAME

Data::Valve::BucketStore::Memcached - Memcached Backend

=head1 DESCRIPTION

Data::Valve::BucketStore::Memcached uses Memcached as its storage backend,
and allows multiple processes to work together.

You need to specify a memcached server in order for t to work:

  Data::Valve->new(
    bucket_store => {
      module => "Memcached",
      args => {
        store => {
          servers => [ '127.0.0.1:11211' ],
          namespace => ...
        }
      }
    }
  );

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
