package matriz_dispersa::Graficar;

# ---> matriz_dispersa/Graficar.pm


use strict;
use warnings;

use matriz_dispersa::MatrizDispersa;

# graficar($matriz, $basename)
# Parametros:
#   $matriz  --> objeto MatrizDispersa a visualizar
#
sub graficar {
    my ($class, $matriz, $basename) = @_;

    my $dot_file = "clase4/reportes/$basename.dot";
    my $png_file = "clase4/reportes/$basename.png";

    open(my $fh, '>', $dot_file)
        or die "No se pudo crear $dot_file: $!";

    # Encabezado del grafo
    print $fh "digraph MatrizDispersa {\n";
    print $fh "    labelloc=\"t\";\n";
    print $fh "    fontsize=16;\n";
    print $fh "    fontname=\"Arial Bold\";\n";
    print $fh "    nodesep=0.6;\n";
    print $fh "    ranksep=0.7;\n";
    print $fh "\n";

    # Estilos base
    print $fh "    node [shape=box, style=filled, fontname=\"Arial\", fontsize=11];\n";
    print $fh "    edge [fontcolor=black, fontsize=9];\n";
    print $fh "\n";

    # matriz vacia
    if ($matriz->es_vacia()) {
        print $fh "    empty [label=\"MATRIZ VACIA\", fillcolor=lightgray, shape=ellipse];\n";
        print $fh "}\n";
        close($fh);
        _compilar($dot_file, $png_file);
        return;
    }

    # Recolectar todos los indices de filas y columnas con datos
    # Recorremos las cabeceras para saber que filas y columnas existen.
    my @filas_con_datos = ();
    my $cf = $matriz->{lista_filas};
    while (defined $cf) {
        push @filas_con_datos, $cf->get_label();
        $cf = $cf->get_next();
    }

    my @cols_con_datos = ();
    my $cc = $matriz->{lista_cols};
    while (defined $cc) {
        push @cols_con_datos, $cc->get_label();
        $cc = $cc->get_next();
    }

    # Nodo "origen" (esquina superior izquierda)
    print $fh "    // Nodo origen (esquina)\n";
    print $fh "    origen [label=\"filas/columna\",";
    print $fh "  fontsize=10];\n\n";

    # Cabeceras de COLUMNAS (fila superior del diagrama)
    print $fh "    // === CABECERAS DE COLUMNAS ========\n";
    for my $c (@cols_con_datos) {
my $group = $c + 1;

print $fh "cab_col_$c [label=\"Col $c\", group=$group, fillcolor=\"#2980b9\", fontcolor=white];\n";
    }
    print $fh "\n";

    # Cabeceras de FILAS (columna izquierda del diagrama)
    print $fh "    // =========== CABECERAS DE FILAS =====\n";
    for my $f (@filas_con_datos) {
print $fh "cab_fil_$f [label=\"Fil $f\", group=0, fillcolor=\"#27ae60\", fontcolor=white];\n";
    }
    print $fh "\n";

    # Nodos DATO (los elementos no-cero)
    # Nombre del nodo: dato_F_C  (fila F, columna C)
    print $fh "    // ========= NODOS DATO (elementos no-cero) ====+==\n";
    $cf = $matriz->{lista_filas};
    while (defined $cf) {
        my $f    = $cf->get_label();
        my $dato = $cf->get_right();
        while (defined $dato) {
            my $c   = $dato->get_col();
            my $v   = $dato->get_valor();
            my $lbl = _label_para_dot($f, $c, $v);
            my $group = $c + 1;

            # Escapar caracteres especiales
            $lbl =~ s/"/\\"/g;
print $fh "dato_${f}_${c} [label=\"$lbl\", group=$group, fillcolor=\"#ecf0f1\"];\n";
            $dato = $dato->get_right();
        }
        $cf = $cf->get_next();
    }
    print $fh "\n";

    # FLECHAS HORIZONTALES (conexiones de fila)
    # Para cada fila: cab_fil --> primer_dato --> segundo_dato --> ...
    print $fh "    // FLECHAS HORIZONTALES (por fila) ============\n";
    $cf = $matriz->{lista_filas};
    while (defined $cf) {
        my $f    = $cf->get_label();
        my $dato = $cf->get_right();

        my $anterior_id = "cab_fil_$f";

        while (defined $dato) {
            my $c          = $dato->get_col();
            my $actual_id  = "dato_${f}_${c}";

            # Flecha bidireccional
            print $fh "    $anterior_id -> $actual_id [dir=both, color=\"#27ae60\"];\n";

            $anterior_id = $actual_id;
            $dato        = $dato->get_right();
        }
        $cf = $cf->get_next();
    }
    print $fh "\n";

    # FLECHAS VERTICALES (conexiones de columna)
    print $fh "    // ========== FLECHAS VERTICALES (por columna) =====\n";
    $cc = $matriz->{lista_cols};
    while (defined $cc) {
        my $c    = $cc->get_label();
        my $dato = $cc->get_down();

        my $anterior_id = "cab_col_$c";

        while (defined $dato) {
            my $f         = $dato->get_fila();
            my $actual_id = "dato_${f}_${c}";

            # Flecha bidireccional
            print $fh "    $anterior_id -> $actual_id [dir=both, color=\"#2980b9\"];\n";

            $anterior_id = $actual_id;
            $dato        = $dato->get_down();
        }
        $cc = $cc->get_next();
    }
    print $fh "\n";

    # RANK CONSTRAINTS (alineacion visual)
    # La fila superior: origen + todas las cab de columna
    print $fh "    // alineacion\n";
    print $fh "    // Fila superior: origen y cabeceras de columna\n";
    my $cabcols_str = join("; ", map { "cab_col_$_" } @cols_con_datos);
    print $fh "    { rank=same; origen; $cabcols_str; }\n";

    # Cada fila de datos: cab_fil + los datos de esa fila
    $cf = $matriz->{lista_filas};
    while (defined $cf) {
        my $f    = $cf->get_label();
        my $dato = $cf->get_right();
        my @ids  = ("cab_fil_$f");

        while (defined $dato) {
            push @ids, "dato_${f}_" . $dato->get_col();
            $dato = $dato->get_right();
        }

        my $rank_str = join("; ", @ids);
        print $fh "    { rank=same; $rank_str; }\n";

        $cf = $cf->get_next();
    }

    # Conectar origen con la primera cab_col y la primera cab_fil
    # (lineas de encuadre, invisibles o de guia)
    if (@cols_con_datos) {
        print $fh "\n    // Enlace de encuadre superior (no se ve)\n";
        my $primera_col = $cols_con_datos[0];
        print $fh "    origen -> cab_col_$primera_col [style=invis];\n";

        # Encadenar las cab_col entre si 
        for my $i (0 .. $#cols_con_datos - 1) {
            my $a = $cols_con_datos[$i];
            my $b = $cols_con_datos[$i + 1];
            print $fh "    cab_col_$a -> cab_col_$b [style=invis];\n";
        }
    }

    if (@filas_con_datos) {
        print $fh "\n    // Enlace de encuadre izquierdo (no se ve)\n";
        my $primera_fila = $filas_con_datos[0];
        print $fh "    origen -> cab_fil_$primera_fila [style=invis];\n";

        # Encadenar las cab_fil entre si 
        for my $i (0 .. $#filas_con_datos - 1) {
            my $a = $filas_con_datos[$i];
            my $b = $filas_con_datos[$i + 1];
            print $fh "    cab_fil_$a -> cab_fil_$b [style=invis];\n";
        }
    }

    print $fh "}\n";
    close($fh);

    print "Archivo DOT generado.\n";
    _compilar($dot_file, $png_file);
}

# _label_para_dot($fila, $col, $valor)
# Genera el texto que aparecera dentro del nodo en el grafico.
# Si el valor es un objeto (referencia), intenta llamar a get_info_graphviz.
sub _label_para_dot {
    my ($f, $c, $v) = @_;

    if (ref($v) && $v->can('get_info_graphviz')) {
        # El objeto sabe como mostrarse en el grafico
        return "($f,$c)\\n" . $v->get_info_graphviz();
    }
    elsif (ref($v)) {
        return "($f,$c)\\n" . ref($v);
    }
    else {
        return "($f,$c)\\nval=$v";
    }
}

# _compilar($dot_file, $png_file)
# Llama al comando 'dot' de Graphviz para generar el PNG.
sub _compilar {
    my ($dot_file, $png_file) = @_;

    print "Generando imagen: $png_file\n";
    my $cmd     = "dot -Tpng $dot_file -o $png_file 2>&1";
    my $output  = `$cmd`;
    my $exit    = $? >> 8;

    if ($exit == 0) {
        print "Imagen generada exitosamente: $png_file\n";
    } else {
        print "[ERROR] Graphviz fallo (exit=$exit). Salida: $output\n";    }
}

1;