package matriz_dispersa::NodoDato;

# ---> matriz_dispersa/NodoDato.pm

use strict;
use warnings;

# CONSTRUCTOR
#   $fila  --> numero de fila donde se inserta este dato
#   $col   --> numero de columna donde se inserta este dato
#   $valor --> el valor 
sub new {
    my ($class, $fila, $col, $valor) = @_;

    my $self = {
        fila  => $fila,    # indice de fila (entero)
        col   => $col,     # indice de columna (entero)
        valor => $valor,   # el dato almacenado

        # enlaces horizontales (misma fila)
        right => undef,
        left  => undef,

        # enlaces verticales (misma columna)
        down  => undef,
        up    => undef,
    };

    bless $self, $class;
    return $self;
}

# GETTERS
sub get_fila  {return $_[0]->{fila}  }
sub get_col   {return $_[0]->{col}}
sub get_valor { return $_[0]->{valor} }

sub get_right {return $_[0]->{right} }
sub get_left  { return $_[0]->{left}}
sub get_down  { return $_[0]->{down}}
sub get_up    { return $_[0]->{up}}

# SETTERS
sub set_valor {
    my ($self, $v) = @_;
    $self->{valor} = $v;
}

sub set_right {
    my ($self, $n) = @_;
    $self->{right} = $n;
}

sub set_left {
    my ($self, $n) = @_;
    $self->{left} = $n;
}

sub set_down {
    my ($self, $n) = @_;
    $self->{down} = $n;
}

sub set_up {
    my ($self, $n) = @_;
    $self->{up} = $n;
}

sub to_string {
    my ($self) = @_;
    my $val = ref($self->{valor}) ? ref($self->{valor}) . "(obj)" : $self->{valor};
    return "NodoDato[fila=$self->{fila}, col=$self->{col}, valor=$val]";
}

1;