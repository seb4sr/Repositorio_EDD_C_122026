#Lista Doblemente Enlazda Circular

package ListaDoblementeEnlazadaCircular;
    use strict;
    use warnings;

    use Nodo;

#Definicion de la lista doblemente enlazada circular

    use Moo;

    has 'cabeza' => (is => 'rw', default => sub { undef });
    has 'cola' => (is => 'rw', default => sub { undef });
    has 'tamanio' => (is => 'rw', default => sub { 0 });

    #Metodo para insertar un nodo al final de la lista
    sub insertar {
        my ($self, $titulo, $artista, $ventas) = @_;
        my $nuevo_nodo = Nodo->new(titulo => $titulo, artista => $artista, ventas => $ventas);

        if (!defined $self->cabeza) {
            $self->cabeza($nuevo_nodo);
            $self->cola($nuevo_nodo);
            $nuevo_nodo->siguiente($nuevo_nodo);
            $nuevo_nodo->anterior($nuevo_nodo);
        } else {
            my $cola = $self->cola;
            $cola->siguiente($nuevo_nodo);
            $nuevo_nodo->anterior($cola);
            $nuevo_nodo->siguiente($self->cabeza);
            $self->cabeza->anterior($nuevo_nodo);
            $self->cola($nuevo_nodo);
        }
        $self->tamanio($self->tamanio + 1);
    }

    #Metodo para mostrar la lista desde la cabeza hasta la cola
    sub mostrar_desde_cabeza {
        my ($self) = @_;
        return unless defined $self->cabeza;

        my $actual = $self->cabeza;
        do {
            print "Titulo: " . $actual->titulo . ", Artista: " . $actual->artista . ", Ventas: " . $actual->ventas . "\n";
            $actual = $actual->siguiente;
        } while ($actual != $self->cabeza);
    }

    #Metodo para mostrar la lista desde la cola hasta la cabeza
    sub mostrar_desde_cola {
        my ($self) = @_;
        return unless defined $self->cola;

        my $actual = $self->cola;
        do {
            print "Titulo: " . $actual->titulo . ", Artista: " . $actual->artista . ", Ventas: " . $actual->ventas . "\n";
            $actual = $actual->anterior;
        } while ($actual != $self->cola);
    }

    #Metodo para insertar un nodo al inicio de la lista
    sub insertar_al_inicio {
        my ($self, $titulo, $artista, $ventas) = @_;
        my $nuevo_nodo = Nodo->new(titulo => $titulo, artista => $artista, ventas => $ventas);

        if (!defined $self->cabeza) {
            $self->cabeza($nuevo_nodo);
            $self->cola($nuevo_nodo);
            $nuevo_nodo->siguiente($nuevo_nodo);
            $nuevo_nodo->anterior($nuevo_nodo);
        } else {
            my $cabeza = $self->cabeza;
            my $cola = $self->cola;
            $nuevo_nodo->siguiente($cabeza);
            $nuevo_nodo->anterior($cola);
            $cabeza->anterior($nuevo_nodo);
            $cola->siguiente($nuevo_nodo);
            $self->cabeza($nuevo_nodo);
        }
        $self->tamanio($self->tamanio + 1);
    }

    #Metodo para buscar un nodo por titulo
    sub buscar_por_titulo {
        my ($self, $titulo) = @_;
        return unless defined $self->cabeza;

        my $actual = $self->cabeza;
        do {
            if ($actual->titulo eq $titulo) {
                return $actual;
            }
            $actual = $actual->siguiente;
        } while ($actual != $self->cabeza);

        return undef; # No encontrado
    }

    #Metodo para eliminar un nodo por titulo
    sub eliminar_por_titulo {
        my ($self, $titulo) = @_;
        return unless defined $self->cabeza;

        my $actual = $self->cabeza;
        do {
            if ($actual->titulo eq $titulo) {
                if ($actual == $self->cabeza && $actual == $self->cola) {
                    $self->cabeza(undef);
                    $self->cola(undef);
                } else {
                    my $anterior = $actual->anterior;
                    my $siguiente = $actual->siguiente;
                    $anterior->siguiente($siguiente);
                    $siguiente->anterior($anterior);

                    if ($actual == $self->cabeza) {
                        $self->cabeza($siguiente);
                    }
                    if ($actual == $self->cola) {
                        $self->cola($anterior);
                    }
                }
                $self->tamanio($self->tamanio - 1);
                return 1; # Eliminado exitosamente
            }
            $actual = $actual->siguiente;
        } while ($actual != $self->cabeza);

        return 0; # No encontrado
    }
1;

