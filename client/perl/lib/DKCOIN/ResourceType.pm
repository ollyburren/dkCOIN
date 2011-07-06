=head1 LICENSE

  Copyright(c) 2011 Cambridge University. All rights reserved. 
  
  This software is distributed under a perl artistic license
  http://dev.perl.org/licenses/artistic.html
  
=head1 AUTHORS

 Oliver Burren & Mikkel Christensen - Diabetes and Inflammation Laboratory
 
=head1 REQUIRMENTS

 Class::Autoclass

=head1 NAME

 DKCOIN::ResourceType - A ResourceType object for DKCOIN

=head1 SYNOPSIS

 my $resourceType = new DKCOIN::ResourceType(
			-name => 'fgs',
			-display_name => 'Functional Genomic Studies',
			);
=cut



package DKCOIN::ResourceType;



use strict;
use base qw/Class::AutoClass/;
use vars qw(@AUTO_ATTRIBUTES @CLASS_ATTRIBUTES %DEFAULTS %SYNONYMS);
@AUTO_ATTRIBUTES = qw(name display_name);
@CLASS_ATTRIBUTES = ();
1;
