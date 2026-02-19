
#Nodo cancion simple
package Nodo;
    use strict;
    use warnings;
    
    #Definicion Nodo para lista simple nombre de cancion y ventas
    use Moo;
    has 'titulo' => (is => 'rw', default => sub { '' });
    has 'ventas' => (is => 'rw', default => sub { 0 });
    has 'siguiente' => (is => 'rw', default => sub { undef });

    1;