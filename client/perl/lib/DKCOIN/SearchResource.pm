=head1 LICENSE

  Copyright(c) 2011 Cambridge University. All rights reserved. 
  
  This software is distributed under a perl artistic license
  http://dev.perl.org/licenses/artistic.html
  
=head1 AUTHORS

 Oliver Burren & Mikkel Christensen - Diabetes and Inflammation Laboratory
 
=head1 REQUIRMENTS

 Class::Autoclass

=head1 NAME

 DKCOIN::SearchResource - A SearchResource object for DKCOIN

=head1 SYNOPSIS

 my $resource = new DKCOIN::SearchResource(
 		-resource_id => 1
 		-collection_id => 2,
		-name => 'PTPN22',
		-internal_id => 26191,
		-internal_url => 'http://www.t1dbase.org/page/Overview/display/gene_id/26191',
		-created_date => '2011-04-18T15:00:00+00:00',
		-modified_date => '2011-04-18T15:00:00+00:00',
		-resourcetype_name => 'foo',
		-resourcetype_title => 'bar'
		-collection_name => 't1dgene',
		-collection_title => 'foo'
		-source_id => 1,
		-source_abbrev => foo ,
		-source_name =>  'Foobar',
		-description => 'protein tyrosine phosphatase, non-receptor type 22 (lymphoid)',
		-internal_create_date => '2011-04-18T15:00:00+00:00',
		);
				
=cut

package DKCOIN::SearchResource;

use strict;
use base qw/Class::AutoClass/;
use vars qw(@AUTO_ATTRIBUTES @CLASS_ATTRIBUTES %DEFAULTS %SYNONYMS);
@AUTO_ATTRIBUTES = qw(resource_id collection_id name internal_id internal_url created_date modified_date resourcetype_name resourcetype_title collection_name collection_title source_id source_abbrev source_name description internal_create_date);
1;
	
