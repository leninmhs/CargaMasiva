#!/usr/bin/perl -w
# Carga masiva de adjudicados
# Realiza operaciones sobre PostgreSQL y Oracle
# Lenin Hernandez leninmhs.wordpress.com
#

#use config;
require 'config.pm';
require 'operacionesdb.pl';

use Text::CSV;
use Data::Dumper;
use Switch;

our $oradb;
our $pgdb;
$archivo = $ARGV[0] or die "Se requiere un archivo CSV como parametro\n";

#my $csv = Text::CSV->new({ sep_char => ';' });
my $csv = Text::CSV->new ( { sep_char => ';', binary => 1, auto_diag => 1, } )
                            or die "Cannot use CSV: ".Text::CSV->error_diag ();

my $cont = -1;
our $id_desarrollo = $ARGV[1] or die "Se requiere el id_desarrollo como parametro\n";
our $usuario_id_creacion = $ARGV[2] or die "Se requiere el usuario_id_creacion como parametro\n";
our $id_unidad_multifamiliar = 0;
our $id_vivienda = 0;

open( my $data, '<:encoding(utf8)', $archivo) or die "No puedo abrir el fichero '$archivo' $!\n";

#$csv->getline ($data); #retiramos la cabecera
$csv->column_names ($csv->getline ($data)); # use header
while (my $campos = $csv->getline_hr( $data )) {
  $cont = $cont + 1;

#print Dumper($campos);
  $id_unidad_multifamiliar = unidadMultifamiliar( { unidad_multifamiliar =>
                $campos->{nombre_unidad_multifamiliar}, tipo_inmueble => $campos->{tipo_inmueble} });

  $id_vivienda = unidadFamiliar( { id_unidad_multifamiliar => $id_unidad_multifamiliar,
                                    campos => $campos });


### Consultamos cedula TABLAS_COMUNES.PERSONA en oracle
  my $cedula = $campos->{cedula};
  my $sth = $oradb->prepare("SELECT ID, NACIONALIDAD , CEDULA, PRIMER_NOMBRE AS PRIMERNOMBRE
                          FROM TABLAS_COMUNES.PERSONA WHERE NACIONALIDAD = '1' AND CEDULA = $cedula ");
  $sth->execute();
  #my ($ID,$nacionalidad,$cedula, $primernombre)  = $sth->fetchrow_array();
  @persona  = $sth->fetchrow_array();
  $sth->finish();

### Fin consulta TABLAS_COMUNES.PERSONA oracle

my $ID = $persona[0];
if( $ID eq ''){

  $sth = $oradb->prepare("SELECT ID, NACIONALIDAD, CEDULA, PRIMERNOMBRE, SEGUNDONOMBRE, PRIMERAPELLIDO, SEGUNDOAPELLIDO, TO_DATE(FECHANACIMIENTO, 'DD-MM-YYYY' ) As FECHANACIMIENTO,2 AS PROCEDENCIA
                          FROM ORGANISMOS_PUBLICOS.SAIME_ORIGINAL
                          WHERE NACIONALIDAD ='V' AND CEDULA = $cedula ");
  $sth->execute();
  #my ($ID,$nacionalidad,$cedula, $primernombre)  = $sth->fetchrow_array();
  @saime  = $sth->fetchrow_array();


  #INSERT INTO TABLAS_COMUNES.PERSONA (ID, CEDULA,NACIONALIDAD,PRIMER_NOMBRE,SEGUNDO_NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,FECHA_NACIMIENTO,GEN_SEXO_ID,CODIGO_HAB,TELEFONO_HAB,CODIGO_MOVIL,TELEFONO_MOVIL,CORREO_PRINCIPAL)
  #VALUES ((SELECT MAX(ID)+1 FROM TABLAS_COMUNES.PERSONA),17845965,1,'KARINA','LISBETH','NIEVES','PARRA',to_date('28-MAY-85','DD/MM/RR'),1,0212,6544565,0416,4565434,'karinitanieves@gmail.com')
  ### Sacar ultimo ID en PERSONA
  $sth = $oradb->prepare("SELECT MAX(ID)+1 FROM TABLAS_COMUNES.PERSONA");
  $sth->execute();
  #my ($ID,$nacionalidad,$cedula, $primernombre)  = $sth->fetchrow_array();
  @id_persona  = $sth->fetchrow_array();

  $sexo = ($campos->{sexo} eq 'MASCULINO') ? 2 : 1;

  $persona_oracle = $oradb->prepare("INSERT INTO TABLAS_COMUNES.PERSONA(ID, CEDULA, NACIONALIDAD, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, FECHA_NACIMIENTO, GEN_SEXO_ID, CODIGO_HAB, TELEFONO_HAB, CODIGO_MOVIL, TELEFONO_MOVIL, CORREO_PRINCIPAL )
         VALUES (?,?, ?, ?, ?, ?, ?, TO_DATE(?,'DD/MM/RR'), ?, ?, ?, ?, ?, ? )");
  #my @persona = Funciones::picapersona( $consulta[8] );
  #$persona_oracle->execute( 9625808,17845965,1,'KARINA','LISBETH','NIEVES','PARRA',TO_DATE('27/05/85','DD/MM/RR'),1,'0212','6544565','0416','4565434','karinitanieves@gmail.com');
  $persona_oracle->execute( $id_persona[0],"$saime[2]",1,"$saime[3]","$saime[4]","$saime[5]","$saime[6]","$saime[7]",$sexo,'0212','6544565','0416','4565434', "$campos->{correo_electronico}");
  my $id_oracle = $oradb->last_insert_id("null", "TABLAS_COMUNES", PERSONA, ID);
  print "ULTIMO ID ORACLE: ".$id_persona[0]."\n";
  #@persona  = $sth->fetchrow_array();

  $persona_oracle->finish();
  $persona_id = $id_persona[0];
}else{
  $persona_id = $persona[0];
}

if( defined( $persona_id ) && $persona_id ne '' ){

print "PRINT ID PERSONA TABLAS_COMUNES: ".Dumper($persona_id );

  $campos->{nacionalidad} = 97;


  $nombre_completo = $campos->{primer_nombre}." ".$campos->{segundo_nombre}." ".$campos->{primer_apellido}." ".$campos->{segundo_apellido};

  my $beneficiariotemp = $pgdb->prepare("INSERT INTO beneficiario_temporal(persona_id, desarrollo_id, unidad_habitacional_id, vivienda_id, nacionalidad, cedula, nombre_completo, estatus, usuario_id_creacion )
         VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ? )");
  #my @persona = Funciones::picapersona( $consulta[8] );
  $beneficiariotemp->execute( $persona_id , $id_desarrollo, $id_unidad_multifamiliar, $id_vivienda, $campos->{nacionalidad}, $campos->{cedula},$nombre_completo,79, $usuario_id_creacion);
  $id_beneficiario_temporal = $pgdb->last_insert_id("null", "public", beneficiario_temporal, id_beneficiario_temporal);


}

  print "\nMultifamiliar: ".$id_unidad_multifamiliar." Vivienda:".$id_vivienda." Cedula: ".$campos->{cedula}." ID Oracle: ".$persona[0]." Cedula Oracle: ".$persona[2]." id_beneficiario_temporal: $id_beneficiario_temporal \n";

}

### Fin recorrido del CSV


if (not $csv->eof) {
  $csv->error_diag();
}

close $data;

print "fin recorrido del CSV Cont: $cont\n";
