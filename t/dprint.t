# $Id: dprint.t,v 1.13 2010-12-01 18:14:54 dpchrist Exp $

use Test::More		tests => 6;

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

$f = join '~', __FILE__, __LINE__, 'tmp';
$g = join '~', __FILE__, __LINE__, 'tmp';

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

