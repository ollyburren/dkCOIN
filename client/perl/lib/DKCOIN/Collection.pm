=head1 LICENSE

  Copyright(c) 2011 Cambridge University. All rights reserved. 
  
  This software is distributed under a perl artistic license
  http://dev.perl.org/licenses/artistic.html
  
=head1 AUTHORS

 Oliver Burren & Mikkel Christensen - Diabetes and Inflammation Laboratory
 
=head1 REQUIRMENTS

 Class::Autoclass

=head1 NAME

 DKCOIN::Collection = A Collection object for DKCOIN

=head1 SYNOPSIS

 my $coll = new DKCOIN::Collection(
				-name => 'mice',
				-displayname => 'Mice'
				-urltemplate => http://www.betacell.org/resources/fetch.php?id={internal_id}
				);
				
=cut

package DKCOIN::Collection;

use strict;
use base qw/Class::AutoClass/;
use vars qw(@AUTO_ATTRIBUTES @CLASS_ATTRIBUTES %DEFAULTS %SYNONYMS);
@AUTO_ATTRIBUTES = qw(name action urltemplate displayname messages);
@CLASS_ATTRIBUTES = qw();
1;
