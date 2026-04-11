package grafo::graficar;


use strict;
use warnings;

my %COLOR_DEP = (
    'DEP-MED' => '#AED6F1',
    'DEP-CIR' => '#FAD7A0',
    'DEP-LAB' => '#F9E79F',
    'DEP-FAR' => '#A9DFBF',
    'SIN-DEP' => '#D5D8DC',
);

my $COLOR_DEFAULT = '#F2F3F4';


sub graficar_grafo {
    my ($class, $grafo, $basename) = @_;

    my $dot_file = "reportes/$basename.dot";
    my $png_file = "reportes/$basename.png";

    system("mkdir reportes 2>nul") unless -d "reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "graph Colaboracion {\n";
    print $fh "    rankdir=LR;\n";
    print $fh "    splines=true;\n";
    print $fh "    overlap=false;\n";
    print $fh "    node [\n";
    print $fh "        shape=ellipse,\n";
    print $fh "        style=filled,\n";
    print $fh "        fontname=\"Arial\",\n";
    print $fh "        fontsize=10\n";
    print $fh "    ];\n";
    print $fh "    edge [fontname=\"Arial\", fontsize=9];\n\n";

    print $fh "    subgraph cluster_leyenda {\n";
    print $fh "        label=\"Departamentos\";\n";
    print $fh "        style=dotted;\n";
    print $fh "        fontname=\"Arial Bold\";\n";
    print $fh "        ley_med [label=\"DEP-MED\", fillcolor=\"#AED6F1\", shape=box];\n";
    print $fh "        ley_cir [label=\"DEP-CIR\", fillcolor=\"#FAD7A0\", shape=box];\n";
    print $fh "        ley_lab [label=\"DEP-LAB\", fillcolor=\"#F9E79F\", shape=box];\n";
    print $fh "        ley_far [label=\"DEP-FAR\", fillcolor=\"#A9DFBF\", shape=box];\n";
    print $fh "        ley_sin [label=\"SIN-DEP\", fillcolor=\"#D5D8DC\", shape=box];\n";
    print $fh "        ley_med -- ley_cir -- ley_lab -- ley_far -- ley_sin [style=invis];\n";
    print $fh "    }\n\n";

    if ($grafo->is_empty()) {
        print $fh "    vacio [label=\"GRAFO VACIO\", shape=box, fillcolor=\"#FADBD8\"];\n";
    } else {
        for my $id ($grafo->get_todos_ids()) {
            my $nodo  = $grafo->get_nodo($id);
            my $dep   = $nodo->get_departamento();
            my $tipo  = $nodo->get_tipo();
            my $nombre = $nodo->get_nombre();
            my $color = $COLOR_DEP{$dep} // $COLOR_DEFAULT;
            my $grado = $grafo->grado($id);

            my $label = "$id\\n$nombre\\n$dep | $tipo\\ngrado: $grado";
            my $node_id = _safe_id($id);

            print $fh "    $node_id [label=\"$label\", fillcolor=\"$color\"];\n";
        }

        print $fh "\n";

        my %aristas_vistas;
        for my $id_a ($grafo->get_todos_ids()) {
            for my $id_b ($grafo->get_vecinos($id_a)) {
                my $clave = join('|', sort($id_a, $id_b));
                next if $aristas_vistas{$clave}++;
                my $na = _safe_id($id_a);
                my $nb = _safe_id($id_b);
                print $fh "    $na -- $nb;\n";
            }
        }
    }

    print $fh "}\n";
    close($fh);

    return $class->_compilar($dot_file, $png_file);
}


sub graficar_lista_adyacencia {
    my ($class, $grafo, $basename) = @_;

    my $dot_file = "reportes/$basename.dot";
    my $png_file = "reportes/$basename.png";

    system("mkdir reportes 2>nul") unless -d "reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "digraph ListaAdyacencia {\n";
    print $fh "    rankdir=LR;\n";
    print $fh "    node [shape=record, style=filled, fontname=\"Courier\", fontsize=10];\n";
    print $fh "    edge [arrowhead=open];\n\n";

    if ($grafo->is_empty()) {
        print $fh "    vacio [label=\"GRAFO VACIO\"];\n";
    } else {
        for my $id ($grafo->get_todos_ids()) {
            my $nodo   = $grafo->get_nodo($id);
            my $dep    = $nodo->get_departamento();
            my $color  = $COLOR_DEP{$dep} // $COLOR_DEFAULT;
            my $nid    = _safe_id($id);
            my $nombre = $nodo->get_nombre();

            print $fh "    ${nid}_head [label=\"{$id | $nombre}\", fillcolor=\"$color\"];\n";

            my @vecinos = sort $grafo->get_vecinos($id);
            if (@vecinos) {
                for my $i (0 .. $#vecinos) {
                    my $vid   = _safe_id($vecinos[$i]);
                    my $vnombre = $grafo->get_nodo($vecinos[$i])->get_nombre();
                    print $fh "    ${nid}_v$i [label=\"{$vecinos[$i] | $vnombre}\", "
                            . "fillcolor=\"#FDFEFE\"];\n";
                }
                print $fh "    ${nid}_head -> ${nid}_v0;\n";
                for my $i (0 .. $#vecinos - 1) {
                    print $fh "    ${nid}_v$i -> ${nid}_v" . ($i + 1) . ";\n";
                }
            } else {
                print $fh "    ${nid}_nil [label=\"NULL\", fillcolor=\"#F2F3F4\"];\n";
                print $fh "    ${nid}_head -> ${nid}_nil;\n";
            }
        }
    }

    print $fh "}\n";
    close($fh);

    return $class->_compilar($dot_file, $png_file);
}


sub _safe_id {
    my ($id) = @_;
    $id =~ s/[-.]/_/g;
    return $id;
}


sub _compilar {
    my ($class, $dot_file, $png_file) = @_;

    my $command = "dot -Tpng \"$dot_file\" -o \"$png_file\" 2>&1";
    my $output  = `$command`;
    my $exit    = $? >> 8;

    if ($exit == 0) {
        print "  Imagen generada: $png_file\n";
        return 1;
    } else {
        print "  Error al generar imagen.\n$output\n";
        return 0;
    }
}

1;


