#!/usr/bin/perl
use strict;
use warnings;

#Nota importante: Cada linea de codigo debe terminar con un punto y coma ;
#                 Los comentarios inician con el simbolo #
#                 El tabulado no es obligatorio pero ayuda a la legibilidad del codigo
#                 Para comentarios multilinea se puede usar =pod y =cut
#Insertando comentario multilinea
=pod
Este es un comentario
multilinea en Perl
=cut

#Imprimir en pantalla
print "Hola, Mundo!\n";

#Variables
my $nombre = "Sergio"; #El signo $ indica que es una variable escalar
my $edad = 25;         #Entero
my $altura = 1.75;     #Decimal (float)
my $es_estudiante = 1; #Booleano (1 para verdadero, 0 para falso), tambien para los booleanos se pueden usar cadenas "true" y "false", el false tambien puede ser 0, cadena vacía "" y undef
my $nulo = undef;      #Valor nulo

print "Nombre: $nombre\n" , "Edad: $edad\n" , "Altura: $altura\n" , "Es estudiante: $es_estudiante\n";

#Operadores
my $suma = $edad + 5;
my $resta = $edad - 3;
my $multiplicacion = $edad * 2;
my $division = $edad / 2;
my $modulo = $edad % 4;

print "Suma: $suma\n" , "Resta: $resta\n" , "Multiplicacion: $multiplicacion\n" , "Division: $division\n" , "Modulo: $modulo\n";

#Condiciones lógicas
my $es_mayor = ($edad > 18); #true

#And y Or
if ($edad >= 18 && $es_estudiante) {
    print "$nombre es mayor de edad y es estudiante.\n";
} elsif ($edad >= 18 || $es_estudiante) {
    print "$nombre es mayor de edad o es estudiante.\n";
} else {
    print "$nombre es menor de edad y no es estudiante.\n";
}

#! negación
if (!$es_estudiante) {
    print "$nombre no es estudiante.\n";
}

#Arrays / Vectores
my @frutas = ("manzana", "banana", "cereza", "mango", "pera");

#Agregar un elemento al array en la ultima posicion tipo push que se interpreta como apilar
push(@frutas, "naranja");

#Quitar un elemento del array en la ultima posicion tipo pop que se interpreta como desapilar
pop(@frutas); #al ser pop devuelve el elemento eliminado, pero si no se asigna a una variable, simplemente se elimina, si se quiere almacenear sera my $fruta_eliminada = pop(@frutas);

#Eliminar por indice 
splice(@frutas, 1,1); #Elimina el elemento en el indice 1, primer para es el indice, segundo es la cantidad de elementos a eliminar
                      # Si no se agrega el tercer parametro, elimina desde el indice hasta el final del array

#Insertar por indice
splice(@frutas, 1, 0, "kiwi"); #En el indice 1, elimina 0 elementos y agrega "kiwi", si coloco 1 en el segundo parametro, elimina el elemento en el indice 1 y agrega "kiwi" en su lugar
                               #En el segundo parametro se puede colocar la cantidad de elementos a eliminar
                               

#Otras operaciones con los arrays
my $cantidad_frutas = @frutas; #Cantidad de elementos en el array
print "Cantidad de frutas: $cantidad_frutas\n";

#Acceder a un elemento por su indice
my $primera_fruta = $frutas[0]; #Indice inicia en 0
print "Primera fruta: $primera_fruta\n";

my $segunda_fruta = $frutas[1];
print "Segunda fruta: $segunda_fruta\n";

#Ciclos
#For
for (my $i = 0; $i < @frutas; $i++) {
    print "Fruta $i: $frutas[$i]\n";
}

#While
my $contador = 0;
while ($contador < @frutas) {
    print "Fruta: $frutas[$contador]\n";
    $contador++;
}

#Foreach
foreach my $fruta (@frutas) {
    print "Fruta: $fruta\n";
}

#Funciones
sub saludar {
    my ($nombre) = @_; #Parametros de la funcion
    print "Hola, $nombre!\n";
}

saludar("Ana");
saludar("Luis");

#Retornar valores desde una funcion
sub sumar {
    my ($a, $b) = @_;
    return $a + $b;
}
my $resultado = sumar(5, 10);
print "Resultado de la suma: $resultado\n";

#hash / diccionario
my %persona = (
    "nombre" => "Carlos",
    "edad" => 30,
    "ciudad" => "Madrid"
);
#Acceder a los valores del hash
print "Nombre: $persona{nombre}\n";
print "Edad: $persona{edad}\n";
print "Ciudad: $persona{ciudad}\n";

#Agregar un nuevo par clave-valor
$persona{"profesion"} = "Ingeniero";
print "Profesion: $persona{profesion}\n";

#Eliminar un par clave-valor
delete $persona{"ciudad"};
print "Ciudad eliminada.\n";

#Recorrer un hash
while (my ($clave, $valor) = each %persona) {
    print "$clave: $valor\n";
}
#Este while dejara de funcionar cuando se hayan recorrido todos los pares clave-valor del hash
#o bien si se modifica el hash durante la iteracion el while puede comportarse de manera inesperada.

#Reemplace en el hash
$persona{"edad"} = 31; #Ahora la edad es 31
print "Edad actualizada: $persona{edad}\n";



