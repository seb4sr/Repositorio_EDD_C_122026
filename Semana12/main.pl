#!/usr/bin/perl

use strict;
use warnings;
use lib '.';

use lzw::lzw;
use lzw::graficar;

print "=" x 60 . "\n";
print "  DEMOSTRACION: Compresion y Descompresion LZW\n";
print "=" x 60 . "\n\n";

# ---------------------------------------------------------------
# Texto de prueba: bitacora de eventos de solicitudes medicas.
#
# Se elige un texto con repeticion deliberada para ilustrar
# como LZW construye su diccionario y aprovecha los patrones
# repetidos para emitir codigos en lugar de caracteres sueltos.
#
# En este caso el patron "MED-SOL" aparece varias veces; en las
# primeras ocurrencias LZW lo registra en el diccionario y en
# las siguientes ya puede referenciarlo con un solo codigo.
# ---------------------------------------------------------------
my $texto = "MED-SOL MED-SOL MED-APR MED-SOL";

print "Texto de entrada:\n";
printf "  '%s'\n", $texto;
printf "  Longitud: %d caracteres\n\n", length($texto);

# ===============================================================
print "-" x 60 . "\n";
print "FASE 1 - COMPRESION\n";
print "-" x 60 . "\n\n";
# ===============================================================

my $lzw     = lzw::lzw->new();
my @codigos = $lzw->comprimir($texto);

print "Secuencia de codigos emitidos:\n";
print "  [ " . join(", ", @codigos) . " ]\n\n";

my $st = $lzw->get_estadisticas();
print "Resumen de compresion:\n";
printf "  Chars originales    : %d\n",  $st->{chars_originales};
printf "  Codigos generados   : %d\n",  $st->{codigos_emitidos};
printf "  Entradas nuevas dic : %d\n",  $st->{entradas_nuevas};
printf "  Ratio chars/codigos : %sx\n\n", $st->{ratio};

# ===============================================================
print "-" x 60 . "\n";
print "FASE 2 - DESCOMPRESION\n";
print "-" x 60 . "\n\n";
# ===============================================================

# La descompresion usa un objeto nuevo con su propio diccionario.
# Solo recibe los codigos numericos; reconstruye el texto original
# rehaciendo los mismos pasos del codificador en sentido inverso.
my $lzw2       = lzw::lzw->new();
my $recuperado = $lzw2->descomprimir(@codigos);

print "Texto recuperado:\n";
printf "  '%s'\n\n", $recuperado;

# ===============================================================
print "-" x 60 . "\n";
print "VERIFICACION DE INTEGRIDAD\n";
print "-" x 60 . "\n";
# ===============================================================

if ($texto eq $recuperado) {
    print "  OK -> Los textos son identicos.\n";
    print "       El ciclo comprimir -> descomprimir es correcto.\n";
} else {
    print "  ERROR -> Los textos difieren.\n";
    printf "  Original  : '%s'\n", $texto;
    printf "  Obtenido  : '%s'\n", $recuperado;
}

# ===============================================================
print "\n" . "-" x 60 . "\n";
print "COMPARATIVA: longitud original vs numero de codigos\n";
print "-" x 60 . "\n";
# ===============================================================

my $n_orig = $st->{chars_originales};
my $n_cod  = $st->{codigos_emitidos};
my $ratio  = $st->{ratio};

printf "  Texto original   : %d caracteres  %s\n",
    $n_orig, "#" x $n_orig;
printf "  Codigos LZW      : %d codigos     %s\n",
    $n_cod, "#" x $n_cod;
printf "  Reduccion        : %.0f%% menos tokens (ratio %sx)\n\n",
    (1 - $n_cod / $n_orig) * 100, $ratio;

# ===============================================================
print "-" x 60 . "\n";
print "GENERANDO REPORTE CON GRAPHVIZ\n";
print "-" x 60 . "\n";
# ===============================================================

lzw::graficar->graficar($lzw, "reporte_lzw");

print "\n" . "=" x 60 . "\n";
print "  FIN DE LA DEMOSTRACION\n";
print "=" x 60 . "\n";
