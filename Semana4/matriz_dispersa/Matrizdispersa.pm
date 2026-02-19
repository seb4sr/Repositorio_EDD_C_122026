package matriz_dispersa::MatrizDispersa;

use strict;
use warnings;

use matriz_dispersa::NodoCabecera;
use matriz_dispersa::NodoDato;

use constant NodoCabecera => 'matriz_dispersa::NodoCabecera';
use constant NodoDato     => 'matriz_dispersa::NodoDato';

# CONSTRUCTOR
# La matriz empieza completamente vacia:
#   - lista_filas: cabecera centinela de la lista de filas (undef = sin filas)
#   - lista_cols:  cabecera centinela de la lista de columnas
#   - num_filas, num_cols: dimensiones logicas de la matriz
sub new {
    my ($class, $num_filas, $num_cols) = @_;

    my $self = {
        lista_filas => undef,   # primer NodoCabecera de filas
        lista_cols  => undef,   # primer NodoCabecera de columnas
        num_filas   => $num_filas,
        num_cols    => $num_cols,
        total_datos => 0,       # contador de elementos no-cero
    };

    bless $self, $class;
    return $self;
}

# METODOS AUXILIARES PRIVADOS

#               _buscar_cab_fila($fila_idx)
# Recorre la lista de cabeceras de filas buscando la que corresponde
# al indice dado. Retorna el NodoCabecera si existe, undef si no.
#
# La lista de cabeceras esta ordenada por indice para eficiencia.
#
sub _buscar_cab_fila {
    my ($self, $fila_idx) = @_;

    my $actual = $self->{lista_filas};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $fila_idx);
       
        # si el label ya supero el indice buscado, no existe
        last if ($actual->get_label() > $fila_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

#                _buscar_cab_col($col_idx)
# Igual que _buscar_cab_fila pero para columnas.
sub _buscar_cab_col {
    my ($self, $col_idx) = @_;

    my $actual = $self->{lista_cols};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $col_idx);
        last if ($actual->get_label() > $col_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

#               _obtener_o_crear_cab_fila($fila_idx)
# Busca la cabecera de la fila indicada. Si no existe, la CREA 
# inserta en la lista de cabeceras de filas (manteniendo orden).
# Retorna la cabecera (existente o nueva).
sub _obtener_o_crear_cab_fila {
    my ($self, $fila_idx) = @_;

    # CASO 1 la lista de filas esta vacia
    if (!defined $self->{lista_filas}) {
        my $nueva = NodoCabecera->new($fila_idx);
        $self->{lista_filas} = $nueva;
        return $nueva;
    }

    # CASO 2 debe ir antes de la primera cabecera
    if ($self->{lista_filas}->get_label() > $fila_idx) {
        my $nueva = NodoCabecera->new($fila_idx);
        $nueva->set_next($self->{lista_filas});
        $self->{lista_filas} = $nueva;
        return $nueva;
    }

    # CASO 3 ya existe
    if ($self->{lista_filas}->get_label() == $fila_idx) {
        return $self->{lista_filas};
    }

    # CASO 4 buscar el lugar correcto (lista ordenada)
    my $anterior = $self->{lista_filas};
    my $actual   = $anterior->get_next();

    while (defined $actual) {
        if ($actual->get_label() == $fila_idx) {
            return $actual;   # ya existe
        }
        if ($actual->get_label() > $fila_idx) {
            # insertar entre anterior y actual
            my $nueva = NodoCabecera->new($fila_idx);
            $nueva->set_next($actual);
            $anterior->set_next($nueva);
            return $nueva;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }

    # CASO 5 insertar al final de la lista
    my $nueva = NodoCabecera->new($fila_idx);
    $anterior->set_next($nueva);
    return $nueva;
}

# _obtener_o_crear_cab_col($col_idx)
# igual que para filas pero para columnas.
sub _obtener_o_crear_cab_col {
    my ($self, $col_idx) = @_;

    if (!defined $self->{lista_cols}) {
        my $nueva = NodoCabecera->new($col_idx);
        $self->{lista_cols} = $nueva;
        return $nueva;
    }

    if ($self->{lista_cols}->get_label() > $col_idx) {
        my $nueva = NodoCabecera->new($col_idx);
        $nueva->set_next($self->{lista_cols});
        $self->{lista_cols} = $nueva;
        return $nueva;
    }

    if ($self->{lista_cols}->get_label() == $col_idx) {
        return $self->{lista_cols};
    }

    my $anterior = $self->{lista_cols};
    my $actual   = $anterior->get_next();

    while (defined $actual) {
        if ($actual->get_label() == $col_idx) {
            return $actual;
        }
        if ($actual->get_label() > $col_idx) {
            my $nueva = NodoCabecera->new($col_idx);
            $nueva->set_next($actual);
            $anterior->set_next($nueva);
            return $nueva;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }

    my $nueva = NodoCabecera->new($col_idx);
    $anterior->set_next($nueva);
    return $nueva;
}

#                         INSERTAR
# insertar($fila, $col, $valor)
# Agrega un nuevo elemento no-cero en la posicion ($fila, $col).
# PASOS INTERNOS:
#   1. Validar que la posicion este dentro de los limites.
#   2. Obtener (o crear) la cabecera de fila.
#   3. Obtener (o crear) la cabecera de columna.
#   4. Crear el NodoDato.
#   5. Enlazarlo horizontalmente en la lista de la fila.
#   6. Enlazarlo verticalmente en la lista de la columna.

# COMO SE INSERTA EN LA FILA (paso 5):
#   Recorremos desde cab_fila->right hacia adelante.
#   Los nodos estan ordenados por col (columna ascendente).
#   Insertamos antes del primer nodo cuya columna sea mayor.

# COMO SE INSERTA EN LA COLUMNA (paso 6):
#
#   Identico pero recorremos cab_col->down y ordenamos por fila.
#
sub insertar {
    my ($self, $fila, $col, $valor) = @_;

    # Validacion: solo rechazar indices negativos (-)
    if ($fila < 0 || $col < 0) {
        print " [ERROR] Indices negativos no permitidos: ($fila,$col)\n";
        return;
    }

    # Expansion automatica de dimensiones
    my $expandio = 0;
    if ($fila >= $self->{num_filas}) {
        my $old = $self->{num_filas};
        $self->{num_filas} = $fila + 1;
        print "redimensiomando matriz Filas: $old -> $self->{num_filas}\n";
        $expandio = 1;
    }
    if ($col >= $self->{num_cols}) {
        my $old = $self->{num_cols};
        $self->{num_cols} = $col + 1;
        print " redimensionado matriz Columnas: $old -> $self->{num_cols}\n";
        $expandio = 1;
    }

    # Obtener o crear las cabeceras
    my $cab_fila = $self->_obtener_o_crear_cab_fila($fila);
    my $cab_col  = $self->_obtener_o_crear_cab_col($col);

    # Verificar si ya existe un dato en esa posicion
    my $existente = $self->obtener($fila, $col);
    if (defined $existente) {
        # Solo actualizamos el valor, no creamos un nuevo nodo
        $existente->set_valor($valor);
        print " [UPDATE] ($fila,$col) actualizado.\n";
        return;
    }

    # Crear el nuevo NodoDato
    my $nuevo = NodoDato->new($fila, $col, $valor);

    # PASO 5: Enlazar horizontalmente (en la fila)
    # Encontrar la posicion correcta dentro de la fila (orden por col)
    #  Caso A: fila vacia  --> cab_fila->right = nuevo
    #  Caso B: insertar al inicio de la fila (nuevo->col < primero->col)
    #  Caso C: insertar en medio o al final

    if (!defined $cab_fila->get_right()) {
        # Caso A: primera entrada en esta fila
        $cab_fila->set_right($nuevo);
        # nuevo->right y nuevo->left quedan undef (es el unico)
    }
    elsif ($cab_fila->get_right()->get_col() > $col) {
        # Caso B: va antes del primer nodo de la fila
        my $primero = $cab_fila->get_right();
        $nuevo->set_right($primero);
        $primero->set_left($nuevo);
        $cab_fila->set_right($nuevo);
    }
    else {
        # Caso C: recorrer para encontrar la posicion
        my $anterior = $cab_fila->get_right();
        my $actual   = $anterior->get_right();

        while (defined $actual && $actual->get_col() < $col) {
            $anterior = $actual;
            $actual   = $actual->get_right();
        }
        # Insertar entre anterior y actual
        $nuevo->set_right($actual);
        $nuevo->set_left($anterior);
        $anterior->set_right($nuevo);
        if (defined $actual) {
            $actual->set_left($nuevo);
        }
    }

    # PASO 6: Enlazar verticalmente (en la columna)
    # Identico al paso 5, pero usando down/up y ordenando por fila.

    if (!defined $cab_col->get_down()) {
        # Primera entrada en esta columna
        $cab_col->set_down($nuevo);
    }
    elsif ($cab_col->get_down()->get_fila() > $fila) {
        # Va antes del primer nodo de la columna
        my $primero = $cab_col->get_down();
        $nuevo->set_down($primero);
        $primero->set_up($nuevo);
        $cab_col->set_down($nuevo);
    }
    else {
        # Recorrer para encontrar la posicion
        my $anterior = $cab_col->get_down();
        my $actual   = $anterior->get_down();

        while (defined $actual && $actual->get_fila() < $fila) {
            $anterior = $actual;
            $actual   = $actual->get_down();
        }
        $nuevo->set_down($actual);
        $nuevo->set_up($anterior);
        $anterior->set_down($nuevo);
        if (defined $actual) {
            $actual->set_up($nuevo);
        }
    }

    $self->{total_datos}++;
    print " [INSERT] ($fila,$col) insertado.\n";
}

# OBTENER
# obtener($fila, $col)
# Busca y retorna el NodoDato en la posicion ($fila, $col).

# COMO FUNCIONA:
#   1. Buscamos la cabecera de la fila.
#   2. Recorremos los nodos de esa fila (hacia la derecha) buscando col.
#   3. Como estan ordenados por col, paramos si superamos el indice.
sub obtener {
    my ($self, $fila, $col) = @_;

    my $cab_fila = $self->_buscar_cab_fila($fila);
    return undef unless defined $cab_fila;

    my $actual = $cab_fila->get_right();
    while (defined $actual) {
        return $actual if ($actual->get_col() == $col);
        last           if ($actual->get_col() >  $col);   # ya lo pasamos
        $actual = $actual->get_right();
    }
    return undef;
}

# BORRAR
# borrar($fila, $col)
# Elimina el NodoDato en ($fila, $col) desconectandolo de su fila y columna.

# PASOS:
#   1. Buscar el nodo con obtener().
#   2. Desconectarlo de la lista horizontal (fila):
#        left->right = nodo->right
#        right->left = nodo->left
#   3. Desconectarlo de la lista vertical (columna):
#        up->down = nodo->down
#        down->up = nodo->up
#   4. Si la fila queda vacia, eliminar su cabecera.
#   5. Si la columna queda vacia, eliminar su cabecera.
sub borrar {
    my ($self, $fila, $col) = @_;

    my $nodo = $self->obtener($fila, $col);
    unless (defined $nodo) {
        print " [WARN] No existe elemento en ($fila,$col). Nada que borrar.\n";
        return;
    }

    my $cab_fila = $self->_buscar_cab_fila($fila);
    my $cab_col  = $self->_buscar_cab_col($col);

    # Desconecte horizontal (fila)
    my $izq = $nodo->get_left();
    my $der = $nodo->get_right();

    if (defined $izq) {
        $izq->set_right($der);
    } else {
        # era el primero de la fila, la cabecera debe apuntar al siguiente
        $cab_fila->set_right($der);
    }

    if (defined $der) {
        $der->set_left($izq);
    }

    # Desconecte vertical (columna)
    my $arriba = $nodo->get_up();
    my $abajo  = $nodo->get_down();

    if (defined $arriba) {
        $arriba->set_down($abajo);
    } else {
        # era el primero de la columna
        $cab_col->set_down($abajo);
    }

    if (defined $abajo) {
        $abajo->set_up($arriba);
    }

    $self->{total_datos}--;

    # Limpiar cabeceras vacias
    # Si la fila quedo vacia (cab_fila->right == undef), eliminamos la cabecera
    unless (defined $cab_fila->get_right()) {
        $self->_eliminar_cab_fila($fila);
    }
    # Si la columna quedo vacia, eliminamos la cabecera
    unless (defined $cab_col->get_down()) {
        $self->_eliminar_cab_col($col);
    }

    print " [DELETE] ($fila,$col) eliminado.\n";
}

# _eliminar_cab_fila($fila_idx)
# Quita el NodoCabecera de esa fila de la lista de cabeceras de filas.
sub _eliminar_cab_fila {
    my ($self, $fila_idx) = @_;

    if (!defined $self->{lista_filas}) { return; }

    if ($self->{lista_filas}->get_label() == $fila_idx) {
        $self->{lista_filas} = $self->{lista_filas}->get_next();
        return;
    }

    my $anterior = $self->{lista_filas};
    my $actual   = $anterior->get_next();
    while (defined $actual) {
        if ($actual->get_label() == $fila_idx) {
            $anterior->set_next($actual->get_next());
            return;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }
}

# _eliminar_cab_col($col_idx)
# Quita el NodoCabecera de esa columna de la lista de cabeceras de columnas.
sub _eliminar_cab_col {
    my ($self, $col_idx) = @_;

    if (!defined $self->{lista_cols}) { return; }

    if ($self->{lista_cols}->get_label() == $col_idx) {
        $self->{lista_cols} = $self->{lista_cols}->get_next();
        return;
    }

    my $anterior = $self->{lista_cols};
    my $actual   = $anterior->get_next();
    while (defined $actual) {
        if ($actual->get_label() == $col_idx) {
            $anterior->set_next($actual->get_next());
            return;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }
}

# RECORRIDOS

#                                   imprimir_lista()
# Recorre TODAS las filas de la lista de cabeceras de filas.
# Por cada fila, recorre todos sus NodoDato hacia la derecha.
# Muestra: (fila, col) = valor
sub imprimir_lista {
    my ($self) = @_;

    print "\n Elementos no-cero de la matriz ($self->{num_filas}x$self->{num_cols}) ---\n";
    print "    Total elementos: $self->{total_datos}\n\n";

    if (!defined $self->{lista_filas}) {
        print "    (matriz vacia)\n";
        print "----------------------------\n\n";
        return;
    }

    # Recorrer la lista de cabeceras de filas
    my $cab_fila = $self->{lista_filas};
    while (defined $cab_fila) {
        my $f = $cab_fila->get_label();
        print "  Fila $f:\n";

        # Recorrer los nodos de esta fila
        my $nodo = $cab_fila->get_right();
        while (defined $nodo) {
            my $c = $nodo->get_col();
            my $v = _valor_a_string($nodo->get_valor());
            print "    ($f, $c) = $v\n";
            $nodo = $nodo->get_right();
        }

        $cab_fila = $cab_fila->get_next();
    }
    print "----------------------------------------\n\n";
}

# imprimir_por_columnas()
# Igual que imprimir_lista pero recorriendo por columnas (down).
sub imprimir_por_columnas {
    my ($self) = @_;

    print "\n--- Recorrido por COLUMNAS -\n\n";

    if (!defined $self->{lista_cols}) {
        print "    (matriz vacia)\n\n";
        return;
    }

    my $cab_col = $self->{lista_cols};
    while (defined $cab_col) {
        my $c = $cab_col->get_label();
        print "  Columna $c:\n";

        my $nodo = $cab_col->get_down();
        while (defined $nodo) {
            my $f = $nodo->get_fila();
            my $v = _valor_a_string($nodo->get_valor());
            print "    (fila $f, col $c) = $v\n";
            $nodo = $nodo->get_down();
        }

        $cab_col = $cab_col->get_next();
    }
    print "--------------------------\n\n";
}

# imprimir_matriz()
# Imprime la matriz completa en formato visual con ceros.
# Para cada posicion (i,j) llama a obtener(i,j).
# Si existe, imprime el valor; si no, imprime " . " (cero visual).
sub imprimir_matriz {
    my ($self) = @_;

    print "\n--  MATRiz ($self->{num_filas}x$self->{num_cols}) ---\n\n";
    print "     ";
    for my $c (0 .. $self->{num_cols} - 1) {
        printf("  C%-2d", $c);
    }
    print "\n";
    print "     " . ("-----" x $self->{num_cols}) . "\n";

    for my $f (0 .. $self->{num_filas} - 1) {
        printf("F%-3d |", $f);
        for my $c (0 .. $self->{num_cols} - 1) {
            my $nodo = $self->obtener($f, $c);
            if (defined $nodo) {
                my $v = $nodo->get_valor();
                if (ref($v)) {
                    printf("  %-4s", "***");  # objeto
                } else {
                    printf("  %-4s", $v);
                }
            } else {
                printf("  %-4s", ".");        # cero
            }
        }
        print "\n";
    }
    print "\n";
}

# _valor_a_string($valor)
# Convierte un valor (escalar u objeto) a string para impresion.
sub _valor_a_string {
    my ($v) = @_;
    return defined($v) ? (ref($v) ? ref($v) . "(obj)" : "$v") : "undef";
}

# es_vacia()
sub es_vacia {
    my ($self) = @_;
    return $self->{total_datos} == 0 ? 1 : 0;
}

# total_elementos() --> cuantos no-ceros hay
sub total_elementos {
    my ($self) = @_;
    return $self->{total_datos};
}

1;