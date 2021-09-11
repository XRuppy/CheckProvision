
# Check Provision

# Descripción
Aplicación desarrollada para con el **SDK Flutter de Google** para obtener mayor compatibilidad con **dispositivos móviles**. Esta aplicación permite mediante un Excel previamente formateado **crear una lista con todos los productos que va a recibir el comercio para su posterior comprobación.**

# Uso de la aplicación y vista previa

## Pantalla principal

![Pantalla principal](https://github.com/XRuppy/CheckProvision/blob/5f20c845c5ec65d7a7bc4ef26f1e5a8ecc85fbf3/Images_Redme/main.jpg "Pantalla principal")

Tras la abrir la aplicación se abrirá automáticamente el explorador de archivos para la obtención del fichero Excel. Una vez cargado le saldrá una pantalla con un buscador donde podrá por código de barras o interno el producto. También le aparecerá el listado con los productos obtenidos del Excel, dando información sobre su del nombre, código y cantidad. Para finalizar la explicación de esta pantalla, cuenta con un Floating Button que guardará en un Excel las modificaciones. A parte de la búsqueda mediante el campo de texto también cuenta con detección al escanear con un escáner Bluetooth.

# Recursos y software utilizado
## Dependencias
   ```yaml
   <dependencies:
  	flutter:
    sdk: flutter
	  file_picker: ^4.0.0
	  excel: ^1.1.5
	  path_provider: ^2.0.2
	  flutter_barcode_listener: ^0.1.0
	  cupertino_icons: ^1.0.2
```
  
## Software utilizado
- Android Studio
- Android 10

## Otros recursos
### Fuentes
La fuente principal es Product Sans. Los ficheros *.ttf* esta ubicado en la **carpeta Fonts.**
```yaml
  fonts:
    - family: Product Sans
      fonts:
        - asset: assets/fonts/Product_Sans.ttf
```
### Assets
Excel con la base de datos de códigos de barras e internos. Este fichero esta ubicados en la **carpeta Assets.**

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/dbProducts.xlsx
```
