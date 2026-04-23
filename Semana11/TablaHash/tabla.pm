package TablaHash::tabla;

use strict;
use warnings;

# ---------------------------------------------------------------
# TABLA HASH - Directorio del Personal por Tipo
#
# Clave  : tipo_usuario  (TIPO-01 .. TIPO-04)
# Valor  : lista enlazada de todos los profesionales de ese tipo
# Colision: encadenamiento (chaining) - cada bucket es un arreglo
# ---------------------------------------------------------------

sub new {
    my ($class, %args) = @_;
    my $size = $args{size} || 4;

    my $self = {
        size       => $size,
        buckets    => [],
        total      => 0,
        colisiones => 0,
    };

    $self->{buckets}[$_] = [] for 0 .. $size - 1;

    bless $self, $class;
    return $self;
}


# Funcion hash: extrae el numero al final de la clave % size
#
#   hash("TIPO-01") = (1 - 1) % size = 0
#   hash("TIPO-02") = (2 - 1) % size = 1
#   hash("TIPO-03") = (3 - 1) % size = 2
#   hash("TIPO-04") = (4 - 1) % size = 3
#
# Con size=4  ->  hash perfecto, 0 colisiones garantizadas
# Con size=3  ->  TIPO-01 y TIPO-04 colisionan en bucket[0]
#
# Fallback para claves que no sigan el patron TIPO-XX:
#   suma de ASCII % size  (hash general)
sub hash_func {
    my ($self, $key) = @_;
    if ($key =~ /(\d+)$/) {
        return ($1 - 1) % $self->{size};
    }
    my $sum = 0;
    $sum += ord($_) for split //, $key;
    return $sum % $self->{size};
}


sub insertar {
    my ($self, $tipo, $numero_colegio, $nombre, $departamento, $especialidad) = @_;

    my $idx = $self->hash_func($tipo);

    # Verificar duplicado
    for my $entry (@{ $self->{buckets}[$idx] }) {
        if ($entry->{numero_colegio} eq $numero_colegio) {
            print "  [AVISO] $numero_colegio ya existe en la tabla. No se inserto duplicado.\n";
            return 0;
        }
    }

    # Detectar colision real: distinto tipo apuntando al mismo bucket
    if (@{ $self->{buckets}[$idx] } > 0) {
        my $tipo_existente = $self->{buckets}[$idx][0]{tipo};
        if ($tipo_existente ne $tipo) {
            $self->{colisiones}++;
            printf("  [COLISION] '%s' colisiona con '%s' en bucket[%d] -> se encadena\n",
                   $tipo, $tipo_existente, $idx);
        }
    }

    push @{ $self->{buckets}[$idx] }, {
        tipo           => $tipo,
        numero_colegio => $numero_colegio,
        nombre         => $nombre,
        departamento   => $departamento,
        especialidad   => $especialidad,
    };

    $self->{total}++;
    printf("  [INSERT] %-12s  bucket[%d]  tipo: %s\n",
           $numero_colegio, $idx, $tipo);
    return 1;
}


sub buscar_por_tipo {
    my ($self, $tipo) = @_;
    my $idx = $self->hash_func($tipo);
    return grep { $_->{tipo} eq $tipo } @{ $self->{buckets}[$idx] };
}


sub eliminar {
    my ($self, $tipo, $numero_colegio) = @_;
    my $idx   = $self->hash_func($tipo);
    my $antes = scalar @{ $self->{buckets}[$idx] };

    $self->{buckets}[$idx] = [
        grep { $_->{numero_colegio} ne $numero_colegio }
        @{ $self->{buckets}[$idx] }
    ];

    if (scalar @{ $self->{buckets}[$idx] } < $antes) {
        $self->{total}--;
        printf("  [DELETE] %s eliminado del bucket[%d]\n", $numero_colegio, $idx);
        return 1;
    }

    printf("  [AVISO] %s no encontrado en tipo '%s'.\n", $numero_colegio, $tipo);
    return 0;
}


sub get_factor_carga { return $_[0]->{total} / $_[0]->{size}; }
sub get_colisiones   { return $_[0]->{colisiones}; }
sub get_total        { return $_[0]->{total}; }
sub get_size         { return $_[0]->{size}; }
sub get_buckets      { return $_[0]->{buckets}; }


sub imprimir_estado {
    my ($self) = @_;
    printf("  Tamano tabla    : %d buckets\n",  $self->{size});
    printf("  Total elementos : %d\n",           $self->{total});
    printf("  Colisiones      : %d\n",           $self->{colisiones});
    printf("  Factor de carga : %.2f  (%.0f%% ocupado)\n",
           $self->get_factor_carga(),
           $self->get_factor_carga() * 100);

    print "\n";
    my $ocupados = 0;
    for my $i (0 .. $self->{size} - 1) {
        my $bucket = $self->{buckets}[$i];
        if (@$bucket) {
            $ocupados++;
            printf("  Bucket[%2d] (%d entrada%s): ", $i,
                   scalar @$bucket, @$bucket == 1 ? '' : 's');
            my @cadena = map {
                sprintf("[%s | %s | %s]",
                    $_->{tipo}, $_->{numero_colegio}, $_->{nombre})
            } @$bucket;
            print join(" -> ", @cadena) . " -> NULL\n";
        } else {
            printf("  Bucket[%2d] (vacio)\n", $i);
        }
    }
    printf("\n  Slots ocupados  : %d / %d\n", $ocupados, $self->{size});
}

1;
