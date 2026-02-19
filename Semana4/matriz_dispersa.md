
# MATRIZ DISPERSA

es una matriz donde la gran mayoria de sus elementos son CERO. 
En lugar de guardar todos los ceros (que desperdiciariam memoria), 
solo almacenamos los elementos DIFERENTES DE CERO.

Por ejemplo: una matriz de 4x5 con 5 elementos diferente a 0

| Fila/clomna | **0** | **1** | **2** | **3** | **4** |
|--------------|:-----:|:-----:|:-----:|:-----:|:-----:|
|     **0**    | 0     | 1     | 0     | 0     | 0     |
|     **1**    | 0     | 2     | -1    | 0     | 0     |
|     **2**    | 0     | 0     | 0     | 0     | 0     |
|     **3**    | 6.6   | 0     | 0     | 0     | 1.4   |


Si noostos quieramos guardar toda la matriz (formato denso), ocupariamos 20 espacios, ya que es de 4x5 

a diferencia de 5 celdas diferentes a 0, o sea 5 nodos Dato.


# Formato -> listas cruzadas
La implementacion usa dos grupos de listas enlazadas que se "cruzan"


## GRUPO 1 - CABECERAS DE FILAS (lista_filas):
    Una lista enlazada de NodoCabecera, uno por cada fila que tenga
    al menos un elemento no-cero. Cada cabecera de fila apunta
    horizontalmente (right ->) a todos los NodoDato de esa fila.

## GRUPO 2 - CABECERAS DE COLUMNAS (lista_cols):
    Una lista enlazada de NodoCabecera, uno por cada columna que tenga
    al menos un elemento no-cero. Cada cabecera de columna apunta
    verticalmente (down) a todos los NodoDato de esa columna.

## NODOS DATO:
    Cada NodoDato tiene 4 punteros:
    right -> / left <- = navegar por la fila
    down   / up        = navegar por la columna

## Interfaz:
o sea, operacions principales de la matriz:
  * insertar($fila, $col, $valor)
  * obtener($fila, $col)
  * borrar($fila, $col)
  * imprimir_lista()
  * imprimir_matriz()


# Nodo Dato
Un NodoDato representa UN elemento distinto de cero de la matriz.
Cada NodoDato vive en exactamente UNA fila y UNA columna al mismo tiempo.

Por tanto tiene 4 enlaces:
![Nodo Dato](/Semana4/images/nodo_dato.png)

* right  --> siguiente NodoDato en la misma FILA (a la derecha)
* left   --> anterior  NodoDato en la misma FILA (a la izquierda)
* down   --> siguiente NodoDato en la misma COLUMNA (abajo)
* up     --> anterior  NodoDato en la misma COLUMNA (arriba)

**Ademas guarda:**
* fila   --> indice de fila donde vive 
* col    --> indice de columna donde vive
* valor  --> el dato real que almacena (numero, objeto, lo que sea)


Todos los NodoDato de una misma fila forman una lista enlazada doble horizontal.
![Nodo Dato](/Semana4/images/columna_nodoDato.png)


Todos los de una misma columna forman una lista enlazada
doble vertical. Cada nodo pertenece a ambas listas simultaneamente.
![Nodo Dato](/Semana4/images/fila_nodoDato.png)


# Nodo CABECERA
En una matriz dispersa ortogonal (o cruciforme), cada fila y cada columna 
necesita una cabecera. Piensalo como el titulo de cada
fila o columna en una tabla de Excel.


**La cabecera tiene:**
 - Un label (nombre o indice que la identifica, ej: "Fila 0", "Col 2")
 - Un puntero "down"  --> apunta al primer NodoDato de esa columna
 - Un puntero "right" --> apunta al primer NodoDato de esa fila
 - Un puntero "next"  --> para encadenar las cabeceras entre si

lista de cabeceras de filas, lista de cabeceras de cols
![nodo cabecera](/Semana4/images/nodo_cabecera.png)