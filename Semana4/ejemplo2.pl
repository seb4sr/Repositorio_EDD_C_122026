
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";

use matriz_dispersa::MatrizDispersa;
use matriz_dispersa::Graficar;

use constant MatrizDispersa => 'matriz_dispersa::MatrizDispersa';
use constant Graficar       => 'matriz_dispersa::Graficar';

sub main {
    print "\n\n\n";
    print " Matriz Dispersa con numeros\n";

 
    my $matriz = MatrizDispersa->new(4, 5);

    #            INSERTAR ELEMENTOS
    #                  insertar($fila, $col, $valor):
    $matriz->insertar(0, 0,  10.0);  
    $matriz->insertar(1, 1,  20.0); 
    $matriz->insertar(2, 2,  30.0); 
    $matriz->insertar(3, 3,  40.0); 


# ya no existe fila  4 y 5
    $matriz->insertar(4, 4,  50.0);   
    $matriz->insertar(5, 5,  60.0);   

        $matriz->insertar(3, 4,  70.0);  

# la columa 5 ya no existe
$matriz->insertar(3, 5,  80.0);  
$matriz->insertar(7, 9,  700.0); 




    Graficar->graficar($matriz, "ejemplo4");
}

main() unless caller;