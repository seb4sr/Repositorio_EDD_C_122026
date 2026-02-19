

#Main para la lista de listas
use strict;
use warnings;
use lib '.'; #Agregar el directorio actual a la ruta de busqueda de modulos
use lib '../Semana 2'; #Agregar el directorio padre a la ruta de busqueda de modulos
use ListaDeListas;
use ListaEnlazada;

#funcion para escribir maunualmente el dot de la lista de listas, esta funcion recibe la lista de listas y genera el dot para graficar la lista de listas.
sub graficar_lista_de_listas {
    my ($lista_de_listas) = @_;
    open(my $fh, '>', 'lista_de_listas.dot') or die "No se pudo crear el archivo: $!";
    print $fh "digraph ListaDeListas {\n";
    print $fh "rankdir=TB;\n"; #importante, define la direccion del grafo de arriba hacia abajo
    print $fh "node [shape=box, style=rounded, fontname=\"Arial\"];\n";

    my @heads; #Array para almacenar los nodos de los cantantes
    my @songs_by_head; #Array para almacenar los nodos de las canciones de cada cantante, cada posicion del array es un array de canciones de cada cantante

    my $actual = $lista_de_listas->cabeza;
    my $contador = 0;
    while (defined $actual) {
        my $head_id = "HEAD" . ($contador + 1);
        push @heads, { id => $head_id, label => $actual->cantante };

        my $lista_canciones = $actual->lista_canciones;
        my $cancion_actual = $lista_canciones->cabeza;
        my @song_ids;
        my $song_index = 1;
        while (defined $cancion_actual) {
            my $song_id = "SONG" . $song_index . "_" . ($contador + 1);
            push @song_ids, { id => $song_id, label => $cancion_actual->titulo };
            $song_index++;
            $cancion_actual = $cancion_actual->siguiente;
        }
        push @songs_by_head, \@song_ids; #en el array de songs_by_head, cada posicion es un array de canciones de cada cantante

        $actual = $actual->siguiente;
        $contador++;
    }

    print $fh "{ rank=same;\n"; #rank=same es importante para que los nodos de los cantantes queden en la misma fila, y las canciones queden debajo de cada cantante
    for my $head (@heads) {
        print $fh $head->{id} . " [label=\"" . $head->{label} . "\"];\n";
    }
    print $fh "}\n";

    #El siguiente for es para conectar los nodos de los cantantes entre si
    for (my $i = 0; $i < @heads - 1; $i++) {
        print $fh $heads[$i]{id} . " -> " . $heads[$i + 1]{id} . ";\n";
    }

    #El siguietne for es para conectar los nodos de las canciones de cada cantante
    for (my $i = 0; $i < @heads; $i++) {
        my $head_id = $heads[$i]{id};
        my $songs = $songs_by_head[$i];

        for my $song (@$songs) {
            print $fh $song->{id} . " [label=\"" . $song->{label} . "\"];\n";
        }

        if (@$songs) { #if para verificar que el cantante tenga canciones, si no tiene canciones no se conecta el nodo del cantante con ningun nodo de cancion
            print $fh $head_id . " -> " . $songs->[0]{id} . ";\n"; #Conectar el nodo del cantante con el primer nodo de cancion
            #for para conectar los nodos de las canciones entre si, cada nodo de cancion se conecta con el siguiente nodo de cancion
            for (my $j = 0; $j < @$songs - 1; $j++) {
                print $fh $songs->[$j]{id} . " -> " . $songs->[$j + 1]{id} . ";\n";
            }
        }
    }

    my $max_len = 0; #Variable para almacenar la longitud maxima de las listas de canciones
    #El siguiente for es para determinar la longitud maxima de las listas de canciones, por que para graficar las canciones en filas iguales, es necesario saber la longitud maxima de las listas de canciones, ya que con esto se puede determinar cuantas filas de canciones se necesitan para graficar las canciones de cada cantante en filas iguales, y con esto se puede utilizar el atributo rank=same para graficar las canciones de cada cantante en filas iguales.
    for my $songs (@songs_by_head) {
        my $len = scalar @$songs; #Obtener la longitud del array de canciones de cada cantante
        $max_len = $len if $len > $max_len; #Actualizar la longitud maxima si la longitud del array de canciones de cada cantante es mayor que la longitud maxima actual
    }  
    #En pocas palabras este for que esta arriba calcula la longitud maxima de las listas de canciones
    #Ya que con la longitud maxima de las listas de canciones, se puede graficar las canciones de cada cantante en filas iguales utilizando el atributo rank=same
    #Ya que el atributo rank=same necesita que se le pase un array de nodos para graficarlos en la misma fila, y para graficar las canciones de cada cantante en filas iguales, es necesario saber cuantas filas de canciones se necesitan, y esto se determina con la longitud maxima de las listas de canciones

    #Este for es para graficar las canciones de cada cantante en filas iguales utilizando el atributo rank=same, este for itera desde 0 hasta la longitud maxima de las listas de canciones, y en cada iteracion se crea un array de nodos de canciones que corresponden a la iteracion actual, y se le pasa ese array de nodos al atributo rank=same para graficar las canciones de cada cantante en filas iguales.
    for (my $row = 0; $row < $max_len; $row++) {
        my @row_ids;
        for my $songs (@songs_by_head) {
            push @row_ids, $songs->[$row]{id} if defined $songs->[$row];
        }
        if (@row_ids > 1) {
            print $fh "{ rank=same; " . join(" ", @row_ids) . " }\n";
        }
    }

    print $fh "}\n";
    close($fh);
}

#funcion para generar la imagen de la lista de listas a partir del dot generado por la funcion graficar_lista_de_listas, esta funcion utiliza el comando dot de graphviz para generar la imagen.
sub generar_imagen {
    system("dot -Tpng lista_de_listas.dot -o lista_de_listas.png");
    print "Imagen generada: lista_de_listas.png\n";
}

#Insercion de 5 Cantantes con sus cacnoines, 2 cantantaes tendras 3 canciones, 2 cantantes tendran 2 canciones y 1 cantante tendra 1 cancion
my $lista_de_listas = ListaDeListas->new();
#Cantante 1 con 3 canciones
my $lista_canciones_1 = ListaEnlazada->new();
$lista_canciones_1->insertar("Cancion 1", 1000);
$lista_canciones_1->insertar("Cancion 2", 2000);
$lista_canciones_1->insertar("Cancion 3", 3000);
$lista_de_listas->insertar("Cantante 1", $lista_canciones_1);
#Cantante 2 con 3 canciones
my $lista_canciones_2 = ListaEnlazada->new();
$lista_canciones_2->insertar("Cancion 4", 4000);
$lista_canciones_2->insertar("Cancion 5", 5000);
$lista_canciones_2->insertar("Cancion 6", 6000);
$lista_de_listas->insertar("Cantante 2", $lista_canciones_2);
#Cantante 3 con 2 canciones
my $lista_canciones_3 = ListaEnlazada->new();
$lista_canciones_3->insertar("Cancion 7", 7000);
$lista_canciones_3->insertar("Cancion 8", 8000);
$lista_de_listas->insertar("Cantante 3", $lista_canciones_3);
#Cantante 4 con 2 canciones 
my $lista_canciones_4 = ListaEnlazada->new();
$lista_canciones_4->insertar("Cancion 9", 9000);
$lista_canciones_4->insertar("Cancion 10", 10000);
$lista_de_listas->insertar("Cantante 4", $lista_canciones_4);
#Cantante 5 con 1 cancion
my $lista_canciones_5 = ListaEnlazada->new();
$lista_canciones_5->insertar("Cancion 11", 11000);
$lista_de_listas->insertar("Cantante 5", $lista_canciones_5);


#Graficar la lista de listas
graficar_lista_de_listas($lista_de_listas);
#Generar la imagen de la lista de listas
generar_imagen();