#!/usr/bin/perl

use strict;
use lib '../lib';
use Test::More qw/no_plan/;
use DKCOIN::Source;

#can we create a ResourceType;

my $source = new DKCOIN::Source(
			-name => 'T1DBase',
			-url => 'http://www.t1dbase.org',
			-abbreviation => 't1dbase',
			-source_id => 1
			);
ok($source,"Testing if we can create a Source");
foreach my $f(qw/name url abbreviation source_id/){
	ok($source->$f,"Testing that attribute $f is set");
}
