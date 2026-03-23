package btree::nodo;

use strict;
use warnings;

# ------------------------------------------------------------------
# Clase Nodo de Arbol B
#
# Cada nodo almacena:
# - keys: arreglo de claves ordenadas de menor a mayor.
# - children: arreglo de referencias a nodos hijos.
# - leaf: bandera booleana (1 si es hoja, 0 si es interno).
#
# Nota teorica:
# En un nodo interno con k claves, deben existir k+1 hijos.
# ------------------------------------------------------------------
# el nodo leaf se usa en 
sub new {
    my ($class, $leaf) = @_;

    # Se inicializa con arreglos vacios y tipo hoja por defecto.
    my $self = {
        keys     => [],
        children => [],
        leaf     => defined($leaf) ? $leaf : 1,
    };

    bless $self, $class;
    return $self;
}

# Retorna referencia al arreglo de claves.
sub get_keys {
    return $_[0]->{keys};
}

# Reemplaza el arreglo de claves completo.
sub set_keys {
    my ($self, $keys_ref) = @_;
    $self->{keys} = $keys_ref;
}

# Retorna referencia al arreglo de hijos.
sub get_children {
    return $_[0]->{children};
}

# Reemplaza el arreglo de hijos completo.
sub set_children {
    my ($self, $children_ref) = @_;
    $self->{children} = $children_ref;
}

# Indica si el nodo es hoja.
sub is_leaf {
    return $_[0]->{leaf} ? 1 : 0;
}

# Cambia el tipo del nodo (hoja/interno).
sub set_leaf {
    my ($self, $leaf) = @_;
    $self->{leaf} = $leaf ? 1 : 0;
}

# Cantidad de claves almacenadas actualmente.
sub key_count {
    my ($self) = @_;
    return scalar(@{$self->{keys}});
}

# Cantidad de hijos almacenados actualmente.
sub child_count {
    my ($self) = @_;
    return scalar(@{$self->{children}});
}

# Inserta una clave en posicion exacta desplazando a la derecha.
sub insert_key_at {
    my ($self, $index, $key) = @_;
    splice(@{$self->{keys}}, $index, 0, $key);
}

# Elimina y retorna una clave por indice.
sub remove_key_at {
    my ($self, $index) = @_;
    return splice(@{$self->{keys}}, $index, 1);
}

# Inserta un hijo en posicion exacta desplazando a la derecha.
sub insert_child_at {
    my ($self, $index, $child) = @_;
    splice(@{$self->{children}}, $index, 0, $child);
}

# Elimina y retorna un hijo por indice.
sub remove_child_at {
    my ($self, $index) = @_;
    return splice(@{$self->{children}}, $index, 1);
}

# Representacion textual util para debug y busqueda.
sub to_string {
    my ($self) = @_;
    my $tipo = $self->is_leaf() ? "Hoja" : "Interno";
    my $keys = join(", ", @{$self->{keys}});
    return "NodoB[tipo=$tipo, keys=[$keys]]\n";
}

1;
