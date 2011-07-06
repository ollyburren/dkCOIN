#!/usr/bin/perl

use strict;
use lib '../lib';
use Test::More qw/no_plan/;
use DKCOIN::Collection;

#can we create a collection;

my $collection = new DKCOIN::Collection(
		-name => 't1dgene',
		-displayname => 'T1D susceptibility gene',
		-urltemplate => "http://www.t1dbase.org/page/Overview/display/gene_id/{internal_id}"
		);
ok($collection,"Testing if we can create a collection");
foreach my $f(qw/name displayname urltemplate/){
	ok($collection->$f,"Testing that attribute $f is set");
}
