%% Mini práctica 1 Remote Sensing
%   PARTE 3: Banda pancromática      
%   Procesamiento Digital de Imágenes   
%                                   
%   Antonio José Moya Díaz          
%       11 de junio de 2012          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear, clc, close all
warning off

% Cargamos las bandas que vamos a necesitar
banda1=imread('adra/banda1.tif'); %BLUE
banda2=imread('adra/banda2.tif'); %GREEN
banda3=imread('adra/banda3.tif'); %RED
%banda4=imread('adra/banda4.tif'); %NIR
%banda5=imread('adra/banda5.tif'); %MIR
%banda61=imread('adra/banda61.tif'); %THERMAL LOW
%banda62=imread('adra/banda62.tif'); %THERMAL HIGH
%banda7=imread('adra/banda7.tif'); %MIR
banda8=imread('adra/banda8.tif'); %PAN

% Mostramos la imagen en RGB a baja resolución
RGB=cat(3,banda3,banda2,banda1);

% Mostramos las imágenes de las que partimos
figure(1)
imshow(uint8(RGB));

figure(2)
imshow(banda8);

% Para crear la imagen a color en alta resolución vamos a aprovecharnos de
% las características perceptuales del ojo humano que como sabemos es mucho
% más sensible a los cambios de intensidad que a los cambios de color. 
% Por ello, como solución vamos a extraer la información de color de las
% bandas a baja resolución y usaremos como banda de luminosidad la banda
% pancromática de alta resolución.

% En primer lugar ampliamos las imágenes de baja resolución para que tengan
% la misma dimensión que la de alta resolución.
% Si mostrásemos la imagen la veríamos pixelada o borrosa, pero no nos 
% importa.
A=imresize(RGB,2);

figure(3)
imshow(A);

% La convertimos a HSV.
% En HSV tendremos una primera banda que será la del color, o tono. Y una
% segunda banda con la información de la saturación. Son las que nos
% interesan.
H=rgb2hsv(A);

% Generamos una nueva imagen que tendrá formato HSV donde la primera banda
% será el tono de la imagen de baja resolución a color, redimensionada, la
% segunda banda la saturación de la misma imagen que la banda anterior, y
% finalmente como luminosidad la banda de alta resolución.
Pan=cat(3,H(:,:,1),H(:,:,2),double(banda8));
Pan(:,:,3)=Pan(:,:,3)+28;

% Convertimos a RGB
HighRes=uint8(hsv2rgb(Pan));

% Finalmente contrastamos la imagen para obtener un mejor resultado
HighRes = imadjust(HighRes,stretchlim(HighRes),[],1.3);

% Muestra del resultado
figure(4),imshow(HighRes)%,title('Imagen resultado de alta resolución')








    