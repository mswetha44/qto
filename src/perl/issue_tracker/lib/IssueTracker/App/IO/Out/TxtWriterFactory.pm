package IssueTracker::App::IO::Out::TxtWriterFactory ; 

   use strict; use warnings;
	
	use Data::Printer ; 

	our $appConfig 		= {} ; 
	our $term			   = $ENV{'period'} || 'daily' ; 
	our $table			   = $ENV{'tables'} || 'daily_issues' ; 
	our $objItem			= {} ; 
	our $objController 	= {} ; 
   our $objLogger       = {} ; 

	# use IssueTracker::App::Db::TxtWriterWeekly  ; 
   use IssueTracker::App::IO::Out::TxtWriter ;  

	#
	# -----------------------------------------------------------------------------
	# fabricates different TxtWriter object 
	# -----------------------------------------------------------------------------
	sub doInstantiate {

		my $self 			= shift ; 	
		my $table			= shift // $table ; # the default is 'daily'

		my @args 			= ( @_ ) ; 
		my $TxtWriter 		= {}   ; 
	   $TxtWriter 				= 'TxtWriter' ; 

		my $package_file     	= "IssueTracker/App/IO/Out/$TxtWriter.pm";
		my $objTxtWriter   		= "IssueTracker::App::IO::Out::$TxtWriter";

		require $package_file;

		return $objTxtWriter->new( \$appConfig , $table , @args);

	}
	# eof sub doInstantiate
	

   #
	# -----------------------------------------------------------------------------
	# the constructor 
	# -----------------------------------------------------------------------------
	sub new {

		my $invocant 			= shift ;    
		$appConfig           = ${ shift @_ } || { 'foo' => 'bar' ,} ; 
		
      # might be class or object, but in both cases invocant
		my $class = ref ( $invocant ) || $invocant ; 

		my $self = {};        # Anonymous hash reference holds instance attributes
		bless( $self, $class );    # Say: $self is a $class
      $self = $self->doInitialize() ; 
		return $self;
	}  
	#eof const
	
   #
	# --------------------------------------------------------
	# intializes this object 
	# --------------------------------------------------------
   sub doInitialize {
      my $self = shift ; 

      %$self = (
           appConfig => $appConfig
      );

	   $objLogger 			= 'IssueTracker::App::Utils::Logger'->new( \$appConfig ) ;


      return $self ; 
	}	
	#eof sub doInitialize

1;


__END__
