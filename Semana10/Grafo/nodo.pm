package grafo::nodo;


use strict;
use warnings;

sub new {
    my ($class, $id, $nombre, $departamento, $tipo) = @_;

    my $self = {
        id           => $id,
        nombre       => $nombre,
        departamento => $departamento // 'SIN-DEP',
        tipo         => $tipo         // 'TIPO-01',
    };

    bless $self, $class;
    return $self;
}

sub get_id           { return $_[0]->{id};           }
sub get_nombre       { return $_[0]->{nombre};       }
sub get_departamento { return $_[0]->{departamento}; }
sub get_tipo         { return $_[0]->{tipo};         }

sub set_departamento { $_[0]->{departamento} = $_[1]; }
sub set_tipo         { $_[0]->{tipo}         = $_[1]; }

sub to_string {
    my ($self) = @_;
    return sprintf("[%s | %s | %s | %s]",
        $self->{id}, $self->{nombre},
        $self->{departamento}, $self->{tipo});
}

1;


