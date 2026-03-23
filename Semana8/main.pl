#!/usr/bin/perl

use strict;
use warnings;
use lib '.';

use btree::btree;
use btree::graficar;

print "=" x 60 . "\n";
print "  DEMOSTRACION: Arbol B de Orden 4\n";
print "=" x 60 . "\n\n";

my $arbol = btree::btree->new();
print "Arbol B creado. Esta vacio? " . ($arbol->is_empty() ? "Si" : "No") . "\n\n";

print "-" x 60 . "\n";
print "INSERTANDO VALORES:\n";
print "-" x 60 . "\n";

foreach my $val (5, 10, 15, 20,3) {
    print "\n>> Insertando $val:\n";
    $arbol->insertar($val);
}

print "\nTamano del arbol: " . $arbol->get_size() . " claves\n";

print "\n" . "-" x 60 . "\n";
print "VALIDACION DE PROPIEDADES DEL ARBOL B:\n";
print "-" x 60 . "\n";
my ($ok, $detalle) = $arbol->validar_propiedades();
print (($ok ? "VALIDO: " : "INVALIDO: ") . "$detalle\n");

print "\n" . "-" x 60 . "\n";
print "INTENTANDO INSERTAR DUPLICADO (30):\n";
print "-" x 60 . "\n";
#$arbol->insertar(30);

print "\n" . "-" x 60 . "\n";
print "ESTRUCTURA ACTUAL DEL ARBOL:\n";
print "-" x 60 . "\n";
$arbol->imprimir_arbol();

print "-" x 60 . "\n";
print "RECORRIDO:\n";
print "-" x 60 . "\n";
$arbol->recorrido_inorden();

print "\n" . "-" x 60 . "\n";
print "BUSQUEDA:\n";
print "-" x 60 . "\n";

my $encontrado = $arbol->buscar(65);
print "Buscar 65: " . (defined($encontrado) ? "ENCONTRADO en nodo -> " . $encontrado->to_string() : "NO encontrado\n");

my $no_existe = $arbol->buscar(999);
print "Buscar 999: " . (defined($no_existe) ? "ENCONTRADO\n" : "NO encontrado\n");

print "\n" . "-" x 60 . "\n";
print "MINIMO Y MAXIMO:\n";
print "-" x 60 . "\n";
print "Valor minimo: " . $arbol->encontrar_minimo() . "\n";
print "Valor maximo: " . $arbol->encontrar_maximo() . "\n";

print "\n" . "-" x 60 . "\n";
print "GENERANDO IMAGEN CON GRAPHVIZ:\n";
print "-" x 60 . "\n";
btree::graficar->graficar($arbol, "mi_arbol_b_orden4");

print "\n" . "=" x 60 . "\n";
print "  FIN DE LA DEMOSTRACION\n";
print "=" x 60 . "\n";
