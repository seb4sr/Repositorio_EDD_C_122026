#!/usr/bin/perl

use strict;
use warnings;
use lib '.';

use TablaHash::tabla;
use TablaHash::graficar;

print "=" x 65 . "\n";
print "  DEMOSTRACION: Tabla Hash\n";
print "  Directorio del Personal por Tipo - Hospital General San Carlos\n";
print "=" x 65 . "\n\n";


# ================================================================
# 1. FUNCION HASH - explicacion paso a paso
# ================================================================
print "-" x 65 . "\n";
print "1. FUNCION HASH  (extraccion numerica del tipo)\n";
print "\n";
print "   El enunciado define claves fijas: TIPO-01 .. TIPO-04.\n";
print "   Como las claves son conocidas, usamos un hash especifico\n";
print "   que extrae el numero al final de la clave:\n";
print "\n";
print "   hash(clave) = (numero_extraido - 1) % size\n";
print "\n";
print "   Con size=4 obtenemos hash perfecto (0 colisiones):\n";
print "\n";

my @tipos_demo = ("TIPO-01", "TIPO-02", "TIPO-03", "TIPO-04");
for my $tipo (@tipos_demo) {
    $tipo =~ /(\d+)$/;
    my $num = $1;
    my $idx = ($num - 1) % 4;
    printf("   hash(\"%-7s\") = (%d - 1) %% 4 = %d  -> bucket[%d]\n",
           $tipo, $num, $idx, $idx);
}
print "\n";
print "   Cada tipo cae en un bucket exclusivo. Hash perfecto.\n";
print "\n";
print "   COMPARACION con suma-ASCII (funcion debil):\n";
for my $tipo (@tipos_demo) {
    my $suma = 0;
    $suma += ord($_) for split //, $tipo;
    printf("   suma_ascii(\"%-7s\") = %d  -> buckets consecutivos, fragil\n",
           $tipo, $suma);
}
print "-" x 65 . "\n\n";


# ================================================================
# 2. CREAR TABLA Y AGREGAR PROFESIONALES
# ================================================================
print "-" x 65 . "\n";
print "2. CREANDO TABLA HASH (size=4) E INSERTANDO PERSONAL\n";
print "   Cada usuario se inserta por su tipo; si hay varios del\n";
print "   mismo tipo se encadenan dentro del mismo bucket.\n";
print "-" x 65 . "\n\n";

my $tabla = TablaHash::tabla->new(size => 4);

print "-- Medicos Generales (TIPO-01) -> bucket[0] --\n";
$tabla->insertar("TIPO-01", "COL-10245", "Ana Ramirez",    "DEP-MED", "Medicina General");
$tabla->insertar("TIPO-01", "COL-10389", "Luis Perez",     "DEP-MED", "Medicina Interna");
$tabla->insertar("TIPO-01", "COL-99001", "Josesito Lopez", "SIN-DEP", "Medicina Interna");

print "\n-- Medicos Especialistas / Cirujanos (TIPO-02) -> bucket[1] --\n";
$tabla->insertar("TIPO-02", "COL-20134", "Carlos Mendoza", "DEP-CIR", "Cirugia General");
$tabla->insertar("TIPO-02", "COL-20567", "Marta Estrada",  "DEP-CIR", "Cirugia Cardiaca");

print "\n-- Enfermeros/as (TIPO-03) -> bucket[2] --\n";
$tabla->insertar("TIPO-03", "COL-30101", "Lucia Flores",   "DEP-MED", "Enfermeria General");
$tabla->insertar("TIPO-03", "COL-30412", "Rosa Mendez",    "DEP-FAR", "Farmacologia");
$tabla->insertar("TIPO-03", "COL-30888", "Juan Castillo",  "DEP-CIR", "Enfermeria Quirurgica");

print "\n-- Tecnicos de Laboratorio (TIPO-04) -> bucket[3] --\n";
$tabla->insertar("TIPO-04", "COL-40210", "Pedro Alvarado", "DEP-LAB", "Bioquimica Clinica");

print "\n>> Intentando insertar duplicado:\n";
$tabla->insertar("TIPO-01", "COL-10245", "Otro Nombre", "DEP-MED", "Medicina General");


# ================================================================
# 3. ESTADO ACTUAL DE LA TABLA
# ================================================================
print "\n" . "-" x 65 . "\n";
print "3. ESTADO ACTUAL DE LA TABLA HASH\n";
print "-" x 65 . "\n\n";

$tabla->imprimir_estado();


# ================================================================
# 4. BUSQUEDA POR TIPO (O(1) al bucket + recorrer la cadena)
# ================================================================
print "\n" . "-" x 65 . "\n";
print "4. BUSQUEDA POR TIPO\n";
print "\n";
print "   El administrador selecciona TIPO-03 (Enfermeros).\n";
print "   hash('TIPO-03') = (3-1) % 4 = 2, va directo al\n";
print "   bucket[2] y retorna toda la cadena en tiempo constante.\n";
print "-" x 65 . "\n\n";

for my $tipo_consulta ("TIPO-01", "TIPO-03") {
    $tipo_consulta =~ /(\d+)$/;
    my $idx = ($1 - 1) % 4;
    printf("  Consultando %s (hash=(%d-1)%%4=%d, bucket[%d]):\n",
           $tipo_consulta, $1, $idx, $idx);

    my @resultado = $tabla->buscar_por_tipo($tipo_consulta);
    if (@resultado) {
        printf("  %-14s %-22s %-12s %s\n",
               "No. Colegio", "Nombre", "Depto.", "Especialidad");
        print "  " . "-" x 62 . "\n";
        for my $e (@resultado) {
            printf("  %-14s %-22s %-12s %s\n",
                   $e->{numero_colegio}, $e->{nombre},
                   $e->{departamento},  $e->{especialidad});
        }
    } else {
        print "  (sin resultados)\n";
    }
    print "\n";
}


# ================================================================
# 5. DEMOSTRACION DE COLISION (tabla pequena, size=3)
# ================================================================
print "-" x 65 . "\n";
print "5. DEMOSTRACION DE COLISION (tabla con size=3)\n";
print "\n";
print "   Si reducimos la tabla a size=3, los calculos cambian:\n";
print "\n";

for my $tipo (@tipos_demo) {
    $tipo =~ /(\d+)$/;
    my $num = $1;
    my $idx = ($num - 1) % 3;
    printf("   hash(\"%-7s\") = (%d - 1) %% 3 = %d  -> bucket[%d]\n",
           $tipo, $num, $idx, $idx);
}
print "\n";
print "   TIPO-01 ((1-1)%3=0) y TIPO-04 ((4-1)%3=0) apuntan al\n";
print "   mismo bucket! El encadenamiento los une en lista.\n";
print "-" x 65 . "\n\n";

my $tabla_col = TablaHash::tabla->new(size => 3);
$tabla_col->insertar("TIPO-01", "COL-10245", "Ana Ramirez",    "DEP-MED", "Medicina General");
$tabla_col->insertar("TIPO-02", "COL-20134", "Carlos Mendoza", "DEP-CIR", "Cirugia General");
$tabla_col->insertar("TIPO-03", "COL-30101", "Lucia Flores",   "DEP-MED", "Enfermeria General");
print "\n>> Insertar TIPO-04 - debe colisionar con TIPO-01 en bucket[0]:\n";
$tabla_col->insertar("TIPO-04", "COL-40210", "Pedro Alvarado", "DEP-LAB", "Bioquimica Clinica");

print "\nEstado de la tabla con colision:\n\n";
$tabla_col->imprimir_estado();


# ================================================================
# 6. ELIMINAR UN USUARIO
# ================================================================
print "\n" . "-" x 65 . "\n";
print "6. ELIMINAR USUARIO DE LA TABLA PRINCIPAL\n";
print "-" x 65 . "\n\n";

print ">> Eliminar COL-99001 (Josesito Lopez, TIPO-01):\n";
$tabla->eliminar("TIPO-01", "COL-99001");

print "\n>> Intentar eliminar un colegio que no existe:\n";
$tabla->eliminar("TIPO-02", "COL-99999");

printf("\nTotal de profesionales tras eliminacion: %d\n", $tabla->get_total());


# ================================================================
# 7. ESTADISTICAS FINALES
# ================================================================
print "\n" . "-" x 65 . "\n";
print "7. ESTADISTICAS FINALES - Tabla principal (size=4)\n";
print "-" x 65 . "\n\n";

printf("  Tamano tabla    : %d\n",     $tabla->get_size());
printf("  Total elementos : %d\n",     $tabla->get_total());
printf("  Colisiones      : %d\n",     $tabla->get_colisiones());
printf("  Factor de carga : %.2f\n",   $tabla->get_factor_carga());
print "\n";
print "  NOTA: Factor de carga > 0.7 es senal de redimensionar.\n";
print "        Este factor indica que tan 'llena' esta la tabla.\n";


# ================================================================
# 8. REPORTE GRAPHVIZ
# ================================================================
print "\n" . "-" x 65 . "\n";
print "8. GENERANDO REPORTES CON GRAPHVIZ\n";
print "-" x 65 . "\n\n";

TablaHash::graficar->graficar_tabla_hash($tabla,     "tabla_hash_principal");
TablaHash::graficar->graficar_tabla_hash($tabla_col, "tabla_hash_colision");


print "\n" . "=" x 65 . "\n";
print "  FIN DE LA DEMOSTRACION\n";
print "=" x 65 . "\n";
