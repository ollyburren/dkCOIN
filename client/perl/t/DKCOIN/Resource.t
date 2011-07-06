#!/usr/bin/perl

use strict;
use lib '../lib';
use Test::More qw/no_plan/;
use DKCOIN::Resource;

#can we create a resource;

my %tresource = (
		name => 'PTPN22',
		internal_id => 26191,
		internal_url => 'http://www.t1dbase.org/page/Overview/display/gene_id/26191',
		resourcetype => 'document',
		collection_name => 't1dgene',
		description => 'protein tyrosine phosphatase, non-receptor type 22 (lymphoid)',
		internal_create_date => '2011-04-18T15:00:00+00:00',
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
my $resource = new DKCOIN::Resource(%tresource);
ok($resource,"Testing if we can create a resource");
foreach my $f(qw/name internal_id internal_url resourcetype collection_name description internal_create_date gene_id pubmed term_identifier/){
	ok(defined($resource->$f),"Testing that attribute $f is set");
}
foreach (qw/gene_id pubmed term_identifier internal_create_date/){
	my %copy=%tresource;
	$copy{$_}='foo';
	eval{$resource = new DKCOIN::Resource(%copy);};
	ok($@,"Creating $_ with bad data creates an error");
}
		
	

