package TablaHash::graficar;

use strict;
use warnings;

my %COLOR_TIPO = (
    'TIPO-01' => '#AED6F1',
    'TIPO-02' => '#FAD7A0',
    'TIPO-03' => '#A9DFBF',
    'TIPO-04' => '#F9E79F',
);

my $COLOR_EMPTY  = '#F2F3F4';
my $COLOR_BUCKET = '#D5D8DC';
my $COLOR_NULL   = '#FADBD8';
my $COLOR_DEFAULT = '#FDFEFE';


sub graficar_tabla_hash {
    my ($class, $tabla, $basename) = @_;

    my $dot_file = "reportes/$basename.dot";
    my $png_file = "reportes/$basename.png";

    system("mkdir reportes 2>nul") unless -d "reportes";

    open(my $fh, '>', $dot_file) or die "No se pudo crear $dot_file: $!";

    print $fh "digraph TablaHash {\n";
    print $fh "    rankdir=LR;\n";
    print $fh "    splines=ortho;\n";
    print $fh "    node [shape=record, style=filled, fontname=\"Courier\", fontsize=10];\n";
    print $fh "    edge [arrowhead=vee, fontname=\"Arial\", fontsize=9];\n\n";

    # Leyenda de tipos
    print $fh "    subgraph cluster_leyenda {\n";
    print $fh "        label=\"Tipos de Usuario\";\n";
    print $fh "        style=dotted;\n";
    print $fh "        fontname=\"Arial Bold\";\n";
    for my $tipo (sort keys %COLOR_TIPO) {
        my $nid = $tipo; $nid =~ s/-/_/g;
        print $fh "        ley_$nid [label=\"$tipo\", fillcolor=\"$COLOR_TIPO{$tipo}\", shape=box];\n";
    }
    print $fh "    }\n\n";

    # Titulo con estadisticas
    my $total    = $tabla->get_total();
    my $size     = $tabla->get_size();
    my $col      = $tabla->get_colisiones();
    my $fc       = sprintf("%.2f", $tabla->get_factor_carga());
    print $fh "    titulo [label=\"Tabla Hash\\nSize=$size | Total=$total | Colisiones=$col | FC=$fc\",\n";
    print $fh "            shape=box, fillcolor=\"#EAECEE\", fontsize=12];\n\n";

    my $buckets = $tabla->get_buckets();

    # Columna de buckets (indices)
    for my $i (0 .. $size - 1) {
        my $bucket = $buckets->[$i];
        if (@$bucket) {
            my $n   = scalar @$bucket;
            my $tip = $bucket->[0]{tipo};
            print $fh "    bucket_$i [label=\"{bucket[$i] | $tip | $n nodo(s)}\", fillcolor=\"$COLOR_BUCKET\"];\n";
        } else {
            print $fh "    bucket_$i [label=\"{bucket[$i] | vacio}\", fillcolor=\"$COLOR_EMPTY\"];\n";
        }
    }

    print $fh "\n";

    # Cadenas (chaining) dentro de cada bucket
    for my $i (0 .. $size - 1) {
        my $bucket = $buckets->[$i];
        next unless @$bucket;

        for my $j (0 .. $#$bucket) {
            my $e     = $bucket->[$j];
            my $color = $COLOR_TIPO{ $e->{tipo} } // $COLOR_DEFAULT;
            my $label = "$e->{numero_colegio}\\n$e->{nombre}\\n$e->{departamento} | $e->{tipo}";
            print $fh "    node_${i}_$j [label=\"{$label}\", fillcolor=\"$color\"];\n";
        }

        # Aristas de la cadena
        print $fh "    bucket_$i -> node_${i}_0;\n";
        for my $j (0 .. $#$bucket - 1) {
            print $fh "    node_${i}_$j -> node_${i}_" . ($j + 1) . ";\n";
        }

        # Terminador NULL
        print $fh "    null_$i [label=\"NULL\", fillcolor=\"$COLOR_NULL\"];\n";
        print $fh "    node_${i}_$#$bucket -> null_$i;\n";
    }

    print $fh "}\n";
    close($fh);

    return $class->_compilar($dot_file, $png_file);
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
