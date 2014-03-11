%% Mini-práctica 1 Remote Sensing   
%   PARTE 1: INDICE DE HUMEDAD      
%   Procesado Digital de Imágenes   
%                                   
%   Antonio José Moya Díaz          
%       9 de junio de 2012          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PASO 0: Preliminares
clear, clc, close all
warning off

% Cargamos las imagenes con las que vamos a trabajar
Aband4=imread('texas/agosto_banda4.tif');
Aband5=imread('texas/agosto_banda5.tif');

Sband4=imread('texas/septiembre_banda4.tif');
Sband5=imread('texas/septiembre_banda5.tif');

figure(31)
    subplot(2,3,1),imshow(Aband4);
    title('Imagen original: Banda 4')

%% PASO 1: Registrado de las imágenes
%
%   Para realizar la estimación de la zona inundada vamos a hacer uso del
%   índice normalizado de humedad NDWI. Hemos de tener en cuenta que la
%   zona contiene previamente zonas húmedas (rios, etc) por lo que para
%   realizar una buena estimación es preciso calcular el área húmeda para
%   la misma zona geográfica con y sin inundación y luego considerar la
%   diferencia. 
%   Para ello, el primer problema que se presenta es que ambas imágenes
%   deben estar registradas. Es decir, deben coincidir, idealmente, píxel a
%   píxel con la misma zona geográfica.


% Se seleccionan, a mano, los puntos para registrar las imagenes
% [inputs_points base_points]=cpselect(Sband4,Aband4,'wait',true);

%   Ya que en principio se van a calcular las áreas de las mismas imágenes,
%   se han seleccionado a mano unos puntos que, considero, son
%   significativos y se han almacenado para agilizar la reproducción de la
%   práctica.
load('puntos2.mat');

% Transformaciones necesarias para el registrado
mytform=cp2tform(inputs_points,base_points,'affine');
[registered2 xdata ydata]=imtransform(Sband4,mytform,'FillValues',255);

% Tendremos cargados en xdata e ydata el offset de la segunda imagen sobre
% la primera, necesarios para registrar ambas imágenes
xdata=fix(xdata);
ydata=fix(ydata);

%% PASO 2: Recortado
%
%   Una vez registradas ambas imágenes, habrá una zona en ambas imágenes
%   que no esté superpuesta con la otra imagen. Éstas zonas de la imagen no
%   nos sirven para hacer el cálculo diferencial anteriormente comentado,
%   por lo que resulta necesario recortar ambas imágenes quedándonos
%   únicamente con la intersección de ambas.

% Preasignamos el espacio que ocuparán las imágenes
AB4=zeros(ydata(end)-1,xdata(end));
AB5=AB4;
SB4=AB4;
SB5=AB4;

% Realizamos el recorte
for i=1:1:xdata(end)-1
    for j=1:1:ydata(end)-1
        % Los propios iteradores no iterarán más allá del límite máximo de
        % la intersección, por lo que las imágenes quedarán,
        % automáticamente, recortadas por el final.
        AB4(j,i)=Aband4(j,i);
        AB5(j,i)=Aband5(j,i);
        
        % Las imágenes de septiembre han sido desplazadas hacia la derecha,
        % por lo que hemos de desplazarlas hacia la izquierda para el
        % correcto registrado.
        SB4(j,i)=Sband4(j,-1*xdata(1)+i);
        SB5(j,i)=Sband5(j,-1*xdata(1)+i);
    end
end

% IMPORTANTE: Notar que este bucle ha sido diseñado específicamente para
% los xdata e ydata guardados. Habría que reajustar los índices si se
% seleccionan otros puntos.

% Notar que no se superponen las imágenes. Solo se recortan según el offset
% calculado.

figure(31)
    subplot(2,3,2),imshow(uint8(AB4));
    title('Imagen recotada: Banda 4');

%% PASO 3: Eliminación de las bandas negras

% Se ha diseñado una función con la única finalidad de eliminar las bandas
% negras debidas al error del satelite
AB4=borrar_errores(AB4);
AB5=borrar_errores(AB5);
SB4=borrar_errores(SB4);
SB5=borrar_errores(SB5);

figure(31)
    subplot(2,3,3),imshow(uint8(AB4))
    title('Imagen sin errores: Banda 4')

%% PASO 4: Cálculo indices de humedad

% Conversion a double para operar
AB4=double(AB4);
AB5=double(AB5);
SB4=double(SB4);
SB5=double(SB5);

% Se calculan los índices para agosto y septiembre
NDWIa=(AB4-AB5)./(AB4+AB5);
NDWIs=(SB4-SB5)./(SB4+SB5);

% El cálculo anterior genera una imagen en el rango (-1,1), así que
% umbralizamos por la mitad, 0.
NDWIamask=im2bw(NDWIa,0);
NDWIsmask=im2bw(NDWIs,0);

% Calculamos la diferencia. Esta será el área de la inundación
Dif=NDWIsmask-NDWIamask;

% Se muestran los resultados
figure(31)
    subplot(2,3,4),imshow(NDWIamask)
        title('Máscara: Agosto');
    subplot(2,3,5),imshow(NDWIsmask)
        title('Máscara: Septiembre')
    subplot(2,3,6),imshow(Dif);
        title('Máscara: Inundación');

% Se calcula el área estimada sabiendo que el pixel representa 30 metros 
% de lado        
area=sum(uint8(Dif(:)))*30^2/1000^2; 
fprintf('Area inundada: %d kilometros cuadrados\n',area)




