#!/usr/bin/perl


use strict;
use lib '../lib';
use DKCOIN;
use DKCOIN::Resource;
use Getopt::Long;
use Term::ReadKey;
use Data::Dumper;

my $USAGE=<<EOL;
USAGE:
$0 -[s]erver -[a]ccount -[m]ethod -[f]ile {-[h]elp} {-[v]erbose} 
EOL


my $HELP=<<EOL;
A script to upload,append or delete resources to a dkcoin server using a tab delim flat file.
It prompts for a password (these are given by dkcoin).

 -[s]erver server to upload to usually staging.dkcoin.org or www.dkcoin.org
 -[a]ccount to use e.g. 't1dbase'
 -[h]elp print this message
 -[f]ile to load
 -[m]ethod ^(delete|append|insert)\$
 -[v]erbose print out status information to STDOUT
 
 FILE FORMAT - first line is a header see DKCOIN::Resource for details
 If an attribute expects an array ref then separate vals by a comma (,). 
 If an attribute expects an array ref of hashes then separate keys/value pairs by semi-colon(;)
 and separate hashes with commma(,) e.g. foo=bar;qux=>wibble,foo=>bar2,qux=>wibble2
 
 See 
 
 __DATA__ for example
 
 NB - delete resources requires only collection_name,name and internal_id attributes.
 This script does not check attributes prior to submitting SOAP request.
 
$USAGE
EOL

#define which fields expect array ref
my @aref_required = qw/gene_id term_identifier/;
#define which fields expect hash ref
my @href_required = qw/pubmed/;

####################
#OPTIONS PROCESSING#
####################

my %options;
my $result = GetOptions(\%options,
		'server|s=s',
		'account|a=s',
		'method|m=s',
		'file|f=s',
		'verbose|v',
		'help|h');
my $errflag = 0;

foreach my $req_args(qw/server account file method/){
	last if defined $options{'help'};
	if(!$options{$req_args}){
		print STDERR " [ERROR] Option required for $req_args\n";
		$errflag++;
	}
}

unless(grep{/^$options{method}$/}qw/append update delete/ && $options{method}){
	print STDERR " [ERROR] Option method must be one of append update or delete\n";
	$errflag++;
}

my $method = $options{method}."Resource";

if($options{'help'} || $errflag){
    warn $HELP;
    exit(1);
}

if(! -e $options{file}){
	print STDERR "Cannot find file ".$options{file}." for loading\n";
}

##########################
#END OF OPTION PROCESSING#
##########################


#parse file DKCOIN::Resource objects

open(RES,$options{file}) || die "Cannot open ".$options{file}."\n";
my @header;
my @resources;
while(<RES>){
	chomp;
	#ommit comments
	next if /^\s*#/;
	my @vals=split("\t",$_);
	if(!@header){
		@header=@vals
	}else{
		my %dhash;
		for(my $x=0;$x<@header;$x++){
			if(grep{/$header[$x]/}@href_required){
				my @array;
				foreach my $e(split(",",$vals[$x])){
					my %th;
					foreach my $vp(split(";",$e)){
						my ($k,$v) = split("=",$vp);
						$th{$k}=$v;
						
					}
					push @array,\%th;
				}
				$dhash{$header[$x]}=\@array;
			}elsif(grep{/$header[$x]/}@aref_required){
				my @array = split(",",$vals[$x]);
				$dhash{$header[$x]}=\@array;
			}else{
				$dhash{$header[$x]}=$vals[$x]
			}
		}
		my $r = eval{new DKCOIN::Resource(%dhash)};
		if($@){
			die "Error creating DKCOIN::Resource at line $.",$@;
		}else{
			verbose("Creating resource ".join("\t",$r->internal_id,$r->name));
			push @resources,$r;
		}
	}
	
}




my $pwd = readpassword("Please enter password for connecting to ".$options{server}." as ".$options{account});

#create dkCOIN object

my $dkcoin = new DKCOIN(
		-server=>$options{server},
		-account=>$options{account},
		-password=>$pwd
		);
#login

if($dkcoin->startSession){
	verbose("Created session successfully");
	verbose("Running method ${method} dkCOIN with ".scalar(@resources)." resource(s)");
	my $out = $dkcoin->$method(\@resources);
	my @updated = grep{$_->action=~/updated/}@$out;
	my @inserted = grep{$_->action=~/inserted/}@$out;
	my @deleted = grep{$_->action=~/deleted/}@$out;
	my @error = grep{!defined($_->action)}@$out;
	my @warnings = grep{$_->messages()}@$out;
	print STDERR "Updated ".scalar(@updated)." resource(s)\n" if @updated; 
	print STDERR "Inserted ".scalar(@inserted)." resource(s)\n" if @inserted;
	print STDERR "Deleted ".scalar(@deleted)." resource(s)\n" if @deleted;
	
	foreach my $r(@warnings){
		print STDERR "[WARNING internal_id=".$r->internal_id."]:".$r->messages()."\n";
	}
	print STDERR "Errors ".scalar(@error)."\n";
	foreach my $r(@error){
		print STDERR "[ERROR internal_id=".$r->internal_id."]:\n";
		
	}
	if(@error && $options{verbose}){
		print STDERR "[SOAP REQUEST]\n";
		print STDERR $dkcoin->error();
		print STDERR "[END OF SOAP REQUEST]\n";
	}
}else{
	die "Cannot log in check account and password\n";
}
if($dkcoin->endSession){
	verbose("Session ended");
}else{
	die "Cannot end session ".$dkcoin->session_id;
}


=head2 readpassword

  NAME: readpassword
  ARGS: String representing a command prompt
  FUNCTION: Writes prompt to terminal and then parses keyboard input
  RETURNS: STRING representing password;

=cut

sub readpassword{
    my $s = shift;
    print STDERR "$s\n";
    print STDERR "followed by ENTER:\n";
    ReadMode('noecho');
    my $password = ReadLine(0);
    ReadMode('normal');
    chomp $password;
    return $password;
}

=head2 verbose

  NAME: verbose
  FUNCTION: Print status information to STDOUT if verbose flag set
  RETURNS: Nothing

=cut

sub verbose{
    my $s = shift;
    print STDOUT "[MSG] $s\n" if $options{'verbose'};
}

###########
#TEST DATA#
###########

__DATA__
name	internal_id	internal_url	resourcetype	collection_name	description	internal_create_date	gene_id	pubmed	term_identifier	
PTPN22	26191	http://www.t1dbase.org/page/Overview/display/gene_id/26191	document	congenic	protein tyrosine phosphatase, non-receptor type 22 (lymphoid)	2011-04-18T15:00:00+00:00	26191,19260,295338	pubmed_id=20962850;citation=0,pubmed_id=20805278;citation=1	GO:0017124
