
use Switch;
#require '/var/www/html/carga-perl/config.pm';

    #### inicio unidad multifamiliar
sub unidadMultifamiliar($) {
      my ($args) = @_;
      my $tipo_inmueble;

      #print "Global: "$campos->{cedula};


      if    ($args->{tipo_inmueble} eq 'EDIFICIO DE APARTAMENTOS' )  { $tipo_inmueble = 82 }
      elsif ($args->{tipo_inmueble} eq 'CASA' )                      { $tipo_inmueble = 83 }
      elsif ($args->{tipo_inmueble} eq 'PARCELA' )                   { $tipo_inmueble = 84 }
      elsif ($args->{tipo_inmueble} eq 'TERRENO' )                   { $tipo_inmueble = 85 }


      $sth = $pgdb->prepare("SELECT id_unidad_habitacional FROM unidad_habitacional WHERE nombre = '".$args->{unidad_multifamiliar} ."' AND desarrollo_id = $id_desarrollo" );
      $sth->execute();
      if ($rows = $sth->execute) {
          if ($rows==0) {
            $multifamiliar = $pgdb->prepare("INSERT INTO unidad_habitacional(nombre,desarrollo_id,gen_tipo_inmueble_id,fuente_datos_entrada_id, estatus, usuario_id_creacion )
                   VALUES ( ?, ?, ?, ?, ?, ? )");
            #my @persona = Funciones::picapersona( $consulta[8] );
            $multifamiliar->execute( $args->{unidad_multifamiliar}, $id_desarrollo, $tipo_inmueble, 91, 77, $usuario_id_creacion);
            $id_unidad_multifamiliar = $pgdb->last_insert_id("null", "public", unidad_habitacional, id_unidad_habitacional);
          }
          else {@unidad_multifamiliar = $sth->fetchrow_array();
              $id_unidad_multifamiliar=$unidad_multifamiliar[0];
          }
      }

        my ($number) = @_;
        #return ($number + 10);
        return $id_unidad_multifamiliar;

}### fin unidad multifamiliar


sub unidadFamiliar($) {
      my ($args) = @_;
      my $tipo_inmueble;

      #print "Global: "$campos->{cedula};
      #print Dumper($args );
      #print Dumper($args->{campos}{numero_de_vivienda} );
      #print Dumper($args->{campos} );

      #for($args->{campos}){s/SI/TRUE/g}
      #print Dumper($args->{campos} );
      #94
      #$args->{id_unidad_multifamiliar}
      #$args->{campos}{area_mt2}
      #$args->{campos}{numero_de_piso}
      #$args->{campos}{numero_de_vivienda}
      $args->{campos}{sala}      = TRUE;
      $args->{campos}{comedor}   = TRUE;
      $args->{campos}{lavandero} = TRUE;
      #$args->{campos}{lindero_norte_vivienda}
      #$args->{campos}{lindero_sur_vivienda}
      #$args->{campos}{lindero_este_vivienda}
      #$args->{campos}{lindero_oeste_vivienda}
      #$args->{campos}{coordenadas}
      #$args->{campos}{precio_de_vivienda}
      #$args->{campos}{puesto_estacionamiento}
      #$args->{campos}{numero_estacionamiento}
      #$args->{campos}{numero_de_habitaciones}
      #$args->{campos}{numero_de_banos}
      #91
      #75
      $args->{campos}{cocina}  = TRUE;
      #$usuario_id_creacion


      $sth = $pgdb->prepare("SELECT id_vivienda FROM vivienda WHERE unidad_habitacional_id = '".$args->{id_unidad_multifamiliar} ."' AND nro_vivienda = '$args->{campos}{numero_de_vivienda}'" );
      $sth->execute();
      if ($rows = $sth->execute) {
          if ($rows==0) {
            $multifamiliar = $pgdb->prepare("INSERT INTO vivienda(tipo_vivienda_id,unidad_habitacional_id,construccion_mt2,nro_piso, nro_vivienda, sala, comedor,lavandero,lindero_norte,lindero_sur,lindero_este,lindero_oeste,coordenadas,precio_vivienda,nro_estacionamientos,descripcion_estac,nro_habitaciones,nro_banos,fuente_datos_entrada_id,estatus_vivienda_id,cocina,usuario_id_creacion )
                   VALUES ( ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,? )");
            #my @persona = Funciones::picapersona( $consulta[8] );
            $multifamiliar->execute( 94, $args->{id_unidad_multifamiliar}, $args->{campos}{area_mt2}, $args->{campos}{numero_de_piso}, $args->{campos}{numero_de_vivienda},$args->{campos}{sala},$args->{campos}{comedor}, $args->{campos}{lavandero},$args->{campos}{lindero_norte_vivienda},$args->{campos}{lindero_sur_vivienda},$args->{campos}{lindero_este_vivienda},$args->{campos}{lindero_oeste_vivienda},$args->{campos}{coordenadas}, $args->{campos}{precio_de_vivienda},$args->{campos}{puesto_estacionamiento},$args->{campos}{numero_estacionamiento},$args->{campos}{numero_de_habitaciones},$args->{campos}{numero_de_banos},91,75,$args->{campos}{cocina}, $usuario_id_creacion);
            $id_vivienda = $pgdb->last_insert_id("null", "public", vivienda, id_vivienda);
          }
          else {@unidad_familiar = $sth->fetchrow_array();
          $id_vivienda=$unidad_familiar[0];
          }
      }

        my ($number) = @_;
        #return ($number + 10);
        return $id_vivienda;

}### fin unidad multifamiliar





1;
