package bst::nodo;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;
    my $self = {
        data  => $data,
        left  => undef,
        right => undef,
    };
    bless $self, $class;
    return $self;
}

sub get_data {
    return $_[0]->{data};
}

sub set_data {
    my ($self, $new_data) = @_;
    $self->{data} = $new_data;
}

sub get_left {
    return $_[0]->{left};
}

sub set_left {
    my ($self, $nodo_izq) = @_;
    $self->{left} = $nodo_izq;
}

sub get_right {
    return $_[0]->{right};
}

sub set_right {
    my ($self, $nodo_der) = @_;
    $self->{right} = $nodo_der;
}

sub es_hoja {
    my ($self) = @_;
    return (!defined($self->{left}) && !defined($self->{right})) ? 1 : 0;
}

sub to_string {
    my ($self) = @_;
    my $data       = $self->{data};
    my $tiene_izq  = defined($self->{left})  ? "Si" : "No";
    my $tiene_der  = defined($self->{right}) ? "Si" : "No";
    return "Nodo[data=$data, hijo_izq=$tiene_izq, hijo_der=$tiene_der]\n";
}

sub imprimir_nodo {
    my ($self) = @_;
    print "Dato: $self->{data}\n";
    print "Hijo izquierdo: " . (defined($self->{left})  ? "Si" : "No") . "\n";
    print "Hijo derecho:   " . (defined($self->{right}) ? "Si" : "No") . "\n\n";
}

1;