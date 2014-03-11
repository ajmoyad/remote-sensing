%% Mini pr�ctica 1 Remote Sensing
%   PARTE 2: Estimaci�n de �reas quemadas      
%   Procesamiento Digital de Im�genes   
%                                   
%   Antonio Jos� Moya D�az          
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

% Generamos las im�genes en RGB y en falso color
IRGB=cat(3,banda3,banda2,banda1);
IfalsoColor=cat(3,banda7,banda5,banda4);

figure(1)
    subplot(1,2,1),imshow(IRGB)
        title('Imagen RGB');
    subplot(1,2,2),imshow(IfalsoColor)
        title('Imagen en falso color')

        
%% Estimaciones del area quemada


%% ESTIMACION 1: FALSO COLOR
%   En una primera estimaci�n vamos a intentar calcular el �rea quemada
%   usando detecci�n por color en la imagen en falso color.

% Convertimos a HSV
IFChsv=rgb2hsv(IfalsoColor);

% Reservamos memoria para la imagen resultado
IFCmask=zeros(size(IFChsv,1),size(IFChsv,2));

for i=1:1:size(IFChsv,1)
    for j=1:1:size(IFChsv,2)
        
        % Recorremos la imagen y si supera un umbral de tono y saturaci�n
        % ponemos el pixel a 1, en su defecto se queda a 0.
        if IFChsv(i,j,1)<0.18 && IFChsv(i,j,2)>0.5
            IFCmask(i,j)=1;
        end
    end
end

% Mostramos la m�scara
figure(2)
    imshow(IFCmask),title('M�scara por falso color');

% Estimamos el area sabiendo que el pixel representa a 30 metros de lado
% Como la imagen es binaria, para conocer cu�ntos pixeles representan el
% area deseada basta con hacer una sumatoria de la imagen.
area1=sum(IFCmask(:))*30^2/1000^2;
fprintf('Estimaci�n: Falso Color.\n    Area quemada: %d km2\n \n',area1);



%% ESTIMACI�N 2: NBR (Normalized Burn Ratio)
%   Realizamos ahora usando el �ndice NBR

% Convertimos las imagenes a dobule para no perder precisi�n en la
% operaci�n
banda4=double(banda4);
banda7=double(banda7);

% Calculamos el �ndice
NBR=(banda4-banda7)./(banda4+banda7);

% La imagen resultante resulta estar en el intervalo [-1,1], sin embargo,
% si a imshow le pasamos la imagen en tipo double espera los datos entre 0
% y 1, saturando todos los mayores a 1 y eliminando todos los menores a 0.
% Es por ello que para represetar bien nos vemos en la obligaci�n de
% reescalar del intervalo original al intervalos [0,1]
NBR=(NBR+1)/2;
figure(3),
    subplot(1,2,1),imshow(NBR),title('Indice NBR');

% Umbralizamos para un resultado m�s �ptimo. Se ha escogido como l�mite de
% umbralizaci�n 1/4 del rango total
NBRmask=1-im2bw(NBR,0.25);
figure(3)
    subplot(1,2,2),imshow(NBRmask),title('mascara NBR');

% Estimamos el area sabiendo que el pixel representa a 30 metros de lado
area2=sum(NBRmask(:))*30^2/1000^2;
fprintf('Estimaci�n: Normalized Burn Ratio (NBR).\n    Area quemada: %d km2\n \n',area2);



%% ESTIMACION 3: NORMALIZED DIFFERENCE WATER INDEX

% Preparamos la banda 5 ya que la vamos a usar
banda5=double(banda5);

% Calculamos el �ndice
NDWI = (banda4-banda5) ./ (banda4+banda5);

% Resulta que la imagen, tras la operaci�n, queda en el intervalo [-1,1]
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
    title('NDWI m�scara')

% Estimamos el area sabiendo que el pixel representa a 30 metros de lado
area3=sum(NDWImask(:))*30^2/1000^2;
fprintf('Estimaci�n: Normalized Difference Water Index (NDWI).\n    Area quemada: %d km2\n \n',area3);


%% ESTIMACI�N 4: Algoritmo de Wang, Qu and Xao

% Preparamos la banda 3
banda3=double(banda3);

% Paso 1: Se calcula su NDVI
NDVI=(banda4-banda3)./(banda4+banda3);

% Nuevamente reescalamos al intervalo [0,1]
NDVI=(NDVI+1)/2;

% Umbralizamos
NDVImask=im2bw(NDVI,0.4);
% Este ser� el l�mite impuesto por el algoritmo, los valores que se hayan
% ido a 0 ser�n suelo, y los que se hayan ido a 1 ser�n vegataci�n.

% Reservamos memoria para el resultado
fuego=zeros(size(NDVI,1),size(NDVI,2));

% Recorremos la imagen haciendo el c�lculo seg�n si se trata de suelo o
% vegetaci�n.
for i=1:1:size(NDVImask,1)
    for j=1:1:size(NDVImask,2)
        if NDVImask(i,j)==1 % Es Vegetaci�n
            fuego(i,j)=(banda4(i,j)-(banda5(i,j)-banda7(i,j)))./(banda4(i,j)+(banda5(i,j)-banda7(i,j)));
        else % Es suelo
            fuego(i,j)=0.9-((banda4(i,j)-(banda5(i,j)-banda7(i,j)))./(banda4(i,j)+(banda5(i,j)-banda7(i,j))));
        end
    end
end

% Finalmente volvemos a umbralizar separando los p�xeles que representan lo
% quemado de los dem�s. Lo hacemos de tal manera que los p�xeles a 1
% (blanco) ser�n la zona quemada.
fuego2=1-im2bw(fuego,0.2);

figure(5),imshow(fuego2)

% Estimamos el area sabiendo que el pixel representa a 30 metros de lado
area4=sum(fuego2(:))*30^2/1000^2;
fprintf('Estimaci�n: Algoritmo Wang-Qu-Hao.\n    Area quemada: %d km2\n \n',area4);


%% Comparativa de Resultados

figure(6)
subplot(2,2,1),imshow(IFCmask),title('Falso color');
subplot(2,2,2),imshow(NBRmask),title('NBR');
subplot(2,2,3),imshow(NDWImask),title('NDWI');
subplot(2,2,4),imshow(fuego2),title('Alg. WangQuHao');


