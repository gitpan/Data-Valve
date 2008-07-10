use strict;
use Test::More (tests => 16);

BEGIN
{
    use_ok("Data::Valve");
}

{
    my $valve = Data::Valve->new(
        max_items => 5,
        interval  => 3
    );

    # 5 items should succeed
    for( 1.. 5) {
        ok( $valve->try_push(), "try $_ should succeed" );
    }

    ok( ! $valve->try_push(), "this try should fail" );

    diag("sleeping for 3 seconds...");
    sleep 3;

    ok( $valve->try_push(), "try after 3 seconds should work");
}

{
    my $valve = Data::Valve->new(
        max_items => 5,
        interval  => 3
    );

    # 5 items should succeed
    for( 1.. 5) {
        ok( $valve->try_push(key => "foo"), "try $_ should succeed" );
    }

    ok( ! $valve->try_push(key => "foo"), "this try should fail" );
    ok( $valve->try_push(key => "bar"), "this try should succeed" );

    diag("sleeping for 3 seconds...");
    sleep 3;

    ok( $valve->try_push(key => "foo"), "try after 3 seconds should work");
}