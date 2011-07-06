#!/usr/bin/perl

use strict;
use lib '../lib';
use Test::More qw/no_plan/;
use DKCOIN::Search;

#can we create a Search;

my %tsearch = (
		name => 'PTPN22',
		resourcetype => 'document',
		gene_id=>[26191],
		pubmed=>[
				{
					pubmed_id => 20962850,
					citation => 1
				}
			],
		term_identifier=>[
					'GO:0017124'
				]
		);

my $search = new DKCOIN::Search(%tsearch);
ok($search,"Testing if we can create a resource");
foreach my $f(qw/name resourcetype gene_id pubmed term_identifier/){
	ok(defined($search->$f),"Testing that attribute $f is set");
}
foreach (qw/gene_id pubmed term_identifier /){
	my %copy=%tsearch;
	$copy{$_}='foo';
	eval{$search = new DKCOIN::Search(%copy);};
	ok($@,"Creating $_ with bad data creates an error");
}



