
#Lista Simple enlazada de canciones
package ListaEnlazada;
    use strict;
    use warnings;

    use Nodo;
#Definicion de la lista simple enlazada, esta lista almacenara una lista de canciones para cada cantante, ademas de un puntero al siguiente nodo de la lista de listas.
    use Moo;

    has 'cabeza' => (is => 'rw', default => sub { undef });
    has 'tamanio' => (is => 'rw', default => sub { 0 });

    #Metodo para insertar un nodo al final de la lista
    sub insertar {
        my ($self, $titulo, $ventas) = @_;
        my $nuevo_nodo = Nodo->new(titulo => $titulo, ventas => $ventas);

        if (!defined $self->cabeza) {
            $self->cabeza($nuevo_nodo);
        } else {
            my $actual = $self->cabeza;
            while (defined $actual->siguiente) {
                $actual = $actual->siguiente;
            }
            $actual->siguiente($nuevo_nodo);
        }
        $self->tamanio($self->tamanio + 1);
    }

    #Metodo para mostrar la lista desde la cabeza hasta la cola
    sub mostrar_desde_cabeza {
        my ($self) = @_;
        return unless defined $self->cabeza;

        my $actual = $self->cabeza;
        while (defined $actual) {
            print "Titulo: " . $actual->titulo . ", Ventas: " . $actual->ventas . "\n";
            $actual = $actual->siguiente;
        }
    }

    1;