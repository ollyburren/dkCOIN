#!/usr/bin/perl

#Script to get current sources from a dkcoin server

use strict;
use lib '../lib';
use DKCOIN;

my $server = 'staging.dkcoin.org';

my $dkcoin = new DKCOIN(-server => $server);
my $rts = $dkcoin->getResourceTypes();
foreach my $rt(@$rts){
	print $rt->name."\n";
}
