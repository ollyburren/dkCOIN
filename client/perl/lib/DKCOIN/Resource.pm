=head1 LICENSE

  Copyright(c) 2011 Cambridge University. All rights reserved. 
  
  This software is distributed under a perl artistic license
  http://dev.perl.org/licenses/artistic.html
  
=head1 AUTHORS

 Oliver Burren & Mikkel Christensen - Diabetes and Inflammation Laboratory
 
=head1 REQUIRMENTS

 Class::Autoclass

=head1 NAME

 DKCOIN::Resource - A Resource object for DKCOIN

=head1 SYNOPSIS

 my $resource = new DKCOIN::Resource(
		-name => 'PTPN22',
		-internal_id => 26191,
		-internal_url => 'http://www.t1dbase.org/page/Overview/display/gene_id/26191',
		-resourcetype => 'document',
		-collection_name => 't1dgene',
		-description => 'protein tyrosine phosphatase, non-receptor type 22 (lymphoid)',
		-internal_create_date => '2011-04-18T15:00:00+00:00',
		-gene_id=>[26191],
		-pubmed=>[
				{
					pubmed_id => 20962850,
					citation => 1
				}
			],
		-term_identifier=>[
					'GO:0017124'
				]
		);
				
=cut

package DKCOIN::Resource;

use strict;
use base qw/Class::AutoClass/;
use vars qw(@AUTO_ATTRIBUTES @CLASS_ATTRIBUTES %DEFAULTS %SYNONYMS);
@AUTO_ATTRIBUTES = qw(name internal_id internal_url resourcetype collection_name term_identifier description resource_id source_name source_abbrev source_id collection_id action pubmed gene_id internal_create_date messages);
@CLASS_ATTRIBUTES = qw();

sub _init_self{
	my($self,$class,$args)=@_;
	return unless $class eq __PACKAGE__; # to prevent subclasses from re-running this
	foreach my $f(qw/gene_id pubmed term_identifier/){
		if($args->{$f} && ref $args->{$f} ne 'ARRAY'){
			die "Cannot create DKCOIN::Resource $f attribute only accepts array ref\n";
		}else{
			$self->$f($args->{$f});
		}
	}
	if($args->{internal_create_date} && $args->{internal_create_date}!~/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/){
		die "Cannot create DKCOIN::Resource internal_create_date should be in ISO 8601 format\n";
	}else{
		$self->internal_create_date($args->{internal_create_date});
	}
}

1;
	
