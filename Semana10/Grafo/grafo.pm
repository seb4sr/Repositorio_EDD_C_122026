package grafo::grafo;


use strict;
use warnings;

use grafo::nodo;

sub new {
    my ($class) = @_;
    my $self = {
        nodos      => {},
        adyacencia => {},
        num_aristas => 0,
    };
    bless $self, $class;
    return $self;
}


sub agregar_nodo {
    my ($self, $id, $nombre, $departamento, $tipo) = @_;

    if (exists $self->{nodos}{$id}) {
        print "  Advertencia: El nodo '$id' ya existe. No se agrego duplicado.\n";
        return 0;
    }

    $self->{nodos}{$id}      = grafo::nodo->new($id, $nombre, $departamento, $tipo);
    $self->{adyacencia}{$id} = [];

    print "  Nodo agregado: " . $self->{nodos}{$id}->to_string() . "\n";
    return 1;
}


sub agregar_arista {
    my ($self, $id_a, $id_b) = @_;

    unless (exists $self->{nodos}{$id_a}) {
        print "  Error: El nodo '$id_a' no existe en el grafo.\n";
        return 0;
    }
    unless (exists $self->{nodos}{$id_b}) {
        print "  Error: El nodo '$id_b' no existe en el grafo.\n";
        return 0;
    }

    if ($id_a eq $id_b) {
        print "  Error: No se permiten bucles (arista de '$id_a' a si mismo).\n";
        return 0;
    }

    if ($self->son_vecinos($id_a, $id_b)) {
        print "  Advertencia: La arista '$id_a' -- '$id_b' ya existe.\n";
        return 0;
    }

    push @{ $self->{adyacencia}{$id_a} }, $id_b;
    push @{ $self->{adyacencia}{$id_b} }, $id_a;
    $self->{num_aristas}++;

    my $nombre_a = $self->{nodos}{$id_a}->get_nombre();
    my $nombre_b = $self->{nodos}{$id_b}->get_nombre();
    print "  Arista creada: $nombre_a ($id_a) <--> $nombre_b ($id_b)\n";
    return 1;
}


sub eliminar_arista {
    my ($self, $id_a, $id_b) = @_;

    unless ($self->son_vecinos($id_a, $id_b)) {
        print "  Advertencia: La arista '$id_a' -- '$id_b' no existe.\n";
        return 0;
    }

    $self->{adyacencia}{$id_a} = [ grep { $_ ne $id_b } @{ $self->{adyacencia}{$id_a} } ];
    $self->{adyacencia}{$id_b} = [ grep { $_ ne $id_a } @{ $self->{adyacencia}{$id_b} } ];
    $self->{num_aristas}--;

    print "  Arista eliminada: '$id_a' -- '$id_b'\n";
    return 1;
}


sub eliminar_nodo {
    my ($self, $id) = @_;

    unless (exists $self->{nodos}{$id}) {
        print "  Error: El nodo '$id' no existe.\n";
        return 0;
    }

    for my $vecino (@{ $self->{adyacencia}{$id} }) {
        $self->{adyacencia}{$vecino} = [ grep { $_ ne $id } @{ $self->{adyacencia}{$vecino} } ];
        $self->{num_aristas}--;
    }

    delete $self->{adyacencia}{$id};
    delete $self->{nodos}{$id};

    print "  Nodo '$id' eliminado junto con todas sus aristas.\n";
    return 1;
}


sub son_vecinos {
    my ($self, $id_a, $id_b) = @_;
    return 0 unless exists $self->{adyacencia}{$id_a}; 
    return grep { $_ eq $id_b } @{ $self->{adyacencia}{$id_a} };
}

sub grado {
    my ($self, $id) = @_;
    return 0 unless exists $self->{adyacencia}{$id};
    return scalar @{ $self->{adyacencia}{$id} };
}

sub get_num_nodos   { return scalar keys %{ $_[0]->{nodos} };  }
sub get_num_aristas { return $_[0]->{num_aristas};             }
sub is_empty        { return (scalar keys %{ $_[0]->{nodos} }) == 0; }
sub get_nodo        { return $_[0]->{nodos}{ $_[1] };          }
sub get_vecinos     { return @{ $_[0]->{adyacencia}{ $_[1] } // [] }; }
sub get_todos_ids   { return sort keys %{ $_[0]->{nodos} };    }


sub bfs {
    my ($self, $id_origen, $verbose) = @_;
    $verbose //= 1;

    unless (exists $self->{nodos}{$id_origen}) {
        print "  Error: El nodo origen '$id_origen' no existe.\n";
        return ();
    }

    my %visitado;
    my @cola    = ($id_origen);
    my @orden;

    $visitado{$id_origen} = 1;

    print "\n  BFS desde '$id_origen':\n" if $verbose;

    while (@cola) {
        my $actual = shift @cola;
        push @orden, $actual;

        if ($verbose) {
            my $nombre = $self->{nodos}{$actual}->get_nombre();
            print "    Visitando: $nombre ($actual)\n";
        }

        for my $vecino (sort @{ $self->{adyacencia}{$actual} }) {
            unless ($visitado{$vecino}) {
                $visitado{$vecino} = 1;
                push @cola, $vecino;
                print "      -> Encolando vecino: $vecino\n" if $verbose;
            }
        }
    }

    return @orden;
}


sub dfs {
    my ($self, $id_origen) = @_;

    unless (exists $self->{nodos}{$id_origen}) {
        print "  Error: El nodo origen '$id_origen' no existe.\n";
        return ();
    }

    my %visitado;
    my @orden;

    print "\n  DFS desde '$id_origen':\n";
    $self->_dfs_recursivo($id_origen, \%visitado, \@orden);

    return @orden;
}

sub _dfs_recursivo {
    my ($self, $id_actual, $visitado, $orden) = @_;

    $visitado->{$id_actual} = 1;
    push @$orden, $id_actual;

    my $nombre = $self->{nodos}{$id_actual}->get_nombre();
    print "    Visitando: $nombre ($id_actual)\n";

    for my $vecino (sort @{ $self->{adyacencia}{$id_actual} }) {
        unless ($visitado->{$vecino}) {
            print "      -> Profundizando hacia: $vecino\n";
            $self->_dfs_recursivo($vecino, $visitado, $orden);
        }
    }
}


sub sugerencias_colaboracion {
    my ($self, $id_usuario) = @_;

    unless (exists $self->{nodos}{$id_usuario}) {
        print "  Error: El usuario '$id_usuario' no existe.\n";
        return ();
    }

    my %nivel1;
    $nivel1{$_} = 1 for $self->get_vecinos($id_usuario);

    my %comunes;

    for my $vecino_directo (keys %nivel1) {
        for my $candidato ($self->get_vecinos($vecino_directo)) {
            next if $candidato eq $id_usuario;
            next if exists $nivel1{$candidato};
            $comunes{$candidato}++;
        }
    }

    my @sugeridos = sort { $comunes{$b} <=> $comunes{$a} } keys %comunes;

    return map { { id => $_, comunes => $comunes{$_} } } @sugeridos;
}


sub imprimir_lista_adyacencia {
    my ($self) = @_;

    print "\n=== Lista de Adyacencia ===\n";
    if ($self->is_empty()) {
        print "(grafo vacio)\n";
        print "===========================\n\n";
        return;
    }

    for my $id ($self->get_todos_ids()) {
        my $nodo    = $self->{nodos}{$id};
        my @vecinos = @{ $self->{adyacencia}{$id} };
        my $lista   = @vecinos ? join(", ", sort @vecinos) : "(sin conexiones)";
        printf("  %-12s %-25s -> [ %s ]\n",
            $id, $nodo->get_nombre(), $lista);
    }
    print "===========================\n\n";
}


sub nodos_aislados {
    my ($self) = @_;
    return grep { $self->grado($_) == 0 } $self->get_todos_ids();
}


sub es_conexo {
    my ($self) = @_;
    return 1 if $self->is_empty();

    my @ids = $self->get_todos_ids();
    my @visitados = $self->bfs($ids[0], 0);

    return scalar(@visitados) == scalar(@ids) ? 1 : 0;
}

1;


