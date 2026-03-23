package btree::graficar;

use strict;
use warnings;

use Scalar::Util qw(refaddr);

# ------------------------------------------------------------------
# Graficador del Arbol B (DOT + PNG)
#
# Este modulo convierte el arbol en formato DOT y luego invoca Graphviz
# para generar una imagen PNG.
# ------------------------------------------------------------------

sub graficar {
    my ($class, $arbol, $basename) = @_;

    my $dot_file = "reportes/$basename.dot";
    my $png_file = "reportes/$basename.png";

    # Crear carpeta de salida si no existe.
    system("mkdir reportes 2>nul") unless -d "reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    # Configuracion general del grafo.
    print $fh "digraph BTree {\n";
    print $fh "    rankdir=TB;\n";   # Raiz arriba, hojas abajo
    print $fh "    ranksep=0.9;\n";  # Separacion vertical entre niveles
    print $fh "    nodesep=0.5;\n";  # Separacion horizontal entre nodos
    print $fh "    node [shape=plain, fontname=\"Arial\"];\n";
    print $fh "    edge [fontname=\"Arial\"];\n\n";

    if ($arbol->is_empty()) {
        # Caso especial de arbol vacio.
        print $fh "    empty [label=\"ARBOL B VACIO\", shape=box, fillcolor=\"#EEEEEE\"];\n";
    } else {
        # Generar nodos y aristas recursivamente.
        $class->_generar_nodos_y_aristas($fh, $arbol->{root});

        # Forzar nodos de un mismo nivel en la misma fila horizontal.
        my %niveles;
        $class->_recolectar_por_nivel($arbol->{root}, 0, \%niveles);
        $class->_emitir_ranks_por_nivel($fh, \%niveles);
    }

    print $fh "}\n";
    close($fh);

    # Ejecutar Graphviz para transformar DOT -> PNG.
    my $command = "dot -Tpng \"$dot_file\" -o \"$png_file\" 2>&1";
    my $output  = `$command`;
    my $exit    = $? >> 8;

    if ($exit == 0) {
        print "Imagen generada correctamente: $png_file\n";
        return 1;
    } else {
        print "DOT generado en: $dot_file\n";
        print "No se pudo generar PNG (verifique Graphviz/dot).\n$output\n";
        return 0;
    }
}

# ID unico de nodo para DOT basado en direccion de referencia.
sub _node_id {
    my ($class, $node) = @_;
    return "n" . refaddr($node);
}

# Construye etiqueta HTML TABLE para mostrar claves en fila horizontal.
# Tambien deja celdas-port para conectar aristas por rangos (c0..cn).
sub _build_html_label {
    my ($class, $node) = @_;

    my @keys = @{$node->get_keys()};
    my $n = scalar(@keys);

    my @cells;
    for (my $i = 0; $i < $n; $i++) {
        # Puerto antes de cada clave: representa el rango hijo i.
        push(@cells, qq{<TD PORT="c$i" WIDTH="18"></TD>});
        push(@cells, qq{<TD>$keys[$i]</TD>});
    }

    # Puerto final: rango hijo n (a la derecha de la ultima clave).
    push(@cells, qq{<TD PORT="c$n" WIDTH="18"></TD>});

    my $fill = $node->is_leaf() ? "#C8E6C9" : "#BBDEFB";

    return "<<TABLE BORDER=\"1\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"8\" BGCOLOR=\"$fill\"><TR>"
        . join("", @cells)
        . "</TR></TABLE>>";
}

# Recorre el arbol y emite nodos y aristas DOT.
sub _generar_nodos_y_aristas {
    my ($class, $fh, $node) = @_;
    return unless defined($node);

    my $id = $class->_node_id($node);
    my $label = $class->_build_html_label($node);

    print $fh "    $id [label=$label];\n";

    if (!$node->is_leaf()) {
        my $children = $node->get_children();

        for (my $i = 0; $i < scalar(@$children); $i++) {
            my $child = $children->[$i];
            my $cid = $class->_node_id($child);

            # Conectar desde el puerto de rango c_i hacia el hijo i.
            print $fh "    $id:c$i -> $cid;\n";
            $class->_generar_nodos_y_aristas($fh, $child);
        }
    }
}

# Recolecta IDs de nodos agrupados por profundidad.
sub _recolectar_por_nivel {
    my ($class, $node, $nivel, $niveles_ref) = @_;
    return unless defined($node);

    push(@{$niveles_ref->{$nivel}}, $class->_node_id($node));

    return if $node->is_leaf();

    foreach my $child (@{$node->get_children()}) {
        $class->_recolectar_por_nivel($child, $nivel + 1, $niveles_ref);
    }
}

# Emite subgrafos rank=same para mantener alineacion horizontal por nivel.
sub _emitir_ranks_por_nivel {
    my ($class, $fh, $niveles_ref) = @_;

    foreach my $nivel (sort { $a <=> $b } keys %{$niveles_ref}) {
        my $ids = $niveles_ref->{$nivel};
        next unless defined($ids) && scalar(@{$ids}) > 1;

        print $fh "    { rank=same; " . join("; ", @{$ids}) . "; }\n";
    }
}

1;
