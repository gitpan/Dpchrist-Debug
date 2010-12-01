# $Id: ddump.t,v 1.4 2010-12-01 18:14:54 dpchrist Exp $

use Test::More		tests => 8;

use strict;
use warnings;

use Capture::Tiny		qw( capture );
use Carp;
use Data::Dumper;
use Dpchrist::Debug		qw( :all );
use File::Basename;
use File::Slurp;

$Data::Dumper::Sortkeys = 1;

$| = 1;

my $f;
my $g;
my @m = ('hello,', 'world!');
my @r;
my $u;
my $v;

my ($stdout, $stderr);


@r = eval {
    ddump 1;
};
ok(								#     1
    $@ =~ /Too few arguments/,
    'call with one argument should fail'
) or confess join(' ',
    Data::Dumper->Dump([\@r, $@],
		     [qw(*r   @)]),
);
@r = eval {
    ddump 1, 2, [3];
};
ok(								#     2
    $@ =~ /Last two arguments are undefined or wrong type/,
    'call with bad array references should fail'
) or confess join(' ',
    Data::Dumper->Dump([\@r, $@],
		     [qw(*r   @)]),
);

$ENV{DEBUG} = undef;

($stdout,$stderr) = capture {
    @r = eval {
	ddump @m, [$f], [qw(f)];
    };
};
ok(								#     3
    @r eq 2
    && $r[0] eq $m[0]
    && $r[1] eq $m[1]
    && $stderr =~ /t.ddump.t \d+ .eval.   hello, world! \$f = undef/,
    'verify return value when DEBUG off'
) or confess join(' ',
    Data::Dumper->Dump([\@r, $@, $stdout, $stderr],
		     [qw(*r   @   stdout   stderr)]),
);

$f = join '~', __FILE__, __LINE__, 'tmp';
$g = join '~', __FILE__, __LINE__, 'tmp';

if (-e $f) { unlink $f or die $! }
if (-e $g) { unlink $g or die $! }

$ENV{DEBUG} = join ':', $f, $g, '*STDERR';

($stdout, $stderr) = capture {
    @r = eval {
    	ddump @m, [$f], [qw(f)];
    }
};
$u = read_file $f;
$v = read_file $g;
ok(								#     4
    @r eq 2
    && $r[0] eq $m[0]
    && $r[1] eq $m[1],
    'verify return value'
) && ok(							#     5
    $u =~ /hello..world.+\$f =/,
    'verify first debug file'
) && ok(							#     6
    $v =~ /hello..world.+\$f =/,
    'verify second debug file'
) && ok(							#     7
    $stdout eq '',
    'verify STDOUT'
) && ok(							#     8
    $stderr =~ /hello..world/,
    'verify STDERR'
) or confess join(' ',
    Data::Dumper->Dump([\@r, $@, $u, $v, $stdout, $stderr],
		     [qw(*r   @   u   v   stdout   stderr)]),
);

