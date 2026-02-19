package matriz_dispersa::Pelicula;

# ---> matriz_dispersa/Pelicula.pm
#
# Objeto de dominio que se almacenara como valor dentro de los NodoDato
# de la matriz dispersa. La matriz dispersa no sabe nada de peliculas;
# simplemente guarda la referencia al objeto en el campo "valor" del NodoDato.

use strict;
use warnings;

# CONSTRUCTOR
sub new {
    my ($class, $nombre, $director, $duracion, $anio, $genero) = @_;

    my $self = {
        nombre   => $nombre,
        director => $director,
        duracion => $duracion,
        anio     => $anio,
        genero   => $genero,
    };

    bless $self, $class;
    return $self;
}

# GETTERS
sub get_nombre{ return $_[0]->{nombre}}
sub get_director{ return $_[0]->{director}}
sub get_duracion{ return $_[0]->{duracion} }
sub get_anio{ return $_[0]->{anio}}
sub get_genero{ return $_[0]->{genero}}

# SETTERS
sub set_nombre   { my ($s,$v) = @_; $s->{nombre}   = $v }
sub set_director { my ($s,$v) = @_; $s->{director} = $v }
sub set_duracion { my ($s,$v) = @_; $s->{duracion} = $v }
sub set_anio     { my ($s,$v) = @_; $s->{anio}     = $v }
sub set_genero{ my ($s,$v) = @_; $s->{genero}= $v }

# imprimir_info()
sub imprimir_info {
    my ($self) = @_;
    print "  .....................................\n";
    print "  Nombre:   $self->{nombre}\n";
    print "  Director: $self->{director}\n";
    print "  Duracion: $self->{duracion} min\n";
    print "  Anio:     $self->{anio}\n";
    print " genero:    $self->{genero}\n";
    print "  .....................................\n\n";
}

# get_info_graphviz()
# Texto compacto para mostrar dentro del nodo en el grafico DOT.
# El \\n se convierte en salto de linea dentro del label de Graphviz.
sub get_info_graphviz {
    my ($self) = @_;
    return "$self->{nombre}\\n" .
           "$self->{anio} | $self->{duracion}min";
}

1;