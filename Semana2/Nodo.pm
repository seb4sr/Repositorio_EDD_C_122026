    package Nodo;
    use strict;
    use warnings;

#Definicion del nodo de la lista, este nodo almacenara informacion de una cancion, como su titulo y artista y ventas.


    use Moo; #Moo es un framework ligero para objetos en Perl, similar a Moose pero más simple y rápido, Este su funcion es facilitar la creación de clases y objetos en Perl.

    has 'titulo' => (is => 'rw');
    has 'artista' => (is => 'rw');
    has 'ventas' => (is => 'rw');
    has 'siguiente' => (is => 'rw');
    has 'anterior' => (is => 'rw');

    1;
