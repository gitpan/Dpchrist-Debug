# $Id: 2_debug_enabled.t,v 1.17 2010-07-03 00:24:42 dpchrist Exp $

use Test::More			tests => 13;

package Foo;
use strict;
use warnings;
use Dpchrist::Debug		qw( :all );
sub foo { return debug_enabled; }

package Bar;
use base qw( Foo );
use strict;
use warnings;
use Dpchrist::Debug		qw( :all );
sub bar { return debug_enabled; }

package Baz;
use strict;
use warnings;
use Dpchrist::Debug		qw( :all );
sub baz { Bar::bar(); }

package main;

use strict;
use warnings;

use Carp;
use Dpchrist::Debug		qw( :all );
use Data::Dumper;
use Test::More;

$Data::Dumper::Sortkeys = 1;

$| = 1;

my $r;

$ENV{FOO__DEBUG}	= undef;
$ENV{DEBUG}		= undef;
$r = eval { Foo::foo() };
ok(								#     1
    $r eq '*STDERR',
    "Foo::foo() should return '*STDERR' " .
    'when FOO__DEBUG and DEBUG are undefined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{FOO__DEBUG}	= __FILE__ . __LINE__;
$ENV{DEBUG}		= undef;
$r = eval { Foo::foo() };
ok(								#     2
    defined $r
    && $r eq $ENV{FOO__DEBUG},
    'Foo::foo() should return FOO__DEBUG ' .
    'when FOO__DEBUG is defined and DEBUG is undefined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{FOO__DEBUG}	= undef;
$ENV{DEBUG}		= __FILE__ . __LINE__;
$r = eval { Foo::foo() };
ok(								#     3
    defined $r
    && $r eq $ENV{DEBUG},
    'Foo::foo() should return DEBUG ' .
    'when FOO__DEBUG is undefined and DEBUG is defined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{FOO__DEBUG}	= __FILE__ . __LINE__;
$ENV{DEBUG}		= __FILE__ . __LINE__;
$r = eval { Foo::foo() };
ok(								#     4
    defined $r
    && $r eq $ENV{FOO__DEBUG},
    'Foo::foo() should return FOO__DEBUG ' .
    'when FOO__DEBUG is undefined and DEBUG is defined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{BAR__DEBUG}	= undef;
$ENV{FOO__DEBUG}	= undef;
$ENV{DEBUG}		= undef;
$r = eval { Bar::bar() };
ok(								#     5
    $r eq '*STDERR',
    "Bar::bar() should return '*STDERR' " .
    'when BAR__DEBUG, FOO__DEBUG, and DEBUG are undefined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{BAR__DEBUG}	= undef;
$ENV{FOO__DEBUG}	= undef;
$ENV{DEBUG}		= __FILE__ . __LINE__;
$r = eval { Bar::bar() };
ok(								#     6
    defined $r
    && $r eq $ENV{DEBUG},
    'Bar::bar() should return DEBUG ' .
    'when BAR__DEBUG and FOO__DEBUG are undefined ' .
    'and DEBUG is defined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{BAR__DEBUG}	= undef;
$ENV{FOO__DEBUG}	= __FILE__ . __LINE__;
$ENV{DEBUG}		= __FILE__ . __LINE__;
$r = eval { Bar::bar() };
ok(								#     7
    defined $r
    && $r eq $ENV{FOO__DEBUG},
    'Bar::bar() should return FOO__DEBUG ' .
    'when BAR__DEBUG is undefined ' .
    'and FOO__DEBUG and DEBUG are defined '
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{BAR__DEBUG}	= __FILE__ . __LINE__;
$ENV{FOO__DEBUG}	= __FILE__ . __LINE__;
$ENV{DEBUG}		= __FILE__ . __LINE__;
$r = eval { Bar::bar() };
ok(								#     8
    defined $r
    && $r eq $ENV{BAR__DEBUG},
    'Bar::bar() should return FOO__DEBUG ' .
    'when BAR__DEBUG, FOO__DEBUG, and DEBUG are defined '
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{BAR__DEBUG}	= undef;
$ENV{FOO__DEBUG}	= undef;
$ENV{BAZ__DEBUG}	= undef;
$ENV{DEBUG}		= undef;
$r = eval { Baz::baz() };
ok(								#     9
    $r eq '*STDERR',
    "Baz::baz() should return '*STDERR' " .
    'when BAR__DEBUG, FOO__DEBUG, BAZ__DEBUG, and DEBUG are undefined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{BAR__DEBUG}	= undef;
$ENV{FOO__DEBUG}	= undef;
$ENV{BAZ__DEBUG}	= undef;
$ENV{DEBUG}		= __FILE__ . __LINE__;
$r = eval { Baz::baz() };
ok(								#    10
    defined $r
    && $r eq $ENV{DEBUG},
    'Baz::baz() should return DEBUG ' .
    'when BAR__DEBUG, FOO__DEBUG, and BAZ__DEBUG are undefined ' .
    'and DEBUG is defined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{BAR__DEBUG}	= undef;
$ENV{FOO__DEBUG}	= undef;
$ENV{BAZ__DEBUG}	= __FILE__ . __LINE__;
$ENV{DEBUG}		= __FILE__ . __LINE__;
$r = eval { Baz::baz() };
ok(								#    11
    defined $r
    && $r eq $ENV{BAZ__DEBUG},
    'Baz::baz() should return BAZ__DEBUG ' .
    'when BAR__DEBUG and FOO__DEBUG are undefined ' .
    'and BAZ__DEBUG and DEBUG are defined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{BAR__DEBUG}	= undef;
$ENV{FOO__DEBUG}	= __FILE__ . __LINE__;
$ENV{BAZ__DEBUG}	= __FILE__ . __LINE__;
$ENV{DEBUG}		= __FILE__ . __LINE__;
$r = eval { Baz::baz() };
ok(								#    12
    defined $r
    && $r eq $ENV{FOO__DEBUG},
    'Baz::baz() should return FOO__DEBUG ' .
    'when BAR__DEBUG is undefined ' .
    'and FOO__DEBUG, BAZ__DEBUG, and DEBUG are defined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

$ENV{BAR__DEBUG}	= __FILE__ . __LINE__;
$ENV{FOO__DEBUG}	= __FILE__ . __LINE__;
$ENV{BAZ__DEBUG}	= __FILE__ . __LINE__;
$ENV{DEBUG}		= __FILE__ . __LINE__;
$r = eval { Baz::baz() };
ok(								#    13
    defined $r
    && $r eq $ENV{BAR__DEBUG},
    'Baz::baz() should return BAR__DEBUG ' .
    'when BAR__DEBUG, FOO__DEBUG, BAZ__DEBUG, and DEBUG are defined'
) or confess join(' ', __FILE__, __LINE__,
    Data::Dumper->Dump([$r, $@], [qw(r @)])
);

