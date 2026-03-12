#!/usr/bin/perl

use strict;
use warnings;
use lib '.';

use avl::avl;
use avl::graficar;

print "=" x 60 . "\n";
print "  DEMOSTRACION: Arbol AVL (Adelson-Velsky y Landis)\n";
print "=" x 60 . "\n\n";

my $arbol = avl::avl->new();
print "Arbol creado. Esta vacio? " . ($arbol->is_empty() ? "Si" : "No") . "\n\n";

# ---------------------------------------------------------------
print "-" x 60 . "\n";
print "INSERTANDO VALORES (observar rotaciones automaticas):\n";
print "-" x 60 . "\n";

# Insertar valores que provocaran rotaciones:
#   10, 20, 30  -> Caso RR (rotacion izquierda en raiz)
#   50, 40      -> Caso RL (rotacion doble derecha+izquierda)
#    5,  1      -> Caso LL (rotacion derecha)
#   25          -> Caso LR (rotacion doble izquierda+derecha)

foreach my $val (10, 20, 30, 50, 40, 5, 1, 25,70,45,105) {
    print "\n>> Insertando $val:\n";
    $arbol->insertar($val);
}

print "\nTamano del arbol: " . $arbol->get_size() . " nodos\n";

# ---------------------------------------------------------------
print "\n" . "-" x 60 . "\n";
print "INTENTANDO INSERTAR DUPLICADO (20):\n";
print "-" x 60 . "\n";
$arbol->insertar(20);

# ---------------------------------------------------------------
print "\n" . "-" x 60 . "\n";
print "ESTRUCTURA ACTUAL DEL ARBOL:\n";
print "-" x 60 . "\n";
print "(cada nodo muestra: [valor | h=altura | bf=factor_de_balance])\n";
$arbol->imprimir_arbol();

# ---------------------------------------------------------------
print "-" x 60 . "\n";
print "RECORRIDOS:\n";
print "-" x 60 . "\n";
$arbol->recorrido_inorden();
$arbol->recorrido_preorden();
$arbol->recorrido_postorden();

# ---------------------------------------------------------------
print "\n" . "-" x 60 . "\n";
print "BUSQUEDA:\n";
print "-" x 60 . "\n";

my $encontrado = $arbol->buscar(40);
print "Buscar 40: " . (defined($encontrado) ? "ENCONTRADO -> " . $encontrado->to_string() : "NO encontrado\n");

my $no_existe = $arbol->buscar(99);
print "Buscar 99: " . (defined($no_existe) ? "ENCONTRADO\n" : "NO encontrado\n");

# ---------------------------------------------------------------
print "\n" . "-" x 60 . "\n";
print "MINIMO Y MAXIMO:\n";
print "-" x 60 . "\n";
print "Valor minimo: " . $arbol->encontrar_minimo() . "\n";
print "Valor maximo: " . $arbol->encontrar_maximo() . "\n";

# ---------------------------------------------------------------
print "\n" . "-" x 60 . "\n";
print "ELIMINANDO NODOS (observar rebalanceo):\n";
print "-" x 60 . "\n";

print "\n>> Eliminando 10:\n";
$arbol->eliminar(10);
print "\nEstructura tras eliminar 10:\n";
$arbol->imprimir_arbol();

print ">> Eliminando 50:\n";
$arbol->eliminar(50);
print "\nEstructura tras eliminar 50:\n";
$arbol->imprimir_arbol();

print ">> Intentando eliminar valor inexistente (99):\n";
$arbol->eliminar(99);

# ---------------------------------------------------------------
print "-" x 60 . "\n";
print "RECORRIDO FINAL:\n";
print "-" x 60 . "\n";
print "Tamano final: " . $arbol->get_size() . " nodos\n";
$arbol->recorrido_inorden();

# ---------------------------------------------------------------
print "\n" . "-" x 60 . "\n";
print "GENERANDO IMAGEN CON GRAPHVIZ:\n";
print "-" x 60 . "\n";
avl::graficar->graficar($arbol, "mi_arbol_avl");

print "\n" . "=" x 60 . "\n";
print "  FIN DE LA DEMOSTRACION\n";
print "=" x 60 . "\n";
