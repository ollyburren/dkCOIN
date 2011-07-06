#!/usr/bin/perl

#Script to get current sources from a dkcoin server

use strict;
use lib '../lib';
use DKCOIN;

my $server = 'staging.dkcoin.org';

my $dkcoin = new DKCOIN(-server => $server);
#my $search = new DKCOIN::Search(-gene_id => [19260]);
my $search = new DKCOIN::Search(-resourcetype => 'mouse', -source => 'T1DBase');
my $rs = $dkcoin->search($search);
print "Found ".scalar(@$rs)." dkCOIN resources matching criteria\n";
my $count = 1;
foreach my $r(@$rs){
	my $url = $r->internal_url;
	#$url =~s
	print join("\t", $count,$r->name,$r->internal_url)."\n"; 
	$count++;
}
