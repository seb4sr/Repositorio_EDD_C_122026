package lzw::lzw;

use strict;
use warnings;

# ---------------------------------------------------------------
# Constructor
# ---------------------------------------------------------------
sub new {
    my ($class) = @_;
    return bless {
        _codigos      => [],   # codigos emitidos en la ultima compresion
        _dic_nuevas   => [],   # nuevas entradas del diccionario [{codigo,patron,origen_w,origen_c}]
        _estadisticas => {},
    }, $class;
}

# ---------------------------------------------------------------
# COMPRESION
#
# Algoritmo LZW estandar:
#   1. Inicializar diccionario con los 256 simbolos ASCII.
#   2. Acumular caracteres en un buffer W hasta que W+C no este
#      en el diccionario.
#   3. Emitir el codigo de W, agregar W+C al diccionario y
#      reiniciar el buffer con el caracter C que no encajo.
#   4. Al terminar el texto, emitir el codigo del buffer restante.
# ---------------------------------------------------------------
sub comprimir {
    my ($self, $texto) = @_;

    $self->{_codigos}      = [];
    $self->{_dic_nuevas}   = [];
    $self->{_estadisticas} = {};

    # --- Fase de inicializacion ---
    my %dic;
    for my $i (0..255) {
        $dic{chr($i)} = $i;
    }
    my $sig = 256;  # proximo codigo libre

    my $w    = "";
    my $paso = 0;

    printf "  Longitud de entrada   : %d caracteres\n", length($texto);
    printf "  Diccionario inicial   : 256 entradas (ASCII 0-255)\n";
    printf "  Primer codigo libre   : %d\n\n", $sig;

    printf "  %-4s  %-14s %-14s  %-6s  %s\n",
        "PASO", "W  (buffer)", "C  (entrante)", "EMITE", "NUEVA ENTRADA DIC";
    print  "  " . "-" x 60 . "\n";

    # --- Fase de codificacion ---
    for my $c (split //, $texto) {
        my $wc = $w . $c;

        if (exists $dic{$wc}) {
            # WC ya esta en el diccionario: extender el buffer sin emitir
            $w = $wc;
        } else {
            # WC no existe: emitir codigo de W y registrar WC como nueva entrada
            my $cod = $dic{$w};
            push @{$self->{_codigos}}, $cod;

            $dic{$wc} = $sig;
            push @{$self->{_dic_nuevas}}, {
                codigo   => $sig,
                patron   => $wc,
                origen_w => $w,
                origen_c => $c,
            };

            $paso++;
            printf "  %-4d  '%-12s'  '%-12s'  %-6d  dic[%d] = '%s'\n",
                $paso, _esc($w), _esc($c), $cod, $sig, _esc($wc);

            $sig++;
            $w = $c;   # el caracter que no encajo inicia el proximo buffer
        }
    }

    # Emitir el ultimo buffer acumulado
    if ($w ne "") {
        my $cod = $dic{$w};
        push @{$self->{_codigos}}, $cod;
        $paso++;
        printf "  %-4d  '%-12s'  '%-12s'  %-6d  (fin de entrada)\n",
            $paso, _esc($w), "---", $cod;
    }

    print "  " . "-" x 60 . "\n\n";

    # Guardar estadisticas para el reporte
    my $n_chars = length($texto);
    my $n_cods  = scalar @{$self->{_codigos}};
    $self->{_estadisticas} = {
        chars_originales => $n_chars,
        codigos_emitidos => $n_cods,
        entradas_nuevas  => scalar @{$self->{_dic_nuevas}},
        ratio            => ($n_cods > 0)
                              ? sprintf("%.2f", $n_chars / $n_cods)
                              : "N/A",
    };

    return @{$self->{_codigos}};
}

# ---------------------------------------------------------------
# DESCOMPRESION
#
# Algoritmo LZW inverso:
#   1. Inicializar el mismo diccionario base de 256 entradas.
#   2. Leer el primer codigo y emitir su cadena; ese es el W inicial.
#   3. Para cada codigo K siguiente:
#        a. Si K esta en el diccionario, entrada = dic[K].
#        b. Caso especial (K aun no en dic): entrada = W + W[0].
#        c. Emitir entrada.
#        d. Agregar dic[sig] = W + entrada[0].
#        e. W = entrada.
#
# Nota: el caso especial ocurre cuando el codificador genera
# una entrada nueva cuyo codigo es el mismo que acaba de emitir
# (patron de la forma XXX... donde X se repite).
# ---------------------------------------------------------------
sub descomprimir {
    my ($self, @codigos) = @_;

    return "" unless @codigos;

    my %dic;
    for my $i (0..255) {
        $dic{$i} = chr($i);
    }
    my $sig = 256;

    my $primer = shift @codigos;
    my $w      = $dic{$primer};
    my $salida = $w;
    my $paso   = 1;

    printf "  Diccionario inicial   : 256 entradas (ASCII 0-255)\n\n";
    printf "  %-4s  %-8s  %-22s  %s\n",
        "PASO", "CODIGO", "DECODIFICA", "NUEVA ENTRADA DIC";
    print "  " . "-" x 60 . "\n";
    printf "  %-4d  %-8d  '%-20s'  (primer simbolo)\n",
        $paso, $primer, _esc($w);

    for my $cod (@codigos) {
        $paso++;
        my $entrada;

        if (exists $dic{$cod}) {
            $entrada = $dic{$cod};
        } else {
            # Caso especial: el decodificador aun no tiene este codigo.
            # La entrada es W concatenado con su primer caracter.
            $entrada = $w . substr($w, 0, 1);
            printf "  [Caso especial] Codigo %d no en dic aun. Entrada calculada: '%s'\n",
                $cod, _esc($entrada);
        }

        $salida .= $entrada;

        my $nueva = $w . substr($entrada, 0, 1);
        $dic{$sig} = $nueva;

        printf "  %-4d  %-8d  '%-20s'  dic[%d] = '%s'\n",
            $paso, $cod, _esc($entrada), $sig, _esc($nueva);

        $sig++;
        $w = $entrada;
    }

    print "  " . "-" x 60 . "\n\n";

    return $salida;
}

# ---------------------------------------------------------------
# Accesores
# ---------------------------------------------------------------
sub get_codigos      { return @{$_[0]->{_codigos}};    }
sub get_dic_nuevas   { return @{$_[0]->{_dic_nuevas}}; }
sub get_estadisticas { return $_[0]->{_estadisticas};  }

# Escapa caracteres de control para visualizacion en consola
sub _esc {
    my ($s) = @_;
    $s =~ s/\n/\\n/g;
    $s =~ s/\t/\\t/g;
    return $s;
}

1;
