package lzw::graficar;

use strict;
use warnings;

# Maximo de entradas del diccionario a mostrar en el grafico.
# Si hay mas, se agrega un nodo resumen al final.
use constant MAX_DIC => 12;

# ---------------------------------------------------------------
# Punto de entrada principal
# Recibe: objeto lzw::lzw ya usado para comprimir, nombre base
# Genera: archivo .dot y .png en la carpeta reportes/
# ---------------------------------------------------------------
sub graficar {
    my ($class, $lzw, $basename) = @_;

    mkdir "reportes" unless -d "reportes";

    my $dot_file = "reportes/$basename.dot";
    my $png_file = "reportes/$basename.png";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    my $stats   = $lzw->get_estadisticas();
    my @codigos = $lzw->get_codigos();
    my @dic     = $lzw->get_dic_nuevas();

    # -------- Cabecera del grafo --------
    print $fh "digraph LZW {\n";
    print $fh "    graph [\n";
    print $fh "        label=\"Reporte Compresion LZW\\nDiccionario Generado durante la Codificacion\"\n";
    print $fh "        fontsize=14\n";
    print $fh "        rankdir=TB\n";
    print $fh "    ];\n";
    print $fh "    node [style=filled fontname=\"Courier New\" fontsize=10];\n";
    print $fh "    edge [color=\"#555555\" fontsize=9];\n\n";

    # -------- Nodo de estadisticas --------
    my $muestra = join(", ", @codigos[0..($#codigos < 7 ? $#codigos : 7)]);
    $muestra   .= ", ..." if @codigos > 8;

    print $fh "    stats [\n";
    print $fh "        shape=record\n";
    print $fh "        fillcolor=\"#B3E5FC\"\n";
    print $fh "        label=\"{ESTADISTICAS DE COMPRESION";
    print $fh " | Chars originales: $stats->{chars_originales}";
    print $fh " | Codigos emitidos: $stats->{codigos_emitidos}";
    print $fh " | Entradas nuevas en dic: $stats->{entradas_nuevas}";
    print $fh " | Ratio (chars por codigo): $stats->{ratio}x";
    print $fh " | Primeros codigos: [$muestra]}\"\n";
    print $fh "    ];\n\n";

    # -------- Nodos del diccionario --------
    # Paleta de colores para diferenciar visualmente las entradas
    my @paleta = (
        "#A5D6A7", "#B2DFDB", "#C8E6C9", "#DCEDC8",
        "#FFF9C4", "#FFE082", "#FFCC80", "#FFAB91",
        "#F48FB1", "#CE93D8", "#90CAF9", "#80DEEA",
    );

    my $n = $#dic < (MAX_DIC - 1) ? $#dic : (MAX_DIC - 1);

    for my $i (0 .. $n) {
        my $e   = $dic[$i];
        my $id  = "dic_$e->{codigo}";
        my $col = $paleta[$i % scalar @paleta];

        my $pat = _esc_dot($e->{patron});
        my $ow  = _esc_dot($e->{origen_w});
        my $oc  = _esc_dot($e->{origen_c});

        print $fh "    $id [\n";
        print $fh "        shape=record\n";
        print $fh "        fillcolor=\"$col\"\n";
        print $fh "        label=\"{dic[$e->{codigo}] | patron: '$pat' | W='$ow'  +  C='$oc'}\"\n";
        print $fh "    ];\n";
    }

    # Nodo resumen si hay mas entradas que MAX_DIC
    if (@dic > MAX_DIC) {
        my $resto = @dic - MAX_DIC;
        print $fh "    dic_resto [\n";
        print $fh "        shape=box\n";
        print $fh "        fillcolor=\"#EEEEEE\"\n";
        print $fh "        label=\"... $resto entradas adicionales ...\"\n";
        print $fh "    ];\n";
    }

    print $fh "\n";

    # -------- Aristas --------
    if (@dic) {
        # Stats apunta a la primera entrada nueva del diccionario
        print $fh "    stats -> dic_$dic[0]->{codigo} [label=\"dic generado\"];\n";

        # Cadena lineal: cada entrada apunta a la siguiente
        for my $i (0 .. ($n - 1)) {
            print $fh "    dic_$dic[$i]->{codigo} -> dic_$dic[$i+1]->{codigo};\n";
        }

        # Ultima entrada visible apunta al nodo resumen (si existe)
        if (@dic > MAX_DIC) {
            print $fh "    dic_$dic[$n]->{codigo} -> dic_resto;\n";
        }
    }

    print $fh "}\n";
    close($fh);

    # -------- Invocar Graphviz --------
    my $salida = `dot -Tpng "$dot_file" -o "$png_file" 2>&1`;
    my $exit   = $? >> 8;

    if ($exit == 0) {
        print "Imagen generada correctamente: $png_file\n";
    } else {
        print "Error al generar la imagen.\n";
        print "$salida\n" if $salida;
    }
}

# ---------------------------------------------------------------
# Escapa caracteres especiales en etiquetas de tipo record DOT.
# Los caracteres | { } < > " \ tienen significado especial
# dentro de un label="{...}" y deben ir precedidos de \
# ---------------------------------------------------------------
sub _esc_dot {
    my ($s) = @_;
    $s =~ s/\\/\\\\/g;   # primero los backslash (evita doble escape)
    $s =~ s/"/\\"/g;
    $s =~ s/\|/\\|/g;
    $s =~ s/\{/\\{/g;
    $s =~ s/\}/\\}/g;
    $s =~ s/</\\</g;
    $s =~ s/>/\\>/g;
    $s =~ s/\n/\\n/g;
    return $s;
}

1;
