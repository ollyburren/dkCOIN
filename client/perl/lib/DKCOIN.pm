=head1 LICENSE

  Copyright(c) 2011 Cambridge University. All rights reserved. 
  
  This software is distributed under a perl artistic license
  http://dev.perl.org/licenses/artistic.html
  
=head1 AUTHORS

  Oliver Burren & Mikkel Christensen - Diabetes and Inflammation Laboratory
  
=head1 REQUIREMENTS

  XML::Twig - Required for pretty printing of SOAP requests for debugging
  XML::Parser - Required for pretty printing of SOAP requests for debugging
  SOAP::Lite
  Class::AutoClass
  
=head1 BUGS

  Cannot add pubmed objects to server through updateResource and appendResource
  
=cut

package DKCOIN;

use strict;
use SOAP::Lite;
	on_fault => sub { my ($soap,$res) = @_;
		die ref $res ? "[ERROR] ".$res->faultdetail : "[ERROR]".
		$soap->transport->status,"\n";
	};
use XML::Twig;
use XML::Parser;
use constant DEBUG=>1;	
use base qw/Class::AutoClass/;
use vars qw(@AUTO_ATTRIBUTES @CLASS_ATTRIBUTES %DEFAULTS %SYNONYMS);
use DKCOIN::Search;
use DKCOIN::Resource;
use DKCOIN::SearchResource;
use DKCOIN::Source;
use DKCOIN::ResourceType;
use Data::Dumper;
@AUTO_ATTRIBUTES = qw();
@CLASS_ATTRIBUTES = qw(server account password session service error);

sub _init_self{
	my($self,$class,$args)=@_;
	return unless $class eq __PACKAGE__; # to prevent subclasses from re-running this
	#setup debug if required
	#my $envelope;
	if(DEBUG){
		SOAP::Lite->import(+trace => [ transport => sub { 
							my ($r) = @_;
							return unless $r->isa('HTTP::Request');
							my $xml = XML::Twig->new(pretty_print => 'indented');
							$xml->parse($r->content);
							$self->error($xml->sprint());
				}] );
	}
	$self->server($args->{server});
	$self->account($args->{account});
	$self->password($args->{password});
	if(!$self->server()){
		die "Cannot create dkCOIN object as target server is not defined";
	}
	my $service = SOAP::Lite->service("http://". $self->server() ."/service/wsdl");
	$self->service($service);
}

sub startSession{
	my $self = shift;
	if($self->account && $self->password){
		#attempt a login
		my ($result,$sessionkey) = $self->service->startSession(
                        SOAP::Data->name('account_name')->value($self->account),
                        SOAP::Data->name('password')->value($self->password),
                );
                if($result =~/success/i){
                	$self->session($sessionkey);
                	return 1;
                }else{
                	print STDERR "Unable to authenticate with ".$self->server()."\n";
                }
	}else{
		print STDERR "Require account and password variables to start a session with ".$self->server()."\n";
	}
	return 0;
}

sub endSession{
	my $self = shift;
	if($self->session()){
		my ($result) = $self->service->endSession($self->session());
		if($result =~/success/i){
			$self->session(undef);#'
			return 1;
		}
	}
	return 0; 
}

sub search{
	my ($self,$search)=@_;
	unless($search->isa('DKCOIN::Search')){
		die "Require a DKCOIN::Search object to run a search\n";
	}
	#pull back all the params and create a search request
	my @param_array;
	foreach my $f(@DKCOIN::Search::AUTO_ATTRIBUTES){
		next unless defined $search->$f;
		#for those with array refs 
		if(ref $search->$f eq 'ARRAY'){
			foreach my $val(@{$search->$f}){
				push @param_array,SOAP::Data->name("$f" => $val);
			}
		}else{
			push @param_array,SOAP::Data->name("$f" => $search->$f);
		}
	}
	my $param = SOAP::Data->name("params" => \SOAP::Data->value(@param_array));
	#run the search;
	my @resources;
	foreach my $r($self->service->search($param)){
		push @resources, new DKCOIN::SearchResource($r);
		
	}
	return \@resources;
}

sub getSources{
	my $self=shift;
	my @sources;
	foreach my $s($self->service->getSources()){
		push @sources, new DKCOIN::Source($s);
	}
	return \@sources;
}

sub getResourceTypes{
	my $self=shift;
	my @rts;
	foreach my $r($self->service->getResourceTypes()){
		push @rts, new DKCOIN::ResourceType($r);
	}
	return \@rts;
}

sub deleteCollection{
	my ($self,$collectionArray)=@_;
	return $self->_alterCollection($collectionArray,'deleteCollection');
}

sub updateCollection{
	my ($self,$collectionArray)=@_;
	return $self->_alterCollection($collectionArray,'updateCollection');
}


sub _alterCollection{
	my ($self,$collectionArray,$method)=@_;
	unless($method =~/^(update|delete)Collection$/){
		die "method must be set and be either deleteCollection or updateCollection\n";
	}
	unless(ref $collectionArray eq 'ARRAY'){
		die "updateCollection accepts a reference to an array of collections\n"
	}
	my @collSOAP;
	my %collRes;
	foreach my $c(@$collectionArray){
		die "$c is not a DKCOIN::Collection" unless $c->isa('DKCOIN::Collection');
		my @param_array;
		foreach my $f(@DKCOIN::Collection::AUTO_ATTRIBUTES){
			next unless defined $c->$f;
			push @param_array,SOAP::Data->name("$f" => $c->$f);
		}
		#add a collection ?
		push @collSOAP,SOAP::Data->name("collection" => \SOAP::Data->value(@param_array));
		$collRes{$c->name}=$c;
		
		
	}
	unless($self->session()){
		die "Cannot updateCollection without logging in first\n";
	}
	my $header = SOAP::Header->name(
		'session'  => \SOAP::Header->value(
			SOAP::Header->name('sessionkey' => $self->session())
		)
	);
	my @output = $self->service->$method($header,@collSOAP);
	foreach my $r(@output){
		if($collRes{$r->{name}}){
			$collRes{$r->{name}}->action($r->{action});
		}
	}
	my @ret = values %collRes;
	return \@ret;
}

sub appendResource{
	my ($self,$resourceArray)=@_;
	return $self->_alterResource($resourceArray,'appendResource');
}

sub updateResource{
	my ($self,$resourceArray)=@_;
	return $self->_alterResource($resourceArray,'updateResource');
}

sub deleteResource{
	my ($self,$resourceArray)=@_;
	return $self->_alterResource($resourceArray,'deleteResource');
}

sub _alterResource{
	my ($self,$resourceArray,$method)=@_;
	unless($method =~/^(append|update|delete)Resource$/){
		die "method must be set and be either appendResource or updateResource";
	}
	unless(ref $resourceArray eq 'ARRAY'){
		die "$method accepts a reference to an array of resources\n"
	}
	
	my @resSOAP;
	my %resRes;
	foreach my $r(@$resourceArray){
		die "$r is not a DKCOIN::Resource" unless $r->isa('DKCOIN::Resource');
		my @param_array;
		foreach my $f(@DKCOIN::Resource::AUTO_ATTRIBUTES){
			next unless defined $r->$f;
			if(ref $r->$f eq 'ARRAY'){
				#pubmeds are more complicated ?
				foreach my $val(@{$r->$f}){
					push @param_array,SOAP::Data->name("$f" => $val);
				}
			}else{
				push @param_array,SOAP::Data->name("$f" => $r->$f);
			}
		}
		#add a resource ?
		push @resSOAP,SOAP::Data->name("resource" => \SOAP::Data->value(@param_array));
		$resRes{$r->internal_id}=$r;
		
		
	}
	unless($self->session()){
		die "Cannot updateResource without logging in first\n";
	}
	my $header = SOAP::Header->name(
		'session'  => \SOAP::Header->value(
			SOAP::Header->name('sessionkey' => $self->session())
		)
	);
	my @output = $self->service->$method($header,@resSOAP);
	foreach my $r(@output){
		if($resRes{$r->{internal_id}}){
			$resRes{$r->{internal_id}}->action($r->{action});
			$resRes{$r->{internal_id}}->messages($r->{messages});
		}
	}
	my @ret = values %resRes;
	return \@ret;
}
	
=head1 NAME

 DKCOIN

=head1 SYNOPSIS
 
 use DKCOIN;


 my $dkcoin = new DKCOIN(
			-server => 'staging.dkcoin.org',
			-account => 'myaccount',
			-password => 'blah',
 );
 #Non authenticated methods
 #get a list of sources
 my $sources = $dkcoin->getSources();
 #get a list of valid resource types 
 my $rts = $dkcoin->getResourceTypes();
 #lets do a search (public method)
 my $search = new DKCOIN::Search(-gene_id => [19260]);
 my $resource = $dkcoin->search($search);
 
 #Authenticated methods
 #Start a session with target server (only required for private methods)
 my $outcome = $dkcoin->startSession();
 #create a collection
 my $collection = new DKCOIN::Collection(
				-name => 'test1',
				-displayname => 'Test1',
				-urltemplate => 'http://www.test.org/{internal_id}'
				);
 #save to target server
 my $out = $dkcoin->updateCollection([$collection]);
 #delete collection
 my $out = $dkcoin->deleteCollection([$collection);
 #create a resource
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
 #save resource to server
 my $out = $dkcoin->updateResource([$resource]);
 #append a resource to server
 my $out = $dkcoin->appendResource([$resource]);
 #delete resource from server
 my $out = $dkcoin->deleteResource([$resource]);
 my $outcome = $dkcoin->endSession();
 
=head1 DESCRIPTION
 
 These modules are a simple object orientated interfaces to dkCOIN webservices. For 
 further information please see http://www.dkcoin.org/
 
=head2 METHODS

=over 4
 
=item new 
 
 Arg:		List of named arguments
 		server [REQUIRED]
 		password [OPTIONAL]
 		account [OPTIONAL]
 Example:	$dkcoin = new DKCOIN(	-server => $server,
 					-password=>'password',
					-account=>'account'	
					);
 Description:	Creates a new DKCOIN object
 Returntype:	DKCOIN
 Note: 		password and account attributes only need to be set if utilising
		an authenticated (private) method.
 Type:		Public
 

=item startSession
 
 Arg:		None
 Example:	my $outcome = $dkcoin->startSession();
 Description:	Creates an authenticated session.
 Returntype:	Boolean
 Type:		Public 
 
=item endSession
 
 Arg:		None
 Example:	my $outcome = $dkcoin->endSession();
 Description:	Destroys an authenticated session.
 Returntype:	Boolean
 Type:		Public 
 
=item search
 
 Arg:		DKCOIN::Search object
 Example:	my $res = $dkcoin->search($search);
 Description:	Searches DKCOIN resource based on search criteria defined in DKCOIN::Search object.
 Returntype:	Array ref of DKCOIN::Resource objects.
 Type:		Public
 
=item getSources
 
 Arg:		None
 Example:	my $sources = $dkcoin->getSources();
 Description:	Gets a list of sources from dkcoin server.
 Returntype:	Array ref of DKCOIN::Source objects.
 Type:		Public
 
=item getResourceTypes
 
 Arg:		None
 Example:	my $resourceTypes = $dkcoin->getResourceTypes();
 Description:	Gets a list of resource type from dkcoin server.
 Returntype:	Array ref of DKCOIN::ResourceType objects.
 Type:		Public
 
=item updateResource
 
 Arg:		Array ref of DKCOIN::Resource objects
 Example:	my $out = $dkcoin->updateResource([$resource]);
 Description:	Creates or updates a resource on dkcoin server
 ReturnType:	Array ref of DKCOIN::Resource objects
 Type:		Private (auth required)
 Notes:		On success DKCOIN::Resource object is updated with action attribute
 		for example inserted,updated. This can be used to verify action. If 
 		it is blank server was unable to complete action.
 		
=item appendResource
 
 Arg:		Array ref of DKCOIN::Resource objects
 Example:	my $out = $dkcoin->appendResource([$resource]);
 Description:	Appends a resource on dkcoin server
 ReturnType:	Array ref of DKCOIN::Resource objects
 Type:		Private (auth required)
 Notes:		On success DKCOIN::Resource object is updated with action attribute
 		for example appended. This can be used to verify action. If 
 		it is blank server was unable to complete action.
 		
=item deleteResource
 
 Arg:		Array ref of DKCOIN::Resource objects
 Example:	my $out = $dkcoin->deleteResource([$resource]);
 Description:	Deletes a resource from dkcoin server
 ReturnType:	Array ref of DKCOIN::Resource objects
 Type:		Private (auth required)
 Notes:		On success DKCOIN::Resource object is updated with action attribute
 		for example deleted. This can be used to verify action. If 
 		it is blank server was unable to complete action.
 		
=item updateCollection
 
 Arg:		Array ref of DKCOIN::Collection objects
 Example:	my $out = $dkcoin->updateCollection([$collection]);
 Description:	Creates or updates a collection on dkcoin server
 ReturnType:	Array ref of DKCOIN::Collection objects
 Type:		Private (auth required)
 Notes:		On success DKCOIN::Collection object is updated with action attribute
 		for example created or updated. This can be used to verify action. If 
 		it is blank server was unable to complete action.
 		
=item deleteCollection
 
 Arg:		Array ref of DKCOIN::Collection objects
 Example:	my $out = $dkcoin->deleteCollection([$collection]);
 Description:	Deletes a collection from dkcoin server
 ReturnType:	Array ref of DKCOIN::Collection objects
 Type:		Private (auth required)
 Notes:		On success DKCOIN::Collection object is updated with action attribute
 		for example deleted. This can be used to verify action. If 
 		it is blank server was unable to complete action.
 
=cut		
		


