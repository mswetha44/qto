package Qto::App::Utils::Initiator ; 

	use strict; use warnings;

	my $VERSION = '1.2.0';    #doc at the end

	require Exporter;
	our @ISA = qw(Exporter Qto::App::Utils::OO::SetGetable Qto::App::Utils::OO::AutoLoadable) ;
	our $AUTOLOAD =();
	our $ModuleDebug = 0 ; 
	use AutoLoader;

	use Cwd qw/abs_path/;
   use File::Basename;
	use File::Path qw(make_path) ;
	use File::Find ; 
	use File::Copy;
	use File::Copy::Recursive ; 
   use Data::Printer ; 
	use Sys::Hostname;
	use Carp qw /cluck confess shortmess croak carp/ ; 

   use parent 'Qto::App::Utils::OO::SetGetable' ;
   use parent 'Qto::App::Utils::OO::AutoLoadable' ;

	our $appConfig						= {} ; 
	our $RunDir 						= '' ; 
	our $ProductBaseDir 				= '' ; 
	our $ProductDir 					= '' ; 
	our $ProductInstanceDir 	   = ''; 
	our $ProductInstanceEnvironment = '' ; 
	our $ProductName 					= '' ; 
	our $ProductType 					= '' ; 
	our $ProductVersion 				= ''; 
	our $ProductOwner 				= '' ; 
	our $HostName 						= '' ; 
	our $ConfFile 						= '' ; 
   our $rel_levels               = 0 ; 
   our $my_absolute_path         = '' ; 
=head1 SYNOPSIS

	doResolves the product version and base dirs , bootstraps cnfig files if needed

		 use Initiator;
		 my $objInitiator = new Initiator () ; 

	=head1 EXPORT

	A list of functions that can be exported.  You can delete this section
	if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS


=cut

	#
	# ---------------------------------------------------------
	# the product base dir is the dir under which all the product
	# instances are installed 
	# ---------------------------------------------------------
	sub doResolveMyProductBaseDir {

		my $self = shift;
		my $msg  = ();
		my $levels_up = 9 + $rel_levels ; 
		my $product_base_dir = '' ; 
		my @DirParts = ();
		@DirParts = @{doGetDirParts($levels_up)};
      $product_base_dir = join( '/', @DirParts );
		#untainting ...
		$ProductBaseDir 						= $product_base_dir ; 
		$product_base_dir 					= $self->untaint ( $product_base_dir); 
		$ProductBaseDir 						= $self->untaint ( $product_base_dir); 
		$self->{'ProductBaseDir'} 			= $ProductBaseDir ; 
		$appConfig->{'ProductBaseDir'} 	= $ProductBaseDir ; 
		$self->{'AppConfig'} 				= $appConfig; 

		return $ProductBaseDir;
	}
	

	#
	# ---------------------------------------------------------
	# the product base dir is the dir under which all the product
	# instances are installed 
	# ---------------------------------------------------------
	sub doGetDirParts {

		my $msg  = ();
		my $levels_up = shift ; 

		$my_absolute_path =~ m/^(.*)(\\|\/)(.*)/;
		$my_absolute_path = $1;
      
		$my_absolute_path =~ tr|\\|/| if ( $^O eq 'MSWin32' );
		my @DirParts = split( '/' , $my_absolute_path );
		for ( my $count = 0; $count < $levels_up ; $count++ ){ 
			pop @DirParts; 
		}
		
		return \@DirParts ; 
	}
	
   #
	# ---------------------------------------------------------
	# the product version dir is the dir where this product 
	# instance is situated
	# ---------------------------------------------------------
	sub doResolveMyProductDir {

		my $self = shift;
		my $msg  = ();
		my $levels_up = 7 + $rel_levels ; 
		my $product_dir = '' ; 
		my @DirParts = @{doGetDirParts ( $levels_up )} ; 
		$ProductDir = join( '/' , @DirParts );
		$self->{'ProductDir'} 			= $ProductDir ; 
		$appConfig->{'ProductDir'} 	= $ProductDir ; 
		$self->{'AppConfig'} 				= $appConfig; 
      
		return $ProductDir;
	}
	#eof sub doResolveMyProductDir
	

	#
	# ---------------------------------------------------------
	# the product version dir is the dir where this product 
	# instance is situated
	# ---------------------------------------------------------
	sub doResolveMyProductInstanceDir {

		my $self = shift;
		my $msg  = ();
		my $levels_up = 5 + $rel_levels ; 
		my $product_instance_dir = '' ; 
		my @DirParts = @{doGetDirParts ( $levels_up )} ; 
		
		$product_instance_dir 					= join( '/' , @DirParts );
		$ProductInstanceDir 						= $product_instance_dir ; 
		$product_instance_dir 					= $self->untaint ( $product_instance_dir); 
		$ProductInstanceDir 						= $self->untaint ( $product_instance_dir); 
		$self->{'ProductInstanceDir'} 	   = $ProductInstanceDir ; 
		$appConfig->{'ProductInstanceDir'} 	= $ProductInstanceDir ; 
		$self->{'AppConfig'} 				   = $appConfig; 

		return $ProductInstanceDir;
	}
	#eof sub doResolveMyProductInstanceDir

	#
	# ---------------------------------------------------------
	# the environment name is the dir identifying this product 
	# instance from other product instances 
	# ---------------------------------------------------------
	sub doResolveMyProductInstanceEnvironment {

		my $self = shift;
		my $msg  = ();

		$ProductInstanceEnvironment 			= $ProductInstanceDir ; 
		$ProductInstanceEnvironment 			=~ s#$ProductBaseDir\/##g ;
		$ProductInstanceEnvironment 			=~ s#(.*?)(\/|\\)(.*)#$3#g ;
		$ProductInstanceEnvironment 			= $self->untaint ( $ProductInstanceEnvironment ); 

		$appConfig->{ 'ProductInstanceEnvironment' } 		= $ProductInstanceEnvironment ; 
		$self->{ 'ProductInstanceEnvironment' } 		= $ProductInstanceEnvironment ; 
		$self->{'AppConfig'} 				= $appConfig; 

		return $ProductInstanceEnvironment;
	}
	#eof sub doResolveMyProductInstanceEnvironment

	#
	# ---------------------------------------------------------
	# the Product name is the name by which this Product is 
	# identified 
	# ---------------------------------------------------------
	sub doResolveMyProductName {

		my $self = shift;
		my $msg  = ();

		#fetch the the product name from the dir struct
		my @tokens = split /\./ , $ProductInstanceEnvironment ; 
		$ProductName = $tokens[0] ; 

		$appConfig->{ 'ProductName' } 			= $ProductName ; 
		$self->{'AppConfig'} 				= $appConfig; 
		return $ProductName;
	}
	#eof sub doResolveMyProductName


	#
	# ---------------------------------------------------------
	# the Product Version is a number identifying the stage 
	# of the evolution of this product 
	# ---------------------------------------------------------
	sub doResolveMyProductVersion {

		my $self = shift;
		my $msg  = ();
		
		my $ProductVersion	= '' ;

		my @tokens 			= split /\./ , $ProductInstanceEnvironment ; 
		$tokens [1] = $tokens [1] // '' ; 
		$tokens [2] = $tokens [2] // '' ; 
		$tokens [3] = $tokens [3] // '' ; 
		$ProductVersion 	= $tokens[1] . '.' . $tokens[2] . '.' . $tokens[3] ; 
		#debug rint "\n\n ProductVersion : $ProductVersion " ; 
		
		$appConfig->{ 'ProductVersion' } 		= $ProductVersion ; 
		$self->{'AppConfig'} 				= $appConfig; 

		return $ProductVersion;
	}
	#eof sub doResolveMyProductVersion

	#
	# ---------------------------------------------------------
	# the Product Type could be :
	# dev -> this product instance is used for development
	# tst -> this product instance is used for testing 
	# qas -> this product instance is used for quality assurance
	# prd -> this product instance is used for production
	# Of course you could define you own abbreviations like ...
	# fub -> full backup
	# ---------------------------------------------------------
	sub doResolveMyProductType {

		my $self = shift;
		my $msg  = ();

		my @tokens = split /\./ , $ProductInstanceEnvironment ; 
		# the type of this environment - dev , test , dev , fb , prod next_line_is_templatized
		my $ProductType = $tokens[4] ; 
		# debug rint "\n\n ProductType : $ProductType " ; 

		$appConfig->{ 'ProductType' } 			= $ProductType ; 
		$self->{ 'ProductType' } 			= $ProductType ; 
		$self->{'AppConfig'} 				= $appConfig; 

		return $ProductType;
	}
	#eof sub doResolveMyProductType



	#
	# ---------------------------------------------------------
	# the Product Owner is the string identifying the main 
	# responsible person for operating the current product 
	# instance 
	# ---------------------------------------------------------
	sub doResolveMyProductOwner {

		my $self = shift;
		my $msg  = ();


		my @tokens = split /\./ , $ProductInstanceEnvironment ; 
		# the Owner of this environment - dev , test , dev , fb , prod next_line_is_templatized
		# The username of the person developin this environment 
		$ProductOwner = $tokens[5] ; 
		#debug rint "\n\n ProductOwner : $ProductOwner " ; 

		$appConfig->{ 'ProductOwner' } 			= $ProductOwner ; 
		$self->{'AppConfig'} 				= $appConfig; 
		return $ProductOwner;
	}
	#eof sub doResolveMyProductOwner


	#
	# ---------------------------------------------------------
	# returns the host name of currently running host
	# by using the Sys::hostname perl module
	# ---------------------------------------------------------
	sub doResolveMyHostName {

		my $self = shift;
		my $msg  = ();

		$HostName = hostname ; 
		$self->set ( 'HostName' , $HostName );
		$appConfig->{ 'HostName' }	      = $HostName ; 
		$self->{'AppConfig'} 				= $appConfig; 
		return $HostName;
	}


	#
	# ---------------------------------------------------------
	# returns the host name of currently running host
	# by using the Sys::ConfFile perl module
	# ---------------------------------------------------------
	sub doResolveMyConfFile {

		my $self 						= shift;
		my $msg  						= ();
		
		my $HostName					= $self->doResolveMyHostName();

		# set the default ConfFile path if no cmd argument is provided
		$ConfFile = "$ProductInstanceDir/cnf/$ProductName.$HostName.cnf" ; 

      # override with env conf file if found one ...
      # cnf/qto.host-name.cnf
      # cnf/qto.dev.host-name.cnf
      # cnf/qto.tst.host-name.cnf
      # cnf/qto.prd.host-name.cnf
      if ( -f "$ProductInstanceDir/cnf/$ProductName.$ProductType.$HostName.cnf" ) {
		   $ConfFile = "$ProductInstanceDir/cnf/$ProductName.$ProductType.$HostName.cnf" 
      }
      

		$self->set('ConfFile' , $ConfFile) ; 
		$appConfig->{'ConfFile'} 	= $ConfFile ; 
		$self->{'AppConfig'} 		= $appConfig; 

		 
		return $ConfFile;
	}


=head2 new
	# -----------------------------------------------------------------------------
	# the constructor
=cut 

	# -----------------------------------------------------------------------------
	# the constructor 
	# -----------------------------------------------------------------------------
	sub new {
		
		my $invocant = shift;    
		# might be class or object, but in both cases invocant
		my $class = ref ( $invocant ) || $invocant ; 
      $rel_levels = shift || 0 ; 

		my $self = {};        # Anonymous hash reference holds instance attributes
		bless( $self, $class );    # Say: $self is a $class

      # !!! important concept - src: https://stackoverflow.com/a/90721/65706
      $my_absolute_path             = abs_path( __FILE__ ); 
		$ProductBaseDir 			      = $self->doResolveMyProductBaseDir();
		$ProductDir 			         = $self->doResolveMyProductDir();
		$ProductInstanceDir 		      = $self->doResolveMyProductInstanceDir();
		$ProductInstanceEnvironment   = $self->doResolveMyProductInstanceEnvironment();
		$ProductName 				      = $self->doResolveMyProductName();
		$ProductVersion 			      = $self->doResolveMyProductVersion();
		$ProductType 				      = $self->doResolveMyProductType();
		$ProductOwner 				      = $self->doResolveMyProductOwner();
		$HostName 					      = $self->doResolveMyHostName();
		$ConfFile 					      = $self->doResolveMyConfFile();


		return $self;
	}  
	#eof const


	# STOP functions
	# =============================================================================

	# -----------------------------------------------------------------------------
	# cleans potentially suspicious dirs and files for the perl -T call
	# -----------------------------------------------------------------------------
	sub untaint {
	   my $self          = shift ; 	
		my $file 			= shift || croak 'no file passed !!!' ;

		# Don't pollute caller's value.
  		local $@;   

		
		# it just does not work under Windows ... 
		return $file if ( $^O eq 'MSWin32' ) ; 

		#debug rint ( "undef file" ) unless ( $file ) ; 
		#debug rint ( "BEFORE untaint -- file: $file " ) ; 
		
		unless ( $self->is_tainted ( $file ) ) {
			
			$file =~ /([\/_\-\@\w.]+)/ ;
			#debug rint "Initiator::untaint \$1 is $1 \n" ; 
			$file = $1; 			
			#$dat should be now untainted
			#debug rint "file : $file is not tainted \n" ; 
			#debug rint ( "AFTER untaint -- file: $file " ) ; 
			return $1 ; 
		} else {
			carp "Bad dat in file path: '$file'"; 	
		}
		
	}
	

	# -----------------------------------------------------------------------------
	# src:http://perldoc.perl.org/functions/local.html
	# src:http://perldoc.perl.org/perlsec.html#Laundering-and-Detecting-Tainted-Data
	# -----------------------------------------------------------------------------
	sub is_tainted {
		my $self = shift ; 
  		local $@;   # Don't pollute caller's value.
      my @params = @_ || ();
		return ! eval { eval("#" . substr(join("", @params), 0, 0)); 1 };
	}



1;

__END__

=head1 NAME

Initiator 

=head1 SYNOPSIS

use Initiator  ; 


=head1 DESCRIPTION
the main purpose is to initiate minimum needed environment for the operation 
of the whole application - man app cnfig hash 

=head2 EXPORT


=head1 SEE ALSO

perldoc perlvars

No mailing list for this module


=head1 AUTHOR

yordan.georgiev@gmail.com

=head1 




# ---------------------------------------------------------
# VersionHistory: 
# ---------------------------------------------------------
#
1.3.0 --- 2017-11-22 22:26:56 -- Improved Tests
1.2.0 --- 2014-09-11 20:44:26 -- tests on Windows 
1.1.0 --- 2014-08-27 11:29:25 -- tests passed with Test::More
1.0.0 --- 2014-08-25 08:25:15 -- refactored away from main calling script

=cut 

