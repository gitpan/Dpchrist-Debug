#######################################################################
# $Id: Debug.pm,v 1.44 2010-11-27 07:37:14 dpchrist Exp $
#######################################################################
# package/ uses/ requires:
#----------------------------------------------------------------------

package Dpchrist::Debug;

use strict;
use warnings;

require Exporter;

use Carp			qw( cluck confess );
use Data::Dumper;
use Dpchrist::File::Append	qw( :all );
use Dpchrist::Tag		qw( :all );

#######################################################################
# package variables:
#----------------------------------------------------------------------

our %EXPORT_TAGS = ( 'all' => [ qw(
    ddump
    dprint
    debug_enabled
) ] );

our @EXPORT_OK = (
    @{ $EXPORT_TAGS{'all'} },
);

our @EXPORT = qw(
);

our @ISA = qw(Exporter);

our $VERSION = sprintf("%d.%03d", q$Revision: 1.44 $ =~ /(\d+)/g);

#######################################################################

=head1 NAME

Dpchrist::Debug - debugging convenience routines


=head1 DESCRIPTION

This documentation describes module revision $Revision: 1.44 $.


This is alpha test level software
and may change or disappear at any time.


=head2 SUBROUTINES

=cut

#######################################################################

=head3 ddump

    ddump LIST,ARRARREF,ARRARREF
    ddump ARRAYREF,ARRAYREF

Similar to dprint(),
except that last two arguments are passed through
to Data::Dumper->Dump().
Returns LIST.

Calls warn() if Dpchrist::File::Append::fappend() fails.

Calls confess() on error.

=cut

#----------------------------------------------------------------------

sub ddump
{
    confess('Too few arguments',
	    Data::Dumper->Dump([\@_], [qw(*_)]),
    ) unless 2 <= @_;

    my $ra2 = pop @_;
    my $ra1 = pop @_;

    confess 'Last two arguments are undefined or wrong type'
	unless defined $ra1 && ref $ra1 eq 'ARRAY'
	    && defined $ra2 && ref $ra2 eq 'ARRAY';

    my $dest = debug_enabled();
    goto DONE unless $dest;

    my $entry = join ' ', __TAG1__, @_,
	Data::Dumper->Dump($ra1, $ra2);
    chomp $entry;

    foreach my $f (split /:/, $dest) {
	eval { fappend($f, $entry, "\n") }
	    or warn;
    }

  DONE:
    return @_;
}

#######################################################################

=head3 debug_enabled

    debug_enabled

Walks the call stack (outer loop)
and inheritance chain (inner loop) recursively,
examining the __PACKAGE__::DEBUG environment variable,
until DEBUG is reached.
Returns the first defined value found,
or '*STDERR' if no defined value was found.

=cut

#----------------------------------------------------------------------

sub debug_enabled()
{
    my $level = 0;	# call stack level
    my $limit = 100;	# runaway loop limit
    my $p;		# package name		
    my $r;		# return value
    my $runaway = 0;	# runaway loop counter
    
    while ( $p = (caller($level++))[0] ) {

	last if $p eq 'main';

	while($p) {

	    if ($p ne "(eval)") {

		my $n = join '::', uc($p), 'DEBUG';
		$n =~ s/[^a-zA-Z0-9]/_/g;

		$r = exists $ENV{$n} ? $ENV{$n} : undef;

		goto DONE if defined $r;
	    }

	    my @isa;
	    my $n = $p . "::ISA";
	    { no strict "refs"; @isa = @$n };

	    $p = $isa[0];

	    if ($limit < $runaway++) {
		cluck 'runaway loop detected';
		goto DONE;
	    }
	}
    }

    $r = $ENV{DEBUG} unless defined $r;

    $r = '*STDERR' unless defined $r;

  DONE:

    $r =~ /(.*)/;
    return $1;
}

#######################################################################

=head3 dprint

    dprint LIST
    dprint

Appends LIST to file name and/or file handle destinations
specified as colon-delimited list
returned by debug_enabled(),
and returns LIST.

Calls warn() if Dpchrist::File::Append::fappend() fails.

=cut

#----------------------------------------------------------------------

sub dprint
{
    my $dest = debug_enabled();
    goto DONE unless $dest;

    my $entry = join ' ', __TAG1__, @_;
    chomp $entry;

    foreach my $f (split /:/, $dest) {
	eval { fappend($f, $entry, "\n") }
	    or warn;
    }

  DONE:
    return @_;
}

#######################################################################
# end of code:
#----------------------------------------------------------------------

1;
__END__

#######################################################################

=head2 EXPORT

None by default.

All of the subroutines may be imported by using the ':all' tag:

    use Dpchrist::Debug		qw( :all );

See 'perldoc Export' for everything in between.


=head1 INSTALLATION

Old school:

    $ perl Makefile.PL
    $ make
    $ make test
    $ make install

Minimal:

    $ cpan Dpchrist::Debug

Complete:

    $ cpan Bundle::Dpchrist

The following warning may be safely ignored:

    Can't locate Dpchrist/Module/MakefilePL.pm in @INC (@INC contains: /
    etc/perl /usr/local/lib/perl/5.10.0 /usr/local/share/perl/5.10.0 /us
    r/lib/perl5 /usr/share/perl5 /usr/lib/perl/5.10 /usr/share/perl/5.10
    /usr/local/lib/site_perl .) at Makefile.PL line 22.


=head2 PREREQUISITES

See Makefile.PL in the source distribution root directory.


=head1 AUTHOR

David Paul Christensen  dpchrist@holgerdanske.com


=head1 COPYRIGHT AND LICENSE

Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
USA.

=cut

#######################################################################
