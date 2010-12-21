# $Id: dprint.t,v 1.15 2010-12-20 06:05:19 dpchrist Exp $

use strict;
use warnings;

use Test::More			tests => 6;

use Dpchrist::Debug		qw( dprint );

use Capture::Tiny		qw( capture );
use Carp;
use Data::Dumper;
use File::Basename;
use File::Slurp;

$|				= 1;
$Data::Dumper::Sortkeys		= 1;

my $f;
my $g;
my @m = ('hello,', 'world!');
my @r;
my $u;
my $v;
my ($stdout, $stderr);


$ENV{DEBUG} = undef;

($stdout, $stderr) = capture {
    @r = eval {
	dprint @m;
    };
};
ok(								#     1
    @r eq 2
    && $r[0] eq $m[0]
    && $r[1] eq $m[1]
    && $stderr =~ /t.dprint.t \d+ .eval.   hello, world!/,
    'verify return value when DEBUG off'
) or confess join(' ',
    Data::Dumper->Dump([\@r, $@, $stdout, $stderr],
		     [qw(*r   @   stdout   stderr)]),
);

$f = join '~', basename(__FILE__), __LINE__, 'tmp';
$g = join '~', basename(__FILE__), __LINE__, 'tmp';

if (-e $f) { unlink $f or die $! }
if (-e $g) { unlink $g or die $! }

$ENV{DEBUG} = join ':', $f, $g, '*STDERR';

($stdout, $stderr) = capture {
    @r = eval {
    	dprint @m;
    }
};
$u = read_file $f;
$v = read_file $g;
ok(								#     2
    @r eq 2
    && $r[0] eq $m[0]
    && $r[1] eq $m[1],
    'verify return value'
) && ok(							#     3
    $u =~ /hello..world/,
    'verify first debug file'
) && ok(							#     4
    $v =~ /hello..world/,
    'verify second debug file'
) && ok(							#     5
    $stdout eq '',
    'verify STDOUT'
) && ok(							#     6
    $stderr =~ /hello..world/,
    'verify STDERR'
) or confess join(' ',
    Data::Dumper->Dump([\@r, $@, $u, $v, $stdout, $stderr],
		     [qw(*r   @   u   v   stdout   stderr)]),
);

