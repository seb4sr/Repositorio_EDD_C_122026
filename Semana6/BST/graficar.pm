package bst::graficar;

use strict;
use warnings;

use bst::bst;

sub graficar {
    my ($class, $arbol, $basename) = @_;

    my $dot_file = "reportes/$basename.dot";
    my $png_file = "reportes/$basename.png";

    system("mkdir reportes 2>nul") unless -d "reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "digraph BST {\n";
    print $fh "    rankdir=TB;\n";
    print $fh "    node [\n";
    print $fh "        shape=circle,\n";
    print $fh "        style=filled,\n";
    print $fh "        fillcolor=\"#B0BEC5\",\n";
    print $fh "        fontname=\"Arial\"\n";
    print $fh "    ];\n\n";

    if ($arbol->is_empty()) {
        print $fh "    empty [label=\"ÁRBOL VACÍO\", shape=box];\n";
    } else {
        $class->_generar_nodos($fh, $arbol->{root});
        $class->_generar_aristas($fh, $arbol->{root});
    }

    print $fh "}\n";
    close($fh);

    my $command = "dot -Tpng \"$dot_file\" -o \"$png_file\" 2>&1";
    my $output  = `$command`;
    my $exit    = $? >> 8;

    if ($exit == 0) {
        print "Imagen generada correctamente: $png_file\n";
        return 1;
    } else {
        print "Error al generar imagen.\n$output\n";
        return 0;
    }
}

sub _generar_nodos {
    my ($class, $fh, $nodo) = @_;

    return if !defined($nodo);

    my $valor = $nodo->get_data();
    my $id    = "n$valor";

    print $fh "    $id [label=\"$valor\"];\n";

    $class->_generar_nodos($fh, $nodo->get_left());
    $class->_generar_nodos($fh, $nodo->get_right());
}

sub _generar_aristas {
    my ($class, $fh, $nodo) = @_;

    return if !defined($nodo);

    my $valor_padre = $nodo->get_data();
    my $id_padre    = "n$valor_padre";

    if (defined($nodo->get_left())) {
        my $valor_izq = $nodo->get_left()->get_data();
        my $id_izq    = "n$valor_izq";
        print $fh "    $id_padre -> $id_izq;\n";
        $class->_generar_aristas($fh, $nodo->get_left());
    }

    if (defined($nodo->get_right())) {
        my $valor_der = $nodo->get_right()->get_data();
        my $id_der    = "n$valor_der";
        print $fh "    $id_padre -> $id_der;\n";
        $class->_generar_aristas($fh, $nodo->get_right());
    }
}

1;