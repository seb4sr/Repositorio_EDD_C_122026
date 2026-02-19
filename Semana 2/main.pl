#Main

use strict;
use warnings;
use lib '.'; #Agregar el directorio actual a la ruta de busqueda de modulos

use ListaDoblementeEnlazadaCircular;
use GraphViz;


#Crear la lista doblemente enlazada circular para almacenar las canciones
my $lista = ListaDoblementeEnlazadaCircular->new();

#Crear la lista doblemente enlazada circular para almacenar las canciones desde un archivo
my $lista_archivo = ListaDoblementeEnlazadaCircular->new();

#Menu de opciones que se mostrara en consola

my $ejecutar = 1;

while ($ejecutar) {

    print "Menu de opciones:\n";
    print "1. Insertar una cancion\n";
    print "2. Insertar desde un Archivo\n";
    print "3. Mostrar lista desde la cabeza\n";
    print "4. Mostrar lista desde la cola\n";
    print "5. Salir\n";

    my $opcion = <STDIN>;
    chomp($opcion);

    if ($opcion < 1 || $opcion > 5) {

        print "Opcion invalida. Saliendo...\n";
        $ejecutar = 0;

    } elsif ($opcion == 1){

        #Pedir al usuario los datos de la cancion
        print "Ingrese el titulo de la cancion: ";
        my $titulo = <STDIN>;
        chomp($titulo);
        print "Ingrese el artista de la cancion: ";
        my $artista = <STDIN>;
        chomp($artista);
        print "Ingrese las ventas de la cancion: ";
        my $ventas = <STDIN>;
        chomp($ventas);
        #Crear la lista doblemente enlazada circular
        $lista->insertar($titulo, $artista, $ventas);
        print "Cancion insertada correctamente.\n";

    } elsif ($opcion == 2) {

        #Leer el archivo canciones.csv de forma que el usuario ingrese la ruta del archivo
        print "Ingrese la ruta del archivo de canciones (canciones.csv): ";
        my $ruta_archivo = <STDIN>;
        chomp($ruta_archivo);

        open(my $fh, '<', $ruta_archivo) or die "No se pudo abrir el archivo: $!"; #forma 1 donde se abre el archivo con la ruta ingresada por el usuario
        #open(my $fh, '<', 'canciones.csv') or die "No se pudo abrir el archivo: $!"; #forma 2 donde se abre el archivo canciones.csv directamente

        #previsualizar el contenido del archivo
        print "Contenido del archivo:\n";
        while (my $linea = <$fh>) {
            print $linea;
        }
        print "\n";
        seek($fh, 0, 0); # Volver al inicio del archivo para poder leerlo nuevamente


        while (my $linea = <$fh>) {
            chomp($linea);
            my ($nombre, $artista, $ventas) = split(',', $linea);
            $lista_archivo->insertar($nombre, $artista, $ventas);
        }

        close($fh);
        print "Canciones insertadas desde el archivo correctamente.\n";

    } elsif ($opcion == 3) {

        #print "Lista desde la cabeza:\n";
        #$lista->mostrar_desde_cabeza();
        print "Lista desde la cabeza (Archivo):\n";
        $lista_archivo->mostrar_desde_cabeza();

    } elsif ($opcion == 4) {

        #print "Lista desde la cola:\n";
        #$lista->mostrar_desde_cola();
        print "Lista desde la cola (Archivo):\n";
        $lista_archivo->mostrar_desde_cola();

    } else {

        print "Saliendo...\n";
        $ejecutar = 0;

    }

}

#funcion para generar el archivo .dot para graphviz y generar la representacion visual de la lista doblemente enlazada circular en la carpeta donde se esta ejecutando el script main.pl
sub generar_dot {
    my ($lista, $nombre_archivo) = @_;
    open(my $fh, '>', $nombre_archivo) or die "No se pudo crear el archivo: $!";

    print $fh "digraph G {\n";
    print $fh "  rankdir=LR;\n";
    print $fh "  node [shape=record];\n";

    my $actual = $lista->cabeza;
    my $index = 0;

    if (defined $actual) {
        do {
            print $fh "  node$index [label=\"{Titulo: " . $actual->titulo . " | Artista: " . $actual->artista . " | Ventas: " . $actual->ventas . "}\"];\n";
            $actual = $actual->siguiente;
            $index++;
        } while ($actual != $lista->cabeza);

        for (my $i = 0; $i < $index; $i++) {
            my $next_index = ($i + 1) % $index;
            my $prev_index = ($i - 1 + $index) % $index;
            print $fh "  node$i -> node$next_index [label=\"siguiente\"];\n";
            print $fh "  node$i -> node$prev_index [label=\"anterior\"];\n";
        }
    }

    print $fh "}\n";
    close($fh);
    print "Archivo DOT generado: $nombre_archivo\n";
}

# Almacenar el código de la gráfica en una variable
my $graph_code = "digraph G {\n";

# Aquí puedes agregar nodos y aristas a la variable $graph_code
# Ejemplo:
# $graph_code .= "  A -> B;\n";

$graph_code .= "}\n";

# Generar la imagen de la gráfica
my $graph = GraphViz->new();
$graph->from_string($graph_code);
$graph->as_png("output_graph.png");

# Llamar a la función generar_dot después de insertar canciones

