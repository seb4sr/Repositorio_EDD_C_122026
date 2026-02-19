

#Creacion de Nodo de la lista de listas, este nodo almacenara una lista de canciones, ademas de un puntero al siguiente nodo de la lista de listas.
package NodoListaDeListas;
    use strict;
    use warnings;

    use Moo; #Moo es un framework ligero para objetos en Perl, similar a Moose pero más simple y rápido, Este su funcion es facilitar la creación de clases y objetos en Perl.

    has 'cantante' => (is => 'rw'); #Este atributo almacenara el nombre del cantante, que a su vez es el nombre de la lista de canciones.
    has 'lista_canciones' => (is => 'rw'); #Este atributo almacenara una lista de canciones, que a su vez es una lista doblemente enlazada circular.
    has 'siguiente' => (is => 'rw'); #Puntero al siguiente nodo de la lista de listas.

    1;