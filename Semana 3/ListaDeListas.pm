

#Lista de Listas
package ListaDeListas;
    use strict;
    use warnings;

    use NodoListaDeListas;

#Definicion de la lista de listas, esta lista almacenara una lista de canciones para cada cantante, ademas de un puntero al siguiente nodo de la lista de listas.

    use Moo;

    has 'cabeza' => (is => 'rw', default => sub { undef });
    has 'tamanio' => (is => 'rw', default => sub { 0 });

    #Metodo para insertar una lista de canciones a la lista de listas, este metodo recibe el nombre del cantante y la lista de canciones.
    sub insertar {
        my ($self, $cantante, $lista_canciones) = @_;
        my $nuevo_nodo = NodoListaDeListas->new(cantante => $cantante, lista_canciones => $lista_canciones);

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

    #Metodo para mostrar la lista de listas, este metodo muestra el nombre del cantante y la lista de canciones de cada nodo de la lista de listas.
    sub mostrar {
        my ($self) = @_;
        return unless defined $self->cabeza;

        my $actual = $self->cabeza;
        while (defined $actual) {
            print "Cantante: " . $actual->cantante . "\n";
            print "Lista de canciones:\n";
            $actual->lista_canciones->mostrar_desde_cabeza();
            print "\n";
            $actual = $actual->siguiente;
        }
    }

    1;