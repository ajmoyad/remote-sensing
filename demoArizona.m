%% Mini práctica 1 Remote Sensing
%   PARTE 2: Estimación de áreas quemadas      
%   Procesamiento Digital de Imágenes   
%                                   
%   Antonio José Moya Díaz          
%       10 de junio de 2012          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear, clc, close all
warning off

% Cargamos las bandas que usaremos 
banda1=imread('arizona/banda1.tif');%BLUE
banda2=imread('arizona/banda2.tif');%GREEN
banda3=imread('arizona/banda3.tif');%RED
banda4=imread('arizona/banda4.tif');%NIR (Infrarrojo cercano)
banda5=imread('arizona/banda5.tif');%MID IR
%banda6=imread('arizona/banda6.tif');%Thermal
banda7=imread('arizona/banda7.tif');%MID IR

% Generamos las imágenes en RGB y en falso color
IRGB=cat(3,banda3,banda2,banda1);
IfalsoColor=cat(3,banda7,banda5,banda4);

figure(1)
    subplot(1,2,1),imshow(IRGB)
        title('Imagen RGB');
    subplot(1,2,2),imshow(IfalsoColor)
        title('Imagen en falso color')

        
%% Estimaciones del area quemada


%% ESTIMACION 1: FALSO COLOR
%   En una primera estimación vamos a intentar calcular el área quemada
%   usando detección por color en la imagen en falso color.

% Convertimos a HSV
IFChsv=rgb2hsv(IfalsoColor);

% Reservamos memoria para la imagen resultado
IFCmask=zeros(size(IFChsv,1),size(IFChsv,2));

for i=1:1:size(IFChsv,1)
    for j=1:1:size(IFChsv,2)
        
        % Recorremos la imagen y si supera un umbral de tono y saturación
        % ponemos el pixel a 1, en su defecto se queda a 0.
        if IFChsv(i,j,1)<0.18 && IFChsv(i,j,2)>0.5
            IFCmask(i,j)=1;
        end
    end
end

% Mostramos la máscara
figure(2)
    imshow(IFCmask),title('Máscara por falso color');

% Estimamos el area sabiendo que el pixel representa a 30 metros de lado
% Como la imagen es binaria, para conocer cuántos pixeles representan el
% area deseada basta con hacer una sumatoria de la imagen.
area1=sum(IFCmask(:))*30^2/1000^2;
fprintf('Estimación: Falso Color.\n    Area quemada: %d km2\n \n',area1);



%% ESTIMACIÓN 2: NBR (Normalized Burn Ratio)
%   Realizamos ahora usando el índice NBR

% Convertimos las imagenes a dobule para no perder precisión en la
% operación
banda4=double(banda4);
banda7=double(banda7);

% Calculamos el índice
NBR=(banda4-banda7)./(banda4+banda7);

% La imagen resultante resulta estar en el intervalo [-1,1], sin embargo,
% si a imshow le pasamos la imagen en tipo double espera los datos entre 0
% y 1, saturando todos los mayores a 1 y eliminando todos los menores a 0.
% Es por ello que para represetar bien nos vemos en la obligación de
% reescalar del intervalo original al intervalos [0,1]
NBR=(NBR+1)/2;
figure(3),
    subplot(1,2,1),imshow(NBR),title('Indice NBR');

% Umbralizamos para un resultado más óptimo. Se ha escogido como límite de
% umbralización 1/4 del rango total
NBRmask=1-im2bw(NBR,0.25);
figure(3)
    subplot(1,2,2),imshow(NBRmask),title('mascara NBR');

% Estimamos el area sabiendo que el pixel representa a 30 metros de lado
area2=sum(NBRmask(:))*30^2/1000^2;
fprintf('Estimación: Normalized Burn Ratio (NBR).\n    Area quemada: %d km2\n \n',area2);



%% ESTIMACION 3: NORMALIZED DIFFERENCE WATER INDEX

% Preparamos la banda 5 ya que la vamos a usar
banda5=double(banda5);

% Calculamos el índice
NDWI = (banda4-banda5) ./ (banda4+banda5);

% Resulta que la imagen, tras la operación, queda en el intervalo [-1,1]
% por lo que hay que reescalar al intervalo [0,1] para que imshow funcione 
% bien
NDWI=(NDWI+1)/2;
figure(4)
    subplot(1,2,1),imshow(NDWI)
    title('Indice NDWI');

% Si umbralizamos...
NDWImask=1-im2bw(NDWI,0.30);
figure(4)
    subplot(1,2,2),imshow(NDWImask)
    title('NDWI máscara')

% Estimamos el area sabiendo que el pixel representa a 30 metros de lado
area3=sum(NDWImask(:))*30^2/1000^2;
fprintf('Estimación: Normalized Difference Water Index (NDWI).\n    Area quemada: %d km2\n \n',area3);


%% ESTIMACIÓN 4: Algoritmo de Wang, Qu and Xao

% Preparamos la banda 3
banda3=double(banda3);

% Paso 1: Se calcula su NDVI
NDVI=(banda4-banda3)./(banda4+banda3);

% Nuevamente reescalamos al intervalo [0,1]
NDVI=(NDVI+1)/2;

% Umbralizamos
NDVImask=im2bw(NDVI,0.4);
% Este será el límite impuesto por el algoritmo, los valores que se hayan
% ido a 0 serán suelo, y los que se hayan ido a 1 serán vegatación.

% Reservamos memoria para el resultado
fuego=zeros(size(NDVI,1),size(NDVI,2));

% Recorremos la imagen haciendo el cálculo según si se trata de suelo o
% vegetación.
for i=1:1:size(NDVImask,1)
    for j=1:1:size(NDVImask,2)
        if NDVImask(i,j)==1 % Es Vegetación
            fuego(i,j)=(banda4(i,j)-(banda5(i,j)-banda7(i,j)))./(banda4(i,j)+(banda5(i,j)-banda7(i,j)));
        else % Es suelo
            fuego(i,j)=0.9-((banda4(i,j)-(banda5(i,j)-banda7(i,j)))./(banda4(i,j)+(banda5(i,j)-banda7(i,j))));
        end
    end
end

% Finalmente volvemos a umbralizar separando los píxeles que representan lo
% quemado de los demás. Lo hacemos de tal manera que los píxeles a 1
% (blanco) serán la zona quemada.
fuego2=1-im2bw(fuego,0.2);

figure(5),imshow(fuego2)

% Estimamos el area sabiendo que el pixel representa a 30 metros de lado
area4=sum(fuego2(:))*30^2/1000^2;
fprintf('Estimación: Algoritmo Wang-Qu-Hao.\n    Area quemada: %d km2\n \n',area4);


%% Comparativa de Resultados

figure(6)
subplot(2,2,1),imshow(IFCmask),title('Falso color');
subplot(2,2,2),imshow(NBRmask),title('NBR');
subplot(2,2,3),imshow(NDWImask),title('NDWI');
subplot(2,2,4),imshow(fuego2),title('Alg. WangQuHao');


