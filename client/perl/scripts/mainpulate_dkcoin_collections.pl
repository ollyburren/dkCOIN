#!/usr/bin/perl


use strict;
use lib '../lib';
use DKCOIN;
use DKCOIN::Collection;
use Getopt::Long;
use Term::ReadKey;
use Data::Dumper;

my $USAGE=<<EOL;
USAGE:
$0 -[s]erver -[a]ccount -[m]ethod -[f]ile {-[h]elp} {-[v]erbose} 
EOL


my $HELP=<<EOL;
A script to upload,append or delete collections to a dkcoin server using a tab delim flat file.
It prompts for a password (these are given by dkcoin).

 -[s]erver server to upload to usually staging.dkcoin.org or www.dkcoin.org
 -[a]ccount to use e.g. 't1dbase'
 -[h]elp print this message
 -[f]ile to load
 -[m]ethod ^(delete|append)\$
 -[v]erbose print out status information to STDOUT
 
 FILE FORMAT - first line is a header see DKCOIN::Collection for details
 
 See 
 
 __DATA__ for example
 
$USAGE
EOL

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

unless(grep{/^$options{method}$/}qw/update delete/ && $options{method}){
	print STDERR " [ERROR] Option method must be one of append update or delete\n";
	$errflag++;
}

my $method = $options{method}."Collection";

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


#parse file and create DKCOIN::Collection objects

open(RES,$options{file}) || die "Cannot open ".$options{file}."\n";
my @header;
my @collections;
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
			$dhash{$header[$x]}=$vals[$x]
		}
		my $c = eval{new DKCOIN::Collection(%dhash)};
		if($@){
			die "Error creating DKCOIN::Collection at line $.",$@;
		}else{
			verbose("Creating collection ".join("\t",$c->name));
			push @collections,$c;
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
	verbose("Running method ${method} on dkCOIN with ".scalar(@collections)." collection(s)");
	my $out = $dkcoin->$method(\@collections);
	my @updated = grep{$_->action=~/updated/}@$out;
	my @inserted = grep{$_->action=~/inserted/}@$out;
	my @deleted = grep{$_->action=~/deleted/}@$out;
	my @error = grep{!defined($_->action)}@$out;
	my @warnings = grep{$_->messages()}@$out;
	print STDERR "Updated ".scalar(@updated)." collection(s)\n" if @updated; 
	print STDERR "Inserted ".scalar(@inserted)." collection(s)\n" if @inserted;
	print STDERR "Deleted ".scalar(@deleted)." collection(s)\n" if @deleted;
	
	foreach my $c(@warnings){
		print STDERR "[WARNING internal_id=".$c->name."]:".$c->messages()."\n";
	}
	print STDERR "Errors ".scalar(@error)."\n";
	foreach my $c(@error){
		print STDERR "[ERROR internal_id=".$c->name."]:\n";
		
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
name	displayname	urltemplate
t1dgene	T1D Gene	http://www.t1dbase.org/t1dgene={internal_id}
