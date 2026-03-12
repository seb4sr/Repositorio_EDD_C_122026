#!/usr/bin/perl

use strict;
use warnings;
use lib '.';

use bst::bst;

print "=" x 60 . "\n";
print "  DEMOSTRACION: Arbol Binario de Busqueda (BST)\n";
print "=" x 60 . "\n\n";

my $arbol = bst::bst->new();
print "Arbol creado. Esta vacio? " . ($arbol->is_empty() ? "Si" : "No") . "\n\n";

print "-" x 40 . "\n";
print "INSERTANDO VALORES:\n";
print "-" x 40 . "\n";

$arbol->insertar(10);
$arbol->insertar(20);
$arbol->insertar(30);
$arbol->insertar(50);
$arbol->insertar(40);
$arbol->insertar(5);
$arbol->insertar(1);
$arbol->insertar(25);




print "\nTamano del arbol: " . $arbol->get_size() . " nodos\n";

print "\nIntentando insertar duplicado (50):\n";
$arbol->insertar(50);

print "-" x 40 . "\n";
print "RECORRIDOS:\n";
print "-" x 40 . "\n";
$arbol->recorrido_inorden();
$arbol->recorrido_preorden();
$arbol->recorrido_postorden();

print "\n";
print "-" x 40 . "\n";
print "BUSQUEDA:\n";
print "-" x 40 . "\n";

my $encontrado = $arbol->buscar(40);
print "Buscar 40: " . (defined($encontrado) ? "ENCONTRADO -> " . $encontrado->to_string() : "NO encontrado\n");

my $no_existe = $arbol->buscar(99);
print "Buscar 99: " . (defined($no_existe) ? "ENCONTRADO\n" : "NO encontrado\n");

print "\n";
print "-" x 40 . "\n";
print "MINIMO Y MAXIMO:\n";
print "-" x 40 . "\n";
print "Valor minimo: " . $arbol->encontrar_minimo() . "\n";
print "Valor maximo: " . $arbol->encontrar_maximo() . "\n";



print "\nTamano final del arbol: " . $arbol->get_size() . " nodos\n";
$arbol->recorrido_inorden();

use bst::graficar;
bst::graficar->graficar($arbol, "mi_arbol");

print "\n" . "=" x 60 . "\n";
print "  FIN DE LA DEMOSTRACION\n";
print "=" x 60 . "\n";
