#!/usr/bin/perl

use strict;
use lib '../lib';
use Test::More qw/no_plan/;
use DKCOIN;
use DKCOIN::Search;
use DKCOIN::Collection;
use Data::Dumper;

my $server = 'staging.dkcoin.org';
#NOTE you will need a valid password and account to proceed
my $account = '';
my $pass = '';

if(!$account && !$pass){
	print STDERR "Please edit this test to provide account and password details, else some tests will fail\n";
}

my $dkcoin = new DKCOIN(-server => $server);

ok($dkcoin,"Test to see that we can hit $server");
$dkcoin->account($account);
$dkcoin->password($pass);
#test we can do a search
my $search = new DKCOIN::Search(-gene_id => [19260]);
my $res = $dkcoin->search($search);
ok($res->[0]->isa('DKCOIN::SearchResource'),"Checking we have result and that they are DKCOIN::SearchResource");
my $sources = $dkcoin->getSources();
ok($sources->[0]->isa('DKCOIN::Source'),"Checking getSources returns a DKCOIN::Source");
my $rts = $dkcoin->getResourceTypes();
ok($rts->[0]->isa('DKCOIN::ResourceType'),"Checking getResourceTypes returns a DKCOIN::ResourceType");

#check we can create a session
ok($dkcoin->startSession,"Check startSession returns 1");



#lets add a resource
my $resource = new DKCOIN::Resource(
		-name => 'PTPN22',
		-internal_id => 26191,
		-internal_url => 'http://www.t1dbase.org/page/Overview/display/gene_id/26191',
		-resourcetype => 'document',
		-collection_name => 'congenic',
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
		
my $out = $dkcoin->updateResource([$resource]);
foreach my $r(@$out){
	ok($r->isa('DKCOIN::Resource'),"Check that DKCOIN::Resource returned update");
	ok($r->action eq 'inserted',"Check that action has been updated accordingly");
}

my $out = $dkcoin->appendResource([$resource]);
foreach my $r(@$out){
	ok($r->isa('DKCOIN::Resource'),"Check that DKCOIN::Resource returned append");
	ok($r->action eq 'appended',"Check that action has been updated accordingly");
}

my $out = $dkcoin->deleteResource([$resource]);
foreach my $r(@$out){
	ok($r->isa('DKCOIN::Resource'),"Check that DKCOIN::Resource returned delete");
	ok($r->action eq 'deleted',"Check that action has been updated accordingly");
}

#lets try updating a Collection

my $collection=new DKCOIN::Collection(
				-name => 'congenic2',
				-displayname => 'Mouse Congenic Strains2',
				-urltemplate => 'http://www.t1dbase.org/page/DrawStrains?strain_name2={internal_id}'
				);

my $collection2=new DKCOIN::Collection(
				-name => 'congenic3',
				-displayname => 'Mouse Congenic Strains3',
				-urltemplate => 'http://www.t1dbase.org/page/DrawStrains?strain_name3={internal_id}'
);

my $out = $dkcoin->updateCollection([$collection,$collection2]);
foreach my $c(@$out){
	ok($c->isa('DKCOIN::Collection'),"Check that DKCOIN::Collection returned update");
	ok($c->action eq 'inserted',"Check that action has been updated accordingly");
}

my $out = $dkcoin->deleteCollection([$collection,$collection2]);
foreach my $c(@$out){
	ok($c->isa('DKCOIN::Collection'),"Check that DKCOIN::Collection returned from delete");
	ok($c->action eq 'deleted',"Check that action has been updated accordingly");
}
#check that we can log out
ok($dkcoin->endSession,"Check endSession returns 1");
ok(!$dkcoin->session,"Check that session key is set to undefined");
