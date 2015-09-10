#!/usr/bin/perl -w
# Carga masiva de adjudicados
# Realiza operaciones sobre PostgreSQL y Oracle
# Lenin Hernandez leninmhs.wordpress.com
#

#use config;
require 'config.pm';
require 'operacionesdb.pl';

use Text::CSV;
use Pg::hstore;
use Data::Dumper;
use Switch;

our $oradb;
our $pgdb;

#my $csv = Text::CSV->new({ sep_char => ';' });
my $csv = Text::CSV->new ( { sep_char => ';', binary => 1, auto_diag => 1, } )
                            or die "Cannot use CSV: ".Text::CSV->error_diag ();

our $linea = 1;
$archivo = $ARGV[0] or die "Se requiere un archivo CSV como parametro\n";
our $id_desarrollo = $ARGV[1] or die "Se requiere el id_desarrollo como parametro\n";
our $usuario_id_creacion = $ARGV[2] or die "Se requiere el usuario_id_creacion como parametro\n";
our $id_carga_masiva = $ARGV[3] or die "Se requiere el usuario_id_creacion como parametro\n";
our $id_unidad_multifamiliar = 0;
our $id_vivienda = 0;
mensajesCarga( "inicio", "inicio el proceso de la carga masiva N° $id_carga_masiva" );

open( my $data, '<:encoding(utf8)', $archivo) or die "No puedo abrir el fichero '$archivo' $!\n";

#$csv->getline ($data); #retiramos la cabecera
$csv->column_names ($csv->getline ($data)); # use header
while (my $campos = $csv->getline_hr( $data )) {
  print $linea = $linea + 1;
  #mensajesCarga( "info$cont", "inicio el recorrido del archivo de la carga masiva N° $id_carga_masiva" );

#print Dumper($campos);
  $id_unidad_multifamiliar = unidadMultifamiliar( { unidad_multifamiliar =>
                $campos->{nombre_unidad_multifamiliar}, tipo_inmueble => $campos->{tipo_inmueble} });

  $id_vivienda = unidadFamiliar( { id_unidad_multifamiliar => $id_unidad_multifamiliar,
                                    campos => $campos });


  $id_beneficiario_temporal = beneficiarioTemporal( { id_unidad_multifamiliar => $id_unidad_multifamiliar,
                                    id_vivienda => $id_vivienda, campos => $campos });

  print "\nMultifamiliar: ".$id_unidad_multifamiliar." Vivienda:".$id_vivienda." Cedula: ".$campos->{cedula}." ID Oracle: ".$persona[0]." Cedula Oracle: ".$persona[2]." id_beneficiario_temporal: $id_beneficiario_temporal \n";

} ### Fin recorrido del CSV

if (not $csv->eof) {
  $csv->error_diag();
}

close $data;



print "fin recorrido del CSV Cont: $linea\n";
mensajesCarga( "info", "finalizo la carga masiva $id_carga_masiva" );

#$pgdb->commit;  # or call $dbh->rollback; to undo changes
#$pgdb->disconnect;
