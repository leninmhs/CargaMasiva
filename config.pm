#!/usr/bin/perl
# aptitude install libclass-dbi-pg-perl libtext-csv-perl
## obviar https://packages.debian.org/sid/amd64/libdbd-oracle-perl/download
# cpan
# yes yes
# >install DBD:Oracle
# export ORACLE_HOME=/usr/lib/oracle/12.1/client/lib
# cd /root/.cpan/build/DBD-Oracle-1.74-aCSyJr
# perl Makefile.PL -V 12.1
# make
# make install

use DBI;

### Inicializacion de variables de entorno
my ($rows, $sth, $multifamiliar, @persona, $persona, $archivo);
###

### Conexion Oracle

$ora_user = 'usuariooracle';
$ora_pass = 'claveoracle';
$ora_host = '192.168.x.x';
$ora_db   = 'dboracle';
$ora_sid  = 'dboracle';

my $cadena_ora = "DBI:Oracle:database=$ora_db;host=$ora_host;sid= $ora_sid;port=1521";

our $oradb = DBI->connect( "dbi:Oracle:$cadena_ora", $ora_user, $ora_pass ) || die( $DBI::errstr . "\n" );

#sub connect{
#return (DBI->connect ($cadena_ora, $ora_user, $ora_pass,
#{PrintError => 0, RaiseError => 1}));
#}
#1;



### Conexion PostgreSQL
$pg_user = 'postgres';
$pg_pass = 'postgres';
$pg_host = '192.168.x.x';
$pg_db   = 'dbpostgres';

our $pgdb = DBI->connect("DBI:Pg:dbname=$pg_db;host=$pg_host", "$pg_user", "$pg_pass", {'RaiseError' => 1});







#1;
