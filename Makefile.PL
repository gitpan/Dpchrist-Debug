#######################################################################
# $Id: Makefile.PL,v 1.26 2010-12-03 05:13:48 dpchrist Exp $
#
# Copyright 2010 by David Paul Christensen dpchrist@holgerdanske.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
# USA.
#######################################################################

package Dpchrist::ExtUtils::MakeMaker;	# for symbols

use ExtUtils::MakeMaker;

eval "use Test::Manifest";
warn $@ if $@;

eval {
    require Dpchrist::ExtUtils::MakeMaker;
    die 'Requires Dpchrist::ExtUtils::MakeMaker 1.013 or higher'
    	unless 1.013 <= $Dpchrist::ExtUtils::MakeMaker::VERSION;
    import  Dpchrist::ExtUtils::MakeMaker (
	postamble => sub {
	    my ($o, $prev) = @_;
	    return join('',
		$prev,
		mcpani  ($o, $ENV{CPAN_AUTHORID}),
		pod2html($o, 'lib/Dpchrist/Debug.pm'),
		readme  ($o, 'lib/Dpchrist/Debug.pm'),
		release ($o, $ENV{RELEASE_ROOT}),
	    );
	},
    );
};
warn $@ if $@;

WriteMakefile(
    NAME		=> 'Dpchrist::Debug',
    VERSION_FROM	=> 'lib/Dpchrist/Debug.pm', # finds $VERSION
    PREREQ_PM		=> {
	Capture::Tiny			=> 0,
	Carp				=> 0,
	Data::Dumper			=> 0,
	Dpchrist::ExtUtils::MakeMaker	=> 1.015,
	Dpchrist::File::Append		=> 1.033,
	Dpchrist::Tag			=> 1.037,
	Exporter			=> 0,
	ExtUtils::MakeMaker		=> 0,
	File::Basename			=> 0,
	File::Slurp			=> 0,
	Test::Compile			=> 0,
	Test::Manifest			=> 0,
	Test::More			=> 0,
	Test::Pod			=> 0,
	Test::Prereq			=> 0,
    },
    ABSTRACT_FROM	=> 'lib/Dpchrist/Debug.pm',
    AUTHOR		=>
	'David Paul Christensen <dpchrist@holgerdanske.com>',
    clean		=> { FILES =>
	q( *~tmp */*~tmp *.tar debug.log )
    },
    realclean		=> {
	FILES => q( README *.html *.tar.gz ),
    },
);

#######################################################################
