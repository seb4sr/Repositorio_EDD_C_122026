package avl::avl;

use strict;
use warnings;

use avl::nodo;

use constant Nodo => 'avl::nodo';

sub new {
    my ($class) = @_;
    my $self = {
        root => undef,
        size => 0,
    };
    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined($self->{root}) ? 1 : 0;
}

sub get_size {
    my ($self) = @_;
    return $self->{size};
}

# ---------------------------------------------------------------
# UTILIDADES DE ALTURA Y BALANCE
# ---------------------------------------------------------------

sub _get_height {
    my ($self, $nodo) = @_;
    return defined($nodo) ? $nodo->get_height() : 0;
}

sub _update_height {
    my ($self, $nodo) = @_;
    return unless defined($nodo);
    my $h_izq = $self->_get_height($nodo->get_left());
    my $h_der = $self->_get_height($nodo->get_right());
    my $nueva_altura = 1 + ($h_izq > $h_der ? $h_izq : $h_der);
    $nodo->set_height($nueva_altura);
}

sub _get_balance {
    my ($self, $nodo) = @_;
    return 0 unless defined($nodo);
    return $self->_get_height($nodo->get_left()) - $self->_get_height($nodo->get_right());
}

# ---------------------------------------------------------------
# ROTACIONES
# ---------------------------------------------------------------

#   Rotacion simple a la DERECHA (caso LL)
#
#       y                x
#      / \              / \
#     x   T3    =>    T1   y
#    / \                  / \
#   T1  T2              T2  T3
#
sub _rotar_derecha {
    my ($self, $y) = @_;

    my $x  = $y->get_left();
    my $T2 = $x->get_right();

    $x->set_right($y);
    $y->set_left($T2);

    $self->_update_height($y);
    $self->_update_height($x);

    my $val_y = $y->get_data();
    my $val_x = $x->get_data();
    print "  [Rotacion DERECHA] Nodo '$val_y' sube a la derecha de '$val_x'.\n";

    return $x;
}

#   Rotacion simple a la IZQUIERDA (caso RR)
#
#     x                  y
#    / \                / \
#   T1   y    =>       x   T3
#       / \           / \
#      T2  T3        T1  T2
#
sub _rotar_izquierda {
    my ($self, $x) = @_;

    my $y  = $x->get_right();
    my $T2 = $y->get_left();

    $y->set_left($x);
    $x->set_right($T2);

    $self->_update_height($x);
    $self->_update_height($y);

    my $val_x = $x->get_data();
    my $val_y = $y->get_data();
    print "  [Rotacion IZQUIERDA] Nodo '$val_x' sube a la izquierda de '$val_y'.\n";

    return $y;
}

# Aplica la rotacion correcta segun el factor de balance
sub _balancear {
    my ($self, $nodo) = @_;

    $self->_update_height($nodo);
    my $balance = $self->_get_balance($nodo);
    my $valor   = $nodo->get_data();

    # Caso LL: desbalance a la izquierda con hijo izquierdo pesado
    if ($balance > 1 && $self->_get_balance($nodo->get_left()) >= 0) {
        print "  [Balance=$balance en '$valor'] Caso LL -> Rotacion simple DERECHA.\n";
        return $self->_rotar_derecha($nodo);
    }

    # Caso LR: desbalance a la izquierda con hijo derecho pesado
    if ($balance > 1 && $self->_get_balance($nodo->get_left()) < 0) {
        print "  [Balance=$balance en '$valor'] Caso LR -> Rotacion doble (IZQUIERDA + DERECHA).\n";
        $nodo->set_left($self->_rotar_izquierda($nodo->get_left()));
        return $self->_rotar_derecha($nodo);
    }

    # Caso RR: desbalance a la derecha con hijo derecho pesado
    if ($balance < -1 && $self->_get_balance($nodo->get_right()) <= 0) {
        print "  [Balance=$balance en '$valor'] Caso RR -> Rotacion simple IZQUIERDA.\n";
        return $self->_rotar_izquierda($nodo);
    }

    # Caso RL: desbalance a la derecha con hijo izquierdo pesado
    if ($balance < -1 && $self->_get_balance($nodo->get_right()) > 0) {
        print "  [Balance=$balance en '$valor'] Caso RL -> Rotacion doble (DERECHA + IZQUIERDA).\n";
        $nodo->set_right($self->_rotar_derecha($nodo->get_right()));
        return $self->_rotar_izquierda($nodo);
    }

    return $nodo;
}

# ---------------------------------------------------------------
# INSERTAR
# ---------------------------------------------------------------

sub insertar {
    my ($self, $data) = @_;

    my $era_vacio = $self->is_empty();
    my $insertado = 0;
    ($self->{root}, $insertado) = $self->_insertar_recursivo($self->{root}, $data);

    if ($insertado) {
        $self->{size}++;
        if ($era_vacio) {
            print "Insertado '$data' como RAIZ del arbol.\n";
        }
    }
}

sub _insertar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    # Caso base: posicion encontrada
    if (!defined($nodo_actual)) {
        my $nuevo = Nodo->new($data);
        return ($nuevo, 1);
    }

    my $valor_actual = $nodo_actual->get_data();
    my $insertado    = 0;

    if ($data < $valor_actual) {
        my $nuevo_izq;
        ($nuevo_izq, $insertado) = $self->_insertar_recursivo($nodo_actual->get_left(), $data);
        $nodo_actual->set_left($nuevo_izq);
        if ($insertado && defined($nodo_actual->get_left())) {
            print "Insertado '$data' a la IZQUIERDA de '$valor_actual'.\n";
        }
    } elsif ($data > $valor_actual) {
        my $nuevo_der;
        ($nuevo_der, $insertado) = $self->_insertar_recursivo($nodo_actual->get_right(), $data);
        $nodo_actual->set_right($nuevo_der);
        if ($insertado && defined($nodo_actual->get_right())) {
            print "Insertado '$data' a la DERECHA de '$valor_actual'.\n";
        }
    } else {
        print "Advertencia: El valor '$data' ya existe en el arbol. No se insertaron duplicados.\n";
        return ($nodo_actual, 0);
    }

    if ($insertado) {
        $nodo_actual = $self->_balancear($nodo_actual);
    }

    return ($nodo_actual, $insertado);
}

# ---------------------------------------------------------------
# BUSCAR
# ---------------------------------------------------------------

sub buscar {
    my ($self, $data) = @_;

    if ($self->is_empty()) {
        print "El arbol esta vacio. No hay nada que buscar.\n";
        return undef;
    }

    return $self->_buscar_recursivo($self->{root}, $data);
}

sub _buscar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    return undef unless defined($nodo_actual);

    my $valor_actual = $nodo_actual->get_data();

    if ($data == $valor_actual) {
        return $nodo_actual;
    } elsif ($data < $valor_actual) {
        return $self->_buscar_recursivo($nodo_actual->get_left(), $data);
    } else {
        return $self->_buscar_recursivo($nodo_actual->get_right(), $data);
    }
}

# ---------------------------------------------------------------
# ELIMINAR
# ---------------------------------------------------------------

sub eliminar {
    my ($self, $data) = @_;

    if ($self->is_empty()) {
        print "El arbol esta vacio. No hay nada que eliminar.\n";
        return;
    }

    my $existe = $self->buscar($data);
    if (!defined($existe)) {
        print "El valor '$data' no existe en el arbol.\n";
        return;
    }

    $self->{root} = $self->_eliminar_recursivo($self->{root}, $data);
    $self->{size}--;
    print "Valor '$data' eliminado exitosamente.\n";
}

sub _eliminar_recursivo {
    my ($self, $nodo_actual, $data) = @_;

    return undef unless defined($nodo_actual);

    my $valor_actual = $nodo_actual->get_data();

    if ($data < $valor_actual) {
        $nodo_actual->set_left(
            $self->_eliminar_recursivo($nodo_actual->get_left(), $data)
        );
    } elsif ($data > $valor_actual) {
        $nodo_actual->set_right(
            $self->_eliminar_recursivo($nodo_actual->get_right(), $data)
        );
    } else {
        if ($nodo_actual->es_hoja()) {
            print "Eliminando hoja con valor '$valor_actual'.\n";
            return undef;
        } elsif (!defined($nodo_actual->get_left())) {
            print "Eliminando nodo '$valor_actual' (solo tiene hijo derecho).\n";
            return $nodo_actual->get_right();
        } elsif (!defined($nodo_actual->get_right())) {
            print "Eliminando nodo '$valor_actual' (solo tiene hijo izquierdo).\n";
            return $nodo_actual->get_left();
        } else {
            print "Eliminando nodo '$valor_actual' (tiene dos hijos).\n";
            print "Buscando sucesor inorden en el subarbol derecho...\n";

            my $sucesor        = $self->_encontrar_minimo($nodo_actual->get_right());
            my $valor_sucesor  = $sucesor->get_data();

            print "Sucesor inorden encontrado: '$valor_sucesor'. Reemplazando...\n";

            $nodo_actual->set_data($valor_sucesor);
            $nodo_actual->set_right(
                $self->_eliminar_recursivo($nodo_actual->get_right(), $valor_sucesor)
            );
        }
    }

    return $self->_balancear($nodo_actual);
}

# ---------------------------------------------------------------
# MINIMO Y MAXIMO
# ---------------------------------------------------------------

sub _encontrar_minimo {
    my ($self, $nodo) = @_;
    return $nodo unless defined($nodo->get_left());
    return $self->_encontrar_minimo($nodo->get_left());
}

sub encontrar_minimo {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "El arbol esta vacio.\n";
        return undef;
    }
    return $self->_encontrar_minimo($self->{root})->get_data();
}

sub encontrar_maximo {
    my ($self) = @_;
    if ($self->is_empty()) {
        print "El arbol esta vacio.\n";
        return undef;
    }
    my $nodo = $self->{root};
    while (defined($nodo->get_right())) {
        $nodo = $nodo->get_right();
    }
    return $nodo->get_data();
}

# ---------------------------------------------------------------
# RECORRIDOS
# ---------------------------------------------------------------

sub recorrido_inorden {
    my ($self) = @_;
    print "Recorrido INORDEN (ascendente): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_inorden_recursivo($self->{root});
    print "\n";
}

sub _inorden_recursivo {
    my ($self, $nodo_actual) = @_;
    return unless defined($nodo_actual);
    $self->_inorden_recursivo($nodo_actual->get_left());
    print $nodo_actual->get_data() . " ";
    $self->_inorden_recursivo($nodo_actual->get_right());
}

sub recorrido_preorden {
    my ($self) = @_;
    print "Recorrido PREORDEN (raiz primero): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_preorden_recursivo($self->{root});
    print "\n";
}

sub _preorden_recursivo {
    my ($self, $nodo_actual) = @_;
    return unless defined($nodo_actual);
    print $nodo_actual->get_data() . " ";
    $self->_preorden_recursivo($nodo_actual->get_left());
    $self->_preorden_recursivo($nodo_actual->get_right());
}

sub recorrido_postorden {
    my ($self) = @_;
    print "Recorrido POSTORDEN (raiz al final): ";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        return;
    }
    $self->_postorden_recursivo($self->{root});
    print "\n";
}

sub _postorden_recursivo {
    my ($self, $nodo_actual) = @_;
    return unless defined($nodo_actual);
    $self->_postorden_recursivo($nodo_actual->get_left());
    $self->_postorden_recursivo($nodo_actual->get_right());
    print $nodo_actual->get_data() . " ";
}

# ---------------------------------------------------------------
# IMPRIMIR ARBOL (vista visual en consola)
# ---------------------------------------------------------------

sub imprimir_arbol {
    my ($self) = @_;
    print "\n=== Estructura del Arbol AVL ===\n";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
    } else {
        $self->_imprimir_recursivo($self->{root}, 0);
    }
    print "================================\n\n";
}

sub _imprimir_recursivo {
    my ($self, $nodo, $nivel) = @_;
    return unless defined($nodo);
    $self->_imprimir_recursivo($nodo->get_right(), $nivel + 1);
    my $indentacion = "    " x $nivel;
    my $balance     = $self->_get_balance($nodo);
    print $indentacion . "[" . $nodo->get_data() . " | h=" . $nodo->get_height() . " | bf=" . $balance . "]\n";
    $self->_imprimir_recursivo($nodo->get_left(), $nivel + 1);
}

1;
