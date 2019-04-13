package Qto::Controller::ListGrid ; 
use strict ; use warnings ; 

use Data::Printer ; 
use Scalar::Util qw /looks_like_number/;
use Carp ; 
use List::Util 1.33 'any';

use Qto::App::Utils::Logger;
use Qto::App::IO::In::CnrUrlPrms ; 
use Qto::App::Db::In::RdrDbsFactory;
use Qto::App::Cnvr::CnrHsr2ToArray ; 
use Qto::App::UI::WtrUIFactory ; 

our $appConfig      = {};
our $objModel       = {} ; 

sub doBuildListControl {

	my $self          	= shift ; 
	my $msg           	= shift ; 
   my $objModel      	= ${ shift @_ } ; 
	my $db               = shift ; 
	my $table            = shift ; 

   my $ret           	= 1 ; 
   my $control       	= '' ; 
   my $cols             = () ; 

   ( $ret , $msg , $cols) = $objModel->doGetItemsDefaultPickCols( $appConfig , $db , $table ) ;
   return ( $ret , $msg , '' ) unless $ret == 0 ; 
		
   my $to_picks   = $objModel->get('select.web-action.pick') ; 
   my @picks      = split ( ',' , $to_picks ) if defined ( $to_picks ) ; 
   my $to_hides   = $objModel->get('select.web-action.hide') ; 
   my @hides      = split ( ',' , $to_hides ) if defined ( $to_hides ) ; 

   unless ( defined ( $to_picks )) {
		foreach my $col ( @$cols ) {
         $control = $control . ",'" . $col . "'" unless ( grep (/^$col$/,@hides )) ; 
      }
   	$control = "['id'," . substr($control, 1) . ']' ; 
	} 
	else {
   	$control = "['id'," ; # it is just the js array definining the cols
		foreach my $to_pick ( @picks ) {
         unless ( grep (/^$to_pick$/,@hides)) {
            $control .= "'" . $to_pick . "' , " unless ( $to_pick eq 'id' );
         }
		}
		for (1..3) { chop ( $control ) } ;
   	$control .= ']' ;
	}
   return ( $ret , $msg , $control ) ; 
}

sub new {
   my $invocant 			= shift ;    
   $appConfig           = ${ shift @_ } || croak 'appConfig not set !!!' ;
   $objModel            = ${ shift @_ } || croak 'objModel not set !!!' ; 
   my $class            = ref ( $invocant ) || $invocant ; 
   my $self             = {}; bless( $self, $class );    
   return $self;
}  


1;

__END__
