=head1 LICENSE

  Copyright(c) 2011 Cambridge University. All rights reserved. 
  
  This software is distributed under a perl artistic license
  http://dev.perl.org/licenses/artistic.html
  
=head1 AUTHORS

 Oliver Burren & Mikkel Christensen - Diabetes and Inflammation Laboratory
 
=head1 REQUIRMENTS

 Class::Autoclass

=head1 NAME

 DKCOIN::Source - A Source object for DKCOIN

=head1 SYNOPSIS

 my $source = new DKCOIN::Source(
			-name => 'T1DBase',
			-url => 'http://www.t1dbase.org',
			-abbreviation => 't1dbase',
			-source_id => 1
			);
=cut

package DKCOIN::Source;

use strict;
use base qw/Class::AutoClass/;
use vars qw(@AUTO_ATTRIBUTES @CLASS_ATTRIBUTES %DEFAULTS %SYNONYMS);
@AUTO_ATTRIBUTES = qw(name url abbreviation source_id);
@CLASS_ATTRIBUTES = ();

1;
				
