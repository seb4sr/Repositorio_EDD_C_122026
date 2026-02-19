
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

    # hacemos la matriz
    # Creamos una matriz de 4 filas x 5 columnas.
    # Al inicio no tiene ningun elemento (total_datos = 0).  
    my $matriz = MatrizDispersa->new(4, 5);
    print "---> esta vacia la matriz = ", $matriz->es_vacia() ? "simochos" : "nelson", "\n\n";

    #            INSERTAR ELEMENTOS
    #                  insertar($fila, $col, $valor):
    $matriz->insertar(0, 1,  62.0);    
    $matriz->insertar(1, 1,  23.0);    
    $matriz->insertar(1, 2, -19.0);    
    $matriz->insertar(3, 0,  82.6);    
    $matriz->insertar(3, 4,  9.4);    

    # IMPRIMIR LISTA 
    $matriz->imprimir_lista();

    # IMPRIMIR POR COLUMNAS

    $matriz->imprimir_por_columnas();

    # matriz completa
    $matriz->imprimir_matriz();

    # buscar
    my $nodo = $matriz->obtener(1, 2);
    if (defined $nodo) {
        print "    obtener(1,2) = ", $nodo->get_valor(), "\n";
    }

    $nodo = $matriz->obtener(2, 2);
    print "    obtener(2,2) = ", (defined $nodo ? $nodo->get_valor() : "undef (cero implicito)"), "\n";
    print "\n";


    # Si llamamos insertar() en una posicion ya ocupada, se sobre escribe el valor.
    $matriz->insertar(1, 1, 999.99);
    $matriz->imprimir_lista();

    # 8. INSERTAR FUERA DE LIMITES (debe mostrar error) + agregue la redimension ya no da error
    $matriz->insertar(10, 10, 42);


    # borarr un nodo
    $matriz->borrar(1, 2);
    $matriz->imprimir_lista();

    # borar un nodo que no exitiste
    $matriz->borrar(2, 2);


    # graficando
    # Genera clase4/reportes/ejemplo1.dot y ejemplo1.png

    $matriz->insertar(2, 2, 3);
    $matriz->insertar(1, 4, "hola");


    $matriz->imprimir_lista();
    Graficar->graficar($matriz, "ejemplo1");
}

main() unless caller;