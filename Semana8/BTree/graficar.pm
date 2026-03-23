package btree::graficar;

use strict;
use warnings;

use Scalar::Util qw(refaddr);

sub graficar {
    my ($class, $arbol, $basename) = @_;

    my $dot_file = "reportes/$basename.dot";
    my $png_file = "reportes/$basename.png";

    system("mkdir reportes 2>nul") unless -d "reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "digraph BTree {\n";
    print $fh "    rankdir=TB;\n";
    print $fh "    ranksep=0.9;\n";
    print $fh "    nodesep=0.5;\n";
    print $fh "    node [shape=plain, fontname=\"Arial\"];\n";
    print $fh "    edge [fontname=\"Arial\"];\n\n";

    if ($arbol->is_empty()) {
        print $fh "    empty [label=\"ARBOL B VACIO\", shape=box, fillcolor=\"#EEEEEE\"];\n";
    } else {
        $class->_generar_nodos_y_aristas($fh, $arbol->{root});

        # Forzar que todos los nodos del mismo nivel aparezcan en la misma fila.
        my %niveles;
        $class->_recolectar_por_nivel($arbol->{root}, 0, \%niveles);
        $class->_emitir_ranks_por_nivel($fh, \%niveles);
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
        print "DOT generado en: $dot_file\n";
        print "No se pudo generar PNG (verifique Graphviz/dot).\n$output\n";
        return 0;
    }
}

sub _node_id {
    my ($class, $node) = @_;
    return "n" . refaddr($node);
}

sub _build_html_label {
    my ($class, $node) = @_;

    my @keys = @{$node->get_keys()};
    my $n = scalar(@keys);

    my @cells;
    for (my $i = 0; $i < $n; $i++) {
        push(@cells, qq{<TD PORT="c$i" WIDTH="18"></TD>});
        push(@cells, qq{<TD>$keys[$i]</TD>});
    }
    push(@cells, qq{<TD PORT="c$n" WIDTH="18"></TD>});

    my $fill = $node->is_leaf() ? "#C8E6C9" : "#BBDEFB";

    return "<<TABLE BORDER=\"1\" CELLBORDER=\"1\" CELLSPACING=\"0\" CELLPADDING=\"8\" BGCOLOR=\"$fill\"><TR>"
        . join("", @cells)
        . "</TR></TABLE>>";
}

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
            print $fh "    $id:c$i -> $cid;\n";
            $class->_generar_nodos_y_aristas($fh, $child);
        }
    }
}

sub _recolectar_por_nivel {
    my ($class, $node, $nivel, $niveles_ref) = @_;
    return unless defined($node);

    push(@{$niveles_ref->{$nivel}}, $class->_node_id($node));

    return if $node->is_leaf();

    foreach my $child (@{$node->get_children()}) {
        $class->_recolectar_por_nivel($child, $nivel + 1, $niveles_ref);
    }
}

sub _emitir_ranks_por_nivel {
    my ($class, $fh, $niveles_ref) = @_;

    foreach my $nivel (sort { $a <=> $b } keys %{$niveles_ref}) {
        my $ids = $niveles_ref->{$nivel};
        next unless defined($ids) && scalar(@{$ids}) > 1;

        print $fh "    { rank=same; " . join("; ", @{$ids}) . "; }\n";
    }
}

1;
