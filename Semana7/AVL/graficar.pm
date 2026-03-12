package avl::graficar;

use strict;
use warnings;

use avl::avl;

sub graficar {
    my ($class, $arbol, $basename) = @_;

    my $dot_file = "reportes/$basename.dot";
    my $png_file = "reportes/$basename.png";

    system("mkdir reportes 2>nul") unless -d "reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "digraph AVL {\n";
    print $fh "    rankdir=TB;\n";
    print $fh "    node [\n";
    print $fh "        shape=record,\n";
    print $fh "        style=filled,\n";
    print $fh "        fontname=\"Arial\"\n";
    print $fh "    ];\n\n";

    if ($arbol->is_empty()) {
        print $fh "    empty [label=\"ARBOL VACIO\", shape=box];\n";
    } else {
        $class->_generar_nodos($fh, $arbol->{root}, $arbol);
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

sub _get_balance {
    my ($class, $arbol, $nodo) = @_;
    return 0 unless defined($nodo);
    my $h_izq = defined($nodo->get_left())  ? $nodo->get_left()->get_height()  : 0;
    my $h_der = defined($nodo->get_right()) ? $nodo->get_right()->get_height() : 0;
    return $h_izq - $h_der;
}

sub _fill_color {
    my ($class, $balance) = @_;
    # Verde si esta balanceado, amarillo si esta en el limite, rojo si desbordado
    return "#EF9A9A" if abs($balance) > 1;   # rojo (no deberia ocurrir en AVL)
    return "#FFF59D" if abs($balance) == 1;  # amarillo
    return "#A5D6A7";                         # verde
}

sub _generar_nodos {
    my ($class, $fh, $nodo, $arbol) = @_;

    return unless defined($nodo);

    my $valor   = $nodo->get_data();
    my $altura  = $nodo->get_height();
    my $balance = $class->_get_balance($arbol, $nodo);
    my $id      = "n$valor";
    my $color   = $class->_fill_color($balance);

    # Etiqueta con valor, altura (h) y factor de balance (bf)
    print $fh "    $id [label=\"{$valor | h=$altura | bf=$balance}\", fillcolor=\"$color\"];\n";

    $class->_generar_nodos($fh, $nodo->get_left(),  $arbol);
    $class->_generar_nodos($fh, $nodo->get_right(), $arbol);
}

sub _generar_aristas {
    my ($class, $fh, $nodo) = @_;

    return unless defined($nodo);

    my $valor_padre = $nodo->get_data();
    my $id_padre    = "n$valor_padre";

    if (defined($nodo->get_left())) {
        my $valor_izq = $nodo->get_left()->get_data();
        my $id_izq    = "n$valor_izq";
        print $fh "    $id_padre -> $id_izq [label=\"L\"];\n";
        $class->_generar_aristas($fh, $nodo->get_left());
    }

    if (defined($nodo->get_right())) {
        my $valor_der = $nodo->get_right()->get_data();
        my $id_der    = "n$valor_der";
        print $fh "    $id_padre -> $id_der [label=\"R\"];\n";
        $class->_generar_aristas($fh, $nodo->get_right());
    }
}

1;
