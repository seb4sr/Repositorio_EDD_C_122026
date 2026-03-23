package btree::btree;

use strict;
use warnings;

use btree::nodo;

use constant Nodo => 'btree::nodo';

# Convencion usada:
# - Orden M = maximo numero de hijos por nodo.
# - Maximo de claves por nodo = M - 1.
# - Minimo de claves (nodos no raiz) = (M/2) - 1.
# - Minimo de hijos  (nodos no raiz) = (M/2).
# Nota: para usar esta forma directa, M debe ser par.
use constant M => 4;
die "El orden M debe ser par para aplicar reglas directas M/2." if (M % 2) != 0;
use constant MAX_CHILDREN => M;
use constant MAX_KEYS => M - 1;
use constant MIN_CHILDREN => int(M / 2);
use constant MIN_KEYS => MIN_CHILDREN - 1;
use constant SPLIT_INDEX => MIN_KEYS;

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

sub get_order {
    return M;
}

sub get_max_children {
    return MAX_CHILDREN;
}

sub get_max_keys {
    return MAX_KEYS;
}

sub get_min_keys_non_root {
    return MIN_KEYS;
}

sub insertar {
    my ($self, $key) = @_;

    if (!defined($key)) {
        print "Advertencia: no se puede insertar valor indefinido.\n";
        return;
    }

    if ($self->contiene($key)) {
        print "Advertencia: El valor '$key' ya existe en el arbol B. No se insertan duplicados.\n";
        return;
    }

    if ($self->is_empty()) {
        my $raiz = Nodo->new(1);
        push(@{$raiz->get_keys()}, $key);
        $self->{root} = $raiz;
        $self->{size} = 1;
        print "Insertado '$key' como RAIZ del arbol B.\n";
        return;
    }

    my $r = $self->{root};
    if ($r->key_count() == MAX_KEYS) {
        print "La raiz esta llena. Se divide antes de insertar '$key'.\n";
        my $s = Nodo->new(0);
        push(@{$s->get_children()}, $r);
        $self->_split_child($s, 0);
        $self->{root} = $s;
    }

    $self->_insert_non_full($self->{root}, $key);
    $self->{size}++;
}

sub _insert_non_full {
    my ($self, $node, $key) = @_;

    my $keys = $node->get_keys();
    my $i = scalar(@$keys) - 1;

    if ($node->is_leaf()) {
        push(@$keys, undef);
        while ($i >= 0 && $key < $keys->[$i]) {
            $keys->[$i + 1] = $keys->[$i];
            $i--;
        }
        $keys->[$i + 1] = $key;
        print "Insertado '$key' en nodo hoja.\n";
        return;
    }

    while ($i >= 0 && $key < $keys->[$i]) {
        $i--;
    }
    $i++;

    my $children = $node->get_children();
    my $child = $children->[$i];

    if ($child->key_count() == MAX_KEYS) {
        print "Hijo en indice $i lleno. Se divide antes de bajar '$key'.\n";
        $self->_split_child($node, $i);

        my $new_keys = $node->get_keys();
        if ($key > $new_keys->[$i]) {
            $i++;
        }
    }

    $self->_insert_non_full($node->get_children()->[$i], $key);
}

sub _split_child {
    my ($self, $parent, $i) = @_;

    my $children = $parent->get_children();
    my $y = $children->[$i];
    my $z = Nodo->new($y->is_leaf());

    my $y_keys = $y->get_keys();
    my $median = $y_keys->[SPLIT_INDEX];

    my @left_keys  = @$y_keys[0 .. SPLIT_INDEX - 1];
    my @right_keys = @$y_keys[SPLIT_INDEX + 1 .. MAX_KEYS - 1];

    $y->set_keys(\@left_keys);
    $z->set_keys(\@right_keys);

    if (!$y->is_leaf()) {
        my $y_children = $y->get_children();
        my @left_children  = @$y_children[0 .. SPLIT_INDEX];     
        my @right_children = @$y_children[SPLIT_INDEX + 1 .. MAX_CHILDREN - 1];
        $y->set_children(\@left_children);
        $z->set_children(\@right_children);
    }

    $parent->insert_key_at($i, $median);
    $parent->insert_child_at($i + 1, $z);

    print "Division de nodo: sube mediana '$median' al padre.\n";
}

sub contiene {
    my ($self, $key) = @_;
    return defined($self->buscar($key)) ? 1 : 0;
}

sub buscar {
    my ($self, $key) = @_;

    if ($self->is_empty()) {
        print "El arbol B esta vacio.\n";
        return undef;
    }

    return $self->_buscar_recursivo($self->{root}, $key);
}

sub _buscar_recursivo {
    my ($self, $node, $key) = @_;

    my $keys = $node->get_keys();
    my $i = 0;

    while ($i < scalar(@$keys) && $key > $keys->[$i]) {
        $i++;
    }

    if ($i < scalar(@$keys) && $key == $keys->[$i]) {
        return $node;
    }

    if ($node->is_leaf()) {
        return undef;
    }

    return $self->_buscar_recursivo($node->get_children()->[$i], $key);
}

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
    my ($self, $node) = @_;
    return unless defined($node);

    my $keys = $node->get_keys();
    my $children = $node->get_children();
    my $n = scalar(@$keys);

    for (my $i = 0; $i < $n; $i++) {
        if (!$node->is_leaf()) {
            $self->_inorden_recursivo($children->[$i]);
        }
        print $keys->[$i] . " ";
    }

    if (!$node->is_leaf()) {
        $self->_inorden_recursivo($children->[$n]);
    }
}

sub encontrar_minimo {
    my ($self) = @_;

    if ($self->is_empty()) {
        print "El arbol B esta vacio.\n";
        return undef;
    }

    my $node = $self->{root};
    while (!$node->is_leaf()) {
        $node = $node->get_children()->[0];
    }
    return $node->get_keys()->[0];
}

sub encontrar_maximo {
    my ($self) = @_;

    if ($self->is_empty()) {
        print "El arbol B esta vacio.\n";
        return undef;
    }

    my $node = $self->{root};
    while (!$node->is_leaf()) {
        my $ult = $node->child_count() - 1;
        $node = $node->get_children()->[$ult];
    }

    my $ult_key = $node->key_count() - 1;
    return $node->get_keys()->[$ult_key];
}

sub imprimir_arbol {
    my ($self) = @_;

    print "\n=== Estructura del Arbol B (Orden 4) ===\n";
    if ($self->is_empty()) {
        print "(arbol vacio)\n";
        print "=========================================\n\n";
        return;
    }

    $self->_imprimir_recursivo($self->{root}, 0);
    print "=========================================\n\n";
}

sub _imprimir_recursivo {
    my ($self, $node, $nivel) = @_;
    return unless defined($node);

    my $indent = "    " x $nivel;
    my $tipo = $node->is_leaf() ? "HOJA" : "INTERNO";
    my $keys_txt = join(", ", @{$node->get_keys()});
    print $indent . "[$tipo] keys: { $keys_txt }\n";

    if (!$node->is_leaf()) {
        foreach my $child (@{$node->get_children()}) {
            $self->_imprimir_recursivo($child, $nivel + 1);
        }
    }
}

sub validar_propiedades {
    my ($self) = @_;

    if ($self->is_empty()) {
        return (1, "Arbol vacio (valido).");
    }

    my @errores;
    my $leaf_level = undef;

    $self->_validar_nodo(
        $self->{root},
        1,
        0,
        \$leaf_level,
        undef,
        undef,
        \@errores
    );

    if (@errores) {
        return (0, join("\n", @errores));
    }

    return (1, "El arbol cumple propiedades de Arbol B para M=" . M . ".");
}

sub _validar_nodo {
    my ($self, $node, $es_raiz, $nivel, $leaf_level_ref, $min, $max, $errores_ref) = @_;
    return unless defined($node);

    my $keys = $node->get_keys();
    my $n = scalar(@$keys);

    if ($n > MAX_KEYS) {
        push(@$errores_ref, "Nodo en nivel $nivel excede maximo de claves (" . MAX_KEYS . ").");
    }

    if (!$es_raiz && $n < MIN_KEYS) {
        push(@$errores_ref, "Nodo no raiz en nivel $nivel tiene menos de " . MIN_KEYS . " claves.");
    }

    for (my $i = 0; $i < $n; $i++) {
        if ($i > 0 && $keys->[$i - 1] >= $keys->[$i]) {
            push(@$errores_ref, "Claves no ordenadas estrictamente en nivel $nivel.");
        }

        if (defined($min) && $keys->[$i] <= $min) {
            push(@$errores_ref, "Clave $keys->[$i] viola limite inferior en nivel $nivel.");
        }

        if (defined($max) && $keys->[$i] >= $max) {
            push(@$errores_ref, "Clave $keys->[$i] viola limite superior en nivel $nivel.");
        }
    }

    if ($node->is_leaf()) {
        if (!defined($$leaf_level_ref)) {
            $$leaf_level_ref = $nivel;
        } elsif ($$leaf_level_ref != $nivel) {
            push(@$errores_ref, "No todas las hojas estan al mismo nivel (esperado $$leaf_level_ref, encontrado $nivel).");
        }
        return;
    }

    my $children = $node->get_children();
    my $c = scalar(@$children);

    if ($c != $n + 1) {
        push(@$errores_ref, "Nodo interno en nivel $nivel debe tener k+1 hijos para k claves.");
    }

    if ($es_raiz && !$node->is_leaf() && $c < 2) {
        push(@$errores_ref, "La raiz no hoja debe tener al menos 2 hijos.");
    }

    if ($c > MAX_CHILDREN) {
        push(@$errores_ref, "Nodo interno en nivel $nivel excede maximo de hijos (" . MAX_CHILDREN . ").");
    }

    if (!$es_raiz && $c < MIN_CHILDREN) {
        push(@$errores_ref, "Nodo interno no raiz en nivel $nivel tiene menos de " . MIN_CHILDREN . " hijos.");
    }

    for (my $i = 0; $i < $c; $i++) {
        my $child = $children->[$i];
        my ($child_min, $child_max) = ($min, $max);

        if ($i == 0) {
            $child_max = $keys->[0] if $n > 0;
        } elsif ($i == $c - 1) {
            $child_min = $keys->[$n - 1] if $n > 0;
        } else {
            $child_min = $keys->[$i - 1];
            $child_max = $keys->[$i];
        }

        $self->_validar_nodo(
            $child,
            0,
            $nivel + 1,
            $leaf_level_ref,
            $child_min,
            $child_max,
            $errores_ref
        );
    }
}

1;
