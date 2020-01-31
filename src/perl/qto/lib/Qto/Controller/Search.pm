package Qto::Controller::Search ; 
use strict ; use warnings ; 

require Exporter;
our @ISA = qw(Exporter Mojo::Base Qto::Controller::BaseController);
our $AUTOLOAD =();
our $ModuleDebug = 0 ; 
use AutoLoader;

use parent qw(Qto::Controller::BaseController);

use Data::Printer ; 
use Data::Dumper; 

use Qto::Controller::PageFactory ; 
use Qto::App::Db::In::RdrDbsFcry;
use Qto::App::Utils::Logger;
use Qto::App::Cnvr::CnrHsr2ToArray ; 
use Qto::App::IO::In::CnrUrlPrms ; 
use Qto::App::Utils::Timer ; 
use Qto::App::Cnvr::CnrDbName qw(toPlainName toEnvName);
use Qto::App::Db::In::RdrRedis ; 

my $module_trace        = 0 ;
our $config          = {};
our $objLogger          = {} ;
our $rdbms_type         = 'postgres';



sub doSearchItems {
   my $self             = shift;
   my $db               = $self->stash('db');
   
   my $objModel         = {} ;
   my $objCnrUrlPrms    = {} ; 
   my $objRdrDbsFcry = {} ; 
   my $objRdrDb         = {} ; 
   my $ret              = 0;
   my $msg              = 'unknown error during search';
   my $hsr2             = {};
   my $msr2             = {};
   my $http_code        = 200 ; 
   my $rows_count       = 0 ; 
   my $as               = 'grid' ; 
   my $srch_control     = 'srch-grid' ; 
   my $notice           = '' ; 
   my $left_menu        = '' ; 
   

   $config		         = $self->app->config ; 
   $db                  = toEnvName ( $db , $config) ;
   return unless ( $self->SUPER::isAuthenticated($db) == 1 ); 
   $self->SUPER::doReloadProjDbMeta( $db,'search' ) ;
   
   $objModel         = 'Qto::App::Mdl::Model'->new ( \$config , $db) ;
   
   $objCnrUrlPrms = 
      'Qto::App::IO::In::CnrUrlPrms'->new(\$config , \$objModel , $self->req->query_params);
   ( $ret , $msg ) = $objCnrUrlPrms->doSetQueryUrlParams('Search' );

   if ( ! defined ($self->req->query_params ) or $ret != 0 ) {
   
      my $objTimer         = 'Qto::App::Utils::Timer'->new( $config->{'env'}->{'log'}->{ 'TimeFormat' } );
      my $page_load_time   = $objTimer->GetHumanReadableTime();
      my $objRdrRedis      = 'Qto::App::Db::In::RdrRedis'->new(\$config);
      my $tables_list      = $objRdrRedis->getData(\$config,"$db" . '.tables-list');
      my @items_arr        = @{$tables_list};
      my $items_lst        = '';
      foreach my $table ( @items_arr ){
         $items_lst .= "'" . "$table" . "'," ;
      }
      $items_lst = substr($items_lst, 0, -1);
  
      $self->render(
         'template'        => 'controls/srch-grid/srch-grid'
       , 'as'              => 'grid'
       , 'item'            => 'search'
       , 'msg'             => ''
       , 'db' 		         => $db
       , 'EnvType' 		=> $config->{'env'}->{'run'}->{'ENV_TYPE'}
       , 'ProductVersion' 	=> $config->{'env'}->{'run'}->{'VERSION'}
       , 'GitShortHash' => $config->{'env'}->{'run'}->{'GitShortHash'}
       , 'page_load_time'  => $page_load_time
       , 'srch_control'    => "['title']" 
       , 'notice'          => $notice
       , 'left_menu'       => $left_menu
       , 'items_lst'       => $items_lst
      ) ; 
      return ; 
   }  else {
      # do render without the table 
      $as = $self->req->query_params->param('as') || $as ; # decide which type of Search page to build
      ( $ret , $msg , $srch_control ) = $self->doBuildSearchControl ( \$objModel , $msg , $db , $as  ) ; 
      
      #$msg = $self->doSetPageMsg ( $ret , $msg ) ; 
      $self->doRenderPageTemplate( \$objModel , $msg , $db , $srch_control , $as, $left_menu) ; 
   }

}

sub doBuildSearchControl {

   my $self             = shift ; 
   my $objModel         = ${ shift @_ } ; 
   my $msg              = shift ; 
   my $db               = shift ; 
   my $as               = shift || 'grid' ; 

   my $ui_type          = 'page/srch-grid' ; 
   my $ret              = 1 ; 
   my $srch_control     = '' ; 
   my $objPageBuilder   = {} ; 
   my $objPageFactory   = {} ; 

   my $lables_pages = { 
          'grid'   => 'srch-grid'
   };

   $ui_type = 'page/' . $lables_pages->{ $as } ; 
  
   $objPageFactory                  = 'Qto::Controller::PageFactory'->new(\$config, \$objModel );
   $objPageBuilder                  = $objPageFactory->doSpawn( $ui_type );
   ( $ret , $msg , $srch_control )  = $objPageBuilder->doBuildSearchControl( $msg , $db  , $as ) ;

   return ( $ret , $msg , $srch_control ) ; 

}



sub doRenderPageTemplate {
   
   my $self             = shift ; 
   my $objModel         = ${ shift @_ } ; 
   my $msg              = shift ; 
   my $db               = shift ; 
   my $srch_control     = shift ; 
   my $as               = shift || 'grid' ; 
   my $left_menu        = shift ;
   my $notice           = '' ; 
   my $as_templates = { 
        'grid'          => 'srch-grid' 
   };
  
   my $template_name    = $as_templates->{ $as } || 'srch-grid' ; 
   my $template         = 'controls/' . $template_name . '/' . $template_name ; 

   my $objTimer         = 'Qto::App::Utils::Timer'->new( $config->{'env'}->{'log'}->{ 'TimeFormat' } );
   my $page_load_time   = $objTimer->GetHumanReadableTime();
   my $objRdrRedis      = 'Qto::App::Db::In::RdrRedis'->new(\$config);
   my $tables_list      = $objRdrRedis->getData(\$config,"$db" . '.tables-list');
   my @items_arr        = @{$tables_list};
   my $items_lst        = '';
   foreach my $table ( @items_arr ){
      $items_lst .= "'" . "$table" . "'," ;
   }
   $items_lst = substr($items_lst, 0, -1);

   $self->render(
      'template'        => $template 
    , 'as'              => $as
    , 'item'            => 'search'
    , 'msg'             => $msg
    , 'db' 		         => $db
    , 'EnvType' 		   => $config->{'env'}->{'run'}->{'ENV_TYPE'}
    , 'ProductVersion' 	=> $config->{'env'}->{'run'}->{'VERSION'}
    , 'GitShortHash'    => $config->{'env'}->{'run'}->{'GitShortHash'}
    , 'page_load_time'  => $page_load_time
    , 'srch_control'    => $srch_control
    , 'notice'          => $notice
    , 'left_menu'       => $left_menu
    , 'items_lst'       => $items_lst
	) ; 

   return ; 
}



1;

__END__
