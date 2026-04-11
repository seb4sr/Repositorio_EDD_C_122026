#!/usr/bin/perl


use strict;
use warnings;
use lib '.';

use grafo::grafo;
use grafo::graficar;

print "=" x 60 . "\n";
print "  DEMOSTRACION: Grafo No Dirigido\n";
print "  Red de Colaboracion Interprofesional\n";
print "=" x 60 . "\n\n";

my $red = grafo::grafo->new();
print "Grafo creado. Esta vacio? " . ($red->is_empty() ? "Si" : "No") . "\n\n";

print "-" x 60 . "\n";
print "1. AGREGANDO PROFESIONALES (nodos)\n";
print "   Formato: ID_colegio, Nombre, Departamento, Tipo\n";
print "-" x 60 . "\n";

$red->agregar_nodo("COL-101", "Ana Ramirez",     "DEP-MED", "TIPO-01");
$red->agregar_nodo("COL-102", "Carlos Mendoza",  "DEP-CIR", "TIPO-02");
$red->agregar_nodo("COL-103", "Lucia Flores",    "DEP-MED", "TIPO-03");
$red->agregar_nodo("COL-104", "Pedro Alvarado",  "DEP-LAB", "TIPO-04");
$red->agregar_nodo("COL-105", "Maria Lopez",     "DEP-FAR", "TIPO-03");
$red->agregar_nodo("COL-106", "Jorge Morales",   "DEP-CIR", "TIPO-02");
$red->agregar_nodo("COL-107", "Sofia Castro",    "SIN-DEP", "TIPO-01");
$red->agregar_nodo("COL-108", "Diego Herrera",   "DEP-MED", "TIPO-01");

print "\n>> Intentando agregar nodo duplicado:\n";
$red->agregar_nodo("COL-101", "Duplicado", "DEP-MED", "TIPO-01");

printf("\nTotal de profesionales registrados: %d\n", $red->get_num_nodos());

print "\n" . "-" x 60 . "\n";
print "2. CREANDO COLABORACIONES (aristas no dirigidas)\n";
print "   Recuerda: A -- B significa que ambos son colaboradores\n";
print "-" x 60 . "\n";


$red->agregar_arista("COL-101", "COL-102");
$red->agregar_arista("COL-101", "COL-103");
$red->agregar_arista("COL-101", "COL-108");
$red->agregar_arista("COL-102", "COL-106");
$red->agregar_arista("COL-103", "COL-105");
$red->agregar_arista("COL-104", "COL-106");

print "\n>> Intentando arista duplicada:\n";
$red->agregar_arista("COL-101", "COL-102");

print "\n>> Intentando bucle (auto-arista):\n";
$red->agregar_arista("COL-101", "COL-101");

printf("\nTotal de colaboraciones activas: %d aristas\n", $red->get_num_aristas());

print "\n" . "-" x 60 . "\n";
print "3. CONSULTAS BASICAS\n";
print "-" x 60 . "\n";

print "\nGrado (numero de colaboradores) de cada profesional:\n";
for my $id ($red->get_todos_ids()) {
    my $nodo = $red->get_nodo($id);
    printf("  %-10s %-20s -> grado: %d\n",
        $id, $nodo->get_nombre(), $red->grado($id));
}

print "\nÂ¿COL-101 y COL-102 son colaboradores? ";
print $red->son_vecinos("COL-101", "COL-102") ? "SI\n" : "NO\n";

print "Â¿COL-101 y COL-106 son colaboradores? ";
print $red->son_vecinos("COL-101", "COL-106") ? "SI\n" : "NO\n";

print "\nVecinos directos de COL-102 (Carlos Mendoza):\n";
for my $v ($red->get_vecinos("COL-102")) {
    my $n = $red->get_nodo($v);
    print "  - $v : " . $n->get_nombre() . " (" . $n->get_departamento() . ")\n";
}

print "\n" . "-" x 60 . "\n";
print "4. LISTA DE ADYACENCIA (representacion interna)\n";
print "-" x 60 . "\n";

$red->imprimir_lista_adyacencia();

print "-" x 60 . "\n";
print "5. RECORRIDO BFS (anchura / por niveles)\n";
print "\n";
print "   BFS visita primero todos los vecinos directos\n";
print "   del nodo origen, luego los vecinos de esos vecinos,\n";
print "   y asi sucesivamente. Usa una COLA (FIFO).\n";
print "\n";
print "   Nivel 0: COL-101\n";
print "   Nivel 1: COL-102, COL-103, COL-108  (vecinos directos)\n";
print "   Nivel 2: COL-106, COL-105  (vecinos de los anteriores)\n";
print "   Nivel 3: COL-104  (vecino de COL-106)\n";
print "-" x 60 . "\n";

my @orden_bfs = $red->bfs("COL-101");
print "\n  Orden BFS: " . join(" -> ", @orden_bfs) . "\n";

print "\n" . "-" x 60 . "\n";
print "6. RECORRIDO DFS (profundidad)\n";
print "\n";
print "   DFS va lo mas profundo posible por cada rama antes\n";
print "   de retroceder. Usa RECURSION (pila implicita).\n";
print "-" x 60 . "\n";

my @orden_dfs = $red->dfs("COL-101");
print "\n  Orden DFS: " . join(" -> ", @orden_dfs) . "\n";

print "\n" . "-" x 60 . "\n";
print "7. SUGERENCIAS DE COLABORACION (BFS de 2 saltos)\n";
print "\n";
print "   Busca 'amigos de amigos' de COL-103 (Lucia Flores):\n";
print "   - Vecinos directos de Lucia: COL-101, COL-105\n";
print "   - Vecinos de COL-101: COL-102, COL-108  <- candidatos\n";
print "   - Vecinos de COL-105: (ninguno nuevo)\n";
print "   Sugerencias ordenadas por vecinos en comun.\n";
print "-" x 60 . "\n";

my @sugs = $red->sugerencias_colaboracion("COL-103");
if (@sugs) {
    print "\n  Sugerencias para Lucia Flores (COL-103):\n";
    for my $s (@sugs) {
        my $nodo = $red->get_nodo($s->{id});
        printf("  -> %-10s %-20s  (vecinos en comun: %d)\n",
            $s->{id}, $nodo->get_nombre(), $s->{comunes});
    }
} else {
    print "\n  Sin sugerencias disponibles.\n";
}

print "\n" . "-" x 60 . "\n";
print "8. NODOS AISLADOS Y CONECTIVIDAD\n";
print "-" x 60 . "\n";

my @aislados = $red->nodos_aislados();
if (@aislados) {
    print "\nProfesionales sin ninguna colaboracion (aislados):\n";
    for my $id (@aislados) {
        my $n = $red->get_nodo($id);
        print "  -> $id : " . $n->get_nombre() . " (" . $n->get_departamento() . ")\n";
    }
} else {
    print "\nTodos los profesionales tienen al menos un colaborador.\n";
}

print "\nEl grafo es conexo (todos los nodos alcanzables)? ";
print $red->es_conexo() ? "SI\n" : "NO (existen nodos desconectados)\n";

print "\n" . "-" x 60 . "\n";
print "9. ELIMINAR ARISTA Y NODO\n";
print "-" x 60 . "\n";

print "\n>> Eliminando la colaboracion COL-103 -- COL-105:\n";
$red->eliminar_arista("COL-103", "COL-105");

print "\n>> Lista de adyacencia tras eliminar arista:\n";
$red->imprimir_lista_adyacencia();

print ">> Eliminando el nodo COL-104 (Pedro Alvarado):\n";
$red->eliminar_nodo("COL-104");

printf("\nEstado final: %d nodos, %d aristas\n",
    $red->get_num_nodos(), $red->get_num_aristas());

print "\n" . "-" x 60 . "\n";
print "10. GENERANDO REPORTES CON GRAPHVIZ\n";
print "-" x 60 . "\n\n";

grafo::graficar->graficar_grafo(
    $red, "grafo_colaboracion"
);

grafo::graficar->graficar_lista_adyacencia(
    $red, "lista_adyacencia"
);

print "\n" . "=" x 60 . "\n";
print "  FIN DE LA DEMOSTRACION\n";
print "=" x 60 . "\n";


