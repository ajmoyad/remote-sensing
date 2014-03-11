%% Mini pr�ctica 1 Remote Sensing
%   PARTE 3: Banda pancrom�tica      
%   Procesamiento Digital de Im�genes   
%                                   
%   Antonio Jos� Moya D�az          
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

% Mostramos la imagen en RGB a baja resoluci�n
RGB=cat(3,banda3,banda2,banda1);

% Mostramos las im�genes de las que partimos
figure(1)
imshow(uint8(RGB));

figure(2)
imshow(banda8);

% Para crear la imagen a color en alta resoluci�n vamos a aprovecharnos de
% las caracter�sticas perceptuales del ojo humano que como sabemos es mucho
% m�s sensible a los cambios de intensidad que a los cambios de color. 
% Por ello, como soluci�n vamos a extraer la informaci�n de color de las
% bandas a baja resoluci�n y usaremos como banda de luminosidad la banda
% pancrom�tica de alta resoluci�n.

% En primer lugar ampliamos las im�genes de baja resoluci�n para que tengan
% la misma dimensi�n que la de alta resoluci�n.
% Si mostr�semos la imagen la ver�amos pixelada o borrosa, pero no nos 
% importa.
A=imresize(RGB,2);

figure(3)
imshow(A);

% La convertimos a HSV.
% En HSV tendremos una primera banda que ser� la del color, o tono. Y una
% segunda banda con la informaci�n de la saturaci�n. Son las que nos
% interesan.
H=rgb2hsv(A);

% Generamos una nueva imagen que tendr� formato HSV donde la primera banda
% ser� el tono de la imagen de baja resoluci�n a color, redimensionada, la
% segunda banda la saturaci�n de la misma imagen que la banda anterior, y
% finalmente como luminosidad la banda de alta resoluci�n.
Pan=cat(3,H(:,:,1),H(:,:,2),double(banda8));
Pan(:,:,3)=Pan(:,:,3)+28;

% Convertimos a RGB
HighRes=uint8(hsv2rgb(Pan));

% Finalmente contrastamos la imagen para obtener un mejor resultado
HighRes = imadjust(HighRes,stretchlim(HighRes),[],1.3);

% Muestra del resultado
figure(4),imshow(HighRes)%,title('Imagen resultado de alta resoluci�n')








    