#!/usr/bin/perl

use strict;
use lib '../lib';
use Test::More qw/no_plan/;
use DKCOIN::ResourceType;

#can we create a ResourceType;

my $resourceType = new DKCOIN::ResourceType(
			-name => 'fgs',
			-display_name => 'Functional Genomic Studies',
			);
ok($resourceType,"Testing if we can create a ResourceType");
foreach my $f(qw/name display_name/){
	ok($resourceType->$f,"Testing that attribute $f is set");
}
