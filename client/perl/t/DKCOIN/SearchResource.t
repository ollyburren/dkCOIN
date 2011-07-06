#!/usr/bin/perl

use strict;
use lib '../lib';
use Test::More qw/no_plan/;
use DKCOIN::SearchResource;

#can we create a SearchResource;

my $searchResource = new DKCOIN::SearchResource(
		-resource_id => 1,
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
		-source_abbrev => 'foo' ,
		-source_name =>  'Foobar',
		-description => 'protein tyrosine phosphatase, non-receptor type 22 (lymphoid)',
		-internal_create_date => '2011-04-18T15:00:00+00:00',
			);
ok($searchResource,"Testing if we can create a SearchResource");
