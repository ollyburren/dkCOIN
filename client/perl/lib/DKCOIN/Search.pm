=head1 LICENSE

  Copyright(c) 2011 Cambridge University. All rights reserved. 
  
  This software is distributed under a perl artistic license
  http://dev.perl.org/licenses/artistic.html
  
=head1 AUTHORS

 Oliver Burren & Mikkel Christensen - Diabetes and Inflammation Laboratory
 
=head1 REQUIRMENTS

 Class::Autoclass

=head1 NAME

 DKCOIN::Search - A Search object for DKCOIN

=head1 SYNOPSIS

 my $search = new DKCOIN::Search(
			-not_source => ['t1dbase'],
			-not_source_id => [2],
			-source => 'bcbc',
			-source_id => 3,
			-name => 'Idd5.1',
			-resourcetype => 'mouse',
			-gene_id=>[1234],
			-term_identifier=>['GO:12345'],
			-pubmed => ['12345']
			);
=cut

package DKCOIN::Search;

use strict;
use base qw/Class::AutoClass/;
use vars qw(@AUTO_ATTRIBUTES @CLASS_ATTRIBUTES %DEFAULTS %SYNONYMS);
@AUTO_ATTRIBUTES = qw(source source_id name resourcetype not_source not_source_id gene_id term_identifier pubmed);
@CLASS_ATTRIBUTES = qw();
sub _init_self{
	my($self,$class,$args)=@_;
	return unless $class eq __PACKAGE__; # to prevent subclasses from re-running this
	foreach my $f(qw/not_source not_source_id gene_id term_identifier pubmed/){
		if($args->{$f} && ref $args->{$f} ne 'ARRAY'){
			die "Cannot create DKCOIN::Search $f attribute only accepts an array ref\n";
		}else{
			$self->$f($args->{$f});
		}
	}
}
1;
				
