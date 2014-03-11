function [B] = borrar_errores(A)
%BORRAR_ERRORES Intenta realizar un borrado de las franjas negras que
%aparecen en las imágenes por satélite 

    % Creamos una imagen nueva, copia de la dada, a la que le aplicamos
    % un fuerte filtro mediana a fin de eliminar las franjas no deseadas.
    M=medfilt2(A,[15 15],'symmetric');

    % Recorremos la imagen dada y, para cada pixel perteneciente a las
    % franjas, se asigna por el valor correspondiente dado en la imagen del
    % filtro mediana
    for i=1:1:size(A,1)
        for j=1:1:size(A,2)
            if A(i,j)==0
                A(i,j)=M(i,j);
            end
        end
    end
   
    B=A;

end

