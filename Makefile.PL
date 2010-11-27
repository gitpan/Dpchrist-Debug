#######################################################################
# $Id: Makefile.PL,v 1.22 2010-11-27 03:37:57 dpchrist Exp $
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

eval {
    require Dpchrist::Module::MakefilePL;
    
    import Dpchrist::Module::MakefilePL (
	-mcpani		=> $ENV{CPAN_AUTHORID},
	-pod2html 	=> 'lib/Dpchrist/Debug.pm',
	-readme	 	=> 'lib/Dpchrist/Debug.pm',
	-release	=> $ENV{RELEASE_ROOT},
    );
};
warn $@ if $@;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME		=> 'Dpchrist::Debug',
    VERSION_FROM	=> 'lib/Dpchrist/Debug.pm', # finds $VERSION
    PREREQ_PM		=> {
	Capture::Tiny		=> 0,
	Dpchrist::File::Append	=> 1.030,
	Dpchrist::Module	=> 1.025,
	Dpchrist::Tag		=> 1.034,
	File::Slurp		=> 0,
	Getopt::Long		=> 0,
	Pod::Html		=> 0,
	Pod::Text		=> 0,
	Pod::Usage		=> 0,
	feature			=> 0,
    },
    ABSTRACT_FROM	=> 'lib/Dpchrist/Debug.pm',
    AUTHOR		=>
	'David Paul Christensen <dpchrist@holgerdanske.com>',
    clean		=> { FILES =>
	q( *~tmp */*~tmp Dpchrist* )
    },
);

#######################################################################
