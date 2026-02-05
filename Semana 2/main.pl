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
    print "5. Generar visualizacion GraphViz\n";
    print "6. Salir\n";

    my $opcion = <STDIN>;
    chomp($opcion);

    if ($opcion < 1 || $opcion > 6) {

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

    } elsif ($opcion == 5) {

        print "Generando visualizacion de la lista...\n";
        print "Ingrese el nombre del archivo (sin extension): ";
        my $nombre_archivo = <STDIN>;
        chomp($nombre_archivo);
        
        # Generar visualización para la lista con archivo
        if (defined $lista_archivo->cabeza) {
            generar_dot($lista_archivo, $nombre_archivo);
        } else {
            print "La lista del archivo esta vacia.\n";
        }

    } else {

        print "Saliendo...\n";
        $ejecutar = 0;

    }

}

#funcion para generar el archivo .dot para graphviz y generar la representacion visual de la lista doblemente enlazada circular en la carpeta donde se esta ejecutando el script main.pl
sub generar_dot {
    my ($lista, $nombre_archivo) = @_;
    
    # Verificar si la lista está vacía
    return unless defined $lista->cabeza;
    
    # Crear el objeto GraphViz
    my $graph = GraphViz->new(
        directed => 1,
        layout => 'dot',
        rankdir => 'LR',
        node => {
            shape => 'record',
            style => 'filled',
            fillcolor => 'lightblue',
            fontname => 'Arial'
        },
        edge => {
            color => 'blue',
            arrowsize => 0.8
        }
    );
    
    # Recorrer la lista y agregar nodos al grafo
    my $actual = $lista->cabeza;
    my $contador = 0;
    my @nodos_ids = ();
    
    do {
        my $nodo_id = "nodo$contador";
        push @nodos_ids, $nodo_id;
        
        # Crear etiqueta del nodo con la información de la canción
        my $label = "{" . $actual->titulo . "|Artista: " . $actual->artista . "|Ventas: " . $actual->ventas . "}";
        
        # Agregar el nodo al grafo
        $graph->add_node($nodo_id, label => $label);
        
        $actual = $actual->siguiente;
        $contador++;
    } while ($actual != $lista->cabeza);
    
    # Agregar las aristas (conexiones) entre los nodos
    for (my $i = 0; $i < scalar(@nodos_ids); $i++) {
        my $siguiente_idx = ($i + 1) % scalar(@nodos_ids);
        
        # Flecha hacia adelante (siguiente)
        $graph->add_edge($nodos_ids[$i] => $nodos_ids[$siguiente_idx], color => 'blue', label => 'sig');
        
        # Flecha hacia atrás (anterior)
        $graph->add_edge($nodos_ids[$siguiente_idx] => $nodos_ids[$i], color => 'red', label => 'ant');
    }
    
    # Generar el archivo de imagen
    my $output_file = $nombre_archivo || 'lista_circular';
    
    # Intentar generar PNG primero, si falla intentar JPG
    eval {
        $graph->as_png("$output_file.png");
        print "Imagen generada exitosamente: $output_file.png\n";
    };
    if ($@) {
        eval {
            $graph->as_jpeg("$output_file.jpg");
            print "Imagen generada exitosamente: $output_file.jpg\n";
        };
        if ($@) {
            print "Error al generar la imagen: $@\n";
            print "Asegúrese de tener GraphViz instalado en su sistema.\n";
        }
    }
}

# Llamar a la función generar_dot después de insertar canciones
# Ejemplo: generar_dot($lista_archivo, 'mi_lista');

